class MentorAvailabilitySlot {
  final DateTime start;
  final DateTime end;
  final bool available;

  const MentorAvailabilitySlot({
    required this.start,
    required this.end,
    required this.available,
  });
}

class MentorAvailability {
  final String timezone;
  final List<MentorAvailabilitySlot> slots;

  const MentorAvailability({
    required this.timezone,
    required this.slots,
  });
}
