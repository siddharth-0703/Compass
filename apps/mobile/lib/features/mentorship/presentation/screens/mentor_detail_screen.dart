import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../providers/mentorship_providers.dart';
import '../../domain/entities/mentor_profile.dart';
import '../../domain/entities/mentor_availability.dart';

class MentorDetailScreen extends ConsumerStatefulWidget {
  final String mentorId;
  const MentorDetailScreen({super.key, required this.mentorId});

  @override
  ConsumerState<MentorDetailScreen> createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends ConsumerState<MentorDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  MentorAvailabilitySlot? _selectedSlot;
  final _goalsController = TextEditingController();

  @override
  void dispose() {
    _goalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(mentorshipRepositoryProvider);

    // FutureProvider matching standard clean architecture patterns
    final mentorDetailsFuture = ref.watch(
      Provider.autoDispose.family<Future<MentorProfile>, String>((ref, id) {
        return repo.getMentorDetails(id);
      })(widget.mentorId),
    );

    // Dynamic slot params family map
    final availabilityParams = {
      'mentorId': widget.mentorId,
      'date': _selectedDate,
    };
    final availabilityState =
        ref.watch(mentorAvailabilityProvider(availabilityParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Profile'),
      ),
      body: FutureBuilder<MentorProfile>(
        future: mentorDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load profile details.'));
          }

          final mentor = snapshot.data!;
          final isVerified = mentor.verificationStatus == 'VERIFIED';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildProfileHeader(mentor, isVerified),
                    const SizedBox(height: 24),
                    const Text('Biography',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16,),),
                    const SizedBox(height: 8),
                    Text(mentor.bio,
                        style: const TextStyle(
                            color: Colors.black87, height: 1.4,),),
                    const SizedBox(height: 24),
                    const Text('Select Date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16,),),
                    const SizedBox(height: 12),
                    _buildDatePickerButton(context),
                    const SizedBox(height: 24),
                    Text(
                      'Available Slots (${mentor.timezone})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,),
                    ),
                    const SizedBox(height: 12),
                    _buildAvailabilityGrid(availabilityState),
                  ],
                ),
              ),
              _buildBookingDock(mentor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(MentorProfile mentor, bool isVerified) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: mentor.profileImage != null
              ? NetworkImage(mentor.profileImage!)
              : null,
          child: mentor.profileImage == null
              ? const Icon(Icons.person, size: 36)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(mentor.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,),),
                  const SizedBox(width: 8),
                  if (isVerified)
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(mentor.headline,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                      '${mentor.rating} (${mentor.completedSessions} sessions)',
                      style: const TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
            _selectedSlot = null; // Reset selection
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.calendar_today, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityGrid(
      AsyncValue<MentorAvailability> availabilityState,) {
    return availabilityState.when(
      data: (availability) {
        if (availability.slots.isEmpty) {
          return const Center(
              child: Text('This mentor currently has no available sessions.'),);
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availability.slots.map((slot) {
            final startLocal = slot.start.toLocal();
            final timeStr =
                '${startLocal.hour.toString().padLeft(2, '0')}:${startLocal.minute.toString().padLeft(2, '0')}';
            final isSelected = _selectedSlot == slot;

            return ChoiceChip(
              label: Text(timeStr),
              selected: isSelected,
              onSelected: slot.available
                  ? (selected) {
                      setState(() {
                        _selectedSlot = selected ? slot : null;
                      });
                    }
                  : null,
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          const Text('Connect to the internet to view availability.'),
    );
  }

  Widget _buildBookingDock(MentorProfile mentor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),),
              ),
              onPressed: _selectedSlot != null
                  ? () => _promptGoalsAndConfirm(mentor)
                  : null,
              child: const Text('Book Session',
                  style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
    );
  }

  void _promptGoalsAndConfirm(MentorProfile mentor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mentor: ${mentor.name}'),
              Text(
                  'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',),
              Text(
                  'Time: ${_selectedSlot!.start.toLocal().toString().split(' ')[1].substring(0, 5)}',),
              const SizedBox(height: 16),
              TextField(
                controller: _goalsController,
                decoration: const InputDecoration(
                  labelText: 'Session Goals',
                  hintText: 'What do you want to learn?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                // Idempotency Key mapping double-tap prevention rules
                final key = const Uuid().v4();

                final success =
                    await ref.read(sessionBookingProvider.notifier).bookSession(
                          mentorId: mentor.id,
                          startTime: _selectedSlot!.start,
                          endTime: _selectedSlot!.end,
                          timezone: mentor.timezone,
                          goals: [_goalsController.text],
                          idempotencyKey: key,
                        );

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Session booked successfully!'),),
                  );
                  context.pop();
                } else {
                  final error =
                      ref.read(sessionBookingProvider).error.toString();
                  if (error.contains('SLOT_ALREADY_BOOKED')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "This time slot was just booked by another user. We've refreshed the available times.",),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    // Refresh slots immediately
                    ref.invalidate(mentorAvailabilityProvider({
                      'mentorId': widget.mentorId,
                      'date': _selectedDate,
                    }),);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Failed to book session. Please try again.',),),
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
