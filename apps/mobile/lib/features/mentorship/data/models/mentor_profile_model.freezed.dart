// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mentor_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MentorProfileModel _$MentorProfileModelFromJson(Map<String, dynamic> json) {
  return _MentorProfileModel.fromJson(json);
}

/// @nodoc
mixin _$MentorProfileModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get profileImage => throw _privateConstructorUsedError;
  String get headline => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  String get verificationStatus => throw _privateConstructorUsedError;
  String get accountStatus => throw _privateConstructorUsedError;
  List<String> get industries => throw _privateConstructorUsedError;
  List<String> get expertise => throw _privateConstructorUsedError;
  int get experienceYears => throw _privateConstructorUsedError;
  List<String> get languages => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get completedSessions => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MentorProfileModelCopyWith<MentorProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentorProfileModelCopyWith<$Res> {
  factory $MentorProfileModelCopyWith(
          MentorProfileModel value, $Res Function(MentorProfileModel) then) =
      _$MentorProfileModelCopyWithImpl<$Res, MentorProfileModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? profileImage,
      String headline,
      String bio,
      String verificationStatus,
      String accountStatus,
      List<String> industries,
      List<String> expertise,
      int experienceYears,
      List<String> languages,
      double rating,
      int completedSessions,
      String location,
      String timezone});
}

/// @nodoc
class _$MentorProfileModelCopyWithImpl<$Res, $Val extends MentorProfileModel>
    implements $MentorProfileModelCopyWith<$Res> {
  _$MentorProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? profileImage = freezed,
    Object? headline = null,
    Object? bio = null,
    Object? verificationStatus = null,
    Object? accountStatus = null,
    Object? industries = null,
    Object? expertise = null,
    Object? experienceYears = null,
    Object? languages = null,
    Object? rating = null,
    Object? completedSessions = null,
    Object? location = null,
    Object? timezone = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileImage: freezed == profileImage
          ? _value.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String,
      accountStatus: null == accountStatus
          ? _value.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      industries: null == industries
          ? _value.industries
          : industries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expertise: null == expertise
          ? _value.expertise
          : expertise // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experienceYears: null == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int,
      languages: null == languages
          ? _value.languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MentorProfileModelImplCopyWith<$Res>
    implements $MentorProfileModelCopyWith<$Res> {
  factory _$$MentorProfileModelImplCopyWith(_$MentorProfileModelImpl value,
          $Res Function(_$MentorProfileModelImpl) then) =
      __$$MentorProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? profileImage,
      String headline,
      String bio,
      String verificationStatus,
      String accountStatus,
      List<String> industries,
      List<String> expertise,
      int experienceYears,
      List<String> languages,
      double rating,
      int completedSessions,
      String location,
      String timezone});
}

