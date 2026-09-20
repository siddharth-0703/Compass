import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/sync_repository.dart';
import '../../data/repository/sync_repository_impl.dart';
import '../../../../core/network/models/sync_task.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/storage/hive_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl();
});

class SyncState {
  final bool isLoading;
  final List<SyncTask> pendingTasks;
  final List<SyncTask> conflictTasks;
  final List<SyncTask> historyTasks;
  final bool isWifiOnly;
  final DateTime? lastSuccessfulSync;
  final bool isConnected;
  final String? connectionType;

  SyncState({
    this.isLoading = false,
    this.pendingTasks = const [],
    this.conflictTasks = const [],
    this.historyTasks = const [],
    this.isWifiOnly = false,
    this.lastSuccessfulSync,
    this.isConnected = true,
    this.connectionType,
  });

  SyncState copyWith({
    bool? isLoading,
    List<SyncTask>? pendingTasks,
    List<SyncTask>? conflictTasks,
    List<SyncTask>? historyTasks,
    bool? isWifiOnly,
    DateTime? lastSuccessfulSync,
    bool? isConnected,
    String? connectionType,
  }) {
    return SyncState(
      isLoading: isLoading ?? this.isLoading,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      conflictTasks: conflictTasks ?? this.conflictTasks,
      historyTasks: historyTasks ?? this.historyTasks,
      isWifiOnly: isWifiOnly ?? this.isWifiOnly,
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final SyncRepository _repository;
  StreamSubscription? _connectivitySub;
  final Connectivity _connectivity = Connectivity();

  SyncNotifier(this._repository) : super(SyncState()) {
    _init();
  }

  void _init() async {
    state = state.copyWith(isLoading: true);

    // Load initial settings and tasks
    final wifiOnly = await _repository.getWifiOnlySetting();
    final lastSync = await _repository.getLastSuccessfulSync();

    await _loadTasks();

    // Check initial connectivity
    final connResult = await _connectivity.checkConnectivity();
    _updateConnectivityState(connResult);

    state = state.copyWith(
      isLoading: false,
      isWifiOnly: wifiOnly,
      lastSuccessfulSync: lastSync,
    );

    // Listen to network changes
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_updateConnectivityState);

    // Listen to Hive box changes to reactively update the UI!
    HiveStorage.syncQueueBox.listenable().addListener(_loadTasks);
    HiveStorage.conflictQueueBox.listenable().addListener(_loadTasks);
    HiveStorage.historyQueueBox.listenable().addListener(_loadTasks);
    HiveStorage.syncSettingsBox.listenable().addListener(_loadSettings);
  }

  void _updateConnectivityState(List<ConnectivityResult> results) {
    bool isConn = false;
    String? type;

    if (results.contains(ConnectivityResult.mobile)) {
      isConn = true;
      type = 'Mobile Data';
    } else if (results.contains(ConnectivityResult.wifi)) {
      isConn = true;
      type = 'WiFi';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      isConn = true;
      type = 'Ethernet';
    }

    state = state.copyWith(isConnected: isConn, connectionType: type);
  }

  Future<void> _loadTasks() async {
    final pending = await _repository.getPendingTasks();
    final conflicts = await _repository.getConflictTasks();
    final history = await _repository.getHistoryTasks();

    state = state.copyWith(
      pendingTasks: pending,
      conflictTasks: conflicts,
      historyTasks: history,
    );
  }

  Future<void> _loadSettings() async {
    final wifiOnly = await _repository.getWifiOnlySetting();
    final lastSync = await _repository.getLastSuccessfulSync();
    state = state.copyWith(isWifiOnly: wifiOnly, lastSuccessfulSync: lastSync);
  }

  Future<void> setWifiOnly(bool value) async {
    await _repository.setWifiOnlySetting(value);
    state = state.copyWith(isWifiOnly: value);
  }

  Future<void> retryTask(String taskId) async {
    await _repository.retryTask(taskId);
    await _loadTasks();
  }

  Future<void> discardTask(String taskId) async {
    await _repository.discardTask(taskId);
    await _loadTasks();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    // In a real app we'd remove Hive listeners here, but it's okay for app lifecycle
    super.dispose();
  }
}

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final repo = ref.watch(syncRepositoryProvider);
  return SyncNotifier(repo);
});
