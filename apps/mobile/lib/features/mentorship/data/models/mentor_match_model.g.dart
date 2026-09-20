// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MentorMatchModelImpl _$$MentorMatchModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MentorMatchModelImpl(
      mentor:
          MentorProfileModel.fromJson(json['mentor'] as Map<String, dynamic>),
      relevanceScore: (json['relevanceScore'] as num).toDouble(),
      matchedRules: (json['matchedRules'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      unmatchedRules: (json['unmatchedRules'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$MentorMatchModelImplToJson(
        _$MentorMatchModelImpl instance) =>
    <String, dynamic>{
      'mentor': instance.mentor,
      'relevanceScore': instance.relevanceScore,
      'matchedRules': instance.matchedRules,
      'unmatchedRules': instance.unmatchedRules,
    };
