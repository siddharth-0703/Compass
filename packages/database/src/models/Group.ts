import mongoose, { Schema, Document } from 'mongoose';
import { IGroup } from '@rural/types';

export interface IGroupDocument extends Omit<IGroup, 'id'>, Document {}

const groupSchema = new Schema<IGroupDocument>({
  name: { type: String, required: true, index: true },
  description: { type: String, required: true },
  type: { type: String, enum: ['location', 'industry', 'government', 'learning', 'private', 'public', 'hybrid'], required: true },
  visibility: { type: String, enum: ['Public', 'Private', 'Invite Only', 'Verified Only'], default: 'Public' },
  tags: { type: [String], default: [] },
  location: { type: Schema.Types.Mixed }, // Maps to IBusinessLocation
  industry: { type: String },
  memberCount: { type: Number, default: 1 },
  ownerId: { type: String, required: true, index: true },
  coverImageUrl: { type: String }
}, { timestamps: true });

export const GroupModel = mongoose.models.Group || mongoose.model<IGroupDocument>('Group', groupSchema);
