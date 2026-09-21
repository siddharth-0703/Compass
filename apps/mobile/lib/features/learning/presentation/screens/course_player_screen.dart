import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/learning_provider.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';

class CoursePlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String? initialLessonId;
  const CoursePlayerScreen({super.key, required this.courseId, this.initialLessonId});

  @override
  ConsumerState<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen> {
  Lesson? _currentLesson;
  String _activeLanguage = 'en'; 
  bool _isPlaying = false;
  int _positionSeconds = 0;
  Timer? _playbackTimer;
  Timer? _syncTimer;
  bool _syncPending = false;

  @override
  void initState() {
    super.initState();
    _startSyncTimer();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _syncTimer?.cancel();
    _flushProgressSync();
    super.dispose();
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentLesson == null) return;

      setState(() {
        if (_positionSeconds < _currentLesson!.durationSeconds) {
          _positionSeconds++;
          _syncPending = true;

          final percent = (_positionSeconds / _currentLesson!.durationSeconds) * 100;
          if (percent >= 90.0) {
            _markLessonComplete(isAuto: true);
          }
        } else {
          _isPlaying = false;
          _playbackTimer?.cancel();
        }
      });
    });
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_syncPending) {
        _flushProgressSync();
      }
    });
  }

  void _flushProgressSync() {
    if (_currentLesson == null) return;
    _syncPending = false;

    final percent = (_positionSeconds / _currentLesson!.durationSeconds) * 100;
    ref.read(learningNotifierProvider.notifier).updateLessonProgress(
          courseId: widget.courseId,
          moduleId: _findModuleIdForLesson(_currentLesson!.id),
          lessonId: _currentLesson!.id,
          positionSeconds: _positionSeconds,
          durationSeconds: _currentLesson!.durationSeconds,
          percentage: percent,
          completed: percent >= 90.0,
        );
  }

  String _findModuleIdForLesson(String lessonId) {
    final learningState = ref.read(learningNotifierProvider);
    final course = learningState.resources.firstWhere((r) => r.id == widget.courseId);
    for (final mod in course.modules) {
      if (mod.lessons.any((l) => l.id == lessonId)) {
        return mod.id;
      }
    }
    return '';
  }

  void _markLessonComplete({bool isAuto = false}) {
    if (_currentLesson == null) return;
    ref.read(learningNotifierProvider.notifier).updateLessonProgress(
          courseId: widget.courseId,
          moduleId: _findModuleIdForLesson(_currentLesson!.id),
          lessonId: _currentLesson!.id,
          positionSeconds: _positionSeconds,
          durationSeconds: _currentLesson!.durationSeconds,
          percentage: 100.0,
          completed: true,
        );
    if (!isAuto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lesson marked complete!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _onLessonSelect(Lesson lesson, List<LessonProgress> progressList) {
    _flushProgressSync(); 

    final progress = progressList.firstWhere(
      (p) => p.lessonId == lesson.id,
      orElse: () => LessonProgress(
        userId: '',
        courseId: widget.courseId,
        moduleId: '',
        lessonId: lesson.id,
        positionSeconds: 0,
        durationSeconds: lesson.durationSeconds,
        percentage: 0.0,
        completed: false,
        clientUpdatedAt: DateTime.now(),
      ),
    );

    setState(() {
      _currentLesson = lesson;
      _positionSeconds = progress.positionSeconds;
      _isPlaying = false;
      _playbackTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningNotifierProvider);
    final course = learningState.resources.firstWhere(
      (r) => r.id == widget.courseId,
      orElse: () => throw Exception('Course not found'),
    );

    final allLessons = course.modules.expand((m) => m.lessons).toList();

    if (_currentLesson == null && allLessons.isNotEmpty) {
      final initialId = widget.initialLessonId ?? allLessons.first.id;
      _currentLesson = allLessons.firstWhere((l) => l.id == initialId, orElse: () => allLessons.first);
    }

    final progressState = ref.watch(courseProgressProvider(widget.courseId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: progressState.when(
        data: (progressList) {
          final completedCount = progressList.where((p) => p.completed).length;
          final totalLessons = allLessons.length;
          final overallProgress = totalLessons > 0 ? (completedCount / totalLessons) * 100 : 0.0;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              
              Widget playerSection = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildVideoPlayer(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _currentLesson?.title ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Language Selector (mocked for now, as in previous implementation)
                            DropdownButton<String>(
                              value: _activeLanguage,
                              items: const [
                                DropdownMenuItem(value: 'en', child: Text('English')),
                                DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                                DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _activeLanguage = val);
                              },
                              underline: const SizedBox(),
                              icon: const Icon(LucideIcons.globe),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentLesson?.description ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              Widget playlistSidebar = _buildPlaylistSidebar(
                context: context,
                lessons: allLessons,
                progressList: progressList,
                completedCount: completedCount,
                overallProgress: overallProgress,
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: playerSection,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 32.0, 32.0, 32.0),
                        child: playlistSidebar,
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      playerSection,
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: playlistSidebar,
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_currentLesson == null) return const SizedBox();

    final isVerified = _currentLesson!.contentStatus == 'VERIFIED';
    
    // In actual app, we'd use a video player package. 
    // Here we're mimicking the web's VideoPlayer.tsx placeholder UI visually.
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isVerified)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.cloudOff, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Video coming soon',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This content is pending verification.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                ],
              )
            else if (_isPlaying)
              // Imagine video playing here, show pause overlay on tap
              GestureDetector(
                onTap: () {
                  setState(() => _isPlaying = false);
                  _playbackTimer?.cancel();
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.pause, color: Colors.white),
                        onPressed: () {
                          setState(() => _isPlaying = false);
                          _playbackTimer?.cancel();
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: _positionSeconds.toDouble(),
                          max: _currentLesson!.durationSeconds.toDouble(),
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) {
                            setState(() => _positionSeconds = val.toInt());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _isPlaying = true);
                        _startPlaybackTimer();
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.play, color: Theme.of(context).colorScheme.primary, size: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Video Player Placeholder',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${_currentLesson!.id}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistSidebar({
    required BuildContext context,
    required List<Lesson> lessons,
    required List<LessonProgress> progressList,
    required int completedCount,
    required double overallProgress,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Content',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${lessons.length} lessons',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•'),
                    ),
                    Text(
                      '$completedCount completed',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COURSE PROGRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${overallProgress.round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: overallProgress / 100,
                  backgroundColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Constrain height if on desktop so it scrolls within itself
          Expanded(
            flex: MediaQuery.of(context).size.width > 900 ? 1 : 0,
            child: ListView.builder(
              shrinkWrap: true,
              physics: MediaQuery.of(context).size.width > 900 
                ? const ClampingScrollPhysics() 
                : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12.0),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isActive = lesson.id == _currentLesson?.id;
                final isCompleted = progressList.any((p) => p.lessonId == lesson.id && p.completed);
                final isVerified = lesson.contentStatus == 'VERIFIED';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      if (isVerified) {
                        _onLessonSelect(lesson, progressList);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Video coming soon in this language.')),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                        border: Border.all(
                          color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2, right: 12),
                            child: isCompleted
                                ? const Icon(LucideIcons.checkCircle, color: Color(0xFF3A9742), size: 20)
                                : isActive
                                    ? Icon(LucideIcons.play, color: Theme.of(context).colorScheme.primary, size: 20)
                                    : Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), width: 2),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                    color: isActive ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(LucideIcons.clock, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${lesson.durationSeconds ~/ 60}:${(lesson.durationSeconds % 60).toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
