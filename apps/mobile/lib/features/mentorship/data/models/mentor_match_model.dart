import 'package:freezed_annotation/freezed_annotation.dart';
import 'mentor_profile_model.dart';
import '../../domain/entities/mentor_match.dart';

part 'mentor_match_model.freezed.dart';
part 'mentor_match_model.g.dart';

@freezed
class MentorMatchModel with _$MentorMatchModel {
  const factory MentorMatchModel({
    required MentorProfileModel mentor,
    required double relevanceScore,
    required List<String> matchedRules,
    required List<String> unmatchedRules,
  }) = _MentorMatchModel;

  factory MentorMatchModel.fromJson(Map<String, dynamic> json) =>
      _$MentorMatchModelFromJson(json);

  const MentorMatchModel._();

  MentorMatch toEntity() {
    return MentorMatch(
      mentor: mentor.toEntity(),
      relevanceScore: relevanceScore,
      matchedRules: matchedRules,
      unmatchedRules: unmatchedRules,
    );
  }
}
