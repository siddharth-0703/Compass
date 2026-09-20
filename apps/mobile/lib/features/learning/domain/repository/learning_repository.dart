import '../entities/course.dart';
import '../entities/lesson_progress.dart';

abstract class LearningRepository {
  Future<List<Course>> getAllResources();
  Future<Course?> getResourceById(String id);
  Future<List<LessonProgress>> getCourseProgress(String courseId);
  Future<void> updateLessonProgress(LessonProgress progress);
  Future<void> enrollInCourse(String courseId);
  Future<void> toggleFavorite(String courseId);
  Future<List<String>> getFavorites();
}
