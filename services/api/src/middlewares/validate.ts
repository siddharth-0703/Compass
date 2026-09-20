import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';

export const validate = (schema: AnyZodObject) => 
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const parsedData = await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      // Important Security Update (Phase 13 Rec 5):
      // Zod strips unknown fields by default in the returned object.
      // We must re-assign the stripped data back to the request object 
      // to ensure malicious payload properties never reach the business logic.
      req.body = parsedData.body;
      req.query = parsedData.query;
      req.params = parsedData.params;
      return next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid request data',
            details: error.errors.map(e => ({ path: e.path.join('.'), message: e.message }))
          }
        });
      }
      return next(error);
    }
  };
