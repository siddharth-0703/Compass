import { Worker, Job } from 'bullmq';
import { logger } from '@rural/logger';
import { connectDatabase } from '@rural/database';
import { SchemePipeline } from '../schemes/SchemePipeline';
import { ManualImportAdapter } from '../schemes/adapters/ManualImportAdapter';
import { MySchemeAdapter } from '../schemes/adapters/MySchemeAdapter';

const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/rural_dev';

export const startSchemeSyncWorker = () => {
  connectDatabase(MONGO_URI);

  const worker = new Worker('scheme-sync-tasks', async (job: Job) => {
    logger.info(`Starting Scheme Sync Job ${job.id} for source ${job.data.sourceId}`);
    
    const { sourceId, syncJobId } = job.data;
    
    let adapter;
    if (sourceId === 'manual_import') {
      adapter = new ManualImportAdapter();
    } else if (sourceId === 'myscheme_gov_in') {
      adapter = new MySchemeAdapter();
    } else {
      throw new Error(`Unsupported sourceId: ${sourceId}`);
    }

    const pipeline = new SchemePipeline(adapter);
    const stats = await pipeline.runSync(syncJobId);
    
    logger.info(`Scheme Sync ${syncJobId} completed. Stats: ${JSON.stringify(stats)}`);
    return stats;

  }, { 
    connection: { host: REDIS_HOST, port: 6379 },
    concurrency: 1 
  });

  worker.on('failed', (job, err) => {
    logger.error({ err }, `Scheme Sync Job ${job?.id} failed critically.`);
  });

  return worker;
};
