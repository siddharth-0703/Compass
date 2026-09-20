import mongoose, { Schema, Document } from 'mongoose';
import { IMentorshipSession } from '@rural/types';

export interface IMentorshipSessionDocument extends Omit<IMentorshipSession, 'id'>, Document {}

const sessionNotesSchema = new Schema({
  mentorObservations: { type: String },
  businessChallenges: { type: String },
  recommendations: { type: String },
  nextActions: { type: String },
  entrepreneurProgress: { type: String }
}, { _id: false });

const sessionSchema = new Schema<IMentorshipSessionDocument>({
  mentorId: { type: String, required: true, index: true },
  businessId: { type: String, required: true, index: true },
  entrepreneurId: { type: String, required: true, index: true },
  status: { type: String, enum: ['Requested', 'Pending', 'Accepted', 'Rejected', 'Scheduled', 'In Progress', 'Completed', 'Cancelled', 'No Show', 'Rescheduled'], default: 'Requested', index: true },
  scheduledAt: { type: Date },
  durationMinutes: { type: Number, required: true },
  meetingPlatform: { type: String, enum: ['Google Meet', 'Zoom', 'Microsoft Teams', 'In-App WebRTC'], default: 'Google Meet' },
  meetingLink: { type: String },
  goals: { type: [String], default: [] },
  notes: sessionNotesSchema,
  rating: { type: Number, min: 1, max: 5 },
  feedback: { type: String }
}, { timestamps: true });

export const MentorshipSessionModel = mongoose.models.MentorshipSession || mongoose.model<IMentorshipSessionDocument>('MentorshipSession', sessionSchema);
