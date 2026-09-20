import mongoose, { Schema, Document } from 'mongoose';
import { ILessonProgress } from '@rural/types';

export interface ILessonProgressDocument extends Document, ILessonProgress {}

const lessonProgressSchema = new Schema<ILessonProgressDocument>({
  userId: { type: String, required: true, index: true },
  courseId: { type: String, required: true, index: true },
  moduleId: { type: String, required: true },
  lessonId: { type: String, required: true, index: true },
  positionSeconds: { type: Number, default: 0 },
  durationSeconds: { type: Number, required: true },
  percentage: { type: Number, default: 0, min: 0, max: 100 },
  completed: { type: Boolean, default: false },
  clientUpdatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

// Ensure unique record per user per lesson
lessonProgressSchema.index({ userId: 1, courseId: 1, lessonId: 1 }, { unique: true });

export const LessonProgressModel = mongoose.models.LessonProgress || mongoose.model<ILessonProgressDocument>('LessonProgress', lessonProgressSchema);
