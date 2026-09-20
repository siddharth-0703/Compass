import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/repositories/mentorship_repository.dart';
import '../../data/repository/mentorship_repository_impl.dart';
import '../../domain/entities/mentor_match.dart';
import '../../domain/entities/mentor_availability.dart';
import '../../domain/entities/mentorship_session.dart';

final mentorshipRepositoryProvider = Provider<MentorshipRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MentorshipRepositoryImpl(apiClient);
});

class MentorMatchingNotifier
    extends StateNotifier<AsyncValue<List<MentorMatch>>> {
  final MentorshipRepository _repo;
  final String _businessId;

  MentorMatchingNotifier(this._repo, this._businessId)
      : super(const AsyncValue.loading()) {
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getMentorMatches(_businessId);
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final mentorMatchingProvider = StateNotifierProvider.family<
    MentorMatchingNotifier,
    AsyncValue<List<MentorMatch>>,
    String>((ref, businessId) {
  final repo = ref.watch(mentorshipRepositoryProvider);
  return MentorMatchingNotifier(repo, businessId);
});

class MentorAvailabilityNotifier
    extends StateNotifier<AsyncValue<MentorAvailability>> {
  final MentorshipRepository _repo;
  final String _mentorId;
  final DateTime _date;

  MentorAvailabilityNotifier(this._repo, this._mentorId, this._date)
      : super(const AsyncValue.loading()) {
    fetchAvailability();
  }

  Future<void> fetchAvailability() async {
    state = const AsyncValue.loading();
    try {
      final availability = await _repo.getMentorAvailability(_mentorId, _date);
      state = AsyncValue.data(availability);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final mentorAvailabilityProvider = StateNotifierProvider.family<
    MentorAvailabilityNotifier,
    AsyncValue<MentorAvailability>,
    Map<String, dynamic>>((ref, params) {
  final repo = ref.watch(mentorshipRepositoryProvider);
  final mentorId = params['mentorId'] as String;
  final date = params['date'] as DateTime;
  return MentorAvailabilityNotifier(repo, mentorId, date);
});

class MySessionsNotifier
    extends StateNotifier<AsyncValue<List<MentorshipSession>>> {
  final MentorshipRepository _repo;
  MySessionsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getMySessions();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelSession(String sessionId) async {
    try {
      await _repo.cancelSession(sessionId);
      await loadSessions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> rescheduleSession({
    required String sessionId,
    required DateTime newStartTime,
    required DateTime newEndTime,
    required String timezone,
  }) async {
    try {
      await _repo.rescheduleSession(
        sessionId: sessionId,
        newStartTime: newStartTime,
        newEndTime: newEndTime,
        timezone: timezone,
      );
      await loadSessions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> submitFeedback({
    required String sessionId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _repo.submitFeedback(
        sessionId: sessionId,
        rating: rating,
        comment: comment,
      );
      await loadSessions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final mySessionsProvider = StateNotifierProvider<MySessionsNotifier,
    AsyncValue<List<MentorshipSession>>>((ref) {
  final repo = ref.watch(mentorshipRepositoryProvider);
  return MySessionsNotifier(repo);
});

class SessionBookingNotifier
    extends StateNotifier<AsyncValue<MentorshipSession?>> {
  final MentorshipRepository _repo;
  final Ref _ref;
  SessionBookingNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> bookSession({
    required String mentorId,
    required DateTime startTime,
    required DateTime endTime,
    required String timezone,
    required List<String> goals,
    required String idempotencyKey,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await _repo.bookSession(
        mentorId: mentorId,
        startTime: startTime,
        endTime: endTime,
        timezone: timezone,
        goals: goals,
        idempotencyKey: idempotencyKey,
      );
      state = AsyncValue.data(session);
      _ref.read(mySessionsProvider.notifier).loadSessions();
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final sessionBookingProvider = StateNotifierProvider<SessionBookingNotifier,
    AsyncValue<MentorshipSession?>>((ref) {
  final repo = ref.watch(mentorshipRepositoryProvider);
  return SessionBookingNotifier(repo, ref);
});

class MentorExplanationNotifier extends StateNotifier<AsyncValue<String>> {
  final MentorshipRepository _repo;
  MentorExplanationNotifier(this._repo) : super(const AsyncValue.data(''));

  Future<void> getExplanation(
      String mentorId, List<String> matchedRules, String language,) async {
    state = const AsyncValue.loading();
    try {
      final explanation =
          await _repo.getMentorExplanation(mentorId, matchedRules, language);
      state = AsyncValue.data(explanation);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final mentorExplanationProvider =
    StateNotifierProvider<MentorExplanationNotifier, AsyncValue<String>>((ref) {
  final repo = ref.watch(mentorshipRepositoryProvider);
  return MentorExplanationNotifier(repo);
});
