import '../../../../core/network/models/sync_task.dart';

abstract class SyncRepository {
  Future<List<SyncTask>> getPendingTasks();
  Future<List<SyncTask>> getConflictTasks();
  Future<List<SyncTask>> getHistoryTasks();

  Future<void> retryTask(String taskId);
  Future<void> discardTask(String taskId);

  Future<bool> getWifiOnlySetting();
  Future<void> setWifiOnlySetting(bool value);

  Future<DateTime?> getLastSuccessfulSync();
}
