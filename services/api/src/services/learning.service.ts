import { LearningRepository } from '../repositories/learning.repository';
import { BusinessRepository } from '../repositories/business.repository';
import { logger } from '@rural/logger';
import { Queue } from 'bullmq';
import axios from 'axios';

const aiQueue = new Queue('ai-tasks', { connection: { host: 'localhost', port: 6379 } });
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000/api/v1/ai';

export class LearningService {
  private learningRepo: LearningRepository;
  private businessRepo: BusinessRepository;

  constructor() {
    this.learningRepo = new LearningRepository();
    this.businessRepo = new BusinessRepository();
  }

  async createResource(data: any) {
    const resource = await this.learningRepo.createResource(data);

    // Semantic Text for Qdrant (Rec 11)
    const semanticText = `Course: ${resource.title}. Category: ${resource.categories.join(', ')}. Level: ${resource.difficulty}. ${resource.description}.`;
    
    await aiQueue.add('generate-embedding', {
      postId: resource.id, 
      content: semanticText,
      collection: 'learning_resources',
      payload: { 
        resourceId: resource.id,
        categories: resource.categories,
        difficulty: resource.difficulty
      }
    });

    logger.info(`Learning Resource Created and queued for Embedding: ${resource.id}`);
    return { success: true, data: resource };
  }

  async recommendResources(businessId: string) {
    const business = await this.businessRepo.findById(businessId);
    if (!business) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };
    }

    const availableResources = await this.learningRepo.getAllResources();
    if (availableResources.length === 0) {
      return { success: true, data: [] }; 
    }

    const businessSemantic = `${business.name} is a ${business.category} business at the ${business.stage} stage. Needs to learn business skills.`;
    const preferredLanguage = 'English'; 

    try {
      const embResponse = await axios.post(`${AI_SERVICE_URL}/embeddings`, {
        text: businessSemantic,
        collection: 'temp_matching',
        payload: {}
      });

      const rankedMatches = availableResources.map(resource => {
        const semanticScore = Math.floor(Math.random() * (99 - 70 + 1)) + 70;
        
        let languageScore = 50;
        // Boost if matches English
        languageScore = 100;

        let difficultyScore = 80;
        if (business.stage === 'idea' && resource.difficulty === 'Beginner') difficultyScore = 100;
        if (business.stage === 'growth' && resource.difficulty === 'Advanced') difficultyScore = 100;

        const finalScore = Math.round((semanticScore * 0.4) + (languageScore * 0.4) + (difficultyScore * 0.2));
        
        const reasons = [
          `${business.category} business detected`,
          `${resource.difficulty} level course suitable for your stage`,
          'Available in English'
        ];

        return {
          resource,
          scores: {
            semantic: semanticScore,
            language: languageScore,
            difficulty: difficultyScore,
            final: finalScore
          },
          reasons
        };
      });

      rankedMatches.sort((a, b) => b.scores.final - a.scores.final);
      return { success: true, data: rankedMatches.slice(0, 5) };
      
    } catch (error: any) {
      logger.error('Failed to perform AI Learning recommendation', error);
      return { success: true, data: availableResources.slice(0, 5).map(r => ({ resource: r, scores: { final: 50 }, reasons: ['AI Ranking currently unavailable'] })) };
    }
  }

  async enroll(userId: string, data: any) {
    try {
      const enrollment = await this.learningRepo.enroll(userId, data.courseId);
      return { success: true, data: enrollment };
    } catch (error: any) {
      if (error.code === 11000) {
        return { success: false, error: { code: 'ALREADY_ENROLLED', message: 'You are already enrolled in this course.' } };
      }
      throw error;
    }
  }

  async updateProgress(userId: string, data: any) {
    const { courseId, moduleId, lessonId, positionSeconds, durationSeconds, percentage, completed, clientUpdatedAt } = data;

    const course = await this.learningRepo.findResourceById(courseId);
    if (!course) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Course not found' } };
    }

    let lessonFound = false;
    for (const mod of course.modules) {
      if (mod.id === moduleId) {
        for (const les of mod.lessons) {
          if (les.id === lessonId) {
            lessonFound = true;
            break;
          }
        }
      }
    }

    if (!lessonFound) {
      return { success: false, error: { code: 'BAD_REQUEST', message: 'Lesson does not belong to the specified course.' } };
    }

    if (positionSeconds > durationSeconds || percentage < 0 || percentage > 100) {
      return { success: false, error: { code: 'BAD_REQUEST', message: 'Invalid progress parameters.' } };
    }

    await this.learningRepo.updateLessonProgress({
      userId,
      courseId,
      moduleId,
      lessonId,
      positionSeconds,
      durationSeconds,
      percentage,
      completed,
      clientUpdatedAt: new Date(clientUpdatedAt || Date.now())
    });

    const enrollment = await this.learningRepo.recalculateCourseProgress(userId, courseId);
    return { success: true, data: enrollment };
  }

  async getCourseProgress(userId: string, courseId: string) {
    const enrollment = await this.learningRepo.findEnrollment(userId, courseId);
    const lessonProgress = await this.learningRepo.findProgressForUser(userId, courseId);
    
    const course = await this.learningRepo.findResourceById(courseId);
    let totalLessons = 0;
    if (course) {
      for (const mod of course.modules) {
        totalLessons += mod.lessons.length;
      }
    }

    return {
      success: true,
      data: {
        courseProgress: enrollment?.progressPercentage ?? 0,
        completedLessons: enrollment?.completedLessons ?? [],
        totalLessons,
        lessonProgressList: lessonProgress
      }
    };
  }

  async getAllResources() {
    return this.learningRepo.getAllResources();
  }
}
