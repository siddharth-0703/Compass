import 'mentor_profile.dart';

class MentorMatch {
  final MentorProfile mentor;
  final double relevanceScore;
  final List<String> matchedRules;
  final List<String> unmatchedRules;

  const MentorMatch({
    required this.mentor,
    required this.relevanceScore,
    required this.matchedRules,
    required this.unmatchedRules,
  });
}
