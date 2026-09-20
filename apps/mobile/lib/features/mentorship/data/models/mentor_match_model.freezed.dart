// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mentor_match_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MentorMatchModel _$MentorMatchModelFromJson(Map<String, dynamic> json) {
  return _MentorMatchModel.fromJson(json);
}

/// @nodoc
mixin _$MentorMatchModel {
  MentorProfileModel get mentor => throw _privateConstructorUsedError;
  double get relevanceScore => throw _privateConstructorUsedError;
  List<String> get matchedRules => throw _privateConstructorUsedError;
  List<String> get unmatchedRules => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MentorMatchModelCopyWith<MentorMatchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorMatchModelCopyWith<$Res> {
  factory $MentorMatchModelCopyWith(
          MentorMatchModel value, $Res Function(MentorMatchModel) then) =
      _$MentorMatchModelCopyWithImpl<$Res, MentorMatchModel>;
  @useResult
  $Res call(
      {MentorProfileModel mentor,
      double relevanceScore,
      List<String> matchedRules,
      List<String> unmatchedRules});

  $MentorProfileModelCopyWith<$Res> get mentor;
}

/// @nodoc
class _$MentorMatchModelCopyWithImpl<$Res, $Val extends MentorMatchModel>
    implements $MentorMatchModelCopyWith<$Res> {
  _$MentorMatchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mentor = null,
    Object? relevanceScore = null,
    Object? matchedRules = null,
    Object? unmatchedRules = null,
  }) {
    return _then(_value.copyWith(
      mentor: null == mentor
          ? _value.mentor
          : mentor // ignore: cast_nullable_to_non_nullable
              as MentorProfileModel,
      relevanceScore: null == relevanceScore
          ? _value.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      matchedRules: null == matchedRules
          ? _value.matchedRules
          : matchedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unmatchedRules: null == unmatchedRules
          ? _value.unmatchedRules
          : unmatchedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MentorProfileModelCopyWith<$Res> get mentor {
    return $MentorProfileModelCopyWith<$Res>(_value.mentor, (value) {
      return _then(_value.copyWith(mentor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MentorMatchModelImplCopyWith<$Res>
    implements $MentorMatchModelCopyWith<$Res> {
  factory _$$MentorMatchModelImplCopyWith(_$MentorMatchModelImpl value,
          $Res Function(_$MentorMatchModelImpl) then) =
      __$$MentorMatchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MentorProfileModel mentor,
      double relevanceScore,
      List<String> matchedRules,
      List<String> unmatchedRules});

  @override
  $MentorProfileModelCopyWith<$Res> get mentor;
}

/// @nodoc
class __$$MentorMatchModelImplCopyWithImpl<$Res>
    extends _$MentorMatchModelCopyWithImpl<$Res, _$MentorMatchModelImpl>
    implements _$$MentorMatchModelImplCopyWith<$Res> {
  __$$MentorMatchModelImplCopyWithImpl(_$MentorMatchModelImpl _value,
      $Res Function(_$MentorMatchModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mentor = null,
    Object? relevanceScore = null,
    Object? matchedRules = null,
    Object? unmatchedRules = null,
  }) {
    return _then(_$MentorMatchModelImpl(
      mentor: null == mentor
          ? _value.mentor
          : mentor // ignore: cast_nullable_to_non_nullable
              as MentorProfileModel,
      relevanceScore: null == relevanceScore
          ? _value.relevanceScore
          : relevanceScore // ignore: cast_nullable_to_non_nullable
              as double,
      matchedRules: null == matchedRules
          ? _value._matchedRules
          : matchedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unmatchedRules: null == unmatchedRules
          ? _value._unmatchedRules
          : unmatchedRules // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorMatchModelImpl extends _MentorMatchModel {
  const _$MentorMatchModelImpl(
      {required this.mentor,
      required this.relevanceScore,
      required final List<String> matchedRules,
      required final List<String> unmatchedRules})
      : _matchedRules = matchedRules,
        _unmatchedRules = unmatchedRules,
        super._();

  factory _$MentorMatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentorMatchModelImplFromJson(json);

  @override
  final MentorProfileModel mentor;
  @override
  final double relevanceScore;
  final List<String> _matchedRules;
  @override
  List<String> get matchedRules {
    if (_matchedRules is EqualUnmodifiableListView) return _matchedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchedRules);
  }

  final List<String> _unmatchedRules;
  @override
  List<String> get unmatchedRules {
    if (_unmatchedRules is EqualUnmodifiableListView) return _unmatchedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unmatchedRules);
  }

  @override
  String toString() {
    return 'MentorMatchModel(mentor: $mentor, relevanceScore: $relevanceScore, matchedRules: $matchedRules, unmatchedRules: $unmatchedRules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorMatchModelImpl &&
            (identical(other.mentor, mentor) || other.mentor == mentor) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore) &&
            const DeepCollectionEquality()
                .equals(other._matchedRules, _matchedRules) &&
            const DeepCollectionEquality()
                .equals(other._unmatchedRules, _unmatchedRules));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mentor,
      relevanceScore,
      const DeepCollectionEquality().hash(_matchedRules),
      const DeepCollectionEquality().hash(_unmatchedRules));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorMatchModelImplCopyWith<_$MentorMatchModelImpl> get copyWith =>
      __$$MentorMatchModelImplCopyWithImpl<_$MentorMatchModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorMatchModelImplToJson(
      this,
    );
  }
}

abstract class _MentorMatchModel extends MentorMatchModel {
  const factory _MentorMatchModel(
      {required final MentorProfileModel mentor,
      required final double relevanceScore,
      required final List<String> matchedRules,
      required final List<String> unmatchedRules}) = _$MentorMatchModelImpl;
  const _MentorMatchModel._() : super._();

  factory _MentorMatchModel.fromJson(Map<String, dynamic> json) =
      _$MentorMatchModelImpl.fromJson;

  @override
  MentorProfileModel get mentor;
  @override
  double get relevanceScore;
  @override
  List<String> get matchedRules;
  @override
  List<String> get unmatchedRules;
  @override
  @JsonKey(ignore: true)
  _$$MentorMatchModelImplCopyWith<_$MentorMatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
