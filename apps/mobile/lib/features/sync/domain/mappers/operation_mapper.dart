import '../../../../core/network/models/sync_task.dart';

class OperationMapper {
  static String getHumanReadableTitle(SyncTask task) {
    if (task.path.contains('/users/profile')) {
      return 'Update Profile';
    }

    if (task.path.contains('/learning/progress')) {
      return 'Save Course Progress';
    }

    // Fallback
    return 'Sync Data (${task.method} ${task.path})';
  }
}
