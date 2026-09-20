import mongoose, { Schema, Document } from 'mongoose';
import { IContentReport } from '@rural/types';

export interface IContentReportDocument extends Omit<IContentReport, 'id'>, Document {}

const contentReportSchema = new Schema<IContentReportDocument>({
  reporterId: { type: String, required: true, index: true },
  targetType: { type: String, enum: ['User', 'Post', 'Listing', 'Scheme', 'Course'], required: true },
  targetId: { type: String, required: true, index: true },
  reason: { type: String, required: true },
  evidence: { type: String },
  status: { type: String, enum: ['Pending', 'Under Review', 'Resolved', 'Rejected', 'Escalated'], default: 'Pending', index: true },
  
  resolvedByAdminId: { type: String },
  resolutionNote: { type: String }
}, { timestamps: true });

export const ContentReportModel = mongoose.models.ContentReport || mongoose.model<IContentReportDocument>('ContentReport', contentReportSchema);
