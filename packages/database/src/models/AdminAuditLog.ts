import mongoose, { Schema, Document } from 'mongoose';
import { IAdminAuditLog } from '@rural/types';

export interface IAdminAuditLogDocument extends Omit<IAdminAuditLog, 'id'>, Document {}

const adminAuditLogSchema = new Schema<IAdminAuditLogDocument>({
  adminId: { type: String, required: true, index: true },
  action: { type: String, required: true },
  targetId: { type: String, required: true },
  targetType: { type: String, required: true },
  reason: { type: String, required: true },
  
  previousState: { type: Schema.Types.Mixed },
  newState: { type: Schema.Types.Mixed }
}, { timestamps: true });

export const AdminAuditLogModel = mongoose.models.AdminAuditLog || mongoose.model<IAdminAuditLogDocument>('AdminAuditLog', adminAuditLogSchema);
