// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mentor_availability_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MentorAvailabilitySlotModel _$MentorAvailabilitySlotModelFromJson(
    Map<String, dynamic> json) {
  return _MentorAvailabilitySlotModel.fromJson(json);
}

/// @nodoc
mixin _$MentorAvailabilitySlotModel {
  String get start =>
      throw _privateConstructorUsedError; // Serialized ISO UTC timestamp
  String get end => throw _privateConstructorUsedError;
  bool get available => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MentorAvailabilitySlotModelCopyWith<MentorAvailabilitySlotModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorAvailabilitySlotModelCopyWith<$Res> {
  factory $MentorAvailabilitySlotModelCopyWith(
          MentorAvailabilitySlotModel value,
          $Res Function(MentorAvailabilitySlotModel) then) =
      _$MentorAvailabilitySlotModelCopyWithImpl<$Res,
          MentorAvailabilitySlotModel>;
  @useResult
  $Res call({String start, String end, bool available});
}

/// @nodoc
class _$MentorAvailabilitySlotModelCopyWithImpl<$Res,
        $Val extends MentorAvailabilitySlotModel>
    implements $MentorAvailabilitySlotModelCopyWith<$Res> {
  _$MentorAvailabilitySlotModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? available = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MentorAvailabilitySlotModelImplCopyWith<$Res>
    implements $MentorAvailabilitySlotModelCopyWith<$Res> {
  factory _$$MentorAvailabilitySlotModelImplCopyWith(
          _$MentorAvailabilitySlotModelImpl value,
          $Res Function(_$MentorAvailabilitySlotModelImpl) then) =
      __$$MentorAvailabilitySlotModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String start, String end, bool available});
}

/// @nodoc
class __$$MentorAvailabilitySlotModelImplCopyWithImpl<$Res>
    extends _$MentorAvailabilitySlotModelCopyWithImpl<$Res,
        _$MentorAvailabilitySlotModelImpl>
    implements _$$MentorAvailabilitySlotModelImplCopyWith<$Res> {
  __$$MentorAvailabilitySlotModelImplCopyWithImpl(
      _$MentorAvailabilitySlotModelImpl _value,
      $Res Function(_$MentorAvailabilitySlotModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? available = null,
  }) {
    return _then(_$MentorAvailabilitySlotModelImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorAvailabilitySlotModelImpl extends _MentorAvailabilitySlotModel {
  const _$MentorAvailabilitySlotModelImpl(
      {required this.start, required this.end, required this.available})
      : super._();

  factory _$MentorAvailabilitySlotModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$MentorAvailabilitySlotModelImplFromJson(json);

  @override
  final String start;
// Serialized ISO UTC timestamp
  @override
  final String end;
  @override
  final bool available;

  @override
  String toString() {
    return 'MentorAvailabilitySlotModel(start: $start, end: $end, available: $available)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorAvailabilitySlotModelImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.available, available) ||
                other.available == available));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, start, end, available);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorAvailabilitySlotModelImplCopyWith<_$MentorAvailabilitySlotModelImpl>
      get copyWith => __$$MentorAvailabilitySlotModelImplCopyWithImpl<
          _$MentorAvailabilitySlotModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorAvailabilitySlotModelImplToJson(
      this,
    );
  }
}

