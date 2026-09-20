import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/eligibility_provider.dart';
import '../presentation/providers/scheme_recommendation_provider.dart';

class SchemeRecommenderScreen extends ConsumerWidget {
  const SchemeRecommenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(eligibilityProfileProvider);
    final recommendationsState = ref.watch(schemeRecommendationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            tooltip: 'Update Eligibility Profile',
            onPressed: () => context.push('/schemes/questionnaire'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Profile Stale Check (Boundary Safety)
          profileState.when(
            data: (profile) {
              if (profile == null) {
                return _buildAlertBox(
                  context,
                  'Profile Incomplete',
                  'Fill in the eligibility questionnaire to discover schemes tailored for you.',
                  actionText: 'Start Questionnaire',
                  onAction: () => context.push('/schemes/questionnaire'),
                );
              }
              // Display version and timestamp metadata
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Version: v${profile.profileVersion}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,),
                    ),
                    Text(
                      'Last Saved: ${profile.profileUpdatedAt?.toLocal().toString().split('.')[0] ?? "Never"}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          // 2. Recommendations List View
          Expanded(
            child: recommendationsState.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                        'No recommendations found. Try updating your profile.',),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildSchemeCard(context, ref, item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error loading recommendations: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBox(BuildContext context, String title, String msg,
      {required String actionText, required VoidCallback onAction,}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.orange,),),
          const SizedBox(height: 4),
          Text(msg,
              style: const TextStyle(fontSize: 14, color: Colors.black87),),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, WidgetRef ref, dynamic item) {
    // Expected dynamic backend response structure
    final scheme = item['scheme'];
    final matchPercentage = item['matchPercentage'] ?? 0;
    final eligibilityStatus = item['eligibilityStatus'] ?? 'INELIGIBLE';

    final matchedRules = List<String>.from(item['matchedRules'] ?? []);
    final failedRules = List<String>.from(item['failedRules'] ?? []);

    final isEligible = eligibilityStatus == 'ELIGIBLE';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${scheme['category']} • ${scheme['ministry'] ?? "Central government"}',
                  style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isEligible ? Colors.green.shade50 : Colors.red.shade50,
                    border: Border.all(
                        color: isEligible
                            ? Colors.green.shade200
                            : Colors.red.shade200,),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEligible ? '$matchPercentage% Relevance' : 'Not Eligible',
                    style: TextStyle(
                        color: isEligible ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scheme['name'] ?? 'Scheme Name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              scheme['shortDescription'] ?? 'Description',
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Render deterministic matched criteria
            if (matchedRules.isNotEmpty) ...[
              const Text('Why You Qualify:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
              const SizedBox(height: 4),
              ...matchedRules.map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 14,),
                      const SizedBox(width: 6),
                      Text(rule, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],

            if (failedRules.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Unmet Requirements:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.red,),),
              const SizedBox(height: 4),
              ...failedRules.map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined,
                          color: Colors.red, size: 14,),
                      const SizedBox(width: 6),
                      Text(rule,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.red),),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),),
                    ),
                    onPressed: () => _showAIExplanation(
                        context, ref, scheme['id'], matchedRules, failedRules,),
                    child: const Text('Why Recommended?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white,),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAIExplanation(
    BuildContext context,
    WidgetRef ref,
    String schemeId,
    List<String> matchedRules,
    List<String> failedRules,
  ) {
    // Request explanation in user language (mocked as 'en' for now, maps to device locale)
    ref
        .read(recommendationExplanationProvider.notifier)
        .getExplanation(schemeId, matchedRules, failedRules, 'en');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final explanationState =
                ref.watch(recommendationExplanationProvider);

            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(context).padding.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('AI Explanation',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold,),),
                    ],
                  ),
                  const SizedBox(height: 16),
                  explanationState.when(
                    data: (text) => Text(
                      text.isNotEmpty ? text : 'No explanation available.',
                      style: const TextStyle(
                          fontSize: 16, height: 1.6, color: Colors.black87,),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text(
                      'Could not generate explanation. Rely on the rule-level matches above.',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,),),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
