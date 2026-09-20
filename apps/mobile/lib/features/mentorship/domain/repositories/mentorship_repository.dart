import '../entities/mentor_profile.dart';
import '../entities/mentor_availability.dart';
import '../entities/mentorship_session.dart';
import '../entities/mentor_match.dart';

abstract class MentorshipRepository {
  Future<List<MentorMatch>> getMentorMatches(String businessId);
  Future<MentorProfile> getMentorDetails(String mentorId);
  Future<MentorAvailability> getMentorAvailability(
      String mentorId, DateTime date,);
  Future<MentorshipSession> bookSession({
    required String mentorId,
    required DateTime startTime,
    required DateTime endTime,
    required String timezone,
    required List<String> goals,
    required String idempotencyKey,
  });
  Future<List<MentorshipSession>> getMySessions();
  Future<void> cancelSession(String sessionId);
  Future<void> rescheduleSession({
    required String sessionId,
    required DateTime newStartTime,
    required DateTime newEndTime,
    required String timezone,
  });
  Future<void> submitFeedback({
    required String sessionId,
    required int rating,
    required String comment,
  });
  Future<String> getMentorExplanation(
      String mentorId, List<String> matchedRules, String language,);
}
