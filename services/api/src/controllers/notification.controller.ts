import { Request, Response, NextFunction } from 'express';
import { NotificationService } from '../services/notification.service';

const notificationService = new NotificationService();

export class NotificationController {
  async getUnread(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await notificationService.getUnread(req.user.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await notificationService.getAll(req.user.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async markAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await notificationService.markAsRead(req.params.id, req.user.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async markAllAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await notificationService.markAllAsRead(req.user.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
