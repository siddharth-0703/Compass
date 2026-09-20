import { Request, Response, NextFunction } from 'express';
import { LearningService } from '../services/learning.service';

const learningService = new LearningService();

export class LearningController {
  async createResource(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await learningService.createResource(req.body);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getAllResources(req: Request, res: Response, next: NextFunction) {
    try {
      const resources = await learningService.getAllResources();
      res.status(200).json({ success: true, data: resources });
    } catch (error) {
      next(error);
    }
  }

  async recommendResources(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.params;
      const response = await learningService.recommendResources(businessId);
      if (!response.success) {
        return res.status(404).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async enroll(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await learningService.enroll(req.user.userId, req.body);
      if (!response.success) {
        return res.status(400).json(response);
      }
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async updateProgress(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await learningService.updateProgress(req.user.userId, req.body);
      if (!response.success) {
        const code = response.error?.code === 'NOT_FOUND' ? 404 : 400;
        return res.status(code).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getCourseProgress(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await learningService.getCourseProgress(req.user.userId, req.params.courseId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
