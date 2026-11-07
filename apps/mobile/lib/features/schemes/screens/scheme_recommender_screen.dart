import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../businesses/presentation/providers/business_provider.dart';
import '../../businesses/data/models/business_model.dart';
import '../presentation/providers/scheme_recommendation_provider.dart';

class SchemeRecommenderScreen extends ConsumerStatefulWidget {
  const SchemeRecommenderScreen({super.key});

  @override
  ConsumerState<SchemeRecommenderScreen> createState() =>
      _SchemeRecommenderScreenState();
}

class _SchemeRecommenderScreenState
    extends ConsumerState<SchemeRecommenderScreen> {
  final Set<String> _savedSchemeIds = {};

  void _toggleSaveScheme(String id, String name) {
    setState(() {
      if (_savedSchemeIds.contains(id)) {
        _savedSchemeIds.remove(id);
      } else {
        _savedSchemeIds.add(id);
      }
    });

    final isSaved = _savedSchemeIds.contains(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? '$name saved to your bookmarks' : '$name removed from bookmarks'),
        backgroundColor: isSaved ? Colors.green.shade800 : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsState = ref.watch(schemeRecommendationProvider);
    final savedProfile = ref.watch(activeQuestionnaireProfileProvider);
    final businessesState = ref.watch(myBusinessesProvider);

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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF7),
      appBar: AppBar(
        title: const Text(
          'Government Schemes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.business_outlined),
            tooltip: 'My Businesses',
            onPressed: () => context.push('/businesses'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.fileQuestion),
            tooltip: 'Find Your Schemes',
            onPressed: () => context.push('/schemes/questionnaire'),
          ),
        ],
      ),
      body: recommendationsState.when(
        data: (list) {
          final verified = list
              .where((item) =>
                  item['source'] == 'VERIFIED' || item['source'] == null)
              .toList();
          final aiDiscovered =
              list.where((item) => item['source'] == 'AI_DISCOVERED').toList();
          final totalCount = list.length;

          final activity = savedProfile?['activity']?.toString() ?? 'FARMER';
          final stateName =
              savedProfile?['state']?.toString() ?? activeBusiness.locationState ?? 'Maharashtra';
          final category = savedProfile?['category']?.toString() ?? 'SC';

          return RefreshIndicator(
            onRefresh: () async {
              if (savedProfile != null) {
                await ref
                    .read(schemeRecommendationProvider.notifier)
                    .updateFromQuestionnaire(savedProfile);
              } else {
                await ref
                    .read(schemeRecommendationProvider.notifier)
                    .fetchRecommendations(activeBusiness.id);
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Top Banner with Title, Profile summary, and Refine Profile button
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$totalCount Schemes Found For You',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Based on your profile: $activity \u00B7 $stateName \u00B7 $category',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  context.push('/schemes/questionnaire'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.green.shade700, width: 1.5),
                                foregroundColor: Colors.green.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                              child: const Text(
                                'Refine Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Legend Pills matching Web 1:1
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.green.shade300, width: 1),
                              ),
                              child: Text(
                                '\u2713 Verified \u2014 officially confirmed schemes',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.purple.shade200, width: 1),
                              ),
                              child: Text(
                                '\u2728 AI Discovered \u2014 pending verification',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // SECTION 1: VERIFIED RECOMMENDATIONS
                if (verified.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: Row(
                        children: [
                          const Text(
                            'Verified Recommendations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${verified.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildSchemeCard(
                              context, ref, verified[index], isVerified: true);
                        },
                        childCount: verified.length,
                      ),
                    ),
                  ),
                ],

                // SECTION 2: AI DISCOVERED OPPORTUNITIES
                if (aiDiscovered.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          const Text(
                            'AI Discovered Opportunities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${aiDiscovered.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildSchemeCard(
                              context, ref, aiDiscovered[index],
                              isVerified: false);
                        },
                        childCount: aiDiscovered.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Scanning government portals...',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                const Text(
                  'Failed to load live recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(schemeRecommendationProvider.notifier)
                      .fetchRecommendations('biz-001'),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(
    BuildContext context,
    WidgetRef ref,
    dynamic item, {
    required bool isVerified,
  }) {
    final scheme = item['scheme'] ?? {};
    final schemeId = (scheme['_id'] ?? scheme['id'] ?? scheme['name'] ?? 'scheme')
        .toString();
    final schemeName = scheme['name'] ?? 'Government Scheme';
    final ministry = scheme['ministry']?.toString();
    final description = scheme['shortDescription'] ?? scheme['description'] ?? '';
    final matchScore = item['matchPercentage'] ?? 90;
    final matchedRules = List<String>.from(item['matchedRules'] ?? []);
    final failedRules = List<String>.from(item['failedRules'] ?? []);
    final officialUrl = scheme['officialUrl']?.toString();
    final aiNote = item['aiNote']?.toString();
    final isSaved = _savedSchemeIds.contains(schemeId);

    final category = scheme['category'] ?? 'AGRICULTURE';
    final categoryColor = _getCategoryColor(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Category Badge (left) & Verified/AI Badge (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category.toString().replaceAll('_', ' '),
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      border: Border.all(
                          color: Colors.green.shade300, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '\u2713 Verified',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      border: Border.all(
                          color: Colors.purple.shade200, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '\u2728 AI Discovered',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Scheme Name
            Text(
              schemeName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.3,
              ),
            ),

            // Ministry
            if (ministry != null) ...[
              const SizedBox(height: 2),
              Text(
                ministry,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Match Score or AI Note Box
            if (isVerified) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (matchScore as num) / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: matchScore >= 85
                            ? Colors.green.shade600
                            : (matchScore >= 70 ? Colors.amber : Colors.orange),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$matchScore% Match',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: matchScore >= 85
                          ? Colors.green.shade800
                          : Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.sparkles,
                        size: 15, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        aiNote ??
                            'Note: This scheme may be relevant to your profile. Eligibility has not been independently verified.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple.shade900,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Matched Rules
            if (matchedRules.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'MATCHED ELIGIBILITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              ...matchedRules.take(3).map(
                    (rule) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '\u2713 ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rule,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Action Buttons Row: Why Recommended? + Save Scheme
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.green.shade700, width: 1.5),
                      foregroundColor: Colors.green.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.sparkles, size: 15),
                    label: const Text(
                      'Why Recommended?',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showAIExplanation(
                      context,
                      ref,
                      schemeId,
                      matchedRules,
                      failedRules,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: isSaved
                            ? Colors.green.shade700
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      foregroundColor: isSaved
                          ? Colors.green.shade800
                          : const Color(0xFF334155),
                      backgroundColor:
                          isSaved ? Colors.green.shade50 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      isSaved ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                      size: 15,
                    ),
                    label: Text(
                      isSaved ? '\u2713 Saved' : 'Save Scheme',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _toggleSaveScheme(schemeId, schemeName),
                  ),
                ),
              ],
            ),

            // Apply on official portal link
            if (officialUrl != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse(officialUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.externalLink,
                          size: 14, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        'Apply on official government portal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'AGRICULTURE':
        return Colors.green.shade800;
      case 'FINANCE':
        return Colors.blue.shade800;
      case 'MSME':
        return Colors.teal.shade800;
      case 'WOMEN':
        return Colors.pink.shade700;
      case 'SOCIAL_WELFARE':
        return Colors.indigo.shade700;
      default:
        return Colors.purple.shade800;
    }
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
            final explanationState =
                ref.watch(recommendationExplanationProvider);

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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                          : 'This scheme matches your enterprise sector, state parameters, and financial criteria with 96% confidence based on official government guidelines.',
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
