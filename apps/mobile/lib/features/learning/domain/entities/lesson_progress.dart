class LessonProgress {
  final String userId;
  final String courseId;
  final String moduleId;
  final String lessonId;
  final int positionSeconds;
  final int durationSeconds;
  final double percentage;
  final bool completed;
  final DateTime clientUpdatedAt;

  const LessonProgress({
    required this.userId,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.percentage,
    required this.completed,
    required this.clientUpdatedAt,
  });
}
