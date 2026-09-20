class EligibilityProfile {
  final String? activityType;
  final String? sector;
  final String? state;
  final String? district;
  final int? age;
  final String? gender;
  final String? socialCategory;
  final double? annualIncome;
  final double? annualTurnover;
  final String? businessStage;
  final String? businessType;
  final bool? isFarmer;
  final bool? ownsLand;
  final double? landSize;
  final String? employmentStatus;
  final String? craftType;
  final int profileVersion;
  final DateTime? profileUpdatedAt;

  const EligibilityProfile({
    this.activityType,
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
    required this.profileVersion,
    this.profileUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'sector': sector,
      'state': state,
      'district': district,
      'age': age,
      'gender': gender,
      'socialCategory': socialCategory,
      'annualIncome': annualIncome,
      'annualTurnover': annualTurnover,
      'businessStage': businessStage,
      'businessType': businessType,
      'isFarmer': isFarmer,
      'ownsLand': ownsLand,
      'landSize': landSize,
      'employmentStatus': employmentStatus,
      'craftType': craftType,
      'profileVersion': profileVersion,
      'profileUpdatedAt': profileUpdatedAt?.toIso8601String(),
    };
  }

  factory EligibilityProfile.fromJson(Map<String, dynamic> json) {
    return EligibilityProfile(
      activityType: json['activityType'] as String?,
      sector: json['sector'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      age: json['age'] as int?,
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
      profileVersion: json['profileVersion'] as int? ?? 1,
      profileUpdatedAt: json['profileUpdatedAt'] != null
          ? DateTime.parse(json['profileUpdatedAt'] as String)
          : null,
    );
  }
}
