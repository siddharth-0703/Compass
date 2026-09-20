import mongoose, { Schema, Document } from 'mongoose';
import { IUserReputation } from '@rural/types';

export interface IUserReputationDocument extends Omit<IUserReputation, 'id'>, Document {}

const userReputationSchema = new Schema<IUserReputationDocument>({
  userId: { type: String, required: true, unique: true, index: true },
  
  score: { type: Number, default: 0 },
  tier: { type: String, enum: ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Community Leader'], default: 'Bronze' },
  trustScore: { type: Number, default: 50, min: 0, max: 100 },
  
  badges: { type: [String], default: [] },
  milestones: { type: [String], default: [] },
  
  activityHistory: [{
    action: { type: String },
    pointsAwarded: { type: Number },
    timestamp: { type: Date, default: Date.now }
  }]
}, { timestamps: true });

export const UserReputationModel = mongoose.models.UserReputation || mongoose.model<IUserReputationDocument>('UserReputation', userReputationSchema);
