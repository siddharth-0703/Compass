// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DownloadTask _$DownloadTaskFromJson(Map<String, dynamic> json) {
  return _DownloadTask.fromJson(json);
}

/// @nodoc
mixin _$DownloadTask {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get savePath => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  DownloadState get state => throw _privateConstructorUsedError;
  int get downloadedBytes => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;
  String? get expectedChecksum => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DownloadTaskCopyWith<DownloadTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadTaskCopyWith<$Res> {
  factory $DownloadTaskCopyWith(
          DownloadTask value, $Res Function(DownloadTask) then) =
      _$DownloadTaskCopyWithImpl<$Res, DownloadTask>;
  @useResult
  $Res call(
      {String id,
      String url,
      String savePath,
      String fileName,
      DownloadState state,
      int downloadedBytes,
      int totalBytes,
      String? expectedChecksum,
      String? version,
      String? error});
}

/// @nodoc
class _$DownloadTaskCopyWithImpl<$Res, $Val extends DownloadTask>
    implements $DownloadTaskCopyWith<$Res> {
  _$DownloadTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? savePath = null,
    Object? fileName = null,
    Object? state = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? expectedChecksum = freezed,
    Object? version = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      savePath: null == savePath
          ? _value.savePath
          : savePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as DownloadState,
      downloadedBytes: null == downloadedBytes
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
      expectedChecksum: freezed == expectedChecksum
          ? _value.expectedChecksum
          : expectedChecksum // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadTaskImplCopyWith<$Res>
    implements $DownloadTaskCopyWith<$Res> {
  factory _$$DownloadTaskImplCopyWith(
          _$DownloadTaskImpl value, $Res Function(_$DownloadTaskImpl) then) =
      __$$DownloadTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String savePath,
      String fileName,
      DownloadState state,
      int downloadedBytes,
      int totalBytes,
      String? expectedChecksum,
      String? version,
      String? error});
}

/// @nodoc
class __$$DownloadTaskImplCopyWithImpl<$Res>
    extends _$DownloadTaskCopyWithImpl<$Res, _$DownloadTaskImpl>
    implements _$$DownloadTaskImplCopyWith<$Res> {
  __$$DownloadTaskImplCopyWithImpl(
      _$DownloadTaskImpl _value, $Res Function(_$DownloadTaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? savePath = null,
    Object? fileName = null,
    Object? state = null,
    Object? downloadedBytes = null,
    Object? totalBytes = null,
    Object? expectedChecksum = freezed,
    Object? version = freezed,
    Object? error = freezed,
  }) {
    return _then(_$DownloadTaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      savePath: null == savePath
          ? _value.savePath
          : savePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as DownloadState,
      downloadedBytes: null == downloadedBytes
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
      expectedChecksum: freezed == expectedChecksum
          ? _value.expectedChecksum
          : expectedChecksum // ignore: cast_nullable_to_non_nullable
              as String?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadTaskImpl extends _DownloadTask {
  const _$DownloadTaskImpl(
      {required this.id,
      required this.url,
      required this.savePath,
      required this.fileName,
      this.state = DownloadState.queued,
      this.downloadedBytes = 0,
      this.totalBytes = 0,
      this.expectedChecksum,
      this.version,
      this.error})
      : super._();

  factory _$DownloadTaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadTaskImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String savePath;
  @override
  final String fileName;
  @override
  @JsonKey()
  final DownloadState state;
  @override
  @JsonKey()
  final int downloadedBytes;
  @override
  @JsonKey()
  final int totalBytes;
  @override
  final String? expectedChecksum;
  @override
  final String? version;
  @override
  final String? error;

  @override
  String toString() {
    return 'DownloadTask(id: $id, url: $url, savePath: $savePath, fileName: $fileName, state: $state, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, expectedChecksum: $expectedChecksum, version: $version, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.savePath, savePath) ||
                other.savePath == savePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.downloadedBytes, downloadedBytes) ||
                other.downloadedBytes == downloadedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.expectedChecksum, expectedChecksum) ||
                other.expectedChecksum == expectedChecksum) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, savePath, fileName,
      state, downloadedBytes, totalBytes, expectedChecksum, version, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadTaskImplCopyWith<_$DownloadTaskImpl> get copyWith =>
      __$$DownloadTaskImplCopyWithImpl<_$DownloadTaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadTaskImplToJson(
      this,
    );
  }
}

abstract class _DownloadTask extends DownloadTask {
  const factory _DownloadTask(
      {required final String id,
      required final String url,
      required final String savePath,
      required final String fileName,
      final DownloadState state,
      final int downloadedBytes,
      final int totalBytes,
      final String? expectedChecksum,
      final String? version,
      final String? error}) = _$DownloadTaskImpl;
  const _DownloadTask._() : super._();

  factory _DownloadTask.fromJson(Map<String, dynamic> json) =
      _$DownloadTaskImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String get savePath;
  @override
  String get fileName;
  @override
  DownloadState get state;
  @override
  int get downloadedBytes;
  @override
  int get totalBytes;
  @override
  String? get expectedChecksum;
  @override
  String? get version;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$DownloadTaskImplCopyWith<_$DownloadTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
