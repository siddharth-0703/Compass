import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_task.freezed.dart';
part 'download_task.g.dart';

enum DownloadState {
  queued,
  preparing,
  downloading,
  paused,
  completed,
  failed,
  cancelled
}

@freezed
class DownloadTask with _$DownloadTask {
  const factory DownloadTask({
    required String id,
    required String url,
    required String savePath,
    required String fileName,
    @Default(DownloadState.queued) DownloadState state,
    @Default(0) int downloadedBytes,
    @Default(0) int totalBytes,
    String? expectedChecksum,
    String? version,
    String? error,
  }) = _DownloadTask;

  const DownloadTask._();

  factory DownloadTask.fromJson(Map<String, dynamic> json) =>
      _$DownloadTaskFromJson(json);

  double get progress => totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
}
