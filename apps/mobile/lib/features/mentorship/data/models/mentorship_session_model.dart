import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/mentorship_session.dart';

part 'mentorship_session_model.freezed.dart';
part 'mentorship_session_model.g.dart';

@freezed
class MentorshipSessionModel with _$MentorshipSessionModel {
  const factory MentorshipSessionModel({
    required String id,
    required String mentorId,
    required String mentorName,
    required String businessId,
    required String entrepreneurId,
    required String status,
    required String scheduledAt, // Serialized ISO UTC timestamp
    required int durationMinutes,
    required String meetingPlatform,
    String? meetingLink,
    required List<String> goals,
    double? rating,
    String? feedback,
    required bool canJoin,
  }) = _MentorshipSessionModel;

  factory MentorshipSessionModel.fromJson(Map<String, dynamic> json) =>
      _$MentorshipSessionModelFromJson(json);

  const MentorshipSessionModel._();

  MentorshipSession toEntity() {
    return MentorshipSession(
      id: id,
      mentorId: mentorId,
      mentorName: mentorName,
      businessId: businessId,
      entrepreneurId: entrepreneurId,
      status: MentorshipSessionStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == status.replaceAll(' ', '').replaceAll('_', '').toLowerCase(),
        orElse: () => MentorshipSessionStatus.requested,
      ),
      scheduledAt: DateTime.parse(scheduledAt).toLocal(),
      durationMinutes: durationMinutes,
      meetingPlatform: meetingPlatform,
      meetingLink: meetingLink,
      goals: goals,
      rating: rating,
      feedback: feedback,
      canJoin: canJoin,
    );
  }
}
