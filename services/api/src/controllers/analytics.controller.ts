import { Request, Response, NextFunction } from 'express';
import { AnalyticsService } from '../services/analytics.service';

const analyticsService = new AnalyticsService();

export class AnalyticsController {
  async logMetric(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await analyticsService.logMetric(req.body);
      if (!response.success) return res.status(400).json(response);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getDashboard(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.params;
      const response = await analyticsService.getDashboard(businessId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async generateForecast(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.params;
      const response = await analyticsService.generateForecast(businessId);
      if (!response.success) return res.status(400).json(response);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }
}
