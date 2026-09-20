import mongoose, { Schema, Document } from 'mongoose';
import { ISession } from '@rural/types';

export interface ISessionDocument extends Omit<ISession, 'id'>, Document {}

const sessionSchema = new Schema<ISessionDocument>({
  userId: { type: String, required: true, index: true },
  refreshTokenHash: { type: String, required: true, unique: true },
  deviceName: { type: String },
  deviceType: { type: String },
  browser: { type: String },
  ip: { type: String },
  lastActive: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true, index: { expires: '1s' } },
  isRevoked: { type: Boolean, default: false }
});

export const SessionModel = mongoose.models.Session || mongoose.model<ISessionDocument>('Session', sessionSchema);
