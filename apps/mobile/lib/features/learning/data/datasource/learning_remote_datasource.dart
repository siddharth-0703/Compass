import '../models/course_model.dart';
import '../../../../core/api/api_client.dart';

class LearningRemoteDataSource {
  final ApiClient _apiClient;

  LearningRemoteDataSource(this._apiClient);

  Future<List<CourseModel>> getAllResources() async {
    final response = await _apiClient.dio.get('/learning/resources');
    final data = response.data['data'] as List;
    return data.map((json) => CourseModel.fromJson(json)).toList();
  }

  Future<void> updateProgress({
    required String courseId,
    required String moduleId,
    required String lessonId,
    required int positionSeconds,
    required int durationSeconds,
    required double percentage,
    required bool completed,
    required DateTime clientUpdatedAt,
  }) async {
    await _apiClient.dio.patch('/learning/progress', data: {
      'courseId': courseId,
      'moduleId': moduleId,
      'lessonId': lessonId,
      'positionSeconds': positionSeconds,
      'durationSeconds': durationSeconds,
      'percentage': percentage.toInt(),
      'completed': completed,
      'clientUpdatedAt': clientUpdatedAt.toIso8601String(),
    },);
  }

  Future<Map<String, dynamic>> getCourseProgress(String courseId) async {
    final response =
        await _apiClient.dio.get('/learning/courses/$courseId/progress');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> enroll(String courseId) async {
    await _apiClient.dio.post('/learning/enroll', data: {
      'courseId': courseId,
    },);
  }
}
