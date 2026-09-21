import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Connect with Mentors', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays),
            tooltip: 'My Sessions',
            onPressed: () => context.push('/mentors/sessions'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Demo Banner matching web MentorshipDashboard.tsx
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.info, color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Mode',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The mentor profiles shown here are fictional examples used to demonstrate the Compass mentorship experience.',
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Filter section
          _buildFilterRow(),
          const SizedBox(height: 8),
          
          Expanded(
            child: matchState.when(
              data: (matches) {
                var filtered = matches;
                if (_selectedLanguage != null) {
                  filtered = filtered.where((m) => m.mentor.languages.contains(_selectedLanguage)).toList();
                }
                if (_selectedSector != null) {
                  filtered = filtered.where((m) => m.mentor.industries.contains(_selectedSector)).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No mentors found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Try changing your search or filters.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      const Icon(LucideIcons.wifiOff, size: 48, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        err.toString().contains('NETWORK_ERROR')
                            ? 'You are offline. Please reconnect to find mentors.'
                            : 'Failed to retrieve matches. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(mentorMatchingProvider('mock-business-id')),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All Languages'),
              selected: _selectedLanguage == null,
              onSelected: (selected) => setState(() => _selectedLanguage = null),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Hindi'),
              selected: _selectedLanguage == 'Hindi',
              onSelected: (selected) => setState(() => _selectedLanguage = selected ? 'Hindi' : null),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Marathi'),
              selected: _selectedLanguage == 'Marathi',
              onSelected: (selected) => setState(() => _selectedLanguage = selected ? 'Marathi' : null),
            ),
            const SizedBox(width: 8),
            const VerticalDivider(width: 16),
            ChoiceChip(
              label: const Text('Agriculture'),
              selected: _selectedSector == 'Agriculture',
              onSelected: (selected) => setState(() => _selectedSector = selected ? 'Agriculture' : null),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Retail'),
              selected: _selectedSector == 'Retail',
              onSelected: (selected) => setState(() => _selectedSector = selected ? 'Retail' : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorCard(BuildContext context, WidgetRef ref, MentorMatch match) {
    final mentor = match.mentor;
    
    // Helper to extract initials
    String getInitials(String name) {
      return name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join('').substring(0, 2).toUpperCase();
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    getInitials(mentor.name),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor.headline,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${match.relevanceScore.toInt()}% Match',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              mentor.bio,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Text(
                      '${mentor.experienceYears} years experience',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Text(
                      mentor.location,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.globe, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Text(
                      mentor.languages.join(', '),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Available',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Logic to request mentorship
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                  ),
                  child: const Text('Request Mentorship'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // Navigate to detail screen
                  },
                  child: const Text('View Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
