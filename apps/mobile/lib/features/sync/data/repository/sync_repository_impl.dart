import '../../domain/repository/sync_repository.dart';
import '../../../../core/network/models/sync_task.dart';
import '../../../../core/storage/hive_storage.dart';

class SyncRepositoryImpl implements SyncRepository {
  @override
  Future<List<SyncTask>> getPendingTasks() async {
    final box = HiveStorage.syncQueueBox;
    final rawTasks = box.values.toList();
    return rawTasks
        .map((e) => SyncTask.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<SyncTask>> getConflictTasks() async {
    final box = HiveStorage.conflictQueueBox;
    final rawTasks = box.values.toList();
    return rawTasks
        .map((e) => SyncTask.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<SyncTask>> getHistoryTasks() async {
    final box = HiveStorage.historyQueueBox;
    final rawTasks = box.values.toList();
    return rawTasks
        .map((e) => SyncTask.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> retryTask(String taskId) async {
    final conflictBox = HiveStorage.conflictQueueBox;
    final queueBox = HiveStorage.syncQueueBox;

    final rawData = conflictBox.get(taskId);
    if (rawData != null) {
      final task = SyncTask.fromJson(Map<String, dynamic>.from(rawData as Map));
      // Reset retry count and move back to queue
      final retriedTask = task.copyWith(
        status: SyncStatus.queued,
        retryCount: 0,
        lastAttempt: null,
      );

      await queueBox.put(taskId, retriedTask.toJson());
      await conflictBox.delete(taskId);
    }
  }

  @override
  Future<void> discardTask(String taskId) async {
    final conflictBox = HiveStorage.conflictQueueBox;
    final historyBox = HiveStorage.historyQueueBox;

    final rawData = conflictBox.get(taskId);
    if (rawData != null) {
      final task = SyncTask.fromJson(Map<String, dynamic>.from(rawData as Map));
      final cancelledTask = task.copyWith(
          status: SyncStatus.cancelled, updatedAt: DateTime.now(),);

      await historyBox.put(taskId, cancelledTask.toJson());
      await conflictBox.delete(taskId);
    }
  }

  @override
  Future<bool> getWifiOnlySetting() async {
    final box = HiveStorage.syncSettingsBox;
    return box.get('wifiOnly', defaultValue: false);
  }

  @override
  Future<void> setWifiOnlySetting(bool value) async {
    final box = HiveStorage.syncSettingsBox;
    await box.put('wifiOnly', value);
  }

  @override
  Future<DateTime?> getLastSuccessfulSync() async {
    final box = HiveStorage.syncSettingsBox;
    final raw = box.get('lastSuccessfulSync');
    if (raw != null) {
      return DateTime.parse(raw);
    }
    return null;
  }
}
