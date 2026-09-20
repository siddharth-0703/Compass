import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/mentor_availability.dart';

part 'mentor_availability_model.freezed.dart';
part 'mentor_availability_model.g.dart';

@freezed
class MentorAvailabilitySlotModel with _$MentorAvailabilitySlotModel {
  const factory MentorAvailabilitySlotModel({
    required String start, // Serialized ISO UTC timestamp
    required String end,
    required bool available,
  }) = _MentorAvailabilitySlotModel;

  factory MentorAvailabilitySlotModel.fromJson(Map<String, dynamic> json) =>
      _$MentorAvailabilitySlotModelFromJson(json);

  const MentorAvailabilitySlotModel._();

  MentorAvailabilitySlot toEntity() {
    return MentorAvailabilitySlot(
      start: DateTime.parse(start).toLocal(),
      end: DateTime.parse(end).toLocal(),
      available: available,
    );
  }
}

@freezed
class MentorAvailabilityModel with _$MentorAvailabilityModel {
  const factory MentorAvailabilityModel({
    required String timezone,
    required List<MentorAvailabilitySlotModel> slots,
  }) = _MentorAvailabilityModel;

  factory MentorAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$MentorAvailabilityModelFromJson(json);

  const MentorAvailabilityModel._();

  MentorAvailability toEntity() {
    return MentorAvailability(
      timezone: timezone,
      slots: slots.map((s) => s.toEntity()).toList(),
    );
  }
}
