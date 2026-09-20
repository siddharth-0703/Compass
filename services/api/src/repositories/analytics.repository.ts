import { BusinessMetricModel, ForecastModel, IBusinessMetricDocument, IForecastDocument } from '@rural/database';
import { IBusinessMetric, IForecast } from '@rural/types';

export class AnalyticsRepository {
  async logMetric(data: Partial<IBusinessMetric>): Promise<IBusinessMetricDocument> {
    const profit = (data.revenue || 0) - (data.expenses || 0);
    const metric = new BusinessMetricModel({ ...data, profit });
    return metric.save();
  }

  async getMetricsByBusiness(businessId: string, limit: number = 12) {
    // Return last 12 periods by default for trend analysis
    return BusinessMetricModel.find({ businessId })
      .sort({ startDate: -1 })
      .limit(limit);
  }

  async saveForecast(data: Partial<IForecast>): Promise<IForecastDocument> {
    const forecast = new ForecastModel(data);
    return forecast.save();
  }

  async getLatestForecast(businessId: string) {
    return ForecastModel.findOne({ businessId }).sort({ generatedAt: -1 });
  }
}
