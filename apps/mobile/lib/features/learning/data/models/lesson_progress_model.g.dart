// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonProgressModelImpl _$$LessonProgressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LessonProgressModelImpl(
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      moduleId: json['moduleId'] as String,
      lessonId: json['lessonId'] as String,
      positionSeconds: (json['positionSeconds'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      completed: json['completed'] as bool,
      clientUpdatedAt: json['clientUpdatedAt'] as String,
    );

Map<String, dynamic> _$$LessonProgressModelImplToJson(
        _$LessonProgressModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'courseId': instance.courseId,
      'moduleId': instance.moduleId,
      'lessonId': instance.lessonId,
      'positionSeconds': instance.positionSeconds,
      'durationSeconds': instance.durationSeconds,
      'percentage': instance.percentage,
      'completed': instance.completed,
      'clientUpdatedAt': instance.clientUpdatedAt,
    };
