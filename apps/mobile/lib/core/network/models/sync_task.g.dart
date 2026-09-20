// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncTaskImpl _$$SyncTaskImplFromJson(Map<String, dynamic> json) =>
    _$SyncTaskImpl(
      id: json['id'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      priority: $enumDecodeNullable(_$SyncPriorityEnumMap, json['priority']) ??
          SyncPriority.normal,
      status: $enumDecodeNullable(_$SyncStatusEnumMap, json['status']) ??
          SyncStatus.queued,
      method: json['method'] as String,
      path: json['path'] as String,
      headers: json['headers'] as Map<String, dynamic>? ?? const {},
      data: json['data'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastAttempt: json['lastAttempt'] == null
          ? null
          : DateTime.parse(json['lastAttempt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      dependsOn: json['dependsOn'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$SyncTaskImplToJson(_$SyncTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'idempotencyKey': instance.idempotencyKey,
      'priority': _$SyncPriorityEnumMap[instance.priority]!,
      'status': _$SyncStatusEnumMap[instance.status]!,
      'method': instance.method,
      'path': instance.path,
      'headers': instance.headers,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastAttempt': instance.lastAttempt?.toIso8601String(),
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'dependsOn': instance.dependsOn,
      'userId': instance.userId,
    };

const _$SyncPriorityEnumMap = {
  SyncPriority.low: 'low',
  SyncPriority.normal: 'normal',
  SyncPriority.high: 'high',
  SyncPriority.critical: 'critical',
};

const _$SyncStatusEnumMap = {
  SyncStatus.queued: 'queued',
  SyncStatus.waiting: 'waiting',
  SyncStatus.syncing: 'syncing',
  SyncStatus.success: 'success',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
  SyncStatus.cancelled: 'cancelled',
};
