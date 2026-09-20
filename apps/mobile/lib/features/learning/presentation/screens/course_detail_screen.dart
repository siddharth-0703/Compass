import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/learning_provider.dart';
import '../../../../core/download/providers/download_provider.dart';
import '../../../../core/download/models/download_task.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  void _handleDownloadAction(String courseId, DownloadTask? task) {
    if (task == null ||
        task.state == DownloadState.failed ||
        task.state == DownloadState.cancelled) {
      ref.read(downloadTasksProvider.notifier).enqueue(
            courseId,
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            'course_$courseId.mp4',
            158000000,
          );
    } else if (task.state == DownloadState.downloading ||
        task.state == DownloadState.queued) {
      ref.read(downloadTasksProvider.notifier).pause(courseId);
    } else if (task.state == DownloadState.paused) {
      ref.read(downloadTasksProvider.notifier).resume(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningNotifierProvider);
    final course = learningState.resources.firstWhere(
      (r) => r.id == widget.courseId,
      orElse: () => throw Exception('Course not found'),
    );
    final isFavorite = learningState.favorites.contains(course.id);
    final progressState = ref.watch(courseProgressProvider(course.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
                color: Colors.white,
                onPressed: () {
                  ref
                      .read(learningNotifierProvider.notifier)
                      .toggleFavorite(course.id);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: course.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.grey[800]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                          label: Text(course.difficulty),
                          backgroundColor: Colors.blue.shade50,),
                      Text('${course.modules.length} Modules',
                          style: const TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold,),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black54, height: 1.4,),
                  ),
                  const SizedBox(height: 16),

                  // Progress display
                  progressState.when(
                    data: (progressList) {
                      final completedCount =
                          progressList.where((p) => p.completed).length;
                      final totalLessons = course.modules
                          .fold<int>(0, (sum, m) => sum + m.lessons.length);
                      final percent = totalLessons > 0
                          ? (completedCount / totalLessons * 100).round()
                          : 0;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Course Progress: $percent%',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,),),
                                Text(
                                    '$completedCount/$totalLessons Lessons Complete',),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                                value: percent / 100,
                                backgroundColor: Colors.blue.shade100,
                                color: Colors.blueAccent,),
                          ],
                        ),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) =>
                        const Text('Offline: Progress list loaded from cache.'),
                  ),

                  const SizedBox(height: 16),
                  _buildDownloadAction(context, widget.courseId),
                  const SizedBox(height: 24),
                  const Text('Course Outline',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const Divider(),
                ],
              ),
            ),
          ),

          // Render Modules and Lessons list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = course.modules[index];
                return ExpansionTile(
                  title: Text(module.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(module.description,
                      style: const TextStyle(fontSize: 12),),
                  children: module.lessons.map((lesson) {
                    final isVerified = lesson.contentStatus == 'VERIFIED';

                    return progressState.when(
                      data: (progressList) {
                        final isCompleted = progressList
                            .any((p) => p.lessonId == lesson.id && p.completed);
                        return ListTile(
                          leading: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : (isVerified
                                    ? Icons.play_circle_outline
                                    : Icons.lock_outline),
                            color: isCompleted
                                ? Colors.green
                                : (isVerified ? Colors.blue : Colors.grey),
                          ),
                          title: Text(lesson.title),
                          subtitle:
                              Text('${lesson.durationSeconds ~/ 60} minutes'),
                          onTap: () {
                            if (isVerified) {
                              context.push(
                                  '/learning/player/${course.id}?lessonId=${lesson.id}',);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Video coming soon in this language.',),),
                              );
                            }
                          },
                        );
                      },
                      loading: () =>
                          const ListTile(title: CircularProgressIndicator()),
                      error: (err, stack) => ListTile(
                        leading: Icon(isVerified
                            ? Icons.play_circle_outline
                            : Icons.lock_outline,),
                        title: Text(lesson.title),
                        onTap: () {
                          if (isVerified) {
                            context.push(
                                '/learning/player/${course.id}?lessonId=${lesson.id}',);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Video coming soon in this language.',),),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              childCount: course.modules.length,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),),
                ),
                onPressed: () {
                  // Enroll in course first, then open player starting at first lesson
                  ref.read(learningNotifierProvider.notifier).enroll(course.id);
                  final firstLessonId =
                      course.modules.firstOrNull?.lessons.firstOrNull?.id;
                  if (firstLessonId != null) {
                    context.push(
                        '/learning/player/${course.id}?lessonId=$firstLessonId',);
                  }
                },
                child: const Text('Start Course',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadAction(BuildContext context, String courseId) {
    final tasks = ref.watch(downloadTasksProvider);
    final task = tasks[courseId];

    if (task?.state == DownloadState.completed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.cloud_done, color: Colors.green),
            SizedBox(width: 12),
            Text('Available Offline',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold,),),
          ],
        ),
      );
    }

    if (task?.state == DownloadState.downloading ||
        task?.state == DownloadState.queued) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task?.state == DownloadState.queued
                  ? 'Queued...'
                  : 'Downloading...',),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () => _handleDownloadAction(courseId, task),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: task?.progress ?? 0.0),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.cloud_download),
        label: const Text('Download Course Videos for Offline Use'),
        onPressed: () => _handleDownloadAction(courseId, task),
      ),
    );
  }
}
