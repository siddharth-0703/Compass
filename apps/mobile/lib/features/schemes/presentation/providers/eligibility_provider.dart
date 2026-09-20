import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../domain/entities/eligibility_profile.dart';
import '../../domain/repositories/scheme_repository.dart';
import '../../data/repository/scheme_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final schemeRepositoryProvider = Provider<SchemeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SchemeRepositoryImpl(apiClient);
});

class EligibilityDraftNotifier extends StateNotifier<Map<String, dynamic>> {
  EligibilityDraftNotifier() : super({}) {
    _loadDraft();
  }

  void _loadDraft() {
    final draft = HiveStorage.schemesDraftBox.get('draft');
    if (draft != null) {
      state = Map<String, dynamic>.from(draft as Map);
    }
  }

  void updateAnswer(String field, dynamic value) {
    final newState = Map<String, dynamic>.from(state)..[field] = value;
    state = newState;
    HiveStorage.schemesDraftBox.put('draft', newState);
  }

  void clearAnswers() {
    state = {};
    HiveStorage.schemesDraftBox.delete('draft');
  }
}

final eligibilityDraftProvider =
    StateNotifierProvider<EligibilityDraftNotifier, Map<String, dynamic>>(
        (ref) {
  return EligibilityDraftNotifier();
});

class EligibilityProfileNotifier
    extends StateNotifier<AsyncValue<EligibilityProfile?>> {
  final SchemeRepository _repo;
  EligibilityProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.getEligibilityProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> submitProfile(EligibilityProfile profile) async {
    state = const AsyncValue.loading();
    try {
      await _repo.saveEligibilityProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final eligibilityProfileProvider = StateNotifierProvider<
    EligibilityProfileNotifier, AsyncValue<EligibilityProfile?>>((ref) {
  final repo = ref.watch(schemeRepositoryProvider);
  return EligibilityProfileNotifier(repo);
});

final profileCompletenessProvider = Provider<double>((ref) {
  final draft = ref.watch(eligibilityDraftProvider);

  // Calculate relative to the dynamic schema required fields
  final requiredFields = ['activityType', 'state', 'district', 'age'];

  if (draft['activityType'] == 'FARMER') {
    requiredFields.addAll(['ownsLand', 'landSize', 'sector']);
  } else if (draft['activityType'] == 'ENTREPRENEUR') {
    requiredFields.addAll(['businessType', 'businessStage', 'annualTurnover']);
  } else if (draft['activityType'] == 'ARTISAN') {
    requiredFields.addAll(['craftType', 'businessStage', 'annualIncome']);
  }

  if (requiredFields.isEmpty) return 0.0;
  int completed = 0;
  for (final field in requiredFields) {
    if (draft[field] != null && draft[field].toString().isNotEmpty) {
      completed++;
    }
  }
  return completed / requiredFields.length;
});
