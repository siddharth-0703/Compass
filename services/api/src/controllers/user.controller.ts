import { Request, Response, NextFunction } from 'express';
import { userService } from '../services/user.service';

export class UserController {
  async saveScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const { schemeId } = req.body;
      const userId = (req as any).user?.id || 'anonymous_user'; // fallback for dev

      if (!schemeId) {
        return res.status(400).json({ success: false, error: { message: 'schemeId is required' } });
      }

      const result = await userService.saveScheme(userId, schemeId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  }

  async removeSavedScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const { schemeId } = req.params;
      const userId = (req as any).user?.id || 'anonymous_user';

      if (!schemeId) {
        return res.status(400).json({ success: false, error: { message: 'schemeId is required' } });
      }

      const result = await userService.removeSavedScheme(userId, schemeId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  }

  async getSavedSchemes(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = (req as any).user?.id || 'anonymous_user';
      const result = await userService.getSavedSchemes(userId);
      res.status(200).json(result);
    } catch (error) {
      next(error);
    }
  }
}
