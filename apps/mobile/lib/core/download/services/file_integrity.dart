import 'dart:io';
import 'package:crypto/crypto.dart';

class FileIntegrity {
  /// Verifies a file's MD5 checksum against an [expectedChecksum].
  /// Returns true if they match or if [expectedChecksum] is null.
  Future<bool> verifyChecksum(String filePath, String? expectedChecksum) async {
    if (expectedChecksum == null) return true;

    final file = File(filePath);
    if (!await file.exists()) return false;

    // Stream the file instead of reading all into memory
    final stream = file.openRead();
    final hash = await md5.bind(stream).first;

    return hash.toString() == expectedChecksum;
  }
}
