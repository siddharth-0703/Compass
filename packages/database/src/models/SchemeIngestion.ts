import mongoose, { Schema, Document } from 'mongoose';
import { SchemeIngestionRecord } from '@rural/types';

export interface ISchemeIngestionDocument extends Omit<SchemeIngestionRecord, 'id'>, Document {}

const schemeIngestionSchema = new Schema<ISchemeIngestionDocument>({
  sourceId: { type: String, required: true, index: true },
  externalSchemeId: { type: String, index: true },
  
  // Storing the entire chaotic government API JSON structure
  rawPayload: { type: Schema.Types.Mixed, required: true },
  payloadHash: { type: String, required: true, index: true },
  
  fetchedAt: { type: Date, required: true },
  syncJobId: { type: String, index: true },
  
  processingStatus: {
    type: String,
    enum: ['RECEIVED', 'TRANSFORMED', 'VALIDATED', 'REJECTED', 'IMPORTED'],
    required: true,
    default: 'RECEIVED',
    index: true
  },
  
  validationErrors: { type: [String], default: [] }
}, { timestamps: true });

// Prevent processing identical payloads from the same source twice
schemeIngestionSchema.index({ sourceId: 1, payloadHash: 1 }, { unique: true });

export const SchemeIngestionModel = mongoose.models.SchemeIngestion || mongoose.model<ISchemeIngestionDocument>('SchemeIngestion', schemeIngestionSchema);
