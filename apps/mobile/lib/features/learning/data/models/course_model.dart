import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/course.dart';
import 'module_model.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

@freezed
class CourseModel with _$CourseModel {
  const factory CourseModel({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String description,
    required List<String> categories,
    required String difficulty,
    String? thumbnailUrl,
    required List<ModuleModel> modules,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

extension CourseModelX on CourseModel {
  Course toEntity() => Course(
        id: id,
        title: title,
        description: description,
        categories: categories,
        difficulty: difficulty,
        thumbnailUrl: thumbnailUrl,
        modules: modules.map((m) => m.toEntity()).toList(),
      );
}
