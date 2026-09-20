import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';

class Downloader {
  final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};

  Downloader(this._dio);

  Future<void> startDownload({
    required String url,
    required String savePath,
    required Function(int downloaded, int total) onProgress,
    int startBytes = 0,
  }) async {
    final cancelToken = CancelToken();
    _cancelTokens[url] = cancelToken;

    final file = File(savePath);
    if (startBytes > 0 && !await file.exists()) {
      startBytes = 0; // File was deleted, start from scratch
    }

    try {
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        options: Options(
          headers: startBytes > 0 ? {'Range': 'bytes=$startBytes-'} : null,
        ),
        onReceiveProgress: (received, total) {
          int realTotal = total != -1 ? total + startBytes : -1;
          onProgress(received + startBytes, realTotal);
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw DownloadCancelledException();
      }
      rethrow;
    } finally {
      _cancelTokens.remove(url);
    }
  }

  void pauseDownload(String url) {
    if (_cancelTokens.containsKey(url)) {
      _cancelTokens[url]?.cancel('Paused by user');
      _cancelTokens.remove(url);
    }
  }

  void cancelDownload(String url) {
    if (_cancelTokens.containsKey(url)) {
      _cancelTokens[url]?.cancel('Cancelled by user');
      _cancelTokens.remove(url);
    }
  }
}

class DownloadCancelledException implements Exception {}
