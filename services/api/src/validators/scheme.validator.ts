import { z } from 'zod';

const SchemeCategories = ['AGRICULTURE', 'ENTREPRENEURSHIP', 'FINANCE', 'EMPLOYMENT', 'EDUCATION', 'HOUSING', 'WOMEN', 'MSME', 'STARTUP', 'SOCIAL_WELFARE', 'DIGITAL', 'OTHER'] as const;

export const createSchemeSchema = z.object({
  body: z.object({
    schemeCode: z.string().min(3),
    name: z.string().min(3),
    shortDescription: z.string().min(10),
    description: z.string().optional(),
    officialSourceUrl: z.string().url(),
    category: z.enum(SchemeCategories),
    targetGroups: z.array(z.string()).optional().default([]),
    benefits: z.array(z.object({
      type: z.string(),
      description: z.string(),
      amount: z.number().optional(),
      percentage: z.number().optional(),
      currency: z.string().optional()
    })).optional().default([]),
    eligibilityRules: z.array(z.object({
      field: z.string(),
      operator: z.enum(['EQ', 'NEQ', 'GT', 'GTE', 'LT', 'LTE', 'IN', 'NOT_IN', 'BETWEEN', 'CONTAINS', 'EXISTS']),
      value: z.any(),
      logicalGroup: z.enum(['AND', 'OR']).optional()
    })).optional().default([]),
    requiredDocuments: z.array(z.string()).optional().default([]),
    states: z.array(z.string()).optional().default([]),
    districts: z.array(z.string()).optional().default([]),
    languages: z.array(z.string()).optional().default(['en']),
  })
});

export const recommendationParamsSchema = z.object({
  params: z.object({
    businessId: z.string().min(1)
  })
});
