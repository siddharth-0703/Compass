import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, hasPermission } from '@rural/auth';

declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Missing token' } });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = verifyAccessToken(token);
    req.user = decoded; // { userId, roles }
    next();
  } catch (error) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED', message: 'Invalid or expired token' } });
  }
};

export const requirePermission = (permission: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !req.user.roles) {
      return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: 'Access denied' } });
    }
    
    if (!hasPermission(req.user.roles, permission)) {
      return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: `Missing required permission: ${permission}` } });
    }
    next();
  };
};

export const requireAdmin = (req: Request, res: Response, next: NextFunction) => {
  if (!req.user || !req.user.roles) {
    return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: 'Access denied. Missing roles.' } });
  }

  // Assuming roles is an array of strings like ['Super Admin', 'User'] or just a 'User' string.
  // We'll enforce a strict check for any Admin level role.
  const adminRoles = ['Super Admin', 'Platform Admin', 'Regional Admin', 'Moderator'];
  const hasAdminRole = Array.isArray(req.user.roles) 
    ? req.user.roles.some((r: string) => adminRoles.includes(r))
    : adminRoles.includes(req.user.roles);
    
  if (!hasAdminRole) {
    return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: 'Admin access required.' } });
  }
  next();
};
