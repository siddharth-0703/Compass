import pino from 'pino';
import pinoHttp from 'pino-http';
import { v4 as uuidv4 } from 'uuid';
import { Request, Response } from 'express';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV !== 'production' 
    ? {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'SYS:standard'
        }
      }
    : undefined,
});

export const httpLogger = pinoHttp({
  logger,
  genReqId: (req: Request) => {
    // Check if upstream (e.g. load balancer) sent a trace ID
    if (req.headers['x-request-id']) {
      return req.headers['x-request-id'] as string;
    }
    return uuidv4();
  },
  customProps: (req: Request, res: Response) => {
    return {
      traceId: req.id
    };
  }
});
