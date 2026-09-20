import { Request, Response, NextFunction } from 'express';
import { BusinessService } from '../services/business.service';

const businessService = new BusinessService();

export class BusinessController {
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await businessService.createBusiness(req.user.userId, req.body);
      if (!response.success) {
        return res.status(400).json(response);
      }
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getMyBusinesses(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await businessService.getMyBusinesses(req.user.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await businessService.getBusinessById(req.params.id);
      if (!response.success) {
        return res.status(404).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await businessService.updateBusiness(req.user.userId, req.params.id, req.body);
      if (!response.success) {
        return res.status(403).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await businessService.deleteBusiness(req.user.userId, req.params.id);
      if (!response.success) {
        return res.status(403).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
