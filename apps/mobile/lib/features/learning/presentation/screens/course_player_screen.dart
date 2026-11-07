import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../providers/learning_provider.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_progress.dart';
import '../../../../core/download/providers/download_provider.dart';
import '../../../../core/download/models/download_task.dart';

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
  bool _syncPending = false;
  final double _playbackSpeed = 1.0;

  // Real Video Player State
  bool _isYoutube = true;
  YoutubePlayerController? _youtubeController;
  StreamSubscription<YoutubeVideoState>? _ytStateSubscription;
  StreamSubscription<YoutubePlayerValue>? _ytValueSubscription;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoBuffering = false;
  bool _isVideoError = false;
  bool _isOfflinePlayback = false;

  @override
  void initState() {
    super.initState();
    _startSyncTimer();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _syncTimer?.cancel();
    _ytStateSubscription?.cancel();
    _ytValueSubscription?.cancel();
    _youtubeController?.close();
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

  void _initVideoForCurrentLesson({bool autoPlay = false}) {
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
    _ytStateSubscription?.cancel();
    _ytStateSubscription = null;
    _ytValueSubscription?.cancel();
    _ytValueSubscription = null;
    _youtubeController?.close();
    _youtubeController = null;

    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _videoController = null;

    final ytId = YoutubePlayerController.convertUrlToId(mediaUrl);

    setState(() {
      _isOfflinePlayback = localPath != null;
      _isVideoInitialized = false;
      _isVideoBuffering = true;
      _isVideoError = false;
      _isYoutube = localPath == null && ytId != null && ytId.isNotEmpty;
    });

    if (localPath != null) {
      // Offline local file playback
      final controller = VideoPlayerController.file(File(localPath));
      _videoController = controller;
      controller.initialize().then((_) {
        if (!mounted || _videoController != controller) return;
        controller.addListener(_videoListener);
        controller.setPlaybackSpeed(_playbackSpeed);
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
          }
        });
      }).catchError((err) {
        if (!mounted || _videoController != controller) return;
        setState(() {
          _isVideoError = true;
          _isVideoBuffering = false;
        });
      });
    } else if (_isYoutube && ytId != null) {
      // 1:1 YouTube embed matching web version
      final ytController = YoutubePlayerController.fromVideoId(
        videoId: ytId,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          enableCaption: true,
          showVideoAnnotations: false,
        ),
      );

      _youtubeController = ytController;
      _ytStateSubscription = ytController.videoStateStream.listen((state) {
        if (!mounted) return;
        final posSec = state.position.inSeconds;
        if (posSec != _positionSeconds) {
          setState(() {
            _positionSeconds = posSec;
            _syncPending = true;
          });
          final durSec = _currentLesson?.durationSeconds ?? 0;
          if (durSec > 0 && (posSec / durSec) >= 0.9) {
            _markLessonComplete(isAuto: true);
          }
        }
      });

      _ytValueSubscription = ytController.listen((event) {
        if (!mounted) return;
        final isPlaying = event.playerState == PlayerState.playing;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      });

      setState(() {
        _isVideoInitialized = true;
        _isVideoBuffering = false;
      });
    } else {
      // Direct MP4 network fallback
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(mediaUrl),
        httpHeaders: const {'User-Agent': 'Mozilla/5.0 Compass/1.0'},
      );
      _videoController = controller;
      controller.initialize().then((_) {
        if (!mounted || _videoController != controller) return;
        controller.addListener(_videoListener);
        setState(() {
          _isVideoInitialized = true;
          _isVideoBuffering = false;
          if (autoPlay) {
            _isPlaying = true;
            controller.play();
          }
        });
      }).catchError((err) {
        if (!mounted) return;
        setState(() {
          _isVideoError = true;
          _isVideoBuffering = false;
        });
      });
    }
  }

  void _videoListener() {
    if (!mounted || _videoController == null || !_isVideoInitialized) return;
    final value = _videoController!.value;
    final newPos = value.position.inSeconds;
    final isPlaying = value.isPlaying;
    final isBuffering = value.isBuffering;

    if (newPos != _positionSeconds ||
        isPlaying != _isPlaying ||
        isBuffering != _isVideoBuffering) {
      setState(() {
        _positionSeconds = newPos;
        _isPlaying = isPlaying;
        _isVideoBuffering = isBuffering;
        _syncPending = true;
      });

      final totalDuration =
          _currentLesson?.durationSeconds ?? value.duration.inSeconds;
      if (totalDuration > 0) {
        final percent = (newPos / totalDuration) * 100;
        if (percent >= 90.0) {
          _markLessonComplete(isAuto: true);
        }
      }
    }
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

    final dur = _videoController != null &&
            _isVideoInitialized &&
            _videoController!.value.duration.inSeconds > 0
        ? _videoController!.value.duration.inSeconds
        : _currentLesson!.durationSeconds;

    final percent = dur > 0 ? (_positionSeconds / dur) * 100 : 0.0;
    ref.read(learningNotifierProvider.notifier).updateLessonProgress(
          courseId: widget.courseId,
          moduleId: _findModuleIdForLesson(_currentLesson!.id),
          lessonId: _currentLesson!.id,
          positionSeconds: _positionSeconds,
          durationSeconds: dur,
          percentage: percent,
          completed: percent >= 90.0,
        );
  }

  String _findModuleIdForLesson(String lessonId) {
    final learningState = ref.read(learningNotifierProvider);
    final course = learningState.resources.firstWhere(
      (r) => r.id == widget.courseId,
      orElse: () => learningState.resources.first,
    );
    for (final mod in course.modules) {
      if (mod.lessons.any((l) => l.id == lessonId)) {
        return mod.id;
      }
    }
    return '';
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

  Future<void> _openExternalStream(String url) async {
    final ytId = YoutubePlayerController.convertUrlToId(url);
    final target = (ytId != null && ytId.isNotEmpty)
        ? 'https://www.youtube.com/watch?v=$ytId'
        : url;
    final uri = Uri.parse(target);

    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Playing directly in application player with offline zero-data support.',
          ),
          backgroundColor: Color(0xFF166534),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Widget _buildVideoPlayer() {
    if (_currentLesson == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101418),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
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
            alignment: Alignment.center,
            children: [
              // 1. YouTube Player (1:1 with Web Version)
              if (_isYoutube && _youtubeController != null)
                YoutubePlayer(
                  controller: _youtubeController!,
                  aspectRatio: 16 / 9,
                )
              // 2. Hardware Video Player for Offline Downloaded Files
              else if (_videoController != null && _isVideoInitialized)
                VideoPlayer(_videoController!)
              // 3. Backdrop Placeholder while initializing
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF142417), Color(0xFF181F26)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

              // 4. Buffering / Loading Indicator
              if (_isVideoBuffering)
                Container(
                  color: Colors.black38,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.greenAccent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Loading YouTube Stream...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Error Fallback
              if (_isVideoError)
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          color: Colors.amberAccent,
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Streaming issue detected',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap retry or use the external stream button below',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(LucideIcons.refreshCw, size: 14),
                          label: const Text('Retry Stream'),
                          onPressed: () =>
                              _initVideoForCurrentLesson(autoPlay: true),
                        ),
                      ],
                    ),
                  ),
                ),

              // 6. Header Badges Overlay (Shown only for offline player or non-youtube)
              if (_isOfflinePlayback)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.tealAccent,
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.hardDrive,
                          color: Colors.tealAccent,
                          size: 11,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'OFFLINE (ZERO-DATA)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
      children: [
        Row(
          children: [
            // External Stream Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(LucideIcons.externalLink, size: 16),
                label: const Text(
                  'Stream Full Video',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () => _openExternalStream(mediaUrl),
              ),
            ),
            const SizedBox(width: 10),
            // Download Offline Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDownloaded
                      ? const Color(0xFF166534)
                      : const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  isDownloaded
                      ? LucideIcons.checkCircle
                      : (isDownloading
                          ? LucideIcons.loader
                          : LucideIcons.download),
                  size: 16,
                ),
                label: Text(
                  isDownloaded
                      ? 'Offline Ready ✓'
                      : (isDownloading
                          ? 'Downloading $progressPct%'
                          : 'Download Video'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () async {
                  if (isDownloaded) {
                    _initVideoForCurrentLesson(autoPlay: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Now playing downloaded offline video with zero data usage!',
                        ),
                        backgroundColor: Color(0xFF166534),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (!isDownloading) {
                    final lessonId = _currentLesson?.id ?? 'video_01';
                    // Companion offline video file for zero-data review
                    await ref.read(downloadTasksProvider.notifier).enqueue(
                          lessonId,
                          'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
                          '$lessonId.mp4',
                          1048576,
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Downloading video for offline zero-data playback...',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
        if (isDownloading) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isActive = lesson.id == _currentLesson?.id;
              final isCompleted = progressList
                  .any((p) => p.lessonId == lesson.id && p.completed);
              final isTaskDownloaded =
                  downloadTasks[lesson.id]?.state == DownloadState.completed &&
                      downloadTasks[lesson.id]?.savePath != null &&
                      File(downloadTasks[lesson.id]!.savePath).existsSync();

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: InkWell(
                  onTap: () => _onLessonSelect(lesson, progressList),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: isActive
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: isCompleted
                              ? const Icon(
                                  LucideIcons.checkCircle,
                                  color: Color(0xFF3A9742),
                                  size: 20,
                                )
                              : isActive
                                  ? const Icon(
                                      LucideIcons.play,
                                      color: Colors.green,
                                      size: 20,
                                    )
                                  : Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
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
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${lesson.durationSeconds ~/ 60} mins',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  if (isTaskDownloaded) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      LucideIcons.downloadCloud,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Offline Ready',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
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
