import mongoose, { Schema, Document } from 'mongoose';
import { IPlatformDailyMetric } from '@rural/types';

export interface IPlatformDailyMetricDocument extends Omit<IPlatformDailyMetric, 'id'>, Document {}

const platformDailyMetricSchema = new Schema<IPlatformDailyMetricDocument>({
  date: { type: Date, required: true, unique: true, index: true },
  
  dailyActiveUsers: { type: Number, default: 0 },
  newRegistrations: { type: Number, default: 0 },
  activeBusinesses: { type: Number, default: 0 },
  marketplaceListingsCreated: { type: Number, default: 0 },
  communityPostsCreated: { type: Number, default: 0 }
}, { timestamps: true });

export const PlatformDailyMetricModel = mongoose.models.PlatformDailyMetric || mongoose.model<IPlatformDailyMetricDocument>('PlatformDailyMetric', platformDailyMetricSchema);
