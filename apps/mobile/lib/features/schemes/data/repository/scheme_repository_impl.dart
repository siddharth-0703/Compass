import '../../../../core/api/api_client.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/repositories/scheme_repository.dart';
import '../../domain/entities/eligibility_profile.dart';

class SchemeRepositoryImpl implements SchemeRepository {
  final ApiClient _apiClient;

  SchemeRepositoryImpl(this._apiClient);

  @override
  Future<EligibilityProfile?> getEligibilityProfile() async {
    // The backend does not support separate eligibility profiles.
    // It relies on the Business profile for recommendations.
    return null;
  }

  @override
  Future<void> saveEligibilityProfile(EligibilityProfile profile) async {
    // Unsupported by backend. Do nothing.
  }

  @override
  Future<List<dynamic>> getRecommendations(String businessId) async {
    try {
      final response = await _apiClient.dio.get('/schemes/recommendations/$businessId');
      if (response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List;
        await HiveStorage.schemesCacheBox.put('cached_recommendations', list);
        await HiveStorage.schemesCacheBox.put(
          'recommendations_generated_at',
          DateTime.now().toIso8601String(),
        );
        return list;
      }
    } catch (e) {
      final cached = HiveStorage.schemesCacheBox.get('cached_recommendations');
      if (cached != null) {
        return cached as List;
      }
    }
    return [];
  }

  @override
  Future<String> getSchemeExplanation(
    String schemeId,
    List<String> matchedRules,
    List<String> failedRules,
    String language,
  ) async {
    // Unsupported by backend. Fallback to generic text or throw.
    return 'Detailed explanation is not available at this time.';
  }
}
