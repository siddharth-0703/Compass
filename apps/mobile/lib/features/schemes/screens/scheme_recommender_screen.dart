import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../businesses/presentation/providers/business_provider.dart';
import '../presentation/providers/scheme_recommendation_provider.dart';

class SchemeRecommenderScreen extends ConsumerWidget {
  const SchemeRecommenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesState = ref.watch(myBusinessesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes',
            style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            tooltip: 'Manage Businesses',
            onPressed: () => context.push('/businesses'),
          ),
        ],
      ),
      body: businessesState.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: _buildAlertBox(
                  context,
                  'No Business Profile Found',
                  'You need to register a business first before we can recommend government schemes tailored for you.',
                  actionText: 'Register Business',
                  onAction: () => context.push('/businesses/new'),
                ),
              ),
            );
          }

          final activeBusiness = businesses.first;
          final recommendationsState = ref.watch(schemeRecommendationProvider);
          
          // Trigger the fetch if it hasn't been fetched yet
          // Note: In Riverpod a better pattern would be a FutureProvider with businessId parameter,
          // but we will keep the StateNotifier for now and use a post-frame callback if it's empty data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (recommendationsState.value == null || recommendationsState.value!.isEmpty) {
              ref.read(schemeRecommendationProvider.notifier).fetchRecommendations(activeBusiness.id);
            }
          });

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recommending schemes for: ${activeBusiness.name}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: recommendationsState.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(
                        child: Text('No recommendations found for this business profile.'),
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
                  error: (err, stack) => Center(child: Text('Error loading recommendations: ${err.toString().replaceAll('Exception: ', '')}')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading business: ${err.toString().replaceAll('Exception: ', '')}')),
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

  Color _getCategoryColor(String? category) {
    switch (category?.toUpperCase()) {
      case 'AGRICULTURE': return Colors.green.shade100;
      case 'ENTREPRENEURSHIP': return Colors.blue.shade100;
      case 'FINANCE': return Colors.amber.shade100;
      case 'EMPLOYMENT': return Colors.purple.shade100;
      case 'EDUCATION': return Colors.indigo.shade100;
      case 'HOUSING': return Colors.orange.shade100;
      case 'WOMEN': return Colors.pink.shade100;
      case 'MSME': return Colors.cyan.shade100;
      case 'STARTUP': return Colors.deepPurple.shade100;
      default: return Colors.grey.shade100;
    }
  }

  Color _getCategoryTextColor(String? category) {
    switch (category?.toUpperCase()) {
      case 'AGRICULTURE': return Colors.green.shade800;
      case 'ENTREPRENEURSHIP': return Colors.blue.shade800;
      case 'FINANCE': return Colors.amber.shade900;
      case 'EMPLOYMENT': return Colors.purple.shade800;
      case 'EDUCATION': return Colors.indigo.shade800;
      case 'HOUSING': return Colors.orange.shade800;
      case 'WOMEN': return Colors.pink.shade800;
      case 'MSME': return Colors.cyan.shade900;
      case 'STARTUP': return Colors.deepPurple.shade800;
      default: return Colors.grey.shade800;
    }
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(scheme['category']),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${scheme['category']} • ${scheme['ministry'] ?? "Central government"}',
                    style: TextStyle(
                      color: _getCategoryTextColor(scheme['category']),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (!isEligible)
                  const Text('Ineligible (Does not meet strict criteria)', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                else ...[
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: matchPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: matchPercentage >= 85 ? Colors.green : (matchPercentage >= 70 ? Colors.amber : Colors.orange),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '$matchPercentage% Match',
                        style: TextStyle(
                          color: matchPercentage >= 85 ? Colors.green.shade700 : (matchPercentage >= 70 ? Colors.amber.shade700 : Colors.orange.shade700),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
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
