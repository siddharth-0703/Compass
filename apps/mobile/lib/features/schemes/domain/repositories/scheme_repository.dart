import '../entities/eligibility_profile.dart';

abstract class SchemeRepository {
  Future<EligibilityProfile?> getEligibilityProfile();
  Future<void> saveEligibilityProfile(EligibilityProfile profile);
  Future<List<dynamic>> getRecommendations(String businessId);
  Future<String> getSchemeExplanation(
    String schemeId,
    List<String> matchedRules,
    List<String> failedRules,
    String language,
  );
}
