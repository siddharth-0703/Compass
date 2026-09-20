import mongoose, { Schema, Document } from 'mongoose';
import { IMembership } from '@rural/types';

export interface IMembershipDocument extends Omit<IMembership, 'id'>, Document {}

const membershipSchema = new Schema<IMembershipDocument>({
  groupId: { type: String, required: true, index: true },
  userId: { type: String, required: true, index: true },
  role: { type: String, enum: ['Owner', 'Admin', 'Moderator', 'Member'], default: 'Member' },
  status: { type: String, enum: ['Pending', 'Approved', 'Rejected', 'Blocked'], default: 'Approved' },
  joinedAt: { type: Date, default: Date.now }
});

// A user can only have one membership per group
membershipSchema.index({ groupId: 1, userId: 1 }, { unique: true });

export const MembershipModel = mongoose.models.Membership || mongoose.model<IMembershipDocument>('Membership', membershipSchema);
