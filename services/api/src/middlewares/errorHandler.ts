import { Request, Response, NextFunction } from 'express';
import { logger } from '@rural/logger';

// Global error format (Rec 10)
export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  logger.error({ error: err.message, stack: err.stack, path: req.path }, 'Unhandled Error:');

  const statusCode = err.statusCode || 500;
  const errorCode = err.code || 'INTERNAL_SERVER_ERROR';
  const message = err.message || 'An unexpected error occurred.';

  res.status(statusCode).json({
    success: false,
    error: {
      code: errorCode,
      message: message
    }
  });
};
