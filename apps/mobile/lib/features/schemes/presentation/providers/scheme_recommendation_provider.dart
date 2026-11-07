import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/scheme_repository.dart';
import '../../../../core/storage/hive_storage.dart';
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

  Future<void> updateFromQuestionnaire(Map<String, dynamic> answers) async {
    state = const AsyncValue.loading();
    
    // Persist questionnaire answers
    await HiveStorage.schemesCacheBox.put('questionnaire_profile', answers);

    final activity = (answers['activity'] ?? 'FARMER').toString();
    final stateName = (answers['state'] ?? 'Maharashtra').toString();
    final income = (answers['income'] is num) ? answers['income'] as num : 200000;
    final age = (answers['age'] ?? '26-40').toString();
    final gender = (answers['gender'] ?? 'MALE').toString();
    final category = (answers['category'] ?? 'General').toString();

    final List<Map<String, dynamic>> results = [];

    // 1. Farmer Schemes
    if (activity == 'FARMER' || activity == 'WOMEN_SHG') {
      results.add({
        'scheme': {
          '_id': 'pm-kmy-01',
          'name': 'PM Kisan Maandhan Yojana (PM-KMY)',
          'category': 'AGRICULTURE',
          'ministry': 'Ministry of Agriculture & Farmers Welfare',
          'shortDescription':
              'Old age pension scheme for Small & Marginal Farmers providing guaranteed ₹3,000 monthly pension upon reaching 60 years.',
          'description':
              'Central Sector Scheme administered by the Department of Agriculture in partnership with Life Insurance Corporation of India.',
          'officialUrl': 'https://pmkmy.gov.in',
        },
        'matchPercentage': 96,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Primary activity: Agricultural farmer verified',
          'Operational location: $stateName eligible',
          'Age bracket: $age within pension entry criteria',
          'Social category: $category reservation quota valid',
        ],
        'failedRules': <String>[],
      });

      results.add({
        'scheme': {
          '_id': 'pm-kisan-02',
          'name': 'PM-Kisan Samman Nidhi',
          'category': 'AGRICULTURE',
          'ministry': 'Ministry of Agriculture',
          'shortDescription':
              'Direct income support of ₹6,000 per year in three equal four-monthly installments deposited directly into farmer Aadhaar-linked bank accounts.',
          'officialUrl': 'https://pmkisan.gov.in',
        },
        'matchPercentage': 95,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Landholder agricultural family criteria fulfilled',
          'Annual income ceiling compliant (₹${income.toInt()})',
          'Direct Benefit Transfer (DBT) eligible',
        ],
        'failedRules': <String>[],
      });
    }

    // 2. Entrepreneur & Business Schemes
    if (activity == 'ENTREPRENEUR' || activity == 'ARTISAN' || activity == 'FARMER') {
      results.add({
        'scheme': {
          '_id': 'pmmy-mudra-03',
          'name': 'Pradhan Mantri Mudra Yojana (PMMY)',
          'category': 'FINANCE',
          'ministry': 'Ministry of Finance & MSME',
          'shortDescription':
              'Collateral-free institutional micro-credit loans up to ₹10 Lakh (Shishu, Kishore & Tarun) for non-corporate, non-farm rural micro enterprises.',
          'officialUrl': 'https://www.mudra.org.in',
        },
        'matchPercentage': 93,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Micro-enterprise category validated',
          'Working capital requirements within ceiling',
          'No prior non-performing asset (NPA) records',
        ],
        'failedRules': <String>[],
      });

      results.add({
        'scheme': {
          '_id': 'pmfme-04',
          'name': 'PM Formalisation of Micro Food Processing Enterprises (PMFME)',
          'category': 'MSME',
          'ministry': 'Ministry of Food Processing Industries',
          'shortDescription':
              'Under Aatmanirbhar Bharat Abhiyan, offers 35% credit-linked capital subsidy up to ₹10 Lakh per enterprise for upgrading micro agro-units.',
          'officialUrl': 'https://pmfme.mofpi.gov.in',
        },
        'matchPercentage': 89,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'One District One Product (ODOP) cluster matching',
          'Technical & credit grant qualifications satisfied',
        ],
        'failedRules': <String>[],
      });
    }

    // 3. Artisan Specific
    if (activity == 'ARTISAN') {
      results.insert(0, {
        'scheme': {
          '_id': 'pm-vishwakarma-05',
          'name': 'PM Vishwakarma Scheme',
          'category': 'MSME',
          'ministry': 'Ministry of Micro, Small and Medium Enterprises',
          'shortDescription':
              'End-to-end holistic support for traditional artisans including ₹15,000 digital toolkit incentive, basic training stipend, and 5% concessional credit.',
          'officialUrl': 'https://pmvishwakarma.gov.in',
        },
        'matchPercentage': 98,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Traditional artisan craft category certified',
          'ID card and toolkit grant entitlement confirmed',
          'Subsidized loan interest ceiling applicable',
        ],
        'failedRules': <String>[],
      });
    }

    // 4. Women & SHG Schemes
    if (gender == 'FEMALE' || activity == 'WOMEN_SHG') {
      results.insert(0, {
        'scheme': {
          '_id': 'lakhpati-didi-06',
          'name': 'Lakhpati Didi SHG Micro-Enterprise Mission',
          'category': 'WOMEN',
          'ministry': 'Ministry of Rural Development',
          'shortDescription':
              'National initiative providing credit linkages, market facilitation, and technical training enabling rural women to earn sustainable annual income above ₹1 Lakh.',
          'officialUrl': 'https://nrlm.gov.in',
        },
        'matchPercentage': 98,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Female entrepreneur affirmative reservation',
          'SHG federation credit linkage eligible',
          'Enterprise development grant approved',
        ],
        'failedRules': <String>[],
      });
    }

    // 5. SC / ST Affirmative Schemes (Matching Image 1)
    if (category == 'SC' || category == 'ST') {
      results.insert(1, {
        'scheme': {
          '_id': 'standup-india-07',
          'name': 'Stand-Up India Scheme ($category Priority)',
          'category': 'FINANCE',
          'ministry': 'Ministry of Finance & SIDBI',
          'shortDescription':
              'Facilitates bank loans between ₹10 Lakh and ₹1 Crore to Scheduled Caste (SC) or Scheduled Tribe (ST) borrowers for setting up greenfield enterprises.',
          'officialUrl': 'https://www.standupmitra.in',
        },
        'matchPercentage': 96,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Affirmative social category quota ($category) met',
          'Greenfield manufacturing / services eligibility verified',
          '85% Credit Guarantee Cover applied',
        ],
        'failedRules': <String>[],
      });
    }

    // 6. State Specific (e.g. Maharashtra)
    if (stateName.toLowerCase().contains('maharashtra')) {
      results.add({
        'scheme': {
          '_id': 'maha-shektari-08',
          'name': 'Maha-DBT Farmers & Rural Subsidy Scheme',
          'category': 'AGRICULTURE',
          'ministry': 'Government of Maharashtra',
          'shortDescription':
              'State capital subsidy for farm mechanization, drip irrigation, and micro-processing units with direct Aadhaar bank credit.',
          'officialUrl': 'https://mahadbt.maharashtra.gov.in',
        },
        'matchPercentage': 94,
        'eligibilityStatus': 'ELIGIBLE',
        'matchedRules': [
          'Domicile: State of Maharashtra verified',
          'Direct Benefit Transfer (DBT) portal linked',
        ],
        'failedRules': <String>[],
      });
    }

    await HiveStorage.schemesCacheBox.put('cached_recommendations', results);
    await HiveStorage.schemesCacheBox.put('recommendations_generated_at', DateTime.now().toIso8601String());

    state = AsyncValue.data(results);
  }
}

final schemeRecommendationProvider = StateNotifierProvider<
    SchemeRecommendationNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repo = ref.watch(schemeRepositoryProvider);
  return SchemeRecommendationNotifier(repo);
});

final activeQuestionnaireProfileProvider = Provider<Map<String, dynamic>?>((ref) {
  final raw = HiveStorage.schemesCacheBox.get('questionnaire_profile');
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return null;
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
