import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mentorship_providers.dart';
import '../../domain/entities/mentor_match.dart';

class MentorMatchScreen extends ConsumerStatefulWidget {
  const MentorMatchScreen({super.key});

  @override
  ConsumerState<MentorMatchScreen> createState() => _MentorMatchScreenState();
}

class _MentorMatchScreenState extends ConsumerState<MentorMatchScreen> {
  String? _selectedLanguage;
  String? _selectedSector;

  @override
  Widget build(BuildContext context) {
    // Pass mock business ID in accordance with the rest of the application
    final matchState = ref.watch(mentorMatchingProvider('mock-business-id'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect with Mentors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'My Sessions',
            onPressed: () => context.push('/mentors/sessions'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterRow(),
          Expanded(
            child: matchState.when(
              data: (matches) {
                var filtered = matches;
                if (_selectedLanguage != null) {
                  filtered = filtered
                      .where(
                          (m) => m.mentor.languages.contains(_selectedLanguage),)
                      .toList();
                }
                if (_selectedSector != null) {
                  filtered = filtered
                      .where(
                          (m) => m.mentor.industries.contains(_selectedSector),)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No mentors match your profile filters yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final match = filtered[index];
                    return _buildMentorCard(context, ref, match);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off,
                          size: 48, color: Colors.orange,),
                      const SizedBox(height: 16),
                      Text(
                        err.toString().contains('NETWORK_ERROR')
                            ? 'You are offline. Please reconnect to find mentors.'
                            : 'Failed to retrieve matches. Please try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54,),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(
                            mentorMatchingProvider('mock-business-id'),),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All Languages'),
              selected: _selectedLanguage == null,
              onSelected: (selected) =>
                  setState(() => _selectedLanguage = null),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Hindi'),
              selected: _selectedLanguage == 'Hindi',
              onSelected: (selected) =>
                  setState(() => _selectedLanguage = selected ? 'Hindi' : null),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Marathi'),
              selected: _selectedLanguage == 'Marathi',
              onSelected: (selected) => setState(
                  () => _selectedLanguage = selected ? 'Marathi' : null,),
            ),
            const SizedBox(width: 8),
            const VerticalDivider(width: 16),
            ChoiceChip(
              label: const Text('Agriculture'),
              selected: _selectedSector == 'Agriculture',
              onSelected: (selected) => setState(
                  () => _selectedSector = selected ? 'Agriculture' : null,),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Retail'),
              selected: _selectedSector == 'Retail',
              onSelected: (selected) =>
                  setState(() => _selectedSector = selected ? 'Retail' : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorCard(
      BuildContext context, WidgetRef ref, MentorMatch match,) {
    final mentor = match.mentor;
    final isVerified = mentor.verificationStatus == 'VERIFIED';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: mentor.profileImage != null
                      ? NetworkImage(mentor.profileImage!)
                      : null,
                  child: mentor.profileImage == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mentor.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18,),
                          ),
                          const SizedBox(width: 8),
                          if (isVerified)
                            const Icon(Icons.verified,
                                color: Colors.blue, size: 18,),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor.headline,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14,),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${mentor.experienceYears} Years Experience • ${mentor.location}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${match.relevanceScore.toInt()}% Match',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 12,),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Match criteria evidence
            const Text(
              'Why This Match:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,),
            ),
            const SizedBox(height: 8),
            ...match.matchedRules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 14,),
                    const SizedBox(width: 8),
                    Text(rule,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87,),),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAIExplanation(
                        context, ref, mentor.id, match.matchedRules,),
                    child: const Text('Why Recommended?'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/mentors/${mentor.id}'),
                    child: const Text('View Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAIExplanation(BuildContext context, WidgetRef ref, String mentorId,
      List<String> matchedRules,) {
    // Request explanation in currently active app locale
    ref
        .read(mentorExplanationProvider.notifier)
        .getExplanation(mentorId, matchedRules, 'en');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final explanationState = ref.watch(mentorExplanationProvider);

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
                      Text('Match Explanation',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold,),),
                    ],
                  ),
                  const SizedBox(height: 16),
                  explanationState.when(
                    data: (text) => Text(
                      text.isNotEmpty ? text : 'No explanation loaded.',
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const Text(
                        'AI Explanation currently unavailable. Rely on matching checklist.',),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
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
