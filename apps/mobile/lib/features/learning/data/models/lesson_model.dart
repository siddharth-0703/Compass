import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/lesson.dart';
import 'localized_media_model.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    required String title,
    required String description,
    required int durationSeconds,
    LocalizedMediaModel? media,
    @Default([]) List<String> resources,
    required int order,
    required bool isPublished,
    required String contentStatus,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}

extension LessonModelX on LessonModel {
  Lesson toEntity() => Lesson(
        id: id,
        title: title,
        description: description,
        durationSeconds: durationSeconds,
        media: media?.toEntity(),
        resources: resources,
        order: order,
        isPublished: isPublished,
        contentStatus: contentStatus,
      );
}
