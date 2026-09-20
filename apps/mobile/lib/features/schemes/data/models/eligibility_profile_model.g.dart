// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eligibility_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EligibilityProfileModelImpl _$$EligibilityProfileModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EligibilityProfileModelImpl(
      activityType: json['activityType'] as String?,
      sector: json['sector'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      socialCategory: json['socialCategory'] as String?,
      annualIncome: (json['annualIncome'] as num?)?.toDouble(),
      annualTurnover: (json['annualTurnover'] as num?)?.toDouble(),
      businessStage: json['businessStage'] as String?,
      businessType: json['businessType'] as String?,
      isFarmer: json['isFarmer'] as bool?,
      ownsLand: json['ownsLand'] as bool?,
      landSize: (json['landSize'] as num?)?.toDouble(),
      employmentStatus: json['employmentStatus'] as String?,
      craftType: json['craftType'] as String?,
      profileVersion: (json['profileVersion'] as num?)?.toInt() ?? 1,
      profileUpdatedAt: json['profileUpdatedAt'] as String?,
    );

Map<String, dynamic> _$$EligibilityProfileModelImplToJson(
        _$EligibilityProfileModelImpl instance) =>
    <String, dynamic>{
      'activityType': instance.activityType,
      'sector': instance.sector,
      'state': instance.state,
      'district': instance.district,
      'age': instance.age,
      'gender': instance.gender,
      'socialCategory': instance.socialCategory,
      'annualIncome': instance.annualIncome,
      'annualTurnover': instance.annualTurnover,
      'businessStage': instance.businessStage,
      'businessType': instance.businessType,
      'isFarmer': instance.isFarmer,
      'ownsLand': instance.ownsLand,
      'landSize': instance.landSize,
      'employmentStatus': instance.employmentStatus,
      'craftType': instance.craftType,
      'profileVersion': instance.profileVersion,
      'profileUpdatedAt': instance.profileUpdatedAt,
    };
