// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentorship_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MentorshipSessionModelImpl _$$MentorshipSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MentorshipSessionModelImpl(
      id: json['id'] as String,
      mentorId: json['mentorId'] as String,
      mentorName: json['mentorName'] as String,
      businessId: json['businessId'] as String,
      entrepreneurId: json['entrepreneurId'] as String,
      status: json['status'] as String,
      scheduledAt: json['scheduledAt'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      meetingPlatform: json['meetingPlatform'] as String,
      meetingLink: json['meetingLink'] as String?,
      goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      canJoin: json['canJoin'] as bool,
    );

Map<String, dynamic> _$$MentorshipSessionModelImplToJson(
        _$MentorshipSessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mentorId': instance.mentorId,
      'mentorName': instance.mentorName,
      'businessId': instance.businessId,
      'entrepreneurId': instance.entrepreneurId,
      'status': instance.status,
      'scheduledAt': instance.scheduledAt,
      'durationMinutes': instance.durationMinutes,
      'meetingPlatform': instance.meetingPlatform,
      'meetingLink': instance.meetingLink,
      'goals': instance.goals,
      'rating': instance.rating,
      'feedback': instance.feedback,
      'canJoin': instance.canJoin,
    };
