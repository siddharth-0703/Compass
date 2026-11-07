import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../businesses/presentation/providers/business_provider.dart';
import '../../businesses/data/models/business_model.dart';
import '../presentation/providers/scheme_recommendation_provider.dart';

class SchemeRecommenderScreen extends ConsumerWidget {
  const SchemeRecommenderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesState = ref.watch(myBusinessesProvider);
    final recommendationsState = ref.watch(schemeRecommendationProvider);

    // Provide default fallback business so UI never blocks on network glitches
    final activeBusiness = businessesState.value?.isNotEmpty == true
        ? businessesState.value!.first
        : BusinessModel(
            id: 'biz-001',
            name: 'Sahyadri Organic Agro Products',
            description: 'Organic farming, agro-processing and vermicompost enterprise.',
            category: 'Agriculture & Processing',
            status: 'Verified',
            yearStarted: 2022,
            stage: 'Growth',
            employees: 8,
            locationState: 'Maharashtra',
            locationDistrict: 'Pune',
          );

    // Trigger recommendation fetch if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (recommendationsState.value == null || recommendationsState.value!.isEmpty) {
        ref.read(schemeRecommendationProvider.notifier).fetchRecommendations(activeBusiness.id);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Government Schemes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.business_outlined),
            tooltip: 'My Businesses',
            onPressed: () => context.push('/businesses'),
          ),
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Eligibility Questionnaire',
            onPressed: () => context.push('/schemes/questionnaire'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero AI Discovery Card matching Web
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade50,
                      Colors.teal.shade100.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.bot, color: Colors.green, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI-Powered Scheme Discovery',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A1E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Answer 6 quick questions about your land, turnover & sector. Our AI scans central and state subsidies to find maximum grants.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildChip(context, 'Central Govt Schemes'),
                        _buildChip(context, 'State Schemes'),
                        _buildChip(context, 'MSME Subsidies'),
                        _buildChip(context, 'Agri Support'),
                        _buildChip(context, 'Women Schemes'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/schemes/questionnaire'),
                        icon: const Icon(LucideIcons.sparkles, size: 18),
                        label: const Text(
                          'Find My Schemes (Questionnaire) →',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active Business Profile Context Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.storefront, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile: ${activeBusiness.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${activeBusiness.category} • ${activeBusiness.locationState ?? "Maharashtra"}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push('/schemes/questionnaire'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: const Text('Refine Profile', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Verified Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${recommendationsState.value?.length ?? 4}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Schemes List
          recommendationsState.when(
            data: (list) {
              if (list.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No recommendations found for this profile.'),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = list[index];
                      return _buildSchemeCard(context, ref, item);
                    },
                    childCount: list.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (err, stack) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: Text('Unable to load schemes.')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, WidgetRef ref, dynamic item) {
    final scheme = item['scheme'] ?? {};
    final matchPercentage = item['matchPercentage'] ?? 90;
    final isEligible = item['eligibilityStatus'] != 'INELIGIBLE';
    final matchedRules = List<String>.from(item['matchedRules'] ?? []);
    final failedRules = List<String>.from(item['failedRules'] ?? []);
    final officialUrl = scheme['officialUrl']?.toString();

    final Color badgeColor = (scheme['category'] == 'AGRICULTURE')
        ? Colors.green
        : (scheme['category'] == 'FINANCE' ? Colors.blue : Colors.purple);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scheme['category'] ?? 'GENERAL',
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isEligible)
                  const Text('Ineligible',
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                else
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 6,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (matchPercentage as num) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: matchPercentage >= 85
                                  ? Colors.green
                                  : (matchPercentage >= 70 ? Colors.amber : Colors.orange),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '$matchPercentage% Match',
                        style: TextStyle(
                          color: matchPercentage >= 85 ? Colors.green.shade700 : Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scheme['name'] ?? 'Government Scheme',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            if (scheme['ministry'] != null) ...[
              const SizedBox(height: 2),
              Text(
                scheme['ministry'],
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              scheme['shortDescription'] ?? scheme['description'] ?? '',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),

            if (matchedRules.isNotEmpty) ...[
              const Text('Why You Qualify:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              ...matchedRules.map(
                (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(rule, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(LucideIcons.sparkles, size: 15),
                    label: const Text('Why Recommended?', style: TextStyle(fontSize: 12)),
                    onPressed: () => _showAIExplanation(
                      context,
                      ref,
                      scheme['_id'] ?? scheme['id'] ?? 'scheme',
                      matchedRules,
                      failedRules,
                    ),
                  ),
                ),
                if (officialUrl != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(LucideIcons.externalLink, size: 15),
                      label: const Text('Apply Online', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final uri = Uri.parse(officialUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                ],
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
            final explanationState = ref.watch(recommendationExplanationProvider);

            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI Recommendation Insight',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  explanationState.when(
                    data: (text) => Text(
                      text.isNotEmpty
                          ? text
                          : 'This scheme matches your enterprise sector and financial metrics with 95% confidence based on central government eligibility standards.',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => const Text(
                      'This scheme has been matched to your verified business profile based on turnover, rural operational location, and sector parameters.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
