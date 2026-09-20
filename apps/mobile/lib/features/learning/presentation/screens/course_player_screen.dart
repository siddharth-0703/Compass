import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learning_provider.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';

class CoursePlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String? initialLessonId;
  const CoursePlayerScreen(
      {super.key, required this.courseId, this.initialLessonId,});

  @override
  ConsumerState<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen> {
  Lesson? _currentLesson;
  String _activeLanguage = 'en'; // English by default
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

          // Check 90% watch threshold criteria
          final percent =
              (_positionSeconds / _currentLesson!.durationSeconds) * 100;
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
    // Throttled sync: push progress updates to backend every 15 seconds
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
    final course =
        learningState.resources.firstWhere((r) => r.id == widget.courseId);
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
        const SnackBar(
            content: Text('Lesson marked complete!'),
            backgroundColor: Colors.green,),
      );
    }
  }

  void _onLessonSelect(Lesson lesson, List<LessonProgress> progressList) {
    _flushProgressSync(); // Save previous progress state

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

    // Flatten lessons list for playback queue mapping
    final allLessons = course.modules.expand((m) => m.lessons).toList();

    // Select initial lesson if not already active
    if (_currentLesson == null && allLessons.isNotEmpty) {
      final initialId = widget.initialLessonId ?? allLessons.first.id;
      _currentLesson = allLessons.firstWhere((l) => l.id == initialId,
          orElse: () => allLessons.first,);
    }

    final progressState = ref.watch(courseProgressProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: progressState.when(
        data: (progressList) {
          return Column(
            children: [
              _buildPlayerContainer(),
              _buildControlPanel(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Text(_currentLesson?.title ?? '',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold,),),
                    const SizedBox(height: 8),
                    Text(_currentLesson?.description ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54,),),
                    const Divider(height: 32),
                    const Text('Course Outline',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold,),),
                    const SizedBox(height: 12),
                    ...allLessons.map((l) {
                      final isCurrent = l.id == _currentLesson?.id;
                      final isCompleted = progressList
                          .any((p) => p.lessonId == l.id && p.completed);
                      final isVerified = l.contentStatus == 'VERIFIED';

                      return ListTile(
                        leading: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : (isCurrent
                                  ? Icons.play_arrow
                                  : (isVerified
                                      ? Icons.play_arrow_outlined
                                      : Icons.lock_outline)),
                          color: isCompleted
                              ? Colors.green
                              : (isVerified ? Colors.blue : Colors.grey),
                        ),
                        title: Text(l.title,
                            style: TextStyle(
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,),),
                        onTap: () {
                          if (isVerified) {
                            _onLessonSelect(l, progressList);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Video coming soon in this language.',),),
                            );
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPlayerContainer() {
    if (_currentLesson == null) return const SizedBox();

    // Check if selected language exists in video lessons
    final mediaMap = _currentLesson!.media;
    bool hasLanguageVideo = false;
    if (mediaMap != null) {
      if (_activeLanguage == 'en' && mediaMap.en != null) {
        hasLanguageVideo = true;
      } else if (_activeLanguage == 'hi' && mediaMap.hi != null) {
        hasLanguageVideo = true;
      } else if (_activeLanguage == 'mr' && mediaMap.mr != null) {
        hasLanguageVideo = true;
      }
    }

    final isVerified = _currentLesson!.contentStatus == 'VERIFIED';

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video placeholder / cover
            if (isVerified && hasLanguageVideo)
              const Icon(Icons.movie, size: 64, color: Colors.white24)
            else
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    Text(
                      !isVerified
                          ? 'Video coming soon'
                          : 'Video currently unavailable in ${_activeLanguage.toUpperCase()}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold,),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Play/Pause Overlay
            if (isVerified && hasLanguageVideo)
              IconButton(
                iconSize: 64,
                icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white.withValues(alpha: 0.8),),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    if (_isPlaying) {
                      _startPlaybackTimer();
                    } else {
                      _playbackTimer?.cancel();
                      _flushProgressSync(); // Sync immediately on pause
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    if (_currentLesson == null) return const SizedBox();

    final minutes = (_positionSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_positionSeconds % 60).toString().padLeft(2, '0');
    final totalMinutes =
        (_currentLesson!.durationSeconds ~/ 60).toString().padLeft(2, '0');
    final totalSeconds =
        (_currentLesson!.durationSeconds % 60).toString().padLeft(2, '0');

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text('$minutes:$seconds'),
              Expanded(
                child: Slider(
                  value: _positionSeconds.toDouble(),
                  min: 0,
                  max: _currentLesson!.durationSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _positionSeconds = value.toInt();
                      _syncPending = true;
                    });
                  },
                  onChangeEnd: (value) {
                    _flushProgressSync(); // Save immediately when user finishes scrubbing
                  },
                ),
              ),
              Text('$totalMinutes:$totalSeconds'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _activeLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                  DropdownMenuItem(value: 'mr', child: Text('Marathi')),
                ],
                onChanged: (lang) {
                  if (lang != null) {
                    setState(() {
                      _activeLanguage = lang;
                      _isPlaying = false;
                      _playbackTimer?.cancel();
                    });
                  }
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Complete'),
                onPressed: _markLessonComplete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
