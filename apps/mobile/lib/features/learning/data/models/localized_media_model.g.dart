// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localized_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalizedMediaSourceModelImpl _$$LocalizedMediaSourceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LocalizedMediaSourceModelImpl(
      contentUrl: json['contentUrl'] as String,
      provider: json['provider'] as String,
      contentType: json['contentType'] as String,
    );

Map<String, dynamic> _$$LocalizedMediaSourceModelImplToJson(
        _$LocalizedMediaSourceModelImpl instance) =>
    <String, dynamic>{
      'contentUrl': instance.contentUrl,
      'provider': instance.provider,
      'contentType': instance.contentType,
    };

_$LocalizedMediaModelImpl _$$LocalizedMediaModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LocalizedMediaModelImpl(
      en: json['en'] == null
          ? null
          : LocalizedMediaSourceModel.fromJson(
              json['en'] as Map<String, dynamic>),
      hi: json['hi'] == null
          ? null
          : LocalizedMediaSourceModel.fromJson(
              json['hi'] as Map<String, dynamic>),
      mr: json['mr'] == null
          ? null
          : LocalizedMediaSourceModel.fromJson(
              json['mr'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LocalizedMediaModelImplToJson(
        _$LocalizedMediaModelImpl instance) =>
    <String, dynamic>{
      'en': instance.en,
      'hi': instance.hi,
      'mr': instance.mr,
    };
