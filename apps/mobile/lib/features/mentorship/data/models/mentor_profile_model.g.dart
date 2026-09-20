// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MentorProfileModelImpl _$$MentorProfileModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MentorProfileModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      headline: json['headline'] as String,
      bio: json['bio'] as String,
      verificationStatus: json['verificationStatus'] as String,
      accountStatus: json['accountStatus'] as String,
      industries: (json['industries'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      expertise:
          (json['expertise'] as List<dynamic>).map((e) => e as String).toList(),
      experienceYears: (json['experienceYears'] as num).toInt(),
      languages:
          (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      completedSessions: (json['completedSessions'] as num).toInt(),
      location: json['location'] as String,
      timezone: json['timezone'] as String,
    );

Map<String, dynamic> _$$MentorProfileModelImplToJson(
        _$MentorProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'profileImage': instance.profileImage,
      'headline': instance.headline,
      'bio': instance.bio,
      'verificationStatus': instance.verificationStatus,
      'accountStatus': instance.accountStatus,
      'industries': instance.industries,
      'expertise': instance.expertise,
      'experienceYears': instance.experienceYears,
      'languages': instance.languages,
      'rating': instance.rating,
      'completedSessions': instance.completedSessions,
      'location': instance.location,
      'timezone': instance.timezone,
    };
