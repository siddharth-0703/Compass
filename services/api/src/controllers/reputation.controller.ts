import { Request, Response, NextFunction } from 'express';
import { ReputationService } from '../services/reputation.service';
import { z } from 'zod';
import { validate } from '../middlewares/validate';

const reputationService = new ReputationService();

const awardSchema = z.object({
  body: z.object({
    points: z.number().min(1),
    action: z.string().min(5)
  })
});

export class ReputationController {
  async getReputation(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await reputationService.getReputation(req.params.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async awardPoints(req: Request, res: Response, next: NextFunction) {
    try {
      // Typically, awarding points would be an internal service call, but we expose an endpoint for the MVP/testing
      const response = await reputationService.awardPoints(req.params.userId, req.body.points, req.body.action);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getLeaderboard(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await reputationService.getLeaderboard();
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
