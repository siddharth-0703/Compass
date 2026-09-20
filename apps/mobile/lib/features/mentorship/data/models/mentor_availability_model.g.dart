// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MentorAvailabilitySlotModelImpl _$$MentorAvailabilitySlotModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MentorAvailabilitySlotModelImpl(
      start: json['start'] as String,
      end: json['end'] as String,
      available: json['available'] as bool,
    );

Map<String, dynamic> _$$MentorAvailabilitySlotModelImplToJson(
        _$MentorAvailabilitySlotModelImpl instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
      'available': instance.available,
    };

_$MentorAvailabilityModelImpl _$$MentorAvailabilityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MentorAvailabilityModelImpl(
      timezone: json['timezone'] as String,
      slots: (json['slots'] as List<dynamic>)
          .map((e) =>
              MentorAvailabilitySlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MentorAvailabilityModelImplToJson(
        _$MentorAvailabilityModelImpl instance) =>
    <String, dynamic>{
      'timezone': instance.timezone,
      'slots': instance.slots,
    };
