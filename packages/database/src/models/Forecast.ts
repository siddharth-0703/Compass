import mongoose, { Schema, Document } from 'mongoose';
import { IForecast } from '@rural/types';

export interface IForecastDocument extends Omit<IForecast, 'id'>, Document {}

const forecastComponentsSchema = new Schema({
  revenuePrediction: { type: Number },
  expensePrediction: { type: Number },
  profitProjection: { type: Number },
  riskLevel: { type: String, enum: ['Low', 'Medium', 'High'] },
  growthOpportunities: { type: [String], default: [] },
  seasonalFactors: { type: [String], default: [] },
  recommendedActions: { type: [String], default: [] }
}, { _id: false });

const forecastSchema = new Schema<IForecastDocument>({
  businessId: { type: String, required: true, index: true },
  generatedAt: { type: Date, default: Date.now },
  
  narrative: { type: String, required: true },
  components: forecastComponentsSchema,
  confidenceScore: { type: Number, min: 0, max: 1 },
  
  inputMetricsIds: { type: [String], default: [] }
}, { timestamps: true });

export const ForecastModel = mongoose.models.Forecast || mongoose.model<IForecastDocument>('Forecast', forecastSchema);
