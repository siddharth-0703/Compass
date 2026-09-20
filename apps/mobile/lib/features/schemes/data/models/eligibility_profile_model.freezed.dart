// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eligibility_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EligibilityProfileModel _$EligibilityProfileModelFromJson(
    Map<String, dynamic> json) {
  return _EligibilityProfileModel.fromJson(json);
}

/// @nodoc
mixin _$EligibilityProfileModel {
  String? get activityType => throw _privateConstructorUsedError;
  String? get sector => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get socialCategory => throw _privateConstructorUsedError;
  double? get annualIncome => throw _privateConstructorUsedError;
  double? get annualTurnover => throw _privateConstructorUsedError;
  String? get businessStage => throw _privateConstructorUsedError;
  String? get businessType => throw _privateConstructorUsedError;
  bool? get isFarmer => throw _privateConstructorUsedError;
  bool? get ownsLand => throw _privateConstructorUsedError;
  double? get landSize => throw _privateConstructorUsedError;
  String? get employmentStatus => throw _privateConstructorUsedError;
  String? get craftType => throw _privateConstructorUsedError;
  int get profileVersion => throw _privateConstructorUsedError;
  String? get profileUpdatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EligibilityProfileModelCopyWith<EligibilityProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EligibilityProfileModelCopyWith<$Res> {
  factory $EligibilityProfileModelCopyWith(EligibilityProfileModel value,
          $Res Function(EligibilityProfileModel) then) =
      _$EligibilityProfileModelCopyWithImpl<$Res, EligibilityProfileModel>;
  @useResult
  $Res call(
      {String? activityType,
      String? sector,
      String? state,
      String? district,
      int? age,
      String? gender,
      String? socialCategory,
      double? annualIncome,
      double? annualTurnover,
      String? businessStage,
      String? businessType,
      bool? isFarmer,
      bool? ownsLand,
      double? landSize,
      String? employmentStatus,
      String? craftType,
      int profileVersion,
      String? profileUpdatedAt});
}

/// @nodoc
class _$EligibilityProfileModelCopyWithImpl<$Res,
        $Val extends EligibilityProfileModel>
    implements $EligibilityProfileModelCopyWith<$Res> {
  _$EligibilityProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityType = freezed,
    Object? sector = freezed,
    Object? state = freezed,
    Object? district = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? socialCategory = freezed,
    Object? annualIncome = freezed,
    Object? annualTurnover = freezed,
    Object? businessStage = freezed,
    Object? businessType = freezed,
    Object? isFarmer = freezed,
    Object? ownsLand = freezed,
    Object? landSize = freezed,
    Object? employmentStatus = freezed,
    Object? craftType = freezed,
    Object? profileVersion = null,
    Object? profileUpdatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      activityType: freezed == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _value.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      socialCategory: freezed == socialCategory
          ? _value.socialCategory
          : socialCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      annualIncome: freezed == annualIncome
          ? _value.annualIncome
          : annualIncome // ignore: cast_nullable_to_non_nullable
              as double?,
      annualTurnover: freezed == annualTurnover
          ? _value.annualTurnover
          : annualTurnover // ignore: cast_nullable_to_non_nullable
              as double?,
      businessStage: freezed == businessStage
          ? _value.businessStage
          : businessStage // ignore: cast_nullable_to_non_nullable
              as String?,
      businessType: freezed == businessType
          ? _value.businessType
          : businessType // ignore: cast_nullable_to_non_nullable
              as String?,
      isFarmer: freezed == isFarmer
          ? _value.isFarmer
          : isFarmer // ignore: cast_nullable_to_non_nullable
              as bool?,
      ownsLand: freezed == ownsLand
          ? _value.ownsLand
          : ownsLand // ignore: cast_nullable_to_non_nullable
              as bool?,
      landSize: freezed == landSize
          ? _value.landSize
          : landSize // ignore: cast_nullable_to_non_nullable
              as double?,
      employmentStatus: freezed == employmentStatus
          ? _value.employmentStatus
          : employmentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      craftType: freezed == craftType
          ? _value.craftType
          : craftType // ignore: cast_nullable_to_non_nullable
              as String?,
      profileVersion: null == profileVersion
          ? _value.profileVersion
          : profileVersion // ignore: cast_nullable_to_non_nullable
              as int,
      profileUpdatedAt: freezed == profileUpdatedAt
          ? _value.profileUpdatedAt
          : profileUpdatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EligibilityProfileModelImplCopyWith<$Res>
    implements $EligibilityProfileModelCopyWith<$Res> {
  factory _$$EligibilityProfileModelImplCopyWith(
          _$EligibilityProfileModelImpl value,
          $Res Function(_$EligibilityProfileModelImpl) then) =
      __$$EligibilityProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? activityType,
      String? sector,
      String? state,
      String? district,
      int? age,
      String? gender,
      String? socialCategory,
      double? annualIncome,
      double? annualTurnover,
      String? businessStage,
      String? businessType,
      bool? isFarmer,
      bool? ownsLand,
      double? landSize,
      String? employmentStatus,
      String? craftType,
      int profileVersion,
      String? profileUpdatedAt});
}

