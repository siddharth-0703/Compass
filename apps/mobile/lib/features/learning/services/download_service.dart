enum DownloadStatus {
  notDownloaded,
  queued,
  downloading,
  paused,
  downloaded,
  failed,
  updating
}

class DownloadService {
  // Stub for future physical media downloader.
  // In Phase 7, we mock the status transitions to allow the UI to handle it.

  Future<DownloadStatus> checkStatus(String resourceId) async {
    // For MVP, always return notDownloaded.
    return DownloadStatus.notDownloaded;
  }

  Future<void> queueDownload(String resourceId, String url) async {
    // Future integration with flutter_downloader
    // Will handle tracking progress, chunking, storage cleanup.
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> deleteDownload(String resourceId) async {
    // Future cleanup logic
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
