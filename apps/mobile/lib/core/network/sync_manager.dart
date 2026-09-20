import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/sync_task.dart';
import '../storage/hive_storage.dart';
import '../storage/secure_storage.dart';
import '../notifications/services/notification_service.dart';
import '../notifications/models/app_notification.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(ref);
});

class SyncManager {
  final Connectivity _connectivity = Connectivity();
  final Ref ref;
  StreamSubscription? _subscription;
  bool _isSyncing = false;
  late final Dio _dio;

  SyncManager(this.ref) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:4000/api', // Android Emulator localhost
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    _initInterceptor();
    _startListening();
  }

  void _initInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage().getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        _checkBackendAndSync();
      }
    });
  }

  Future<void> _checkBackendAndSync() async {
    if (_isSyncing) return;
    try {
      // 1. Health Ping
      final response = await _dio.get('/health');
      if (response.statusCode == 200) {
        // 2. Start Sync
        await _processQueue();
      }
    } catch (e) {
      // Backend not reachable, do nothing
    }
  }

  Future<void> _processQueue() async {
    _isSyncing = true;
    try {
      final box = HiveStorage.syncQueueBox;
      final conflictBox = HiveStorage.conflictQueueBox;
      final historyBox = HiveStorage.historyQueueBox;
      final settingsBox = HiveStorage.syncSettingsBox;

      final bool wifiOnly = settingsBox.get('wifiOnly') ?? false;
      if (wifiOnly) {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (!connectivityResult.contains(ConnectivityResult.wifi)) {
          _isSyncing = false;
          return;
        }
      }

      // Convert raw Map to SyncTask objects
      final rawTasks = box.values.toList();
      List<SyncTask> tasks = rawTasks.map((e) {
        // Hive sometimes returns linked maps, cast properly
        final map = Map<String, dynamic>.from(e as Map);
        return SyncTask.fromJson(map);
      }).toList();

      if (tasks.isEmpty) {
        _isSyncing = false;
        return;
      }

      // Sort by Priority (critical first) then chronological
      tasks.sort((a, b) {
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        return a.createdAt.compareTo(b.createdAt);
      });

      // Filter tasks waiting for dependencies
      final completedTaskIds = <String>{};

      for (var task in tasks) {
        if (task.dependsOn != null &&
            !completedTaskIds.contains(task.dependsOn)) {
          // Skip for now, dependency hasn't been met yet
          continue;
        }

        // Exponential backoff check
        if (task.lastAttempt != null && task.retryCount > 0) {
          final waitSeconds = _calculateBackoff(task.retryCount);
          final nextAllowedTime =
              task.lastAttempt!.add(Duration(seconds: waitSeconds));
          if (DateTime.now().isBefore(nextAllowedTime)) {
            continue; // Skip, too early to retry
          }
        }

        // Try to execute
        task = task.copyWith(status: SyncStatus.syncing);
        await box.put(
            task.id, task.toJson(),); // Update state for UI to see it's syncing

        try {
          await _dio.request(
            task.path,
            data: task.data,
            options: Options(
              method: task.method,
              headers: {
                ...task.headers,
                'X-Idempotency-Key': task.idempotencyKey,
              },
            ),
          );

          task = task.copyWith(
              status: SyncStatus.success, updatedAt: DateTime.now(),);
          await historyBox.put(task.id, task.toJson());
          await box.delete(task.id);
          completedTaskIds.add(task.id);
          settingsBox.put(
              'lastSuccessfulSync', DateTime.now().toIso8601String(),);

          // Notify the user that their offline action has been successfully synced
          ref.read(notificationServiceProvider).push(
                'Sync Complete',
                'Your offline changes have been saved to the cloud.',
                NotificationType.sync,
              );
        } on DioException catch (e) {
          final statusCode = e.response?.statusCode;

          if (statusCode == 409 || statusCode == 400 || statusCode == 403) {
            task = task.copyWith(
                status: SyncStatus.conflict, updatedAt: DateTime.now(),);
            await conflictBox.put(task.id, task.toJson());
            await box.delete(task.id);

            // Notify the user about the conflict
            ref.read(notificationServiceProvider).push(
                  'Sync Conflict',
                  'An issue occurred while syncing your changes. Please review.',
                  NotificationType.system,
                );
          } else if (statusCode == 401) {
            // Need token refresh - Handled by standard interceptor in full app.
            // For now, abort sync to let normal API layer refresh.
            break;
          } else {
            // 5xx or Network Error -> Retry
            final newCount = task.retryCount + 1;
            if (newCount >= task.maxRetries) {
              task = task.copyWith(
                  status: SyncStatus.failed, updatedAt: DateTime.now(),);
              await conflictBox.put(task.id, task.toJson());
              await box.delete(task.id);
            } else {
              task = task.copyWith(
                status: SyncStatus.waiting,
                retryCount: newCount,
                lastAttempt: DateTime.now(),
              );
              await box.put(task.id, task.toJson());
            }
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  int _calculateBackoff(int retryCount) {
    // Attempt 1: 5s, Attempt 2: 15s, Attempt 3: 45s, Attempt 4: 120s...
    switch (retryCount) {
      case 1:
        return 5;
      case 2:
        return 15;
      case 3:
        return 45;
      case 4:
        return 120;
      default:
        return 300; // 5 min max
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
