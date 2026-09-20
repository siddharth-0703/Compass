import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/learning_repository.dart';
import '../../data/repository/learning_repository_impl.dart';
import '../../data/datasource/learning_remote_datasource.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

// DI
final learningRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LearningRemoteDataSource(apiClient);
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  final remoteDataSource = ref.watch(learningRemoteDataSourceProvider);
  return LearningRepositoryImpl(remoteDataSource);
});

class LearningState {
  final bool isLoading;
  final List<Course> resources;
  final List<String> favorites;
  final String? error;

  LearningState({
    this.isLoading = false,
    this.resources = const [],
    this.favorites = const [],
    this.error,
  });

  LearningState copyWith({
    bool? isLoading,
    List<Course>? resources,
    List<String>? favorites,
    String? error,
    bool clearError = false,
  }) {
    return LearningState(
      isLoading: isLoading ?? this.isLoading,
      resources: resources ?? this.resources,
      favorites: favorites ?? this.favorites,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LearningNotifier extends StateNotifier<LearningState> {
  final LearningRepository _repository;
  final Ref _ref;

  LearningNotifier(this._repository, this._ref) : super(LearningState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resources = await _repository.getAllResources();
      final favorites = await _repository.getFavorites();
      state = state.copyWith(
        isLoading: false,
        resources: resources,
        favorites: favorites,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFavorite(String courseId) async {
    try {
      await _repository.toggleFavorite(courseId);
      final favorites = await _repository.getFavorites();
      state = state.copyWith(favorites: favorites);
    } catch (e) {
      // Ignored for UI optimism
    }
  }

  Future<void> enroll(String courseId) async {
    try {
      await _repository.enrollInCourse(courseId);
      _ref.invalidate(courseProgressProvider(courseId));
    } catch (e) {
      // Ignored
    }
  }

  Future<void> updateLessonProgress({
    required String courseId,
    required String moduleId,
    required String lessonId,
    required int positionSeconds,
    required int durationSeconds,
    required double percentage,
    required bool completed,
  }) async {
    final userId = _ref.read(authNotifierProvider).user?.id ?? 'local-user';
    final progress = LessonProgress(
      userId: userId,
      courseId: courseId,
      moduleId: moduleId,
      lessonId: lessonId,
      positionSeconds: positionSeconds,
      durationSeconds: durationSeconds,
      percentage: percentage,
      completed: completed,
      clientUpdatedAt: DateTime.now(),
    );

    await _repository.updateLessonProgress(progress);
    _ref.invalidate(courseProgressProvider(courseId));
  }

  List<Course> get recommendedCourses => state.resources.take(3).toList();
  List<Course> get popularCourses => state.resources.skip(3).take(5).toList();
  List<Course> get favoriteCourses =>
      state.resources.where((r) => state.favorites.contains(r.id)).toList();
}

final learningNotifierProvider =
    StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  final repository = ref.watch(learningRepositoryProvider);
  return LearningNotifier(repository, ref);
});

// FutureProvider for granular progress reconciliation
final courseProgressProvider =
    FutureProvider.family<List<LessonProgress>, String>((ref, courseId) async {
  final repository = ref.watch(learningRepositoryProvider);
  return repository.getCourseProgress(courseId);
});
