import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';

// Use a dedicated redis client for rate limiting
const redisClient = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', { family: 0 });
redisClient.on('error', (err) => console.error('Redis RateLimiter Error:', err));

const createLimiter = (prefix: string, windowMs: number, max: number, message: string) => {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Disable the `X-RateLimit-*` headers
    message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message } },
    store: new RedisStore({
      sendCommand: (...args: string[]) => redisClient.call(args[0], ...args.slice(1)) as any,
      prefix: `rl:${prefix}:`,
    }),
  });
};

// General API Limits (High)
export const globalLimiter = createLimiter(
  'global', 
  15 * 60 * 1000, // 15 minutes
  500, // Limit each IP to 500 requests per window
  'Too many requests from this IP, please try again later.'
);

// Auth Limits (Strict - prevent brute force)
export const authLimiter = createLimiter(
  'auth',
  15 * 60 * 1000,
  20, 
  'Too many authentication attempts, please try again after 15 minutes.'
);

// AI Action Limits (Very Strict - prevent cost abuse)
export const aiLimiter = createLimiter(
  'ai',
  60 * 60 * 1000, // 1 Hour
  50, // Max 50 AI requests per hour per IP
  'AI inference quota exceeded. Please try again later.'
);

// Admin Action Limits (Very Strict)
export const adminLimiter = createLimiter(
  'admin',
  15 * 60 * 1000,
  30, 
  'Too many administrative actions. Please slow down.'
);
