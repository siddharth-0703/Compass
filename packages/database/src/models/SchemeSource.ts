import mongoose, { Schema, Document } from 'mongoose';
import { SchemeSourceConfig } from '@rural/types';

export interface ISchemeSourceDocument extends Omit<SchemeSourceConfig, 'id'>, Document {}

const schemeSourceSchema = new Schema<ISchemeSourceDocument>({
  sourceId: { type: String, required: true, unique: true, index: true },
  sourceName: { type: String, required: true },
  type: { type: String, enum: ['API', 'JSON', 'CSV', 'MANUAL'], required: true },
  enabled: { type: Boolean, default: false },
  
  baseUrl: { type: String },
  credentialsConfigured: { type: Boolean, default: false }, // Enforces environment variables check
  
  lastSyncAt: { type: Date },
  lastSuccessfulSyncAt: { type: Date }
}, { timestamps: true });

export const SchemeSourceModel = mongoose.models.SchemeSource || mongoose.model<ISchemeSourceDocument>('SchemeSource', schemeSourceSchema);
