import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/learning_provider.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../../../core/download/providers/download_provider.dart';
import '../../../../core/download/models/download_task.dart';

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
  double _playbackSpeed = 1.0;

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
    _playbackTimer = Timer.periodic(Duration(milliseconds: (1000 / _playbackSpeed).round()), (timer) {
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
    final course = learningState.resources.firstWhere((r) => r.id == widget.courseId,
        orElse: () => learningState.resources.first);
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
          positionSeconds: _currentLesson!.durationSeconds,
          durationSeconds: _currentLesson!.durationSeconds,
          percentage: 100.0,
          completed: true,
        );

    if (!isAuto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson completed!'),
          backgroundColor: Color(0xFF3A9742),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onLessonSelect(Lesson lesson, List<LessonProgress> progressList) {
    if (_currentLesson?.id == lesson.id) return;

    _flushProgressSync();
    _playbackTimer?.cancel();

    final prog = progressList.firstWhere(
      (p) => p.lessonId == lesson.id,
      orElse: () => LessonProgress(
        userId: '',
        courseId: widget.courseId,
        moduleId: '',
        lessonId: lesson.id,
        positionSeconds: 0,
        durationSeconds: lesson.durationSeconds,
        percentage: 0,
        completed: false,
        clientUpdatedAt: DateTime.now(),
      ),
    );

    setState(() {
      _currentLesson = lesson;
      _positionSeconds = prog.positionSeconds;
      _isPlaying = false;
    });
  }

  String _getMediaUrl() {
    if (_currentLesson == null) return '';
    final media = _currentLesson!.media;
    if (media == null) return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    
    String? url;
    if (_activeLanguage == 'hi') {
      url = media.hi?.contentUrl;
    } else if (_activeLanguage == 'mr') {
      url = media.mr?.contentUrl;
    } else {
      url = media.en?.contentUrl;
    }
    return url ?? media.en?.contentUrl ?? media.hi?.contentUrl ?? media.mr?.contentUrl ?? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  }

  Future<void> _openExternalStream(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video stream in external player.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningNotifierProvider);
    final progressAsync = ref.watch(courseProgressProvider(widget.courseId));
    final downloadTasks = ref.watch(downloadTasksProvider);

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_currentLesson?.title ?? 'Course Player',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: learningState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : progressAsync.when(
              data: (progressList) {
                final course = learningState.resources.firstWhere(
                  (r) => r.id == widget.courseId,
                  orElse: () => learningState.resources.isNotEmpty
                      ? learningState.resources.first
                      : throw Exception('Course not found'),
                );

                final allLessons = course.modules.expand((m) => m.lessons).toList();
                if (allLessons.isEmpty) {
                  return const Center(child: Text('No lessons in this course.'));
                }

                if (_currentLesson == null) {
                  if (widget.initialLessonId != null) {
                    _currentLesson = allLessons.firstWhere(
                      (l) => l.id == widget.initialLessonId,
                      orElse: () => allLessons.first,
                    );
                  } else {
                    _currentLesson = allLessons.first;
                  }
                  final initialProg = progressList.firstWhere(
                    (p) => p.lessonId == _currentLesson!.id,
                    orElse: () => LessonProgress(
                      userId: '',
                      courseId: widget.courseId,
                      moduleId: '',
                      lessonId: _currentLesson!.id,
                      positionSeconds: 0,
                      durationSeconds: _currentLesson!.durationSeconds,
                      percentage: 0,
                      completed: false,
                      clientUpdatedAt: DateTime.now(),
                    ),
                  );
                  _positionSeconds = initialProg.positionSeconds;
                }

                final completedCount = progressList.where((p) => p.completed).length;
                final overallProgress = allLessons.isNotEmpty ? (completedCount / allLessons.length) * 100 : 0.0;
                final isCurrentCompleted = progressList.any((p) => p.lessonId == _currentLesson?.id && p.completed);

                final currentTaskId = _currentLesson?.id ?? '';
                final currentTask = downloadTasks[currentTaskId];

                Widget playerSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildVideoPlayer(),
                    const SizedBox(height: 16),
                    _buildActionButtons(currentTask),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _currentLesson?.title ?? '',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
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
                                icon: const Icon(LucideIcons.globe, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentLesson?.description ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: isCurrentCompleted ? null : () => _markLessonComplete(),
                                icon: Icon(
                                  isCurrentCompleted ? LucideIcons.checkCircle : LucideIcons.check,
                                  color: isCurrentCompleted ? Colors.green : null,
                                  size: 16,
                                ),
                                label: Text(
                                  isCurrentCompleted ? 'Completed ✓' : 'Mark as Completed',
                                  style: TextStyle(
                                    color: isCurrentCompleted ? Colors.green.shade700 : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
                  downloadTasks: downloadTasks,
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: playerSection,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 24.0, 24.0, 24.0),
                          child: playlistSidebar,
                        ),
                      ),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: playerSection,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          child: playlistSidebar,
                        ),
                      ],
                    ),
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_currentLesson == null) return const SizedBox();

    final duration = _currentLesson!.durationSeconds;
    final currentPos = _positionSeconds.clamp(0, duration);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101418),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // Simulated Player Screen Backdrop
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A261D),
                      _isPlaying ? const Color(0xFF1E3A24) : const Color(0xFF181C24),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isPlaying) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade800,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                                  SizedBox(width: 6),
                                  Text(
                                    'STREAMING 1080p HD',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Icon(LucideIcons.playCircle, size: 64, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text(
                          'Now Playing: ${_currentLesson!.title}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: () {
                            setState(() => _isPlaying = true);
                            _startPlaybackTimer();
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.play, color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tap to Play Stream',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Language: ${_activeLanguage.toUpperCase()} • Direct MP4 & HLS Available',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Player Controls Bar Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrub Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: Colors.greenAccent,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: currentPos.toDouble(),
                          max: duration > 0 ? duration.toDouble() : 100,
                          onChanged: (val) {
                            setState(() => _positionSeconds = val.toInt());
                          },
                        ),
                      ),
                      // Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_isPlaying ? LucideIcons.pause : LucideIcons.play, color: Colors.white, size: 20),
                                onPressed: () {
                                  setState(() => _isPlaying = !_isPlaying);
                                  if (_isPlaying) {
                                    _startPlaybackTimer();
                                  } else {
                                    _playbackTimer?.cancel();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.replay_10, color: Colors.white70, size: 20),
                                onPressed: () {
                                  setState(() => _positionSeconds = (_positionSeconds - 10).clamp(0, duration));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10, color: Colors.white70, size: 20),
                                onPressed: () {
                                  setState(() => _positionSeconds = (_positionSeconds + 10).clamp(0, duration));
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${currentPos ~/ 60}:${(currentPos % 60).toString().padLeft(2, '0')} / ${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          // Speed Button
                          PopupMenuButton<double>(
                            initialValue: _playbackSpeed,
                            tooltip: 'Playback Speed',
                            onSelected: (speed) {
                              setState(() => _playbackSpeed = speed);
                              if (_isPlaying) {
                                _startPlaybackTimer();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                '${_playbackSpeed}x',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                              const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                              const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                              const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(DownloadTask? currentTask) {
    final mediaUrl = _getMediaUrl();
    final isDownloaded = currentTask?.state == DownloadState.completed;
    final isDownloading = currentTask?.state == DownloadState.downloading || currentTask?.state == DownloadState.queued;

    return Row(
      children: [
        // External Stream Button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.externalLink, size: 16),
            label: const Text('Stream Full Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () => _openExternalStream(mediaUrl),
          ),
        ),
        const SizedBox(width: 10),
        // Download Offline Button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDownloaded ? Colors.green.shade800 : Colors.teal.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(
              isDownloaded ? LucideIcons.checkCircle : (isDownloading ? LucideIcons.loader : LucideIcons.download),
              size: 16,
            ),
            label: Text(
              isDownloaded
                  ? 'Offline Ready ✓'
                  : (isDownloading ? 'Downloading...' : 'Download Video'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () async {
              if (isDownloaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video saved offline on your device! Ready for zero-data playback.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (!isDownloading) {
                final lessonId = _currentLesson?.id ?? 'video_01';
                await ref.read(downloadTasksProvider.notifier).enqueue(
                      lessonId,
                      mediaUrl,
                      '$lessonId.mp4',
                      12000000,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video download started in background!')),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistSidebar({
    required BuildContext context,
    required List<Lesson> lessons,
    required List<LessonProgress> progressList,
    required int completedCount,
    required double overallProgress,
    required Map<String, DownloadTask> downloadTasks,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Lessons',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${lessons.length} lessons',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•'),
                    ),
                    Text(
                      '$completedCount completed',
                      style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: overallProgress / 100,
                  backgroundColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isActive = lesson.id == _currentLesson?.id;
              final isCompleted = progressList.any((p) => p.lessonId == lesson.id && p.completed);
              final isTaskDownloaded = downloadTasks[lesson.id]?.state == DownloadState.completed;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: InkWell(
                  onTap: () => _onLessonSelect(lesson, progressList),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withValues(alpha: 0.12) : Colors.transparent,
                      border: Border.all(
                        color: isActive ? Colors.green.withValues(alpha: 0.3) : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: isCompleted
                              ? const Icon(LucideIcons.checkCircle, color: Color(0xFF3A9742), size: 20)
                              : isActive
                                  ? const Icon(LucideIcons.play, color: Colors.green, size: 20)
                                  : Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
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
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${lesson.durationSeconds ~/ 60} mins',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  if (isTaskDownloaded) ...[
                                    const SizedBox(width: 8),
                                    const Icon(LucideIcons.downloadCloud, size: 12, color: Colors.green),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Offline Ready',
                                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
