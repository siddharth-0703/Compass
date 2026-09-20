import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/module.dart';
import 'lesson_model.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

@freezed
class ModuleModel with _$ModuleModel {
  const factory ModuleModel({
    required String id,
    required String title,
    required String description,
    required int order,
    required List<LessonModel> lessons,
  }) = _ModuleModel;

  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);
}

extension ModuleModelX on ModuleModel {
  Module toEntity() => Module(
        id: id,
        title: title,
        description: description,
        order: order,
        lessons: lessons.map((l) => l.toEntity()).toList(),
      );
}
