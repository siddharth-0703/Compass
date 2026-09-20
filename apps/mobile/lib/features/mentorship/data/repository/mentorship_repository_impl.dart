import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/repositories/mentorship_repository.dart';
import '../../domain/entities/mentor_profile.dart';
import '../../domain/entities/mentor_availability.dart';
import '../../domain/entities/mentorship_session.dart';
import '../../domain/entities/mentor_match.dart';
import '../models/mentor_profile_model.dart';
import '../models/mentor_availability_model.dart';
import '../models/mentorship_session_model.dart';
import '../models/mentor_match_model.dart';

class MentorshipRepositoryImpl implements MentorshipRepository {
  final ApiClient _apiClient;

  MentorshipRepositoryImpl(this._apiClient);

  @override
  Future<List<MentorMatch>> getMentorMatches(String businessId) async {
    try {
      final response = await _apiClient.dio.post(
        '/mentorship/match',
        data: {'businessId': businessId},
      );
      if (response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list
            .map((item) => MentorMatchModel.fromJson(item).toEntity())
            .toList();
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
    return [];
  }

  @override
  Future<MentorProfile> getMentorDetails(String mentorId) async {
    try {
      final response =
          await _apiClient.dio.get('/mentorship/mentors/$mentorId');
      if (response.data != null && response.data['success'] == true) {
        return MentorProfileModel.fromJson(response.data['data']).toEntity();
      }
      throw Exception('Failed to load mentor details');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<MentorAvailability> getMentorAvailability(
      String mentorId, DateTime date,) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _apiClient.dio.get(
        '/mentorship/mentors/$mentorId/availability',
        queryParameters: {'date': dateStr},
      );
      if (response.data != null && response.data['success'] == true) {
        return MentorAvailabilityModel.fromJson(response.data['data'])
            .toEntity();
      }
      throw Exception('Failed to load availability');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<MentorshipSession> bookSession({
    required String mentorId,
    required DateTime startTime,
    required DateTime endTime,
    required String timezone,
    required List<String> goals,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/mentorship/sessions',
        data: {
          'mentorId': mentorId,
          'scheduledAt': startTime.toUtc().toIso8601String(),
          'durationMinutes': endTime.difference(startTime).inMinutes,
          'timezone': timezone,
          'goals': goals,
          'idempotencyKey': idempotencyKey,
        },
      );
      if (response.data != null && response.data['success'] == true) {
        return MentorshipSessionModel.fromJson(response.data['data'])
            .toEntity();
      }
      throw Exception('Failed to book session');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<MentorshipSession>> getMySessions() async {
    try {
      final response = await _apiClient.dio.get('/mentorship/sessions');
      if (response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List;
        return list
            .map((item) => MentorshipSessionModel.fromJson(item).toEntity())
            .toList();
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
    return [];
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    try {
      await _apiClient.dio.post('/mentorship/sessions/$sessionId/cancel');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> rescheduleSession({
    required String sessionId,
    required DateTime newStartTime,
    required DateTime newEndTime,
    required String timezone,
  }) async {
    try {
      await _apiClient.dio.post(
        '/mentorship/sessions/$sessionId/reschedule',
        data: {
          'newStartTime': newStartTime.toUtc().toIso8601String(),
          'newEndTime': newEndTime.toUtc().toIso8601String(),
          'timezone': timezone,
        },
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> submitFeedback({
    required String sessionId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _apiClient.dio.post(
        '/mentorship/sessions/$sessionId/feedback',
        data: {
          'rating': rating,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<String> getMentorExplanation(
      String mentorId, List<String> matchedRules, String language,) async {
    try {
      final response = await _apiClient.dio.post(
        '/mentorship/matches/$mentorId/explain',
        data: {
          'matchedRules': matchedRules,
          'language': language,
        },
      );
      if (response.data != null && response.data['success'] == true) {
        return response.data['data']['explanation'] as String;
      }
      throw Exception('Failed to get match explanation');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.response != null) {
      final code = e.response!.data?['error']?['code'];
      final message =
          e.response!.data?['error']?['message'] ?? 'An error occurred';

      if (e.response!.statusCode == 409 || code == 'CONFLICT') {
        return Exception('SLOT_ALREADY_BOOKED: $message');
      } else if (e.response!.statusCode == 401) {
        return Exception('UNAUTHORIZED: $message');
      } else if (e.response!.statusCode == 403) {
        return Exception('FORBIDDEN: $message');
      } else if (e.response!.statusCode == 404) {
        return Exception('NOT_FOUND: $message');
      }
    }
    return Exception('NETWORK_ERROR: ${e.message}');
  }
}
