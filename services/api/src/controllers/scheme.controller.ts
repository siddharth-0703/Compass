import { Request, Response, NextFunction } from 'express';
import { SchemeService } from '../services/scheme.service';

const schemeService = new SchemeService();

export class SchemeController {
  async createScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await schemeService.createScheme(req.body);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  /**
   * @openapi
   * /api/v1/schemes/recommendations/{businessId}:
   *   get:
   *     description: Deterministically evaluate and rank scheme recommendations for a specific business profile.
   *     tags: [Schemes]
   */
  async getRecommendations(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.params;
      
      // In Phase 1 we pass 'undefined' for the User object to rely on the business profile.
      const response = await schemeService.getRecommendations(businessId, undefined);
      
      if (!response.success) {
        return res.status(404).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // Backwards compatibility alias for the old mobile endpoints
  async matchSchemes(req: Request, res: Response, next: NextFunction) {
    return this.getRecommendations(req, res, next);
  }
}
