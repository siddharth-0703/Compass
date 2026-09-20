import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/mentor_profile.dart';

part 'mentor_profile_model.freezed.dart';
part 'mentor_profile_model.g.dart';

@freezed
class MentorProfileModel with _$MentorProfileModel {
  const factory MentorProfileModel({
    required String id,
    required String userId,
    required String name,
    String? profileImage,
    required String headline,
    required String bio,
    required String verificationStatus,
    required String accountStatus,
    required List<String> industries,
    required List<String> expertise,
    required int experienceYears,
    required List<String> languages,
    required double rating,
    required int completedSessions,
    required String location,
    required String timezone,
  }) = _MentorProfileModel;

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$MentorProfileModelFromJson(json);

  const MentorProfileModel._();

  MentorProfile toEntity() {
    return MentorProfile(
      id: id,
      userId: userId,
      name: name,
      profileImage: profileImage,
      headline: headline,
      bio: bio,
      verificationStatus: verificationStatus,
      accountStatus: accountStatus,
      industries: industries,
      expertise: expertise,
      experienceYears: experienceYears,
      languages: languages,
      rating: rating,
      completedSessions: completedSessions,
      location: location,
      timezone: timezone,
    );
  }
}
