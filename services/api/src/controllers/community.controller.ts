import { Request, Response, NextFunction } from 'express';
import { CommunityService } from '../services/community.service';

const communityService = new CommunityService();

export class CommunityController {
  async createGroup(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await communityService.createGroup(req.user.userId, req.body);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async createPost(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await communityService.createPost(req.user.userId, req.body);
      if (!response.success) {
        return res.status(403).json(response); // Blocked by moderation or non-member
      }
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getGroupPosts(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await communityService.getGroupPosts(req.params.groupId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
