import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/download_task.dart';
import '../services/downloader.dart';
import '../services/file_integrity.dart';
import '../services/storage_manager.dart';
import '../../storage/hive_storage.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  // Use a dedicated Dio instance without interceptors that might block large files or add token logic where unnecessary,
  // or reuse the core one if authentication is needed to download. We'll reuse the core one for MVP.
  final dio = ref.watch(apiClientProvider).dio;
  return DownloadManager(
    Downloader(dio),
    StorageManager(),
    FileIntegrity(),
  );
});

class DownloadManager {
  final Downloader _downloader;
  final StorageManager _storageManager;
  final FileIntegrity _fileIntegrity;

  bool _isProcessing = false;

  DownloadManager(this._downloader, this._storageManager, this._fileIntegrity) {
    _processQueue(); // Start on init
  }

  Future<void> enqueue(
      String id, String url, String fileName, int expectedSizeBytes,
      {String? expectedChecksum, String? version,}) async {
    final box = HiveStorage.downloadQueueBox;
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';

    final task = DownloadTask(
      id: id,
      url: url,
      savePath: savePath,
      fileName: fileName,
      state: DownloadState.queued,
      totalBytes: expectedSizeBytes,
      expectedChecksum: expectedChecksum,
      version: version,
    );

    await box.put(id, task.toJson());
    _processQueue();
  }

  Future<void> pause(String id) async {
    final box = HiveStorage.downloadQueueBox;
    final rawTask = box.get(id);
    if (rawTask != null) {
      var task = DownloadTask.fromJson(Map<String, dynamic>.from(rawTask));
      if (task.state == DownloadState.downloading ||
          task.state == DownloadState.queued) {
        _downloader.pauseDownload(task.url);
        task = task.copyWith(state: DownloadState.paused);
        await box.put(id, task.toJson());
      }
    }
  }

  Future<void> resume(String id) async {
    final box = HiveStorage.downloadQueueBox;
    final rawTask = box.get(id);
    if (rawTask != null) {
      var task = DownloadTask.fromJson(Map<String, dynamic>.from(rawTask));
      if (task.state == DownloadState.paused ||
          task.state == DownloadState.failed) {
        task = task.copyWith(state: DownloadState.queued, error: null);
        await box.put(id, task.toJson());
        _processQueue();
      }
    }
  }

  Future<void> cancel(String id) async {
    final box = HiveStorage.downloadQueueBox;
    final rawTask = box.get(id);
    if (rawTask != null) {
      var task = DownloadTask.fromJson(Map<String, dynamic>.from(rawTask));
      _downloader.cancelDownload(task.url);

      // Delete partial file
      final file = File(task.savePath);
      if (await file.exists()) {
        await file.delete();
      }

      await box.delete(id);
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final box = HiveStorage.downloadQueueBox;

      while (true) {
        final rawTasks = box.values.toList();
        final tasks = rawTasks
            .map((e) =>
                DownloadTask.fromJson(Map<String, dynamic>.from(e as Map)),)
            .toList();

        // Find next queued task
        final nextTaskIndex =
            tasks.indexWhere((t) => t.state == DownloadState.queued);
        if (nextTaskIndex == -1) {
          break; // Queue empty or everything is paused/failed/done
        }

        var task = tasks[nextTaskIndex];

        // 1. Storage Check
        final bytesLeft = task.totalBytes - task.downloadedBytes;
        if (!await _storageManager.hasEnoughSpace(bytesLeft)) {
          task = task.copyWith(
              state: DownloadState.failed, error: 'Not enough storage space',);
          await box.put(task.id, task.toJson());
          continue;
        }

        // 2. Start Downloading
        task = task.copyWith(state: DownloadState.downloading);
        await box.put(task.id, task.toJson());

        try {
          await _downloader.startDownload(
            url: task.url,
            savePath: task.savePath,
            startBytes: task.downloadedBytes,
            onProgress: (downloaded, total) {
              // Update state periodically (to avoid spamming Hive, we could debounce this,
              // but for MVP updating every time is okay for small progress jumps)
              final updatedTask = task.copyWith(
                downloadedBytes: downloaded,
                totalBytes: total > 0 ? total : task.totalBytes,
              );
              box.put(task.id, updatedTask.toJson()); // async put is fine here
            },
          );

          // 3. Verify Checksum
          if (await _fileIntegrity.verifyChecksum(
              task.savePath, task.expectedChecksum,)) {
            task = task.copyWith(
                state: DownloadState.completed,
                downloadedBytes: task.totalBytes,);
            await box.put(task.id, task.toJson());
          } else {
            task = task.copyWith(
                state: DownloadState.failed,
                error: 'Checksum verification failed',);
            await box.put(task.id, task.toJson());
          }
        } on DownloadCancelledException {
          // It was paused or cancelled by user, state is already updated in pause/cancel methods
          // or we just skip.
        } catch (e) {
          task =
              task.copyWith(state: DownloadState.failed, error: e.toString());
          await box.put(task.id, task.toJson());
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}
