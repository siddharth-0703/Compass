import '../../domain/repository/learning_repository.dart';
import '../datasource/learning_remote_datasource.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson_progress.dart';
import '../models/course_model.dart';
import '../models/lesson_progress_model.dart';
import '../../../../core/storage/hive_storage.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningRemoteDataSource _remoteDataSource;

  LearningRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Course>> getAllResources() async {
    final models = await _remoteDataSource.getAllResources();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Course?> getResourceById(String id) async {
    final resources = await getAllResources();
    try {
      return resources.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LessonProgress>> getCourseProgress(String courseId) async {
    try {
      final data = await _remoteDataSource.getCourseProgress(courseId);
      final list = data['lessonProgressList'] as List;
      final parsed = list
          .map((json) => LessonProgressModel.fromJson(json).toEntity())
          .toList();

      final box = HiveStorage.courseProgressBox;
      await box.put('progress_list_$courseId', list);

      return parsed;
    } catch (e) {
      final box = HiveStorage.courseProgressBox;
      final cached = box.get('progress_list_$courseId') as List?;
      if (cached != null) {
        return cached
            .map((json) =>
                LessonProgressModel.fromJson(Map<String, dynamic>.from(json))
                    .toEntity(),)
            .toList();
      }
      return [];
    }
  }

  @override
  Future<void> updateLessonProgress(LessonProgress progress) async {
    final box = HiveStorage.courseProgressBox;
    final cacheKey = 'progress_list_${progress.courseId}';
    final cachedList = box.get(cacheKey) as List? ?? [];

    final model = LessonProgressModel(
      userId: progress.userId,
      courseId: progress.courseId,
      moduleId: progress.moduleId,
      lessonId: progress.lessonId,
      positionSeconds: progress.positionSeconds,
      durationSeconds: progress.durationSeconds,
      percentage: progress.percentage,
      completed: progress.completed,
      clientUpdatedAt: progress.clientUpdatedAt.toIso8601String(),
    );

    final list = List<Map<String, dynamic>>.from(
        cachedList.map((item) => Map<String, dynamic>.from(item)),);
    final index =
        list.indexWhere((item) => item['lessonId'] == progress.lessonId);

    if (index >= 0) {
      final currentPercentage = list[index]['percentage'] as num;
      if (progress.percentage > currentPercentage) {
        list[index] = model.toJson();
      }
    } else {
      list.add(model.toJson());
    }

    await box.put(cacheKey, list);

    try {
      await _remoteDataSource.updateProgress(
        courseId: progress.courseId,
        moduleId: progress.moduleId,
        lessonId: progress.lessonId,
        positionSeconds: progress.positionSeconds,
        durationSeconds: progress.durationSeconds,
        percentage: progress.percentage,
        completed: progress.completed,
        clientUpdatedAt: progress.clientUpdatedAt,
      );
    } catch (e) {
      // Fails silently for optimistic offline support
    }
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    await _remoteDataSource.enroll(courseId);
  }

  @override
  Future<void> toggleFavorite(String courseId) async {
    final box = HiveStorage.favoritesBox;
    final isFavorite = box.get(courseId) ?? false;
    if (isFavorite) {
      await box.delete(courseId);
    } else {
      await box.put(courseId, true);
    }
  }

  @override
  Future<List<String>> getFavorites() async {
    final box = HiveStorage.favoritesBox;
    return box.keys.cast<String>().toList();
  }
}
