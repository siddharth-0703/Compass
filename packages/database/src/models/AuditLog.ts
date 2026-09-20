import mongoose, { Schema, Document } from 'mongoose';
import { IAuditLog } from '@rural/types';

export interface IAuditLogDocument extends Omit<IAuditLog, 'id'>, Document {}

const auditLogSchema = new Schema<IAuditLogDocument>({
  userId: { type: String, required: true, index: true },
  action: { type: String, required: true },
  ip: { type: String },
  device: { type: String },
  browser: { type: String },
  timestamp: { type: Date, default: Date.now },
  metadata: { type: Schema.Types.Mixed }
});

export const AuditLogModel = mongoose.models.AuditLog || mongoose.model<IAuditLogDocument>('AuditLog', auditLogSchema);
