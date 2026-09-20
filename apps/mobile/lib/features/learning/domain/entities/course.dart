import 'module.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final List<String> categories;
  final String difficulty;
  final String? thumbnailUrl;
  final List<Module> modules;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.difficulty,
    this.thumbnailUrl,
    required this.modules,
  });
}
