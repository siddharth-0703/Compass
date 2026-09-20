// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SyncTask _$SyncTaskFromJson(Map<String, dynamic> json) {
  return _SyncTask.fromJson(json);
}

/// @nodoc
mixin _$SyncTask {
  String get id => throw _privateConstructorUsedError;
  String get idempotencyKey => throw _privateConstructorUsedError;
  SyncPriority get priority => throw _privateConstructorUsedError;
  SyncStatus get status => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  Map<String, dynamic> get headers => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastAttempt => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  String? get dependsOn => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SyncTaskCopyWith<SyncTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncTaskCopyWith<$Res> {
  factory $SyncTaskCopyWith(SyncTask value, $Res Function(SyncTask) then) =
      _$SyncTaskCopyWithImpl<$Res, SyncTask>;
  @useResult
  $Res call(
      {String id,
      String idempotencyKey,
      SyncPriority priority,
      SyncStatus status,
      String method,
      String path,
      Map<String, dynamic> headers,
      Map<String, dynamic> data,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? lastAttempt,
      int retryCount,
      int maxRetries,
      String? dependsOn,
      String? userId});
}

/// @nodoc
class _$SyncTaskCopyWithImpl<$Res, $Val extends SyncTask>
    implements $SyncTaskCopyWith<$Res> {
  _$SyncTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? idempotencyKey = null,
    Object? priority = null,
    Object? status = null,
    Object? method = null,
    Object? path = null,
    Object? headers = null,
    Object? data = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? lastAttempt = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? dependsOn = freezed,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as SyncPriority,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      headers: null == headers
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _value.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      dependsOn: freezed == dependsOn
          ? _value.dependsOn
          : dependsOn // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncTaskImplCopyWith<$Res>
    implements $SyncTaskCopyWith<$Res> {
  factory _$$SyncTaskImplCopyWith(
          _$SyncTaskImpl value, $Res Function(_$SyncTaskImpl) then) =
      __$$SyncTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String idempotencyKey,
      SyncPriority priority,
      SyncStatus status,
      String method,
      String path,
      Map<String, dynamic> headers,
      Map<String, dynamic> data,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? lastAttempt,
      int retryCount,
      int maxRetries,
      String? dependsOn,
      String? userId});
}

/// @nodoc
class __$$SyncTaskImplCopyWithImpl<$Res>
    extends _$SyncTaskCopyWithImpl<$Res, _$SyncTaskImpl>
    implements _$$SyncTaskImplCopyWith<$Res> {
  __$$SyncTaskImplCopyWithImpl(
      _$SyncTaskImpl _value, $Res Function(_$SyncTaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? idempotencyKey = null,
    Object? priority = null,
    Object? status = null,
    Object? method = null,
    Object? path = null,
    Object? headers = null,
    Object? data = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? lastAttempt = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? dependsOn = freezed,
    Object? userId = freezed,
  }) {
    return _then(_$SyncTaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as SyncPriority,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      headers: null == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastAttempt: freezed == lastAttempt
          ? _value.lastAttempt
          : lastAttempt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      dependsOn: freezed == dependsOn
          ? _value.dependsOn
          : dependsOn // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncTaskImpl implements _SyncTask {
  const _$SyncTaskImpl(
      {required this.id,
      required this.idempotencyKey,
      this.priority = SyncPriority.normal,
      this.status = SyncStatus.queued,
      required this.method,
      required this.path,
      final Map<String, dynamic> headers = const {},
      final Map<String, dynamic> data = const {},
      required this.createdAt,
      this.updatedAt,
      this.lastAttempt,
      this.retryCount = 0,
      this.maxRetries = 3,
      this.dependsOn,
      this.userId})
      : _headers = headers,
        _data = data;

  factory _$SyncTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncTaskImplFromJson(json);

  @override
  final String id;
  @override
  final String idempotencyKey;
  @override
  @JsonKey()
  final SyncPriority priority;
  @override
  @JsonKey()
  final SyncStatus status;
  @override
  final String method;
  @override
  final String path;
  final Map<String, dynamic> _headers;
  @override
  @JsonKey()
  Map<String, dynamic> get headers {
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_headers);
  }

  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastAttempt;
  @override
  @JsonKey()
  final int retryCount;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  final String? dependsOn;
  @override
  final String? userId;

  @override
  String toString() {
    return 'SyncTask(id: $id, idempotencyKey: $idempotencyKey, priority: $priority, status: $status, method: $method, path: $path, headers: $headers, data: $data, createdAt: $createdAt, updatedAt: $updatedAt, lastAttempt: $lastAttempt, retryCount: $retryCount, maxRetries: $maxRetries, dependsOn: $dependsOn, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.idempotencyKey, idempotencyKey) ||
                other.idempotencyKey == idempotencyKey) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastAttempt, lastAttempt) ||
                other.lastAttempt == lastAttempt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.dependsOn, dependsOn) ||
                other.dependsOn == dependsOn) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      idempotencyKey,
      priority,
      status,
      method,
      path,
      const DeepCollectionEquality().hash(_headers),
      const DeepCollectionEquality().hash(_data),
      createdAt,
      updatedAt,
      lastAttempt,
      retryCount,
      maxRetries,
      dependsOn,
      userId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncTaskImplCopyWith<_$SyncTaskImpl> get copyWith =>
      __$$SyncTaskImplCopyWithImpl<_$SyncTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncTaskImplToJson(
      this,
    );
  }
}

abstract class _SyncTask implements SyncTask {
  const factory _SyncTask(
      {required final String id,
      required final String idempotencyKey,
      final SyncPriority priority,
      final SyncStatus status,
      required final String method,
      required final String path,
      final Map<String, dynamic> headers,
      final Map<String, dynamic> data,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final DateTime? lastAttempt,
      final int retryCount,
      final int maxRetries,
      final String? dependsOn,
      final String? userId}) = _$SyncTaskImpl;

  factory _SyncTask.fromJson(Map<String, dynamic> json) =
      _$SyncTaskImpl.fromJson;

  @override
  String get id;
  @override
  String get idempotencyKey;
  @override
  SyncPriority get priority;
  @override
  SyncStatus get status;
  @override
  String get method;
  @override
  String get path;
  @override
  Map<String, dynamic> get headers;
  @override
  Map<String, dynamic> get data;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastAttempt;
  @override
  int get retryCount;
  @override
  int get maxRetries;
  @override
  String? get dependsOn;
  @override
  String? get userId;
  @override
  @JsonKey(ignore: true)
  _$$SyncTaskImplCopyWith<_$SyncTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
