// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      media: json['media'] == null
          ? null
          : LocalizedMediaModel.fromJson(json['media'] as Map<String, dynamic>),
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      order: (json['order'] as num).toInt(),
      isPublished: json['isPublished'] as bool,
      contentStatus: json['contentStatus'] as String,
    );

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'durationSeconds': instance.durationSeconds,
      'media': instance.media,
      'resources': instance.resources,
      'order': instance.order,
      'isPublished': instance.isPublished,
      'contentStatus': instance.contentStatus,
    };
