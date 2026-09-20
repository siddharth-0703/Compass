import mongoose, { Schema, Document } from 'mongoose';
import { ICourse } from '@rural/types';

export interface ILearningResourceDocument extends Omit<ICourse, 'id'>, Document {}

const localizedMediaSourceSchema = new Schema({
  contentUrl: { type: String, required: true },
  provider: { type: String, enum: ['YOUTUBE', 'MP4', 'HLS'], required: true },
  contentType: { type: String, default: 'VIDEO' }
}, { _id: false });

const localizedMediaSchema = new Schema({
  en: { type: localizedMediaSourceSchema },
  hi: { type: localizedMediaSourceSchema },
  mr: { type: localizedMediaSourceSchema }
}, { _id: false });

const lessonSchema = new Schema({
  id: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  durationSeconds: { type: Number, required: true },
  media: { type: localizedMediaSchema },
  resources: { type: [String], default: [] },
  order: { type: Number, required: true },
  isPublished: { type: Boolean, default: true },
  contentStatus: { type: String, enum: ['NOT_CONFIGURED', 'CONFIGURED', 'VERIFIED', 'UNAVAILABLE'], default: 'NOT_CONFIGURED' }
}, { _id: false });

const moduleSchema = new Schema({
  id: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  order: { type: Number, required: true },
  lessons: { type: [lessonSchema], default: [] }
}, { _id: false });

const courseSchema = new Schema<ILearningResourceDocument>({
  title: { type: String, required: true, index: true },
  description: { type: String, required: true },
  categories: { type: [String], required: true, index: true },
  difficulty: { type: String, enum: ['Beginner', 'Intermediate', 'Advanced', 'Expert'], required: true, index: true },
  thumbnailUrl: { type: String },
  modules: { type: [moduleSchema], default: [] }
}, { timestamps: true });

export const LearningResourceModel = mongoose.models.LearningResource || mongoose.model<ILearningResourceDocument>('LearningResource', courseSchema);
