// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localized_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalizedMediaSourceModel _$LocalizedMediaSourceModelFromJson(
    Map<String, dynamic> json) {
  return _LocalizedMediaSourceModel.fromJson(json);
}

/// @nodoc
mixin _$LocalizedMediaSourceModel {
  String get contentUrl => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocalizedMediaSourceModelCopyWith<LocalizedMediaSourceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizedMediaSourceModelCopyWith<$Res> {
  factory $LocalizedMediaSourceModelCopyWith(LocalizedMediaSourceModel value,
          $Res Function(LocalizedMediaSourceModel) then) =
      _$LocalizedMediaSourceModelCopyWithImpl<$Res, LocalizedMediaSourceModel>;
  @useResult
  $Res call({String contentUrl, String provider, String contentType});
}

/// @nodoc
class _$LocalizedMediaSourceModelCopyWithImpl<$Res,
        $Val extends LocalizedMediaSourceModel>
    implements $LocalizedMediaSourceModelCopyWith<$Res> {
  _$LocalizedMediaSourceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentUrl = null,
    Object? provider = null,
    Object? contentType = null,
  }) {
    return _then(_value.copyWith(
      contentUrl: null == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalizedMediaSourceModelImplCopyWith<$Res>
    implements $LocalizedMediaSourceModelCopyWith<$Res> {
  factory _$$LocalizedMediaSourceModelImplCopyWith(
          _$LocalizedMediaSourceModelImpl value,
          $Res Function(_$LocalizedMediaSourceModelImpl) then) =
      __$$LocalizedMediaSourceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String contentUrl, String provider, String contentType});
}

/// @nodoc
class __$$LocalizedMediaSourceModelImplCopyWithImpl<$Res>
    extends _$LocalizedMediaSourceModelCopyWithImpl<$Res,
        _$LocalizedMediaSourceModelImpl>
    implements _$$LocalizedMediaSourceModelImplCopyWith<$Res> {
  __$$LocalizedMediaSourceModelImplCopyWithImpl(
      _$LocalizedMediaSourceModelImpl _value,
      $Res Function(_$LocalizedMediaSourceModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contentUrl = null,
    Object? provider = null,
    Object? contentType = null,
  }) {
    return _then(_$LocalizedMediaSourceModelImpl(
      contentUrl: null == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizedMediaSourceModelImpl implements _LocalizedMediaSourceModel {
  const _$LocalizedMediaSourceModelImpl(
      {required this.contentUrl,
      required this.provider,
      required this.contentType});

  factory _$LocalizedMediaSourceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizedMediaSourceModelImplFromJson(json);

  @override
  final String contentUrl;
  @override
  final String provider;
  @override
  final String contentType;

  @override
  String toString() {
    return 'LocalizedMediaSourceModel(contentUrl: $contentUrl, provider: $provider, contentType: $contentType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizedMediaSourceModelImpl &&
            (identical(other.contentUrl, contentUrl) ||
                other.contentUrl == contentUrl) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, contentUrl, provider, contentType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizedMediaSourceModelImplCopyWith<_$LocalizedMediaSourceModelImpl>
      get copyWith => __$$LocalizedMediaSourceModelImplCopyWithImpl<
          _$LocalizedMediaSourceModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizedMediaSourceModelImplToJson(
      this,
    );
  }
}

abstract class _LocalizedMediaSourceModel implements LocalizedMediaSourceModel {
  const factory _LocalizedMediaSourceModel(
      {required final String contentUrl,
      required final String provider,
      required final String contentType}) = _$LocalizedMediaSourceModelImpl;

  factory _LocalizedMediaSourceModel.fromJson(Map<String, dynamic> json) =
      _$LocalizedMediaSourceModelImpl.fromJson;

  @override
  String get contentUrl;
  @override
  String get provider;
  @override
  String get contentType;
  @override
  @JsonKey(ignore: true)
  _$$LocalizedMediaSourceModelImplCopyWith<_$LocalizedMediaSourceModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LocalizedMediaModel _$LocalizedMediaModelFromJson(Map<String, dynamic> json) {
  return _LocalizedMediaModel.fromJson(json);
}

/// @nodoc
mixin _$LocalizedMediaModel {
  LocalizedMediaSourceModel? get en => throw _privateConstructorUsedError;
  LocalizedMediaSourceModel? get hi => throw _privateConstructorUsedError;
  LocalizedMediaSourceModel? get mr => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocalizedMediaModelCopyWith<LocalizedMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizedMediaModelCopyWith<$Res> {
  factory $LocalizedMediaModelCopyWith(
          LocalizedMediaModel value, $Res Function(LocalizedMediaModel) then) =
      _$LocalizedMediaModelCopyWithImpl<$Res, LocalizedMediaModel>;
  @useResult
  $Res call(
      {LocalizedMediaSourceModel? en,
      LocalizedMediaSourceModel? hi,
      LocalizedMediaSourceModel? mr});

  $LocalizedMediaSourceModelCopyWith<$Res>? get en;
  $LocalizedMediaSourceModelCopyWith<$Res>? get hi;
  $LocalizedMediaSourceModelCopyWith<$Res>? get mr;
}

/// @nodoc
class _$LocalizedMediaModelCopyWithImpl<$Res, $Val extends LocalizedMediaModel>
    implements $LocalizedMediaModelCopyWith<$Res> {
  _$LocalizedMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = freezed,
    Object? hi = freezed,
    Object? mr = freezed,
  }) {
    return _then(_value.copyWith(
      en: freezed == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as LocalizedMediaSourceModel?,
      hi: freezed == hi
          ? _value.hi
          : hi // ignore: cast_nullable_to_non_nullable
              as LocalizedMediaSourceModel?,
      mr: freezed == mr
          ? _value.mr
          : mr // ignore: cast_nullable_to_non_nullable
              as LocalizedMediaSourceModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedMediaSourceModelCopyWith<$Res>? get en {
    if (_value.en == null) {
      return null;
    }

    return $LocalizedMediaSourceModelCopyWith<$Res>(_value.en!, (value) {
      return _then(_value.copyWith(en: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedMediaSourceModelCopyWith<$Res>? get hi {
    if (_value.hi == null) {
      return null;
    }

    return $LocalizedMediaSourceModelCopyWith<$Res>(_value.hi!, (value) {
      return _then(_value.copyWith(hi: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocalizedMediaSourceModelCopyWith<$Res>? get mr {
    if (_value.mr == null) {
      return null;
    }

    return $LocalizedMediaSourceModelCopyWith<$Res>(_value.mr!, (value) {
      return _then(_value.copyWith(mr: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LocalizedMediaModelImplCopyWith<$Res>
    implements $LocalizedMediaModelCopyWith<$Res> {
  factory _$$LocalizedMediaModelImplCopyWith(_$LocalizedMediaModelImpl value,
          $Res Function(_$LocalizedMediaModelImpl) then) =
      __$$LocalizedMediaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LocalizedMediaSourceModel? en,
      LocalizedMediaSourceModel? hi,
      LocalizedMediaSourceModel? mr});

  @override
  $LocalizedMediaSourceModelCopyWith<$Res>? get en;
  @override
  $LocalizedMediaSourceModelCopyWith<$Res>? get hi;
  @override
  $LocalizedMediaSourceModelCopyWith<$Res>? get mr;
}

/// @nodoc
class __$$LocalizedMediaModelImplCopyWithImpl<$Res>
    extends _$LocalizedMediaModelCopyWithImpl<$Res, _$LocalizedMediaModelImpl>
    implements _$$LocalizedMediaModelImplCopyWith<$Res> {
  __$$LocalizedMediaModelImplCopyWithImpl(_$LocalizedMediaModelImpl _value,
      $Res Function(_$LocalizedMediaModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = freezed,
    Object? hi = freezed,
    Object? mr = freezed,
  }) {
    return _then(_$LocalizedMediaModelImpl(
      en: freezed == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as LocalizedMediaSourceModel?,
      hi: freezed == hi
          ? _value.hi
          : hi // ignore: cast_nullable_to_non_nullable
              as LocalizedMediaSourceModel?,
      mr: freezed == mr
          ? _value.mr
          : mr // ignore: cast_nullable_to_non_nullable
              as LocalizedMediaSourceModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizedMediaModelImpl implements _LocalizedMediaModel {
  const _$LocalizedMediaModelImpl({this.en, this.hi, this.mr});

  factory _$LocalizedMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizedMediaModelImplFromJson(json);

  @override
  final LocalizedMediaSourceModel? en;
  @override
  final LocalizedMediaSourceModel? hi;
  @override
  final LocalizedMediaSourceModel? mr;

  @override
  String toString() {
    return 'LocalizedMediaModel(en: $en, hi: $hi, mr: $mr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizedMediaModelImpl &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.hi, hi) || other.hi == hi) &&
            (identical(other.mr, mr) || other.mr == mr));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, en, hi, mr);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizedMediaModelImplCopyWith<_$LocalizedMediaModelImpl> get copyWith =>
      __$$LocalizedMediaModelImplCopyWithImpl<_$LocalizedMediaModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizedMediaModelImplToJson(
      this,
    );
  }
}

abstract class _LocalizedMediaModel implements LocalizedMediaModel {
  const factory _LocalizedMediaModel(
      {final LocalizedMediaSourceModel? en,
      final LocalizedMediaSourceModel? hi,
      final LocalizedMediaSourceModel? mr}) = _$LocalizedMediaModelImpl;

  factory _LocalizedMediaModel.fromJson(Map<String, dynamic> json) =
      _$LocalizedMediaModelImpl.fromJson;

  @override
  LocalizedMediaSourceModel? get en;
  @override
  LocalizedMediaSourceModel? get hi;
  @override
  LocalizedMediaSourceModel? get mr;
  @override
  @JsonKey(ignore: true)
  _$$LocalizedMediaModelImplCopyWith<_$LocalizedMediaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