/// @nodoc
class __$$MentorProfileModelImplCopyWithImpl<$Res>
    extends _$MentorProfileModelCopyWithImpl<$Res, _$MentorProfileModelImpl>
    implements _$$MentorProfileModelImplCopyWith<$Res> {
  __$$MentorProfileModelImplCopyWithImpl(_$MentorProfileModelImpl _value,
      $Res Function(_$MentorProfileModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? profileImage = freezed,
    Object? headline = null,
    Object? bio = null,
    Object? verificationStatus = null,
    Object? accountStatus = null,
    Object? industries = null,
    Object? expertise = null,
    Object? experienceYears = null,
    Object? languages = null,
    Object? rating = null,
    Object? completedSessions = null,
    Object? location = null,
    Object? timezone = null,
  }) {
    return _then(_$MentorProfileModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileImage: freezed == profileImage
          ? _value.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String,
      accountStatus: null == accountStatus
          ? _value.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      industries: null == industries
          ? _value._industries
          : industries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expertise: null == expertise
          ? _value._expertise
          : expertise // ignore: cast_nullable_to_non_nullable
              as List<String>,
      experienceYears: null == experienceYears
          ? _value.experienceYears
          : experienceYears // ignore: cast_nullable_to_non_nullable
              as int,
      languages: null == languages
          ? _value._languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      completedSessions: null == completedSessions
          ? _value.completedSessions
          : completedSessions // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MentorProfileModelImpl extends _MentorProfileModel {
  const _$MentorProfileModelImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.profileImage,
      required this.headline,
      required this.bio,
      required this.verificationStatus,
      required this.accountStatus,
      required final List<String> industries,
      required final List<String> expertise,
      required this.experienceYears,
      required final List<String> languages,
      required this.rating,
      required this.completedSessions,
      required this.location,
      required this.timezone})
      : _industries = industries,
        _expertise = expertise,
        _languages = languages,
        super._();

  factory _$MentorProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MentorProfileModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? profileImage;
  @override
  final String headline;
  @override
  final String bio;
  @override
  final String verificationStatus;
  @override
  final String accountStatus;
  final List<String> _industries;
  @override
  List<String> get industries {
    if (_industries is EqualUnmodifiableListView) return _industries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_industries);
  }

  final List<String> _expertise;
  @override
  List<String> get expertise {
    if (_expertise is EqualUnmodifiableListView) return _expertise;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expertise);
  }

  @override
  final int experienceYears;
  final List<String> _languages;
  @override
  List<String> get languages {
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_languages);
  }

  @override
  final double rating;
  @override
  final int completedSessions;
  @override
  final String location;
  @override
  final String timezone;

  @override
  String toString() {
    return 'MentorProfileModel(id: $id, userId: $userId, name: $name, profileImage: $profileImage, headline: $headline, bio: $bio, verificationStatus: $verificationStatus, accountStatus: $accountStatus, industries: $industries, expertise: $expertise, experienceYears: $experienceYears, languages: $languages, rating: $rating, completedSessions: $completedSessions, location: $location, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentorProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.verificationStatus, verificationStatus) ||
                other.verificationStatus == verificationStatus) &&
            (identical(other.accountStatus, accountStatus) ||
                other.accountStatus == accountStatus) &&
            const DeepCollectionEquality()
                .equals(other._industries, _industries) &&
            const DeepCollectionEquality()
                .equals(other._expertise, _expertise) &&
            (identical(other.experienceYears, experienceYears) ||
                other.experienceYears == experienceYears) &&
            const DeepCollectionEquality()
                .equals(other._languages, _languages) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.completedSessions, completedSessions) ||
                other.completedSessions == completedSessions) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      profileImage,
      headline,
      bio,
      verificationStatus,
      accountStatus,
      const DeepCollectionEquality().hash(_industries),
      const DeepCollectionEquality().hash(_expertise),
      experienceYears,
      const DeepCollectionEquality().hash(_languages),
      rating,
      completedSessions,
      location,
      timezone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MentorProfileModelImplCopyWith<_$MentorProfileModelImpl> get copyWith =>
      __$$MentorProfileModelImplCopyWithImpl<_$MentorProfileModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MentorProfileModelImplToJson(
      this,
    );
  }
}

abstract class _MentorProfileModel extends MentorProfileModel {
  const factory _MentorProfileModel(
      {required final String id,
      required final String userId,
      required final String name,
      final String? profileImage,
      required final String headline,
      required final String bio,
      required final String verificationStatus,
      required final String accountStatus,
      required final List<String> industries,
      required final List<String> expertise,
      required final int experienceYears,
      required final List<String> languages,
      required final double rating,
      required final int completedSessions,
      required final String location,
      required final String timezone}) = _$MentorProfileModelImpl;
  const _MentorProfileModel._() : super._();

  factory _MentorProfileModel.fromJson(Map<String, dynamic> json) =
      _$MentorProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get profileImage;
  @override
  String get headline;
  @override
  String get bio;
  @override
  String get verificationStatus;
  @override
  String get accountStatus;
  @override
  List<String> get industries;
  @override
  List<String> get expertise;
  @override
  int get experienceYears;
  @override
  List<String> get languages;
  @override
  double get rating;
  @override
  int get completedSessions;
  @override
  String get location;
  @override
  String get timezone;
  @override
  @JsonKey(ignore: true)
  _$$MentorProfileModelImplCopyWith<_$MentorProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