/// @nodoc
class __$$EligibilityProfileModelImplCopyWithImpl<$Res>
    extends _$EligibilityProfileModelCopyWithImpl<$Res,
        _$EligibilityProfileModelImpl>
    implements _$$EligibilityProfileModelImplCopyWith<$Res> {
  __$$EligibilityProfileModelImplCopyWithImpl(
      _$EligibilityProfileModelImpl _value,
      $Res Function(_$EligibilityProfileModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityType = freezed,
    Object? sector = freezed,
    Object? state = freezed,
    Object? district = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? socialCategory = freezed,
    Object? annualIncome = freezed,
    Object? annualTurnover = freezed,
    Object? businessStage = freezed,
    Object? businessType = freezed,
    Object? isFarmer = freezed,
    Object? ownsLand = freezed,
    Object? landSize = freezed,
    Object? employmentStatus = freezed,
    Object? craftType = freezed,
    Object? profileVersion = null,
    Object? profileUpdatedAt = freezed,
  }) {
    return _then(_$EligibilityProfileModelImpl(
      activityType: freezed == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String?,
      sector: freezed == sector
          ? _value.sector
          : sector // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      socialCategory: freezed == socialCategory
          ? _value.socialCategory
          : socialCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      annualIncome: freezed == annualIncome
          ? _value.annualIncome
          : annualIncome // ignore: cast_nullable_to_non_nullable
              as double?,
      annualTurnover: freezed == annualTurnover
          ? _value.annualTurnover
          : annualTurnover // ignore: cast_nullable_to_non_nullable
              as double?,
      businessStage: freezed == businessStage
          ? _value.businessStage
          : businessStage // ignore: cast_nullable_to_non_nullable
              as String?,
      businessType: freezed == businessType
          ? _value.businessType
          : businessType // ignore: cast_nullable_to_non_nullable
              as String?,
      isFarmer: freezed == isFarmer
          ? _value.isFarmer
          : isFarmer // ignore: cast_nullable_to_non_nullable
              as bool?,
      ownsLand: freezed == ownsLand
          ? _value.ownsLand
          : ownsLand // ignore: cast_nullable_to_non_nullable
              as bool?,
      landSize: freezed == landSize
          ? _value.landSize
          : landSize // ignore: cast_nullable_to_non_nullable
              as double?,
      employmentStatus: freezed == employmentStatus
          ? _value.employmentStatus
          : employmentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      craftType: freezed == craftType
          ? _value.craftType
          : craftType // ignore: cast_nullable_to_non_nullable
              as String?,
      profileVersion: null == profileVersion
          ? _value.profileVersion
          : profileVersion // ignore: cast_nullable_to_non_nullable
              as int,
      profileUpdatedAt: freezed == profileUpdatedAt
          ? _value.profileUpdatedAt
          : profileUpdatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EligibilityProfileModelImpl extends _EligibilityProfileModel {
  const _$EligibilityProfileModelImpl(
      {this.activityType,
      this.sector,
      this.state,
      this.district,
      this.age,
      this.gender,
      this.socialCategory,
      this.annualIncome,
      this.annualTurnover,
      this.businessStage,
      this.businessType,
      this.isFarmer,
      this.ownsLand,
      this.landSize,
      this.employmentStatus,
      this.craftType,
      this.profileVersion = 1,
      this.profileUpdatedAt})
      : super._();

  factory _$EligibilityProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EligibilityProfileModelImplFromJson(json);

  @override
  final String? activityType;
  @override
  final String? sector;
  @override
  final String? state;
  @override
  final String? district;
  @override
  final int? age;
  @override
  final String? gender;
  @override
  final String? socialCategory;
  @override
  final double? annualIncome;
  @override
  final double? annualTurnover;
  @override
  final String? businessStage;
  @override
  final String? businessType;
  @override
  final bool? isFarmer;
  @override
  final bool? ownsLand;
  @override
  final double? landSize;
  @override
  final String? employmentStatus;
  @override
  final String? craftType;
  @override
  @JsonKey()
  final int profileVersion;
  @override
  final String? profileUpdatedAt;

  @override
  String toString() {
    return 'EligibilityProfileModel(activityType: $activityType, sector: $sector, state: $state, district: $district, age: $age, gender: $gender, socialCategory: $socialCategory, annualIncome: $annualIncome, annualTurnover: $annualTurnover, businessStage: $businessStage, businessType: $businessType, isFarmer: $isFarmer, ownsLand: $ownsLand, landSize: $landSize, employmentStatus: $employmentStatus, craftType: $craftType, profileVersion: $profileVersion, profileUpdatedAt: $profileUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EligibilityProfileModelImpl &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.sector, sector) || other.sector == sector) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.socialCategory, socialCategory) ||
                other.socialCategory == socialCategory) &&
            (identical(other.annualIncome, annualIncome) ||
                other.annualIncome == annualIncome) &&
            (identical(other.annualTurnover, annualTurnover) ||
                other.annualTurnover == annualTurnover) &&
            (identical(other.businessStage, businessStage) ||
                other.businessStage == businessStage) &&
            (identical(other.businessType, businessType) ||
                other.businessType == businessType) &&
            (identical(other.isFarmer, isFarmer) ||
                other.isFarmer == isFarmer) &&
            (identical(other.ownsLand, ownsLand) ||
                other.ownsLand == ownsLand) &&
            (identical(other.landSize, landSize) ||
                other.landSize == landSize) &&
            (identical(other.employmentStatus, employmentStatus) ||
                other.employmentStatus == employmentStatus) &&
            (identical(other.craftType, craftType) ||
                other.craftType == craftType) &&
            (identical(other.profileVersion, profileVersion) ||
                other.profileVersion == profileVersion) &&
            (identical(other.profileUpdatedAt, profileUpdatedAt) ||
                other.profileUpdatedAt == profileUpdatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      activityType,
      sector,
      state,
      district,
      age,
      gender,
      socialCategory,
      annualIncome,
      annualTurnover,
      businessStage,
      businessType,
      isFarmer,
      ownsLand,
      landSize,
      employmentStatus,
      craftType,
      profileVersion,
      profileUpdatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EligibilityProfileModelImplCopyWith<_$EligibilityProfileModelImpl>
      get copyWith => __$$EligibilityProfileModelImplCopyWithImpl<
          _$EligibilityProfileModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EligibilityProfileModelImplToJson(
      this,
    );
  }
}

abstract class _EligibilityProfileModel extends EligibilityProfileModel {
  const factory _EligibilityProfileModel(
      {final String? activityType,
      final String? sector,
      final String? state,
      final String? district,
      final int? age,
      final String? gender,
      final String? socialCategory,
      final double? annualIncome,
      final double? annualTurnover,
      final String? businessStage,
      final String? businessType,
      final bool? isFarmer,
      final bool? ownsLand,
      final double? landSize,
      final String? employmentStatus,
      final String? craftType,
      final int profileVersion,
      final String? profileUpdatedAt}) = _$EligibilityProfileModelImpl;
  const _EligibilityProfileModel._() : super._();

  factory _EligibilityProfileModel.fromJson(Map<String, dynamic> json) =
      _$EligibilityProfileModelImpl.fromJson;

  @override
  String? get activityType;
  @override
  String? get sector;
  @override
  String? get state;
  @override
  String? get district;
  @override
  int? get age;
  @override
  String? get gender;
  @override
  String? get socialCategory;
  @override
  double? get annualIncome;
  @override
  double? get annualTurnover;
  @override
  String? get businessStage;
  @override
  String? get businessType;
  @override
  bool? get isFarmer;
  @override
  bool? get ownsLand;
  @override
  double? get landSize;
  @override
  String? get employmentStatus;
  @override
  String? get craftType;
  @override
  int get profileVersion;
  @override
  String? get profileUpdatedAt;
  @override
  @JsonKey(ignore: true)
  _$$EligibilityProfileModelImplCopyWith<_$EligibilityProfileModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
