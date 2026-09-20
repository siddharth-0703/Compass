import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_task.freezed.dart';
part 'sync_task.g.dart';

enum SyncStatus {
  queued,
  waiting,
  syncing,
  success,
  failed,
  conflict,
  cancelled
}

enum SyncPriority { low, normal, high, critical }

@freezed
class SyncTask with _$SyncTask {
  const factory SyncTask({
    required String id,
    required String idempotencyKey,
    @Default(SyncPriority.normal) SyncPriority priority,
    @Default(SyncStatus.queued) SyncStatus status,
    required String method,
    required String path,
    @Default({}) Map<String, dynamic> headers,
    @Default({}) Map<String, dynamic> data,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? lastAttempt,
    @Default(0) int retryCount,
    @Default(3) int maxRetries,
    String? dependsOn,
    String? userId,
  }) = _SyncTask;

  factory SyncTask.fromJson(Map<String, dynamic> json) =>
      _$SyncTaskFromJson(json);
}
