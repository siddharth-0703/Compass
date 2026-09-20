import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/lesson_progress.dart';

part 'lesson_progress_model.freezed.dart';
part 'lesson_progress_model.g.dart';

@freezed
class LessonProgressModel with _$LessonProgressModel {
  const factory LessonProgressModel({
    required String userId,
    required String courseId,
    required String moduleId,
    required String lessonId,
    required int positionSeconds,
    required int durationSeconds,
    required double percentage,
    required bool completed,
    required String clientUpdatedAt,
  }) = _LessonProgressModel;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressModelFromJson(json);
}

extension LessonProgressModelX on LessonProgressModel {
  LessonProgress toEntity() => LessonProgress(
        userId: userId,
        courseId: courseId,
        moduleId: moduleId,
        lessonId: lessonId,
        positionSeconds: positionSeconds,
        durationSeconds: durationSeconds,
        percentage: percentage,
        completed: completed,
        clientUpdatedAt: DateTime.parse(clientUpdatedAt),
      );
}
