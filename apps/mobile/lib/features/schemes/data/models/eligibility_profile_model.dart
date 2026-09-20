import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/eligibility_profile.dart';

part 'eligibility_profile_model.freezed.dart';
part 'eligibility_profile_model.g.dart';

@freezed
class EligibilityProfileModel with _$EligibilityProfileModel {
  const factory EligibilityProfileModel({
    String? activityType,
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
    @Default(1) int profileVersion,
    String? profileUpdatedAt,
  }) = _EligibilityProfileModel;

  factory EligibilityProfileModel.fromJson(Map<String, dynamic> json) =>
      _$EligibilityProfileModelFromJson(json);

  factory EligibilityProfileModel.fromEntity(EligibilityProfile entity) {
    return EligibilityProfileModel(
      activityType: entity.activityType,
      sector: entity.sector,
      state: entity.state,
      district: entity.district,
      age: entity.age,
      gender: entity.gender,
      socialCategory: entity.socialCategory,
      annualIncome: entity.annualIncome,
      annualTurnover: entity.annualTurnover,
      businessStage: entity.businessStage,
      businessType: entity.businessType,
      isFarmer: entity.isFarmer,
      ownsLand: entity.ownsLand,
      landSize: entity.landSize,
      employmentStatus: entity.employmentStatus,
      craftType: entity.craftType,
      profileVersion: entity.profileVersion,
      profileUpdatedAt: entity.profileUpdatedAt?.toIso8601String(),
    );
  }

  const EligibilityProfileModel._();

  EligibilityProfile toEntity() {
    return EligibilityProfile(
      activityType: activityType,
      sector: sector,
      state: state,
      district: district,
      age: age,
      gender: gender,
      socialCategory: socialCategory,
      annualIncome: annualIncome,
      annualTurnover: annualTurnover,
      businessStage: businessStage,
      businessType: businessType,
      isFarmer: isFarmer,
      ownsLand: ownsLand,
      landSize: landSize,
      employmentStatus: employmentStatus,
      craftType: craftType,
      profileVersion: profileVersion,
      profileUpdatedAt:
          profileUpdatedAt != null ? DateTime.parse(profileUpdatedAt!) : null,
    );
  }
}
