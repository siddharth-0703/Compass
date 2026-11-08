import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import '../providers/learning_provider.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../data/services/video_stream_resolver.dart';
import '../../../../core/download/providers/download_provider.dart';
import '../../../../core/download/models/download_task.dart';
import '../../../../core/localization/locale_provider.dart';

class CoursePlayerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String? initialLessonId;
  const CoursePlayerScreen({
    super.key,
    required this.courseId,
    this.initialLessonId,
  });

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
  Timer? _controlsTimer;
  bool _syncPending = false;
  double _playbackSpeed = 1.0;

  // Custom Video Player State (100% In-App, Zero External App)
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoBuffering = false;
  bool _isVideoError = false;
  String _errorMessage = '';
  bool _isOfflinePlayback = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  double _dragSliderPosition = -1;

  @override
  void initState() {
    super.initState();
    final savedLang = ref.read(appLocaleProvider);
    if (savedLang == 'hi' || savedLang == 'mr' || savedLang == 'en') {
      _activeLanguage = savedLang;
    }
    _startSyncTimer();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _syncTimer?.cancel();
    _controlsTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _flushProgressSync();
    super.dispose();
  }

  String _getMediaUrl() {
    if (_currentLesson == null) return '';
    final media = _currentLesson!.media;
    const defaultYt = 'https://www.youtube.com/watch?v=pDPWTRA2nPM';
    if (media == null) return defaultYt;

    String? url;
    if (_activeLanguage == 'hi') {
      url = media.hi?.contentUrl;
    } else if (_activeLanguage == 'mr') {
      url = media.mr?.contentUrl;
    } else {
      url = media.en?.contentUrl;
    }

    return url ??
        media.en?.contentUrl ??
        media.hi?.contentUrl ??
        media.mr?.contentUrl ??
        defaultYt;
  }

  Future<void> _initVideoForCurrentLesson({bool autoPlay = false}) async {
    final mediaUrl = _getMediaUrl();
    if (mediaUrl.isEmpty) return;

    // Check if downloaded offline
    final lessonId = _currentLesson?.id ?? '';
    final downloadTasks = ref.read(downloadTasksProvider);
    final task = downloadTasks[lessonId];
    String? localPath;
    if (task != null && task.state == DownloadState.completed) {
      final file = File(task.savePath);
      if (file.existsSync() && file.lengthSync() > 1000) {
        localPath = task.savePath;
      }
    }

    _playbackTimer?.cancel();
    _controlsTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _videoController = null;

    setState(() {
      _isOfflinePlayback = localPath != null;
      _isVideoInitialized = false;
      _isVideoBuffering = true;
      _isVideoError = false;
      _errorMessage = '';
      _showControls = true;
    });

    try {
      VideoPlayerController controller;

      if (localPath != null) {
        // 1. Play directly from offline downloaded file (Zero mobile data)
        controller = VideoPlayerController.file(File(localPath));
      } else {
        // 2. Resolve direct MP4 in-app stream URL
        final streamInfo = await VideoStreamResolver.resolve(mediaUrl);
        if (streamInfo == null || streamInfo.streamUrl.isEmpty) {
          throw Exception('Unable to resolve video stream. Please check connection or download while online.');
        }
        controller = VideoPlayerController.networkUrl(
          Uri.parse(streamInfo.streamUrl),
        );
      }

      _videoController = controller;
      await controller.initialize();

      if (!mounted || _videoController != controller) return;

      controller.addListener(_videoListener);
      await controller.setPlaybackSpeed(_playbackSpeed);

      setState(() {
        _isVideoInitialized = true;
        _isVideoBuffering = false;
        if (_positionSeconds > 0 &&
            _positionSeconds < controller.value.duration.inSeconds) {
          controller.seekTo(Duration(seconds: _positionSeconds));
        }
        if (autoPlay) {
          _isPlaying = true;
          controller.play();
          _scheduleControlsHide();
        }
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _isVideoError = true;
        _isVideoBuffering = false;
        _errorMessage = err.toString();
      });
    }
  }

  void _videoListener() {
    if (!mounted || _videoController == null) return;
    final value = _videoController!.value;

    final posSec = value.position.inSeconds;
    final isBuffering = value.isBuffering;
    final isPlaying = value.isPlaying;

    if (posSec != _positionSeconds ||
        isBuffering != _isVideoBuffering ||
        isPlaying != _isPlaying) {
      setState(() {
        _positionSeconds = posSec;
        _isVideoBuffering = isBuffering;
        _isPlaying = isPlaying;
        _syncPending = true;
      });

      final durSec = value.duration.inSeconds;
      if (durSec > 0 && (posSec / durSec) >= 0.9) {
        _markLessonComplete(isAuto: true);
      }
    }
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_syncPending) {
        _flushProgressSync();
      }
    });
  }

  void _flushProgressSync() {
    if (_currentLesson == null) return;
    _syncPending = false;

    final dur = _videoController != null &&
            _isVideoInitialized &&
            _videoController!.value.duration.inSeconds > 0
        ? _videoController!.value.duration.inSeconds
        : (_currentLesson!.durationSeconds > 0
            ? _currentLesson!.durationSeconds
            : 1);

    final pct = ((_positionSeconds / dur) * 100).clamp(0.0, 100.0);
    final completed = pct >= 90.0;

    ref.read(learningNotifierProvider.notifier).updateLessonProgress(
          courseId: widget.courseId,
          moduleId: _findModuleIdForLesson(_currentLesson!.id),
          lessonId: _currentLesson!.id,
          positionSeconds: _positionSeconds,
          durationSeconds: dur,
          percentage: pct,
          completed: completed,
        );
  }

  String _findModuleIdForLesson(String lessonId) {
    final state = ref.read(learningNotifierProvider);
    final course = state.resources.firstWhere(
      (r) => r.id == widget.courseId,
      orElse: () => state.resources.first,
    );
    for (var mod in course.modules) {
      if (mod.lessons.any((l) => l.id == lessonId)) {
        return mod.id;
      }
    }
    return '';
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;

    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() => _showControls = true);
      _controlsTimer?.cancel();
    } else {
      _videoController!.play();
      _scheduleControlsHide();
    }
  }

  void _seekRelative(int seconds) {
    if (_videoController == null || !_isVideoInitialized) return;
    final current = _videoController!.value.position;
    final total = _videoController!.value.duration;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;

    _videoController!.seekTo(target);
    _scheduleControlsHide();
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _isPlaying) {
      _scheduleControlsHide();
    }
  }

  void _changeSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _videoController?.setPlaybackSpeed(speed);
    Navigator.of(context).pop();
  }

  void _showSpeedDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Playback Speed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              for (var speed in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                ListTile(
                  title: Text('${speed}x'),
                  trailing: _playbackSpeed == speed
                      ? const Icon(Icons.check, color: Color(0xFF0D9488))
                      : null,
                  onTap: () => _changeSpeed(speed),
                ),
            ],
          ),
        );
      },
    );
  }

  void _markLessonComplete({bool isAuto = false}) {
    if (_currentLesson == null) return;
    final dur = _videoController != null &&
            _isVideoInitialized &&
            _videoController!.value.duration.inSeconds > 0
        ? _videoController!.value.duration.inSeconds
        : _currentLesson!.durationSeconds;

    ref.read(learningNotifierProvider.notifier).updateLessonProgress(
          courseId: widget.courseId,
          moduleId: _findModuleIdForLesson(_currentLesson!.id),
          lessonId: _currentLesson!.id,
          positionSeconds: dur,
          durationSeconds: dur,
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
    _controlsTimer?.cancel();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideoForCurrentLesson(autoPlay: true);
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startDownloadForCurrentLesson() async {
    if (_currentLesson == null) return;
    final lesson = _currentLesson!;
    final mediaUrl = _getMediaUrl();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing high-quality video for offline download...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final streamInfo = await VideoStreamResolver.resolve(mediaUrl);
      if (streamInfo == null || streamInfo.streamUrl.isEmpty) {
        throw Exception('Could not fetch video download link.');
      }

      await ref.read(downloadTasksProvider.notifier).enqueue(
            lesson.id,
            streamInfo.streamUrl,
            '${lesson.id}.mp4',
            streamInfo.totalBytes > 0 ? streamInfo.totalBytes : 35000000,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading started! You can watch offline once done.'),
            backgroundColor: Color(0xFF0F766E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteDownloadedLesson() async {
    if (_currentLesson == null) return;
    final lessonId = _currentLesson!.id;
    final tasks = ref.read(downloadTasksProvider);
    final task = tasks[lessonId];
    if (task != null) {
      await ref.read(downloadTasksProvider.notifier).cancel(lessonId);
      final file = File(task.savePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloaded video removed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _initVideoForCurrentLesson();
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningNotifierProvider);
    final progressAsync = ref.watch(courseProgressProvider(widget.courseId));
    final downloadTasks = ref.watch(downloadTasksProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: _buildCustomVideoPlayerWidget(isFullscreen: true),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _currentLesson?.title ?? 'Course Player',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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

                final allLessons =
                    course.modules.expand((m) => m.lessons).toList();
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

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _initVideoForCurrentLesson();
                  });
                }

                final completedCount =
                    progressList.where((p) => p.completed).length;
                final overallProgress = allLessons.isNotEmpty
                    ? (completedCount / allLessons.length) * 100
                    : 0.0;
                final isCurrentCompleted = progressList
                    .any((p) => p.lessonId == _currentLesson?.id && p.completed);

                final currentTaskId = _currentLesson?.id ?? '';
                final currentTask = downloadTasks[currentTaskId];

                Widget playerSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCustomVideoPlayerWidget(isFullscreen: false),
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
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DropdownButton<String>(
                                value: _activeLanguage,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('English'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hi',
                                    child: Text('हिंदी'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'mr',
                                    child: Text('मराठी'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null && val != _activeLanguage) {
                                    setState(() => _activeLanguage = val);
                                    _initVideoForCurrentLesson(
                                      autoPlay: _isPlaying,
                                    );
                                  }
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: isCurrentCompleted
                                    ? null
                                    : () => _markLessonComplete(),
                                icon: Icon(
                                  isCurrentCompleted
                                      ? LucideIcons.checkCircle
                                      : LucideIcons.check,
                                  color:
                                      isCurrentCompleted ? Colors.green : null,
                                  size: 16,
                                ),
                                label: Text(
                                  isCurrentCompleted
                                      ? 'Completed ✓'
                                      : 'Mark as Completed',
                                  style: TextStyle(
                                    color: isCurrentCompleted
                                        ? Colors.green.shade700
                                        : null,
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
                          padding:
                              const EdgeInsets.fromLTRB(0, 24.0, 24.0, 24.0),
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

  /// 100% Custom Player Widget (ExoPlayer Flutter texture, zero external app redirects, zero YouTube branding)
  Widget _buildCustomVideoPlayerWidget({required bool isFullscreen}) {
    if (_currentLesson == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(isFullscreen ? 0 : 16),
        boxShadow: isFullscreen
            ? null
            : const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isFullscreen ? 0 : 16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // 1. Direct Hardware Video Surface
              if (_videoController != null && _isVideoInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.playCircle,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),

              // 2. Gesture Detector for Controls and Double-Tap Seek
              Row(
                children: [
                  // Left Double Tap: -10s
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleControlsVisibility,
                      onDoubleTap: () => _seekRelative(-10),
                    ),
                  ),
                  // Right Double Tap: +10s
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleControlsVisibility,
                      onDoubleTap: () => _seekRelative(10),
                    ),
                  ),
                ],
              ),

              // 3. Buffering / Loading State
              if (_isVideoBuffering)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF2DD4BF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _isOfflinePlayback
                              ? 'Loading Offline Media...'
                              : 'Streaming In-App HD Video...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 4. Error State
              if (_isVideoError)
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          color: Colors.amberAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Playback Error',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage.isNotEmpty
                              ? _errorMessage
                              : 'Could not play video stream.',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(LucideIcons.refreshCw, size: 14),
                          label: const Text('Retry Playback'),
                          onPressed: () =>
                              _initVideoForCurrentLesson(autoPlay: true),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Custom Player Controls Overlay
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Bar: Lesson title & Badges & Fullscreen
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _isOfflinePlayback
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isOfflinePlayback
                                        ? const Color(0xFF2DD4BF)
                                        : Colors.white24,
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isOfflinePlayback
                                          ? LucideIcons.hardDrive
                                          : LucideIcons.tv,
                                      color: _isOfflinePlayback
                                          ? const Color(0xFF2DD4BF)
                                          : Colors.white70,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isOfflinePlayback
                                          ? 'OFFLINE ZERO-DATA'
                                          : 'IN-APP HD',
                                      style: TextStyle(
                                        color: _isOfflinePlayback
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.speed,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Playback Speed',
                                onPressed: _showSpeedDialog,
                              ),
                              IconButton(
                                icon: Icon(
                                  isFullscreen
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                tooltip: 'Toggle Fullscreen',
                                onPressed: () {
                                  setState(() => _isFullscreen = !_isFullscreen);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Center: Rewind, Large Play/Pause, Forward
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Rewind 10s
                            IconButton(
                              iconSize: 34,
                              icon: const Icon(
                                Icons.replay_10_rounded,
                                color: Colors.white,
                              ),
                              tooltip: 'Rewind 10s',
                              onPressed: () => _seekRelative(-10),
                            ),
                            const SizedBox(width: 24),
                            // Large Play/Pause Button
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0D9488),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2DD4BF)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Fast-Forward 10s
                            IconButton(
                              iconSize: 34,
                              icon: const Icon(
                                Icons.forward_10_rounded,
                                color: Colors.white,
                              ),
                              tooltip: 'Forward 10s',
                              onPressed: () => _seekRelative(10),
                            ),
                          ],
                        ),

                        // Bottom: Position, Scrubber Slider, Duration
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _videoController != null &&
                                            _isVideoInitialized
                                        ? _formatDuration(
                                            _videoController!.value.position,
                                          )
                                        : '0:00',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor:
                                            const Color(0xFF2DD4BF),
                                        inactiveTrackColor: Colors.white24,
                                        thumbColor: const Color(0xFF2DD4BF),
                                        overlayColor: const Color(0xFF2DD4BF)
                                            .withValues(alpha: 0.2),
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 6,
                                        ),
                                        trackHeight: 3.5,
                                      ),
                                      child: Slider(
                                        min: 0.0,
                                        max: _videoController != null &&
                                                _isVideoInitialized &&
                                                _videoController!
                                                        .value.duration.inSeconds >
                                                    0
                                            ? _videoController!
                                                .value.duration.inSeconds
                                                .toDouble()
                                            : 100.0,
                                        value: _dragSliderPosition >= 0
                                            ? _dragSliderPosition
                                            : (_videoController != null &&
                                                    _isVideoInitialized
                                                ? _videoController!
                                                    .value.position.inSeconds
                                                    .toDouble()
                                                    .clamp(
                                                      0.0,
                                                      _videoController!.value
                                                          .duration.inSeconds
                                                          .toDouble(),
                                                    )
                                                : 0.0),
                                        onChangeStart: (val) {
                                          setState(() =>
                                              _dragSliderPosition = val,);
                                          _controlsTimer?.cancel();
                                        },
                                        onChanged: (val) {
                                          setState(() =>
                                              _dragSliderPosition = val,);
                                        },
                                        onChangeEnd: (val) {
                                          if (_videoController != null &&
                                              _isVideoInitialized) {
                                            _videoController!.seekTo(
                                              Duration(seconds: val.toInt()),
                                            );
                                          }
                                          setState(
                                            () => _dragSliderPosition = -1,
                                          );
                                          _scheduleControlsHide();
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _videoController != null &&
                                            _isVideoInitialized
                                        ? _formatDuration(
                                            _videoController!.value.duration,
                                          )
                                        : (_currentLesson != null
                                            ? '${_currentLesson!.durationMinutes}:00'
                                            : '0:00'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(DownloadTask? currentTask) {
    final isDownloaded = currentTask?.state == DownloadState.completed &&
        currentTask?.savePath != null &&
        File(currentTask!.savePath).existsSync();
    final isDownloading = currentTask?.state == DownloadState.downloading ||
        currentTask?.state == DownloadState.queued;

    final progressPct = (currentTask != null && currentTask.totalBytes > 0)
        ? ((currentTask.downloadedBytes / currentTask.totalBytes) * 100)
            .clamp(0, 100)
            .toInt()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Download / Offline Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDownloaded
                      ? const Color(0xFF166534) // Emerald-800
                      : const Color(0xFF0F766E), // Teal-700
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  isDownloaded
                      ? LucideIcons.checkCheck
                      : (isDownloading
                          ? LucideIcons.loader
                          : LucideIcons.download),
                  size: 18,
                ),
                label: Text(
                  isDownloaded
                      ? 'Downloaded (Offline Ready ✓)'
                      : (isDownloading
                          ? 'Downloading ($progressPct%)...'
                          : 'Download Lesson (Offline)'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  if (isDownloaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Video saved locally. Plays offline with zero mobile data.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (!isDownloading) {
                    _startDownloadForCurrentLesson();
                  }
                },
              ),
            ),
            if (isDownloaded) ...[
              const SizedBox(width: 8),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(LucideIcons.trash2, size: 18),
                tooltip: 'Delete downloaded video',
                onPressed: _deleteDownloadedLesson,
              ),
            ],
          ],
        ),
        if (isDownloading) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPct > 0 ? progressPct / 100 : null,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
              minHeight: 6,
            ),
          ),
        ],
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
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
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
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•'),
                    ),
                    Text(
                      '$completedCount completed',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: overallProgress / 100,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isCurrent = _currentLesson?.id == lesson.id;
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

              final isDownloaded = downloadTasks[lesson.id]?.state ==
                      DownloadState.completed &&
                  File(downloadTasks[lesson.id]?.savePath ?? '').existsSync();

              return ListTile(
                selected: isCurrent,
                selectedTileColor:
                    const Color(0xFF0D9488).withValues(alpha: 0.1),
                leading: CircleAvatar(
                  backgroundColor: isCurrent
                      ? const Color(0xFF0D9488)
                      : (prog.completed
                          ? Colors.green.shade100
                          : Colors.grey.shade100),
                  foregroundColor: isCurrent
                      ? Colors.white
                      : (prog.completed
                          ? Colors.green.shade700
                          : Colors.grey.shade600),
                  child: prog.completed
                      ? const Icon(LucideIcons.check, size: 16)
                      : (isCurrent
                          ? const Icon(LucideIcons.play, size: 16)
                          : Text('${index + 1}')),
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                    color: isCurrent ? const Color(0xFF0D9488) : null,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      '${lesson.durationMinutes} mins',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    if (isDownloaded) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.hardDrive,
                        size: 12,
                        color: Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: isCurrent
                    ? const Icon(
                        LucideIcons.volume2,
                        color: Color(0xFF0D9488),
                        size: 18,
                      )
                    : null,
                onTap: () => _onLessonSelect(lesson, progressList),
              );
            },
          ),
        ],
      ),
    );
  }
}
