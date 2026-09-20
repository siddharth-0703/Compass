import { Request, Response, NextFunction } from 'express';
import { AdminService } from '../services/admin.service';
import { observabilityService } from '../services/observability.service';

const adminService = new AdminService();

export class AdminController {
  async getReports(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.getReports(req.query.status);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async resolveReport(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.resolveReport(req.params.id, req.user.userId, req.body.resolutionNote);
      if (!response.success) return res.status(404).json(response);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async banUser(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.banUser(req.params.userId, req.user.userId, req.body.reason);
      if (!response.success) return res.status(404).json(response);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getPlatformMetrics(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.getPlatformMetrics();
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getHealth(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await observabilityService.getHealthMetrics();
      res.status(200).json({ success: true, data: response });
    } catch (error) {
      next(error);
    }
  }

  async getUsers(req: Request, res: Response, next: NextFunction) {
    try {
      const params = {
        page: req.query.page ? parseInt(req.query.page as string, 10) : 1,
        pageSize: req.query.pageSize ? parseInt(req.query.pageSize as string, 10) : 20,
        search: req.query.search as string,
        sortBy: req.query.sortBy as string,
        sortOrder: req.query.sortOrder as 'asc' | 'desc',
        filters: req.query.role ? { role: req.query.role } : undefined
      };
      const response = await adminService.getUsers(params);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async getBusinesses(req: Request, res: Response, next: NextFunction) {
    try {
      const params = {
        page: req.query.page ? parseInt(req.query.page as string, 10) : 1,
        pageSize: req.query.pageSize ? parseInt(req.query.pageSize as string, 10) : 20,
        search: req.query.search as string,
        sortBy: req.query.sortBy as string,
        sortOrder: req.query.sortOrder as 'asc' | 'desc',
        filters: {} as any
      };
      
      if (req.query.status) params.filters.status = req.query.status;
      if (req.query.category) params.filters.category = req.query.category;
      
      const response = await adminService.getBusinesses(params);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  // --- SCHEME ADMIN MANAGEMENT ---
  async syncSchemes(req: Request, res: Response, next: NextFunction) {
    try {
      const { source } = req.body;
      if (!source) {
        return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR', message: 'Missing source in request body' } });
      }
      // Trigger BullMQ async job and return job ID immediately
      const response = await adminService.triggerSchemeSync(req.user.userId, source);
      res.status(202).json(response);
    } catch (error) {
      next(error);
    }
  }

  async createScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.createScheme(req.user.userId, req.body);
      res.status(201).json(response);
    } catch (error) {
      next(error);
    }
  }

  async updateScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.updateScheme(req.user.userId, req.params.id, req.body);
      if (!response.success) return res.status(404).json(response);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async verifyScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.verifyScheme(req.user.userId, req.params.id);
      if (!response.success && response.error?.code === 'INVALID_TRANSITION') {
         return res.status(409).json(response); // Conflict for bad transition
      }
      if (!response.success) return res.status(404).json(response);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async rejectScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.rejectScheme(req.user.userId, req.params.id, req.body.reason || 'No reason provided');
      if (!response.success) return res.status(404).json(response);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }

  async archiveScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const response = await adminService.archiveScheme(req.user.userId, req.params.id);
      if (!response.success) return res.status(404).json(response);
      res.status(200).json(response);
    } catch (error) {
      next(error);
    }
  }
}
