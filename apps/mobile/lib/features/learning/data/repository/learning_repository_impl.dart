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
      if (models.isNotEmpty && models.any((m) => m.id == 'organic-farming')) {
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
          .map(
            (json) => LessonProgressModel.fromJson(
              Map<String, dynamic>.from(json),
            ).toEntity(),
          )
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
    } catch (_) {
      // Offline sync queue
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
        id: 'organic-farming',
        title: 'Modern Organic Farming Techniques',
        description:
            'Complete masterclass on natural soil nutrition, composting, bio-fertilizers, and organic certification for Indian farmers.',
        categories: ['Agriculture'],
        difficulty: 'Intermediate',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1615811361523-6bd03d7748e7?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-organic-1',
            title: 'Organic Soil & Composting',
            description: 'Natural soil health and organic matter preparation.',
            order: 1,
            lessons: [
              Lesson(
                id: 'of-en-1',
                title: 'Masterclass: Organic Soil & Composting',
                description:
                    'A complete guide to natural soil health and organic matter preparation.',
                durationSeconds: 2700,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Organic_Farming_Guide.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=pDPWTRA2nPM',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=XUwptP0_v00',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=yu2MMDwVDR0',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
              Lesson(
                id: 'of-hi-2',
                title: 'Bio-Pesticides and Natural Crop Protection',
                description:
                    'Preparing Neem Astra, Agni Astra and Dashparni Ark for organic pest control.',
                durationSeconds: 1500,
                order: 2,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['BioPesticide_Recipes.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=pDPWTRA2nPM',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=2qiNKen-rm0',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=TwnPqUBSAEQ',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
              Lesson(
                id: 'of-hi-3',
                title: 'Organic Certification & Premium Mandi Pricing',
                description:
                    'Natural fertilizers, certification, and getting 40% premium mandi rates.',
                durationSeconds: 2700,
                order: 3,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Certification_Checklist.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=pDPWTRA2nPM',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=Kouij55MvzE',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=yu2MMDwVDR0',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Course(
        id: 'digital-marketing',
        title: 'Digital Marketing for Local Products',
        description:
            'Grow your business using WhatsApp Business, social media, and digital brochures to reach customers beyond your village.',
        categories: ['Digital Skills'],
        difficulty: 'Beginner',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-digital-1',
            title: 'Direct-to-Consumer Channels',
            description:
                'Learn how to use WhatsApp Business and Facebook to attract local customers.',
            order: 1,
            lessons: [
              Lesson(
                id: 'dm-en-1',
                title: 'Complete Digital Marketing Guide',
                description:
                    'Learn how to use WhatsApp Business and Facebook to attract local customers.',
                durationSeconds: 4200,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Marketing_Checklist.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=kGARu1dgLl4',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=5Nm5raGEo0E',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=_ZRkfA6GmGU',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
              Lesson(
                id: 'dm-catalog-2',
                title: 'WhatsApp Business Catalogs & Digital Brochures',
                description:
                    'Creating professional digital brochures and sharing product catalogs directly with buyers.',
                durationSeconds: 2400,
                order: 2,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Catalog_Templates.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=kGARu1dgLl4',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=5Nm5raGEo0E',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=_ZRkfA6GmGU',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Course(
        id: 'financial-literacy-gst',
        title: 'Understanding GST & Business Taxation',
        description:
            'A jargon-free guide to Indian business taxes, GST registration, accounting, and avoiding financial penalties.',
        categories: ['Financial Literacy'],
        difficulty: 'Intermediate',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-gst-1',
            title: 'Taxes & Accounting for MSMEs',
            description:
                'Everything a small business owner needs to know about GST and basic accounting.',
            order: 1,
            lessons: [
              Lesson(
                id: 'gst-en-1',
                title: 'GST Masterclass for MSMEs',
                description:
                    'Everything a small business owner needs to know about GST and basic accounting.',
                durationSeconds: 3300,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Tax_Calendar.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=mT3P0YSNonE',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=qIcA38MYsdk',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=pDPWTRA2nPM',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
              Lesson(
                id: 'gst-ledger-2',
                title: 'Bookkeeping & Working Capital Management',
                description:
                    'Maintaining digital credit ledgers and cashflow tracking for rural enterprises.',
                durationSeconds: 2100,
                order: 2,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Ledger_Guide.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=mT3P0YSNonE',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=qIcA38MYsdk',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=pDPWTRA2nPM',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Course(
        id: 'gov-schemes-guide',
        title: 'Navigating Government Schemes & Subsidies',
        description:
            'Learn how to access government support, Mudra loans, PMFME, and state-level subsidy applications without middlemen.',
        categories: ['Government Schemes'],
        difficulty: 'Beginner',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?q=80&w=800&auto=format&fit=crop',
        modules: [
          Module(
            id: 'mod-schemes-1',
            title: 'Subsidies & Official Portals',
            description:
                'Overview of Mudra loans, PMFME, and state-level subsidy applications.',
            order: 1,
            lessons: [
              Lesson(
                id: 'gov-en-1',
                title: 'Complete Guide to Business Subsidies',
                description:
                    'An overview of Mudra loans, PMFME, and state-level subsidy applications.',
                durationSeconds: 2400,
                order: 1,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Subsidies_Handbook.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=_ZRkfA6GmGU',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=5Nm5raGEo0E',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=5blQaNL1qO4',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                ),
              ),
              Lesson(
                id: 'gov-docs-2',
                title: 'Document Verification & JanSamarth Application',
                description:
                    'Aadhaar linkage, 7/12 land records, and online application on JanSamarth portal.',
                durationSeconds: 1800,
                order: 2,
                isPublished: true,
                contentStatus: 'VERIFIED',
                resources: ['Scheme_Documents_Checklist.pdf'],
                media: LocalizedMedia(
                  en: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=_ZRkfA6GmGU',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  hi: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=5Nm5raGEo0E',
                    provider: 'YOUTUBE',
                    contentType: 'VIDEO',
                  ),
                  mr: LocalizedMediaSource(
                    contentUrl: 'https://www.youtube.com/watch?v=5blQaNL1qO4',
                    provider: 'YOUTUBE',
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
