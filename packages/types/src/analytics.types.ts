export type MetricPeriod = 'Daily' | 'Weekly' | 'Monthly' | 'Quarterly' | 'Yearly';

export interface IBusinessMetric {
  id?: string;
  businessId: string;
  period: MetricPeriod;
  startDate: Date;
  endDate: Date;
  
  revenue: number;
  expenses: number;
  profit: number; // Derived
  
  salesCount?: number;
  customersCount?: number;
  inventoryValue?: number;
  productionUnits?: number;
  loanAmount?: number;
  marketingSpend?: number;
  employeeCount?: number;

  createdAt?: Date;
  updatedAt?: Date;
}

export interface IForecastComponents {
  revenuePrediction: number;
  expensePrediction: number;
  profitProjection: number;
  riskLevel: 'Low' | 'Medium' | 'High';
  growthOpportunities: string[];
  seasonalFactors: string[];
  recommendedActions: string[];
}

export interface IForecast {
  id?: string;
  businessId: string;
  generatedAt: Date;
  
  narrative: string;
  components: IForecastComponents;
  confidenceScore: number; // 0.0 to 1.0
  
  inputMetricsIds: string[]; // References to the metrics used to generate this
  
  createdAt?: Date;
  updatedAt?: Date;
}
