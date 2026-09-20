import mongoose, { Schema, Document } from 'mongoose';
import { IBusiness } from '@rural/types';

export interface IBusinessDocument extends Omit<IBusiness, 'id'>, Document {}

const locationSchema = new Schema({
  state: { type: String, required: true },
  district: { type: String, required: true },
  village: { type: String },
  pincode: { type: String, required: true },
  geo: {
    type: { type: String, enum: ['Point'] },
    coordinates: { type: [Number], default: undefined } // [longitude, latitude]
  }
}, { _id: false });

const financialsSchema = new Schema({
  annualTurnover: { type: Number },
  monthlyRevenue: { type: Number },
  monthlyProfit: { type: Number },
  monthlyExpenses: { type: Number }
}, { _id: false });

const analyticsSchema = new Schema({
  views: { type: Number, default: 0 },
  followers: { type: Number, default: 0 },
  profileCompletion: { type: Number, default: 0 },
  marketplaceListings: { type: Number, default: 0 },
  mentorSessions: { type: Number, default: 0 },
  schemeMatches: { type: Number, default: 0 },
  growthScore: { type: Number, default: 0 }
}, { _id: false });

const aiSchema = new Schema({
  embeddingId: { type: String },
  vectorId: { type: String },
  summary: { type: String },
  keywords: { type: [String], default: [] },
  tags: { type: [String], default: [] },
  classification: { type: String },
  recommendationScore: { type: Number, default: 0 }
}, { _id: false });

const businessSchema = new Schema<IBusinessDocument>({
  userId: { type: String, required: true, index: true },
  name: { type: String, required: true, index: true },
  description: { type: String, required: true },
  category: { 
    type: String, 
    required: true, 
    enum: ['Agriculture', 'Food Processing', 'Handicrafts', 'Textiles', 'Retail', 'Services', 'Manufacturing', 'Livestock', 'Tourism', 'Education', 'Technology', 'Healthcare', 'Fisheries'],
    index: true 
  },
  subcategory: { type: String },
  status: { 
    type: String, 
    enum: ['Draft', 'Pending Verification', 'Verified', 'Rejected', 'Suspended', 'Archived'], 
    default: 'Draft',
    index: true
  },
  yearStarted: { type: Number },
  gstNumber: { type: String },
  msmeNumber: { type: String },
  registrationType: { type: String },
  stage: { type: String, enum: ['idea', 'early', 'growth', 'mature'] },
  employees: { type: Number },
  womenOwned: { type: Boolean, default: false },
  farmerProducerOrganization: { type: Boolean, default: false },
  website: { type: String },
  socialMedia: { type: Map, of: String },
  languages: { type: [String], default: [] },
  operatingHours: { type: String },
  logoUrl: { type: String },
  coverImageUrl: { type: String },
  location: locationSchema,
  financials: financialsSchema,
  analytics: analyticsSchema,
  aiReadyMetadata: aiSchema
}, {
  timestamps: true
});

// Geo index for map-based searches
businessSchema.index({ 'location.geo': '2dsphere' });

export const BusinessModel = mongoose.models.Business || mongoose.model<IBusinessDocument>('Business', businessSchema);
