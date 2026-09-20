class StorageManager {
  static const int _reservedSpaceBytes = 300 * 1024 * 1024; // 300 MB

  /// Checks if there is enough space to download a file of [requiredBytes] size.
  /// Returns true if available space > required + reserved.
  Future<bool> hasEnoughSpace(int requiredBytes) async {
    final availableBytes = await _getAvailableDiskSpace();
    return availableBytes > (requiredBytes + _reservedSpaceBytes);
  }

  Future<int> _getAvailableDiskSpace() async {
    // In a real app, use a package like `disk_space_plus` or `storage_info`
    // For MVP, assume we have 5GB free.
    return 5 * 1024 * 1024 * 1024;
  }
}
