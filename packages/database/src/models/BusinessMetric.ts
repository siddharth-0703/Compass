import mongoose, { Schema, Document } from 'mongoose';
import { IBusinessMetric } from '@rural/types';

export interface IBusinessMetricDocument extends Omit<IBusinessMetric, 'id'>, Document {}

const businessMetricSchema = new Schema<IBusinessMetricDocument>({
  businessId: { type: String, required: true, index: true },
  period: { type: String, enum: ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'], required: true },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  
  revenue: { type: Number, required: true, default: 0 },
  expenses: { type: Number, required: true, default: 0 },
  profit: { type: Number, required: true, default: 0 },
  
  salesCount: { type: Number },
  customersCount: { type: Number },
  inventoryValue: { type: Number },
  productionUnits: { type: Number },
  loanAmount: { type: Number },
  marketingSpend: { type: Number },
  employeeCount: { type: Number }
}, { timestamps: true });

// Prevent duplicate entries for the same period for a business
businessMetricSchema.index({ businessId: 1, startDate: 1, endDate: 1, period: 1 }, { unique: true });

export const BusinessMetricModel = mongoose.models.BusinessMetric || mongoose.model<IBusinessMetricDocument>('BusinessMetric', businessMetricSchema);
