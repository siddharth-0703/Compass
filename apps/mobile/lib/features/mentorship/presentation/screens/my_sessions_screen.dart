import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/mentorship_providers.dart';
import '../../domain/entities/mentorship_session.dart';

class MySessionsScreen extends ConsumerWidget {
  const MySessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(mySessionsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Sessions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: sessionsState.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(
                  child: Text("You haven't booked a mentorship session yet."),);
            }

            final upcoming = sessions
                .where(
                  (s) =>
                      s.status == MentorshipSessionStatus.requested ||
                      s.status == MentorshipSessionStatus.confirmed ||
                      s.status == MentorshipSessionStatus.rescheduleRequested,
                )
                .toList();

            final past = sessions
                .where(
                  (s) =>
                      s.status == MentorshipSessionStatus.completed ||
                      s.status == MentorshipSessionStatus.cancelled ||
                      s.status == MentorshipSessionStatus.rejected ||
                      s.status == MentorshipSessionStatus.noShow,
                )
                .toList();

            return TabBarView(
              children: [
                _buildSessionsList(context, ref, upcoming),
                _buildSessionsList(context, ref, past),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error loading sessions: $err')),
        ),
      ),
    );
  }

  Widget _buildSessionsList(
      BuildContext context, WidgetRef ref, List<MentorshipSession> list,) {
    if (list.isEmpty) {
      return const Center(child: Text('No sessions in this section.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final session = list[index];
        return _buildSessionCard(context, ref, session);
      },
    );
  }

  Widget _buildSessionCard(
      BuildContext context, WidgetRef ref, MentorshipSession session,) {
    final timeStr = session.scheduledAt.toLocal().toString().split('.')[0];
    final isUpcoming = session.status == MentorshipSessionStatus.requested ||
        session.status == MentorshipSessionStatus.confirmed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'With ${session.mentorName}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16,),
                ),
                _buildStatusBadge(session.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Scheduled: $timeStr'),
            Text('Duration: ${session.durationMinutes} minutes'),
            const SizedBox(height: 12),
            Text(
              'Goals: ${session.goals.join(', ')}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isUpcoming) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,),
                      onPressed: () => _confirmCancel(context, ref, session.id),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: session.canJoin && session.meetingLink != null
                          ? () => launchUrl(Uri.parse(session.meetingLink!))
                          : null,
                      child: const Text('Join Session'),
                    ),
                  ),
                ],
                if (session.status == MentorshipSessionStatus.completed &&
                    session.rating == null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showFeedbackDialog(context, ref, session.id),
                      child: const Text('Give Feedback'),
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

  Widget _buildStatusBadge(MentorshipSessionStatus status) {
    Color color;
    switch (status) {
      case MentorshipSessionStatus.confirmed:
        color = Colors.green;
        break;
      case MentorshipSessionStatus.requested:
        color = Colors.orange;
        break;
      case MentorshipSessionStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),),
      child: Text(status.name,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12,),),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref, String sessionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Session'),
          content: const Text(
              'Are you sure you want to cancel this mentorship session?',),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(mySessionsProvider.notifier)
                    .cancelSession(sessionId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Session cancelled successfully.'),),
                );
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(
      BuildContext context, WidgetRef ref, String sessionId,) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Your Session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1;
                      return IconButton(
                        icon: Icon(
                          starVal <= rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => setState(() => rating = starVal),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'What did you learn?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Skip'),),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref.read(mySessionsProvider.notifier).submitFeedback(
                          sessionId: sessionId,
                          rating: rating,
                          comment: commentController.text,
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Thank you for your feedback!'),),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
