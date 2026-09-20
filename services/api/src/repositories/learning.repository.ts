import { LearningResourceModel, CourseEnrollmentModel, LessonProgressModel, ILearningResourceDocument, ICourseEnrollmentDocument } from '@rural/database';
import { ICourse, ILessonProgress } from '@rural/types';

export class LearningRepository {
  async createResource(data: Partial<ICourse>): Promise<ILearningResourceDocument> {
    const resource = new LearningResourceModel(data);
    return resource.save();
  }

  async findResourceById(id: string) {
    return LearningResourceModel.findById(id);
  }

  async findResourcesByCategory(categories: string[]) {
    if (categories.length > 0) {
      return LearningResourceModel.find({ categories: { $in: categories } });
    }
    return LearningResourceModel.find({});
  }

  async getAllResources() {
    return LearningResourceModel.find({});
  }

  async enroll(userId: string, courseId: string): Promise<ICourseEnrollmentDocument> {
    const enrollment = new CourseEnrollmentModel({ userId, courseId });
    return enrollment.save();
  }

  async findEnrollment(userId: string, courseId: string) {
    return CourseEnrollmentModel.findOne({ userId, courseId });
  }

  async findProgressForUser(userId: string, courseId: string) {
    return LessonProgressModel.find({ userId, courseId });
  }

  async updateLessonProgress(progress: ILessonProgress) {
    const { userId, courseId, moduleId, lessonId, positionSeconds, durationSeconds, percentage, completed, clientUpdatedAt } = progress;

    const existing = await LessonProgressModel.findOne({ userId, courseId, lessonId });

    if (existing) {
      // Conflict Resolution: Prefer the greatest position/percentage, and never revert completion
      const newPercentage = Math.max(existing.percentage, percentage);
      const newPosition = Math.max(existing.positionSeconds, positionSeconds);
      const isCompleted = existing.completed || completed;

      existing.percentage = newPercentage;
      existing.positionSeconds = newPosition;
      existing.completed = isCompleted;
      existing.clientUpdatedAt = clientUpdatedAt;
      
      await existing.save();
      return existing;
    } else {
      const doc = new LessonProgressModel({
        userId,
        courseId,
        moduleId,
        lessonId,
        positionSeconds,
        durationSeconds,
        percentage,
        completed,
        clientUpdatedAt
      });
      await doc.save();
      return doc;
    }
  }

  async recalculateCourseProgress(userId: string, courseId: string) {
    const course = await this.findResourceById(courseId);
    if (!course) return null;

    // Count total lessons
    let totalLessons = 0;
    const lessonIds: string[] = [];
    for (const mod of course.modules) {
      for (const les of mod.lessons) {
        totalLessons++;
        lessonIds.push(les.id);
      }
    }

    if (totalLessons === 0) return null;

    // Get completed lessons for this course
    const completedDocs = await LessonProgressModel.find({
      userId,
      courseId,
      lessonId: { $in: lessonIds },
      completed: true
    });

    const completedLessonIds = completedDocs.map(d => d.lessonId);
    const progressPercentage = Math.round((completedLessonIds.length / totalLessons) * 100);

    return CourseEnrollmentModel.findOneAndUpdate(
      { userId, courseId },
      {
        progressPercentage,
        completedLessons: completedLessonIds,
        status: progressPercentage === 100 ? 'Completed' : 'In Progress',
        lastAccessedAt: new Date(),
        certificateEarned: progressPercentage === 100
      },
      { new: true, upsert: true }
    );
  }
}
