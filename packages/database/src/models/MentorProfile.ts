import mongoose, { Schema, Document } from 'mongoose';
import { IMentorProfile } from '@rural/types';

export interface IMentorProfileDocument extends Omit<IMentorProfile, 'id'>, Document {}

const expertiseSchema = new Schema({
  industries: { type: [String], default: [] },
  businessStages: { type: [String], default: [] },
  businessFunctions: { type: [String], default: [] },
  technicalSkills: { type: [String], default: [] },
  softSkills: { type: [String], default: [] },
  languages: { type: [String], default: [] },
  experienceYears: { type: Number, required: true }
}, { _id: false });

const availabilitySchema = new Schema({
  timezone: { type: String, default: 'Asia/Kolkata' },
  availableDays: { type: [String], default: [] },
  timeSlots: { type: [String], default: [] },
  sessionDurationMinutes: { type: Number, default: 45 },
  bufferTimeMinutes: { type: Number, default: 15 },
  maxSessionsPerWeek: { type: Number, default: 5 }
}, { _id: false });

const reputationSchema = new Schema({
  completedSessions: { type: Number, default: 0 },
  averageRating: { type: Number, default: 0 },
  responseTimeHours: { type: Number, default: 24 },
  acceptanceRate: { type: Number, default: 100 },
  repeatSessions: { type: Number, default: 0 }
}, { _id: false });

const mentorProfileSchema = new Schema<IMentorProfileDocument>({
  userId: { type: String, required: true, index: true, unique: true },
  headline: { type: String, required: true },
  bio: { type: String, required: true },
  expertise: expertiseSchema,
  availability: availabilitySchema,
  reputation: reputationSchema,
  verificationStatus: { type: String, enum: ['Pending', 'Verified', 'Rejected', 'Suspended'], default: 'Pending', index: true },
  verificationSource: { type: String },
  sessionType: { type: String, enum: ['Free', 'Paid', 'Sponsored'], default: 'Free' },
  embeddingId: { type: String }
}, { timestamps: true });

export const MentorProfileModel = mongoose.models.MentorProfile || mongoose.model<IMentorProfileDocument>('MentorProfile', mentorProfileSchema);
