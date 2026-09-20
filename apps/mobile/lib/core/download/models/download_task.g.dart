// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DownloadTaskImpl _$$DownloadTaskImplFromJson(Map<String, dynamic> json) =>
    _$DownloadTaskImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      savePath: json['savePath'] as String,
      fileName: json['fileName'] as String,
      state: $enumDecodeNullable(_$DownloadStateEnumMap, json['state']) ??
          DownloadState.queued,
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt() ?? 0,
      expectedChecksum: json['expectedChecksum'] as String?,
      version: json['version'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$DownloadTaskImplToJson(_$DownloadTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'savePath': instance.savePath,
      'fileName': instance.fileName,
      'state': _$DownloadStateEnumMap[instance.state]!,
      'downloadedBytes': instance.downloadedBytes,
      'totalBytes': instance.totalBytes,
      'expectedChecksum': instance.expectedChecksum,
      'version': instance.version,
      'error': instance.error,
    };

const _$DownloadStateEnumMap = {
  DownloadState.queued: 'queued',
  DownloadState.preparing: 'preparing',
  DownloadState.downloading: 'downloading',
  DownloadState.paused: 'paused',
  DownloadState.completed: 'completed',
  DownloadState.failed: 'failed',
  DownloadState.cancelled: 'cancelled',
};
