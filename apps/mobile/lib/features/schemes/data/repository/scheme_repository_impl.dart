import '../../../../core/api/api_client.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/repositories/scheme_repository.dart';
import '../../domain/entities/eligibility_profile.dart';
import '../models/eligibility_profile_model.dart';

class SchemeRepositoryImpl implements SchemeRepository {
  final ApiClient _apiClient;

  SchemeRepositoryImpl(this._apiClient);

  @override
  Future<EligibilityProfile?> getEligibilityProfile() async {
    try {
      final response =
          await _apiClient.dio.get('/users/me/eligibility-profile');
      if (response.data != null && response.data['success'] == true) {
        final model = EligibilityProfileModel.fromJson(response.data['data']);
        await HiveStorage.schemesCacheBox.put('active_profile', model.toJson());
        return model.toEntity();
      }
    } catch (e) {
      final cached = HiveStorage.schemesCacheBox.get('active_profile');
      if (cached != null) {
        return EligibilityProfileModel.fromJson(
                Map<String, dynamic>.from(cached as Map),)
            .toEntity();
      }
    }
    return null;
  }

  @override
  Future<void> saveEligibilityProfile(EligibilityProfile profile) async {
    final model = EligibilityProfileModel.fromEntity(profile);

    // Automatically increment profileVersion and stamp compilation date
    final updatedModel = model.copyWith(
      profileVersion: model.profileVersion + 1,
      profileUpdatedAt: DateTime.now().toIso8601String(),
    );

    // Save locally to cache first
    await HiveStorage.schemesCacheBox
        .put('active_profile', updatedModel.toJson());

    // Submit payload to endpoint
    await _apiClient.dio.put(
      '/users/me/eligibility-profile',
      data: updatedModel.toJson(),
    );
  }

  @override
  Future<List<dynamic>> getRecommendations(String businessId) async {
    try {
      final response =
          await _apiClient.dio.get('/schemes/recommendations/$businessId');
      if (response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List;
        await HiveStorage.schemesCacheBox.put('cached_recommendations', list);
        await HiveStorage.schemesCacheBox.put(
            'recommendations_generated_at', DateTime.now().toIso8601String(),);
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
    final response = await _apiClient.dio.post(
      '/schemes/explain',
      data: {
        'schemeId': schemeId,
        'matchedRules': matchedRules,
        'failedRules': failedRules,
        'language': language,
      },
    );
    return response.data['data']['explanation'] as String;
  }
}
