import { AnalyticsRepository } from '../repositories/analytics.repository';
import { BusinessRepository } from '../repositories/business.repository';
import { logger } from '@rural/logger';
import axios from 'axios';

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000/api/v1/ai';

export class AnalyticsService {
  private analyticsRepo: AnalyticsRepository;
  private businessRepo: BusinessRepository;

  constructor() {
    this.analyticsRepo = new AnalyticsRepository();
    this.businessRepo = new BusinessRepository();
  }

  async logMetric(data: any) {
    try {
      const metric = await this.analyticsRepo.logMetric(data);
      return { success: true, data: metric };
    } catch (error: any) {
      if (error.code === 11000) {
        return { success: false, error: { code: 'DUPLICATE_METRIC', message: 'Metric for this period already exists.' } };
      }
      throw error;
    }
  }

  async getDashboard(businessId: string) {
    const metrics = await this.analyticsRepo.getMetricsByBusiness(businessId);
    const forecast = await this.analyticsRepo.getLatestForecast(businessId);
    
    // Reverse metrics to be chronological for frontend charts
    metrics.reverse();

    return { 
      success: true, 
      data: {
        metrics,
        forecast
      }
    };
  }

  // Hybrid Forecast Generation (Rec 6, 11)
  async generateForecast(businessId: string) {
    const business = await this.businessRepo.findById(businessId);
    if (!business) return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };

    const metrics = await this.analyticsRepo.getMetricsByBusiness(businessId, 6); // Last 6 periods
    if (metrics.length < 2) {
      return { success: false, error: { code: 'INSUFFICIENT_DATA', message: 'Need at least 2 periods of data to forecast' } };
    }

    // Sort chronologically for calculation
    const chronologicalMetrics = [...metrics].sort((a, b) => a.startDate.getTime() - b.startDate.getTime());

    // 1. Statistical Calculation Engine (MVP simplistic trend) (Rec 6)
    let totalRevGrowth = 0;
    let totalExpGrowth = 0;
    for (let i = 1; i < chronologicalMetrics.length; i++) {
      const prev = chronologicalMetrics[i - 1];
      const curr = chronologicalMetrics[i];
      if (prev.revenue > 0) totalRevGrowth += (curr.revenue - prev.revenue) / prev.revenue;
      if (prev.expenses > 0) totalExpGrowth += (curr.expenses - prev.expenses) / prev.expenses;
    }
    
    const avgRevGrowth = totalRevGrowth / (chronologicalMetrics.length - 1);
    const avgExpGrowth = totalExpGrowth / (chronologicalMetrics.length - 1);
    
    const lastMetric = chronologicalMetrics[chronologicalMetrics.length - 1];
    const statRevenuePrediction = Math.round(lastMetric.revenue * (1 + avgRevGrowth));
    const statExpensePrediction = Math.round(lastMetric.expenses * (1 + avgExpGrowth));
    const statProfitProjection = statRevenuePrediction - statExpensePrediction;

    // 2. LLM Interpretation via Python AI Microservice (Rec 11)
    try {
      const promptData = {
        business_profile: {
          category: business.category,
          stage: business.stage,
          location: business.location?.state
        },
        historical_metrics: chronologicalMetrics.map(m => ({
          revenue: m.revenue, expenses: m.expenses, profit: m.profit
        })),
        statistical_predictions: {
          next_revenue: statRevenuePrediction,
          next_expenses: statExpensePrediction,
          next_profit: statProfitProjection
        }
      };

      // Call Python service to get narrative and recommendations
      const aiResponse = await axios.post(`${AI_SERVICE_URL}/generate-insights`, promptData);
      
      const forecastData = {
        businessId,
        generatedAt: new Date(),
        narrative: aiResponse.data.data.narrative,
        components: {
          revenuePrediction: statRevenuePrediction,
          expensePrediction: statExpensePrediction,
          profitProjection: statProfitProjection,
          riskLevel: aiResponse.data.data.riskLevel,
          growthOpportunities: aiResponse.data.data.opportunities,
          seasonalFactors: aiResponse.data.data.seasonality,
          recommendedActions: aiResponse.data.data.recommendations
        },
        confidenceScore: 0.85,
        inputMetricsIds: metrics.map(m => m.id as string)
      };

      const savedForecast = await this.analyticsRepo.saveForecast(forecastData);
      logger.info(`Forecast generated for Business ${businessId}`);
      
      return { success: true, data: savedForecast };

    } catch (error: any) {
      logger.error('Failed to generate AI Forecast', error);
      return { success: false, error: { code: 'AI_SERVICE_ERROR', message: 'Failed to generate insights' } };
    }
  }
}
