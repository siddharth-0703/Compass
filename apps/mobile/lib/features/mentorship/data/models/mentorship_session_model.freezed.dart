// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mentorship_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MentorshipSessionModel _$MentorshipSessionModelFromJson(
    Map<String, dynamic> json) {
  return _MentorshipSessionModel.fromJson(json);
}

/// @nodoc
mixin _$MentorshipSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get mentorId => throw _privateConstructorUsedError;
  String get mentorName => throw _privateConstructorUsedError;
  String get businessId => throw _privateConstructorUsedError;
  String get entrepreneurId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get scheduledAt =>
      throw _privateConstructorUsedError; // Serialized ISO UTC timestamp
  int get durationMinutes => throw _privateConstructorUsedError;
  String get meetingPlatform => throw _privateConstructorUsedError;
  String? get meetingLink => throw _privateConstructorUsedError;
  List<String> get goals => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;
  bool get canJoin => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MentorshipSessionModelCopyWith<MentorshipSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorshipSessionModelCopyWith<$Res> {
  factory $MentorshipSessionModelCopyWith(MentorshipSessionModel value,
          $Res Function(MentorshipSessionModel) then) =
      _$MentorshipSessionModelCopyWithImpl<$Res, MentorshipSessionModel>;
  @useResult
  $Res call(
      {String id,
      String mentorId,
      String mentorName,
      String businessId,
      String entrepreneurId,
      String status,
      String scheduledAt,
      int durationMinutes,
      String meetingPlatform,
      String? meetingLink,
      List<String> goals,
      double? rating,
      String? feedback,
      bool canJoin});
}

/// @nodoc
class _$MentorshipSessionModelCopyWithImpl<$Res,
        $Val extends MentorshipSessionModel>
    implements $MentorshipSessionModelCopyWith<$Res> {
  _$MentorshipSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mentorId = null,
    Object? mentorName = null,
    Object? businessId = null,
    Object? entrepreneurId = null,
    Object? status = null,
    Object? scheduledAt = null,
    Object? durationMinutes = null,
    Object? meetingPlatform = null,
    Object? meetingLink = freezed,
    Object? goals = null,
    Object? rating = freezed,
    Object? feedback = freezed,
    Object? canJoin = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mentorId: null == mentorId
          ? _value.mentorId
          : mentorId // ignore: cast_nullable_to_non_nullable
              as String,
      mentorName: null == mentorName
          ? _value.mentorName
          : mentorName // ignore: cast_nullable_to_non_nullable
              as String,
      businessId: null == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String,
      entrepreneurId: null == entrepreneurId
          ? _value.entrepreneurId
          : entrepreneurId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      meetingPlatform: null == meetingPlatform
          ? _value.meetingPlatform
          : meetingPlatform // ignore: cast_nullable_to_non_nullable
              as String,
      meetingLink: freezed == meetingLink
          ? _value.meetingLink
          : meetingLink // ignore: cast_nullable_to_non_nullable
              as String?,
      goals: null == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      canJoin: null == canJoin
          ? _value.canJoin
          : canJoin // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MentorshipSessionModelImplCopyWith<$Res>
    implements $MentorshipSessionModelCopyWith<$Res> {
  factory _$$MentorshipSessionModelImplCopyWith(
          _$MentorshipSessionModelImpl value,
          $Res Function(_$MentorshipSessionModelImpl) then) =
      __$$MentorshipSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String mentorId,
      String mentorName,
      String businessId,
      String entrepreneurId,
      String status,
      String scheduledAt,
      int durationMinutes,
      String meetingPlatform,
      String? meetingLink,
      List<String> goals,
      double? rating,
      String? feedback,
      bool canJoin});
}

