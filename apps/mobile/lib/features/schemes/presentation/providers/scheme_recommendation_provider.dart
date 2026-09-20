import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/scheme_repository.dart';
import 'eligibility_provider.dart';

class SchemeRecommendationNotifier
    extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SchemeRepository _repo;
  SchemeRecommendationNotifier(this._repo) : super(const AsyncValue.data([]));

  Future<void> fetchRecommendations(String businessId) async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getRecommendations(businessId);
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final schemeRecommendationProvider = StateNotifierProvider<
    SchemeRecommendationNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repo = ref.watch(schemeRepositoryProvider);
  return SchemeRecommendationNotifier(repo);
});

class RecommendationExplanationNotifier
    extends StateNotifier<AsyncValue<String>> {
  final SchemeRepository _repo;
  RecommendationExplanationNotifier(this._repo)
      : super(const AsyncValue.data(''));

  Future<void> getExplanation(String schemeId, List<String> matchedRules,
      List<String> failedRules, String language,) async {
    state = const AsyncValue.loading();
    try {
      final explanation = await _repo.getSchemeExplanation(
          schemeId, matchedRules, failedRules, language,);
      state = AsyncValue.data(explanation);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final recommendationExplanationProvider = StateNotifierProvider<
    RecommendationExplanationNotifier, AsyncValue<String>>((ref) {
  final repo = ref.watch(schemeRepositoryProvider);
  return RecommendationExplanationNotifier(repo);
});
