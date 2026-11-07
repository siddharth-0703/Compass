import '../../domain/repository/learning_repository.dart';
import '../datasource/learning_remote_datasource.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/module.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../models/course_model.dart';
import '../models/lesson_progress_model.dart';
import '../../../../core/storage/hive_storage.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningRemoteDataSource _remoteDataSource;

  LearningRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Course>> getAllResources() async {
    try {
      final models = await _remoteDataSource.getAllResources();
      if (models.isNotEmpty) {
        return models.map((m) => m.toEntity()).toList();
      }
    } catch (_) {
      // Offline fallback
    }

    return _getDefaultCourses();
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
            .map(
              (json) => LessonProgressModel.fromJson(
                Map<String, dynamic>.from(json),
              ).toEntity(),
            )
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
      cachedList.map((item) => Map<String, dynamic>.from(item)),
    );
    final index =
        list.indexWhere((item) => item['lessonId'] == progress.lessonId);

    if (index >= 0) {
      list[index] = model.toJson();
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
      // Ignored for offline-first design
    }
  }

  @override
  Future<List<String>> getFavorites() async {
    final box = HiveStorage.favoritesBox;
    return List<String>.from(box.get('favorite_course_ids') ?? []);
  }

  @override
  Future<void> toggleFavorite(String courseId) async {
    final box = HiveStorage.favoritesBox;
    final list = List<String>.from(box.get('favorite_course_ids') ?? []);
    if (list.contains(courseId)) {
      list.remove(courseId);
    } else {
      list.add(courseId);
    }
    await box.put('favorite_course_ids', list);
  }

  @override
  Future<void> enrollInCourse(String courseId) async {
    try {
      await _remoteDataSource.enroll(courseId);
    } catch (e) {
      // Offline fallback
    }
  }

  List<Course> _getDefaultCourses() {
    return [
      const Course(
        id: 'course-agri-01',
        title: 'Modern Organic Farming Techniques',
        description:
            'Complete masterclass on natural soil nutrition, composting, bio-fertilizers, and organic certification for Indian farmers.',
        categories: ['Agriculture'],
        difficulty: 'Beginner',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1615811361523-6bd03d7748e7?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-1',
            title: 'Soil Health & Vermicomposting',
            description: 'Building rich organic soil without chemical inputs.',
            order: 1,
            lessons: [
              Lesson(
                id: 'les-1',
                title: 'Compost Pit Preparation & Microorganisms',
                description:
                    'Step-by-step method to prepare Jeevamrit and vermicompost.',
                durationSeconds: 1200,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Organic_Fertilizer_Guide.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
              Lesson(
                id: 'les-1b',
                title: 'Bio-Pesticides and Natural Crop Protection',
                description:
                    'Preparing Neem Astra, Agni Astra and Dashparni Ark for organic pest control.',
                durationSeconds: 960,
                order: 2,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['BioPesticide_Recipes.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Course(
        id: 'course-fin-02',
        title: 'Financial Literacy for Rural Micro-Enterprises',
        description:
            'Master bookkeeping, cash-flow forecasting, UPI business reconciliation, and securing MUDRA/KCC loans.',
        categories: ['Finance'],
        difficulty: 'Beginner',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-2',
            title: 'Bookkeeping & Working Capital',
            description: 'Simple financial management using mobile registers.',
            order: 1,
            lessons: [
              Lesson(
                id: 'les-2',
                title: 'Daily Cash Inflow vs. Operating Expenses',
                description: 'How to calculate gross profit margin accurately.',
                durationSeconds: 900,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Cashflow_Template.xlsx'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Course(
        id: 'course-mkt-03',
        title: 'Digital Marketing for Rural Artisans & Farmers',
        description:
            'Learn how to sell processed agricultural goods and handloom products directly on ONDC, WhatsApp Catalogs, and Instagram.',
        categories: ['Marketing', 'Digital Skills'],
        difficulty: 'Intermediate',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-3',
            title: 'Direct-to-Consumer Channels',
            description: 'Packaging, pricing, and dispatching online orders.',
            order: 1,
            lessons: [
              Lesson(
                id: 'les-3',
                title: 'Setting up WhatsApp Business & Catalog Sharing',
                description: 'Creating professional digital brochures.',
                durationSeconds: 1500,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Catalog_Checklist.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Course(
        id: 'course-gov-04',
        title: 'Government Schemes & Subsidies Practical Guide',
        description:
            'Detailed eligibility breakdown and paperwork walkthrough for PM-KMY, PMMY Mudra, NABARD Dairy Venture, and Stand-Up India.',
        categories: ['Government Schemes'],
        difficulty: 'Beginner',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1541872703-74c5e44368f9?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-4',
            title: 'Applying via CSC & JanSamarth',
            description: 'Step by step submission without middleman commissions.',
            order: 1,
            lessons: [
              Lesson(
                id: 'les-4',
                title: 'Document Verification & Eligibility Checklist',
                description: 'Aadhaar linkage, land records, and 7/12 extract.',
                durationSeconds: 1080,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Scheme_Checklist.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4',
                    provider: 'MP4',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
