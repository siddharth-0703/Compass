import { Request, Response, NextFunction } from 'express';
import { MentorshipService } from '../services/mentorship.service';

const mentorshipService = new MentorshipService();

export class MentorshipController {
  async createProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await mentorshipService.createMentorProfile(req.user.userId, req.body);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async matchMentors(req: Request, res: Response, next: NextFunction) {
    try {
      const { businessId } = req.body;
      const response = await mentorshipService.matchMentors(businessId);
      if (!response.success) {
        return res.status(404).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getMentorDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await mentorshipService.getMentorDetails(req.params.mentorId);
      if (!response.success) {
        return res.status(404).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getMentorAvailability(req: Request, res: Response, next: NextFunction) {
    try {
      const { mentorId } = req.params;
      const { date } = req.query;
      const response = await mentorshipService.getMentorAvailability(mentorId, date as string);
      if (!response.success) {
        return res.status(404).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getMySessions(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await mentorshipService.getMySessions(req.user.userId);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async scheduleSession(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await mentorshipService.scheduleSession(req.user.userId, req.body);
      if (!response.success) {
        const status = response.error?.code === 'CONFLICT' ? 409 : 400;
        return res.status(status).json(response);
      }
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async cancelSession(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await mentorshipService.cancelSession(req.user.userId, req.params.sessionId);
      if (!response.success) {
        const status = response.error?.code === 'FORBIDDEN' ? 403 : response.error?.code === 'NOT_FOUND' ? 404 : 400;
        return res.status(status).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async rescheduleSession(req: Request, res: Response, next: NextFunction) {
    try {
      const { newStartTime, newEndTime } = req.body;
      const response = await mentorshipService.rescheduleSession(
        req.user.userId,
        req.params.sessionId,
        newStartTime,
        newEndTime
      );
      if (!response.success) {
        const status = response.error?.code === 'CONFLICT' ? 409 : response.error?.code === 'FORBIDDEN' ? 403 : 400;
        return res.status(status).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async submitFeedback(req: Request, res: Response, next: NextFunction) {
    try {
      const { rating, comment } = req.body;
      const response = await mentorshipService.submitFeedback(
        req.user.userId,
        req.params.sessionId,
        rating,
        comment
      );
      if (!response.success) {
        const status = response.error?.code === 'FORBIDDEN' ? 403 : 400;
        return res.status(status).json(response);
      }
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async explainMatch(req: Request, res: Response, next: NextFunction) {
    try {
      const { matchedRules, language } = req.body;
      const response = await mentorshipService.explainMatch(
        req.params.mentorId,
        matchedRules,
        language
      );
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
