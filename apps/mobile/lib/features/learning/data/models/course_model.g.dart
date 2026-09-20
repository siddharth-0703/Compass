// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseModelImpl _$$CourseModelImplFromJson(Map<String, dynamic> json) =>
    _$CourseModelImpl(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      difficulty: json['difficulty'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      modules: (json['modules'] as List<dynamic>)
          .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CourseModelImplToJson(_$CourseModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'categories': instance.categories,
      'difficulty': instance.difficulty,
      'thumbnailUrl': instance.thumbnailUrl,
      'modules': instance.modules,
    };
