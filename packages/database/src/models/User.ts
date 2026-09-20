import mongoose, { Schema, Document } from 'mongoose';
import { IUser } from '@rural/types';

export interface IUserDocument extends Omit<IUser, 'id'>, Document {}

const userSchema = new Schema<IUserDocument>({
  phone: { type: String, required: true, unique: true },
  email: { type: String, sparse: true, unique: true },
  roles: { type: [String], default: ['entrepreneur'] },
  name: { type: String },
  isVerified: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true },
  accountStatus: { type: String, enum: ['active', 'suspended', 'pending_verification'], default: 'active' },
  profileCompletion: { type: Number, default: 10 },
  lastLogin: { type: Date },
  failedLoginAttempts: { type: Number, default: 0 },
  passwordHash: { type: String }
}, {
  timestamps: true
});

// Avoid re-compiling model in dev hot-reloads
export const UserModel = mongoose.models.User || mongoose.model<IUserDocument>('User', userSchema);