/// @nodoc
class __$$MentorshipSessionModelImplCopyWithImpl<$Res>
    extends _$MentorshipSessionModelCopyWithImpl<$Res,
        _$MentorshipSessionModelImpl>
    implements _$$MentorshipSessionModelImplCopyWith<$Res> {
  __$$MentorshipSessionModelImplCopyWithImpl(
      _$MentorshipSessionModelImpl _value,
      $Res Function(_$MentorshipSessionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mentorId = null,
    Object? mentorName = null,
    Object? businessId = null,
    Object? entrepreneurId = null,
    Object? status = null,
    Object? scheduledAt = null,
    Object? durationMinutes = null,
    Object? meetingPlatform = null,
    Object? meetingLink = freezed,
    Object? goals = null,
    Object? rating = freezed,
    Object? feedback = freezed,
    Object? canJoin = null,
  }) {
    return _then(_$MentorshipSessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mentorId: null == mentorId
          ? _value.mentorId
          : mentorId // ignore: cast_nullable_to_non_nullable
              as String,
      mentorName: null == mentorName
          ? _value.mentorName
          : mentorName // ignore: cast_nullable_to_non_nullable
              as String,
      businessId: null == businessId
          ? _value.businessId
          : businessId // ignore: cast_nullable_to_non_nullable
              as String,
      entrepreneurId: null == entrepreneurId
          ? _value.entrepreneurId
          : entrepreneurId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: null == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      meetingPlatform: null == meetingPlatform
          ? _value.meetingPlatform
          : meetingPlatform // ignore: cast_nullable_to_non_nullable
              as String,
      meetingLink: freezed == meetingLink
          ? _value.meetingLink
          : meetingLink // ignore: cast_nullable_to_non_nullable
              as String?,
      goals: null == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      feedback: freezed == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as String?,
      canJoin: null == canJoin
          ? _value.canJoin
          : canJoin // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorshipSessionModelImpl extends _MentorshipSessionModel {
  const _$MentorshipSessionModelImpl(
      {required this.id,
      required this.mentorId,
      required this.mentorName,
      required this.businessId,
      required this.entrepreneurId,
      required this.status,
      required this.scheduledAt,
      required this.durationMinutes,
      required this.meetingPlatform,
      this.meetingLink,
      required final List<String> goals,
      this.rating,
      this.feedback,
      required this.canJoin})
      : _goals = goals,
        super._();

  factory _$MentorshipSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentorshipSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String mentorId;
  @override
  final String mentorName;
  @override
  final String businessId;
  @override
  final String entrepreneurId;
  @override
  final String status;
  @override
  final String scheduledAt;
// Serialized ISO UTC timestamp
  @override
  final int durationMinutes;
  @override
  final String meetingPlatform;
  @override
  final String? meetingLink;
  final List<String> _goals;
  @override
  List<String> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  @override
  final double? rating;
  @override
  final String? feedback;
  @override
  final bool canJoin;

  @override
  String toString() {
    return 'MentorshipSessionModel(id: $id, mentorId: $mentorId, mentorName: $mentorName, businessId: $businessId, entrepreneurId: $entrepreneurId, status: $status, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, meetingPlatform: $meetingPlatform, meetingLink: $meetingLink, goals: $goals, rating: $rating, feedback: $feedback, canJoin: $canJoin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorshipSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mentorId, mentorId) ||
                other.mentorId == mentorId) &&
            (identical(other.mentorName, mentorName) ||
                other.mentorName == mentorName) &&
            (identical(other.businessId, businessId) ||
                other.businessId == businessId) &&
            (identical(other.entrepreneurId, entrepreneurId) ||
                other.entrepreneurId == entrepreneurId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.meetingPlatform, meetingPlatform) ||
                other.meetingPlatform == meetingPlatform) &&
            (identical(other.meetingLink, meetingLink) ||
                other.meetingLink == meetingLink) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.canJoin, canJoin) || other.canJoin == canJoin));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mentorId,
      mentorName,
      businessId,
      entrepreneurId,
      status,
      scheduledAt,
      durationMinutes,
      meetingPlatform,
      meetingLink,
      const DeepCollectionEquality().hash(_goals),
      rating,
      feedback,
      canJoin);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorshipSessionModelImplCopyWith<_$MentorshipSessionModelImpl>
      get copyWith => __$$MentorshipSessionModelImplCopyWithImpl<
          _$MentorshipSessionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorshipSessionModelImplToJson(
      this,
    );
  }
}

abstract class _MentorshipSessionModel extends MentorshipSessionModel {
  const factory _MentorshipSessionModel(
      {required final String id,
      required final String mentorId,
      required final String mentorName,
      required final String businessId,
      required final String entrepreneurId,
      required final String status,
      required final String scheduledAt,
      required final int durationMinutes,
      required final String meetingPlatform,
      final String? meetingLink,
      required final List<String> goals,
      final double? rating,
      final String? feedback,
      required final bool canJoin}) = _$MentorshipSessionModelImpl;
  const _MentorshipSessionModel._() : super._();

  factory _MentorshipSessionModel.fromJson(Map<String, dynamic> json) =
      _$MentorshipSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get mentorId;
  @override
  String get mentorName;
  @override
  String get businessId;
  @override
  String get entrepreneurId;
  @override
  String get status;
  @override
  String get scheduledAt;
  @override // Serialized ISO UTC timestamp
  int get durationMinutes;
  @override
  String get meetingPlatform;
  @override
  String? get meetingLink;
  @override
  List<String> get goals;
  @override
  double? get rating;
  @override
  String? get feedback;
  @override
  bool get canJoin;
  @override
  @JsonKey(ignore: true)
  _$$MentorshipSessionModelImplCopyWith<_$MentorshipSessionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
