import { z } from 'zod';

export const logMetricSchema = z.object({
  body: z.object({
    businessId: z.string(),
    period: z.enum(['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly']),
    startDate: z.string().datetime(),
    endDate: z.string().datetime(),
    
    revenue: z.number().min(0),
    expenses: z.number().min(0),
    
    salesCount: z.number().min(0).optional(),
    customersCount: z.number().min(0).optional(),
    inventoryValue: z.number().min(0).optional(),
    productionUnits: z.number().min(0).optional(),
    loanAmount: z.number().min(0).optional(),
    marketingSpend: z.number().min(0).optional(),
    employeeCount: z.number().min(0).optional()
  })
});
