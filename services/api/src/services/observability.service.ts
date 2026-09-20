import { logger } from '@rural/logger';
import mongoose from 'mongoose';
import Redis from 'ioredis';

class ObservabilityService {
  private redisClient: Redis;

  constructor() {
    this.redisClient = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', { family: 0 });
    this.redisClient.on('error', (err) => logger.error({ err }, 'Redis Observability Error'));
  }

  async getHealthMetrics() {
    const mongoStatus = mongoose.connection.readyState === 1 ? 'Healthy' : 'Degraded';
    
    let redisStatus = 'Healthy';
    try {
      await this.redisClient.ping();
    } catch (e) {
      redisStatus = 'Degraded';
      logger.error(`Redis Health Check Failed: ${e}`);
    }

    return {
      status: (mongoStatus === 'Healthy' && redisStatus === 'Healthy') ? 'Healthy' : 'Degraded',
      services: {
        api: 'Healthy',
        database: mongoStatus,
        redis: redisStatus,
        ai: process.env.ENABLE_AI === 'true' ? 'Healthy' : 'Disabled'
      },
      metrics: {
        uptime: process.uptime(),
        memoryUsage: process.memoryUsage(),
        // Mock queue size, in production fetch from bullmq
        activeSyncConflicts: Math.floor(Math.random() * 5),
        aiLatencyAvgMs: 450 
      }
    };
  }
}

export const observabilityService = new ObservabilityService();
