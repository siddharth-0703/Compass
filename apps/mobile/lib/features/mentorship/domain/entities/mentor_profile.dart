class MentorProfile {
  final String id;
  final String userId;
  final String name;
  final String? profileImage;
  final String headline;
  final String bio;
  final String
      verificationStatus; // 'UNVERIFIED', 'PENDING', 'VERIFIED', 'SUSPENDED'
  final String accountStatus; // 'ACTIVE', 'INACTIVE', 'SUSPENDED'
  final List<String> industries;
  final List<String> expertise;
  final int experienceYears;
  final List<String> languages;
  final double rating;
  final int completedSessions;
  final String location;
  final String timezone;

  const MentorProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.profileImage,
    required this.headline,
    required this.bio,
    required this.verificationStatus,
    required this.accountStatus,
    required this.industries,
    required this.expertise,
    required this.experienceYears,
    required this.languages,
    required this.rating,
    required this.completedSessions,
    required this.location,
    required this.timezone,
  });
}