abstract class _MentorAvailabilitySlotModel
    extends MentorAvailabilitySlotModel {
  const factory _MentorAvailabilitySlotModel(
      {required final String start,
      required final String end,
      required final bool available}) = _$MentorAvailabilitySlotModelImpl;
  const _MentorAvailabilitySlotModel._() : super._();

  factory _MentorAvailabilitySlotModel.fromJson(Map<String, dynamic> json) =
      _$MentorAvailabilitySlotModelImpl.fromJson;

  @override
  String get start;
  @override // Serialized ISO UTC timestamp
  String get end;
  @override
  bool get available;
  @override
  @JsonKey(ignore: true)
  _$$MentorAvailabilitySlotModelImplCopyWith<_$MentorAvailabilitySlotModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MentorAvailabilityModel _$MentorAvailabilityModelFromJson(
    Map<String, dynamic> json) {
  return _MentorAvailabilityModel.fromJson(json);
}

/// @nodoc
mixin _$MentorAvailabilityModel {
  String get timezone => throw _privateConstructorUsedError;
  List<MentorAvailabilitySlotModel> get slots =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MentorAvailabilityModelCopyWith<MentorAvailabilityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorAvailabilityModelCopyWith<$Res> {
  factory $MentorAvailabilityModelCopyWith(MentorAvailabilityModel value,
          $Res Function(MentorAvailabilityModel) then) =
      _$MentorAvailabilityModelCopyWithImpl<$Res, MentorAvailabilityModel>;
  @useResult
  $Res call({String timezone, List<MentorAvailabilitySlotModel> slots});
}

/// @nodoc
class _$MentorAvailabilityModelCopyWithImpl<$Res,
        $Val extends MentorAvailabilityModel>
    implements $MentorAvailabilityModelCopyWith<$Res> {
  _$MentorAvailabilityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timezone = null,
    Object? slots = null,
  }) {
    return _then(_value.copyWith(
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<MentorAvailabilitySlotModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MentorAvailabilityModelImplCopyWith<$Res>
    implements $MentorAvailabilityModelCopyWith<$Res> {
  factory _$$MentorAvailabilityModelImplCopyWith(
          _$MentorAvailabilityModelImpl value,
          $Res Function(_$MentorAvailabilityModelImpl) then) =
      __$$MentorAvailabilityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String timezone, List<MentorAvailabilitySlotModel> slots});
}

/// @nodoc
class __$$MentorAvailabilityModelImplCopyWithImpl<$Res>
    extends _$MentorAvailabilityModelCopyWithImpl<$Res,
        _$MentorAvailabilityModelImpl>
    implements _$$MentorAvailabilityModelImplCopyWith<$Res> {
  __$$MentorAvailabilityModelImplCopyWithImpl(
      _$MentorAvailabilityModelImpl _value,
      $Res Function(_$MentorAvailabilityModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timezone = null,
    Object? slots = null,
  }) {
    return _then(_$MentorAvailabilityModelImpl(
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<MentorAvailabilitySlotModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorAvailabilityModelImpl extends _MentorAvailabilityModel {
  const _$MentorAvailabilityModelImpl(
      {required this.timezone,
      required final List<MentorAvailabilitySlotModel> slots})
      : _slots = slots,
        super._();

  factory _$MentorAvailabilityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentorAvailabilityModelImplFromJson(json);

  @override
  final String timezone;
  final List<MentorAvailabilitySlotModel> _slots;
  @override
  List<MentorAvailabilitySlotModel> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  String toString() {
    return 'MentorAvailabilityModel(timezone: $timezone, slots: $slots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorAvailabilityModelImpl &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            const DeepCollectionEquality().equals(other._slots, _slots));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, timezone, const DeepCollectionEquality().hash(_slots));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorAvailabilityModelImplCopyWith<_$MentorAvailabilityModelImpl>
      get copyWith => __$$MentorAvailabilityModelImplCopyWithImpl<
          _$MentorAvailabilityModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorAvailabilityModelImplToJson(
      this,
    );
  }
}

abstract class _MentorAvailabilityModel extends MentorAvailabilityModel {
  const factory _MentorAvailabilityModel(
          {required final String timezone,
          required final List<MentorAvailabilitySlotModel> slots}) =
      _$MentorAvailabilityModelImpl;
  const _MentorAvailabilityModel._() : super._();

  factory _MentorAvailabilityModel.fromJson(Map<String, dynamic> json) =
      _$MentorAvailabilityModelImpl.fromJson;

  @override
  String get timezone;
  @override
  List<MentorAvailabilitySlotModel> get slots;
  @override
  @JsonKey(ignore: true)
  _$$MentorAvailabilityModelImplCopyWith<_$MentorAvailabilityModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
