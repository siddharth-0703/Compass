enum MentorshipSessionStatus {
  requested,
  confirmed,
  rejected,
  cancelled,
  rescheduleRequested,
  completed,
  noShow
}

class MentorshipSession {
  final String id;
  final String mentorId;
  final String mentorName;
  final String businessId;
  final String entrepreneurId;
  final MentorshipSessionStatus status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String meetingPlatform;
  final String? meetingLink;
  final List<String> goals;
  final double? rating;
  final String? feedback;
  final bool canJoin;

  const MentorshipSession({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.businessId,
    required this.entrepreneurId,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.meetingPlatform,
    this.meetingLink,
    required this.goals,
    this.rating,
    this.feedback,
    required this.canJoin,
  });
}
