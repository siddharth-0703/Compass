import mongoose, { Schema, Document } from 'mongoose';
import { IGovernmentScheme } from '@rural/types';

export interface ISchemeDocument extends Omit<IGovernmentScheme, 'id'>, Document {}

const eligibilityRuleSchema = new Schema({
  field: { type: String, required: true },
  operator: { type: String, required: true, enum: ['EQ', 'NEQ', 'GT', 'GTE', 'LT', 'LTE', 'IN', 'NOT_IN', 'BETWEEN', 'CONTAINS', 'EXISTS'] },
  value: { type: Schema.Types.Mixed },
  logicalGroup: { type: String, enum: ['AND', 'OR'] },
  sourceText: { type: String },
  sourceUrl: { type: String },
  confidence: { type: String, enum: ['EXACT', 'STRUCTURED', 'AMBIGUOUS'] },
  requiresReview: { type: Boolean, default: false }
}, { _id: false });

const provenanceSchema = new Schema({
  sourceId: { type: String, required: true, index: true },
  sourceName: { type: String, required: true },
  sourceUrl: { type: String },
  externalSchemeId: { type: String, index: true },
  fetchedAt: { type: Date, required: true },
  lastVerifiedAt: { type: Date },
  sourceVersion: { type: String },
  sourceHash: { type: String },
  verificationStatus: { 
    type: String, 
    enum: ['UNVERIFIED', 'PENDING_REVIEW', 'VERIFIED', 'REJECTED'],
    required: true,
    default: 'UNVERIFIED',
    index: true
  },
  verifiedBy: { type: String },
  verifiedAt: { type: Date }
}, { _id: false });

const benefitSchema = new Schema({
  type: { type: String, required: true },
  description: { type: String, required: true },
  amount: { type: Number },
  percentage: { type: Number },
  currency: { type: String, default: 'INR' }
}, { _id: false });

const schemeSchema = new Schema<ISchemeDocument>({
  schemeCode: { type: String, required: true },
  name: { type: String, required: true, index: true },
  localizedName: { type: Map, of: String },
  shortDescription: { type: String, required: true },
  description: { type: String },
  ministry: { type: String },
  department: { type: String, index: true },
  category: { 
    type: String, 
    enum: ['AGRICULTURE', 'ENTREPRENEURSHIP', 'FINANCE', 'EMPLOYMENT', 'EDUCATION', 'HOUSING', 'WOMEN', 'MSME', 'STARTUP', 'SOCIAL_WELFARE', 'DIGITAL', 'OTHER'], 
    required: true,
    index: true 
  },
  targetGroups: { type: [String], default: [] },
  benefits: [benefitSchema],
  eligibilityRules: [eligibilityRuleSchema],
  requiredDocuments: { type: [String], default: [] },
  applicationProcess: { type: String },
  officialSourceUrl: { type: String, required: true },
  applicationUrl: { type: String },
  states: { type: [String], default: [] },
  districts: { type: [String], default: [] },
  languages: { type: [String], default: ['en'] },
  status: { 
    type: String, 
    enum: ['DRAFT', 'PENDING_REVIEW', 'VERIFIED', 'ACTIVE', 'ARCHIVED', 'REJECTED', 'PENDING_ARCHIVAL'], 
    default: 'DRAFT', 
    index: true 
  },
  
  provenance: provenanceSchema,
  lastReviewedAt: { type: Date, required: true },
  version: { type: Number, required: true, default: 1 },

}, { timestamps: true });

// Create compound index for deduplication identity (sourceId + externalSchemeId)
schemeSchema.index({ 'provenance.sourceId': 1, 'provenance.externalSchemeId': 1 }, { unique: true, sparse: true });

// Avoid re-compiling model in dev hot-reloads
export const SchemeModel = mongoose.models.Scheme || mongoose.model<ISchemeDocument>('Scheme', schemeSchema);
