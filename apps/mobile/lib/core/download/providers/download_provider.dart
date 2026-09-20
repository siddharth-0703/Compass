import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/download_task.dart';
import '../manager/download_manager.dart';
import '../../storage/hive_storage.dart';

final downloadTasksProvider =
    StateNotifierProvider<DownloadTasksNotifier, Map<String, DownloadTask>>(
        (ref) {
  final manager = ref.watch(downloadManagerProvider);
  return DownloadTasksNotifier(manager);
});

class DownloadTasksNotifier extends StateNotifier<Map<String, DownloadTask>> {
  final DownloadManager _manager;

  DownloadTasksNotifier(this._manager) : super({}) {
    _loadTasks();
    HiveStorage.downloadQueueBox.listenable().addListener(_loadTasks);
  }

  void _loadTasks() {
    final box = HiveStorage.downloadQueueBox;
    final Map<String, DownloadTask> tasks = {};
    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        tasks[key.toString()] =
            DownloadTask.fromJson(Map<String, dynamic>.from(raw as Map));
      }
    }
    state = tasks;
  }

  Future<void> enqueue(
      String id, String url, String fileName, int expectedSize,) async {
    await _manager.enqueue(id, url, fileName, expectedSize);
  }

  Future<void> pause(String id) async {
    await _manager.pause(id);
  }

  Future<void> resume(String id) async {
    await _manager.resume(id);
  }

  Future<void> cancel(String id) async {
    await _manager.cancel(id);
  }
}
