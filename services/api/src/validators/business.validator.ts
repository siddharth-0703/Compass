import { z } from 'zod';

const BusinessCategories = ['Agriculture', 'Food Processing', 'Handicrafts', 'Textiles', 'Retail', 'Services', 'Manufacturing', 'Livestock', 'Tourism', 'Education', 'Technology', 'Healthcare', 'Fisheries'] as const;

const locationSchema = z.object({
  state: z.string().min(2),
  district: z.string().min(2),
  village: z.string().optional(),
  pincode: z.string().regex(/^\d{6}$/, "Must be a valid 6-digit Indian PIN code"),
  geo: z.object({
    type: z.literal('Point'),
    coordinates: z.tuple([
      z.number().min(-180).max(180), // Longitude
      z.number().min(-90).max(90)    // Latitude
    ])
  }).optional()
});

const financialsSchema = z.object({
  annualTurnover: z.number().min(0).optional(),
  monthlyRevenue: z.number().min(0).optional(),
  monthlyProfit: z.number().optional(), // Can be negative for startups
  monthlyExpenses: z.number().min(0).optional()
}).optional();

export const createBusinessSchema = z.object({
  body: z.object({
    name: z.string().min(3).max(100),
    description: z.string().min(10).max(2000),
    category: z.enum(BusinessCategories),
    subcategory: z.string().optional(),
    yearStarted: z.number().min(1900).max(new Date().getFullYear()).optional(),
    gstNumber: z.string().regex(/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/, "Invalid GST Number").optional(),
    msmeNumber: z.string().optional(),
    registrationType: z.string().optional(),
    stage: z.enum(['idea', 'early', 'growth', 'mature']).optional(),
    employees: z.number().min(0).optional(),
    womenOwned: z.boolean().optional(),
    farmerProducerOrganization: z.boolean().optional(),
    website: z.string().url().optional(),
    languages: z.array(z.string()).optional(),
    operatingHours: z.string().optional(),
    location: locationSchema,
    financials: financialsSchema
  }),
  params: z.object({
    id: z.string().optional()
  }).optional(),
  query: z.any().optional()
});

export const updateBusinessSchema = z.object({
  body: createBusinessSchema.shape.body.partial(), // All fields optional for PATCH
  params: z.object({
    id: z.string()
  }),
  query: z.any().optional()
});
