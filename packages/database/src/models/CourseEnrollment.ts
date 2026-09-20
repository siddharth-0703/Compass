import mongoose, { Schema, Document } from 'mongoose';
import { ICourseEnrollment } from '@rural/types';

export interface ICourseEnrollmentDocument extends Omit<ICourseEnrollment, 'id'>, Document {}

const courseEnrollmentSchema = new Schema<ICourseEnrollmentDocument>({
  userId: { type: String, required: true, index: true },
  courseId: { type: String, required: true, index: true },
  status: { type: String, enum: ['Started', 'In Progress', 'Completed', 'Dropped'], default: 'Started', index: true },
  progressPercentage: { type: Number, default: 0, min: 0, max: 100 },
  completedLessons: { type: [String], default: [] },
  lastAccessedAt: { type: Date, default: Date.now },
  certificateEarned: { type: Boolean, default: false }
}, { timestamps: true });

// A user should only have one enrollment record per course
courseEnrollmentSchema.index({ userId: 1, courseId: 1 }, { unique: true });

export const CourseEnrollmentModel = mongoose.models.CourseEnrollment || mongoose.model<ICourseEnrollmentDocument>('CourseEnrollment', courseEnrollmentSchema);
