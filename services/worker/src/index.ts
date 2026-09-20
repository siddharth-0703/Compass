import { Worker, Job } from 'bullmq';
import { logger } from '@rural/logger';
import { connectDatabase, PostModel, SchemeModel, MentorProfileModel, LearningResourceModel, NotificationModel } from '@rural/database';
import axios from 'axios';

const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/rural_dev';
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000/api/v1/ai';

// Initialize Database connection for the worker
connectDatabase(MONGO_URI);

const aiWorker = new Worker('ai-tasks', async (job: Job) => {
  logger.info(`Processing job ${job.id} of type ${job.name}`);

  if (job.name === 'generate-embedding') {
    const { postId, content, tags, collection, payload } = job.data;

    try {
      // 1. Call the AI microservice to generate and store the embedding in Qdrant
      const response = await axios.post(`${AI_SERVICE_URL}/embeddings`, {
        text: content,
        collection: collection,
        payload: payload || { postId, tags, type: 'post' }
      });

      if (response.data.success) {
        const embeddingId = response.data.data.point_id;
        
        // 2. Update the corresponding MongoDB document
        if (collection === 'community_posts') {
          await PostModel.findByIdAndUpdate(postId, { embeddingId });
          logger.info(`Successfully embedded Post ${postId} into Qdrant.`);
        } else if (collection === 'government_schemes') {
          await SchemeModel.findByIdAndUpdate(postId, { embeddingId });
          logger.info(`Successfully embedded Scheme ${postId} into Qdrant.`);
        } else if (collection === 'mentor_profiles') {
          await MentorProfileModel.findByIdAndUpdate(postId, { embeddingId });
          logger.info(`Successfully embedded Mentor Profile ${postId} into Qdrant.`);
        } else if (collection === 'learning_resources') {
          await LearningResourceModel.findByIdAndUpdate(postId, { embeddingId });
          logger.info(`Successfully embedded Learning Resource ${postId} into Qdrant.`);
        }
      } else {
        throw new Error('AI Service failed to generate embedding');
      }

    } catch (error: any) {
      logger.error({ error: error.message }, `Failed to generate embedding for Post ${postId}`);
      throw error; // Let BullMQ handle retries
    }
  }
}, { connection: { host: REDIS_HOST, port: 6379 } });

// Notification Worker (Phase 11 Rec 5)
const notificationWorker = new Worker('notification-tasks', async (job: Job) => {
  if (job.name === 'deliver-notification') {
    try {
      // Create the notification document
      const notification = new NotificationModel({
        ...job.data,
        status: 'Delivered', // For MVP (In-App only), creating it effectively delivers it.
        deliveryAttempts: 1
      });
      await notification.save();
      logger.info(`Successfully delivered In-App Notification to User ${job.data.userId}`);
      
      // Future: If job.data.channel === 'Email', call SendGrid API here.
      
    } catch (error: any) {
      logger.error({ error: error.message }, `Failed to process notification for User ${job.data.userId}`);
      throw error;
    }
  }
}, { connection: { host: REDIS_HOST, port: 6379 } });


import { startSchemeSyncWorker } from './jobs/scheme-sync.job';

// Initialize the new Scheme Sync worker
const schemeSyncWorker = startSchemeSyncWorker();

aiWorker.on('completed', job => {
  logger.info(`${job.id} has completed!`);
});

aiWorker.on('failed', (job, err) => {
  logger.error({ err }, `${job?.id} has failed with ${err.message}`);
});

logger.info('Background Worker Service started successfully.');
