import { z } from 'zod';

const BusinessCategories = ['Agriculture', 'Food Processing', 'Handicrafts', 'Textiles', 'Retail', 'Services', 'Manufacturing', 'Livestock', 'Tourism', 'Education', 'Technology', 'Healthcare', 'Fisheries'] as const;

export const createListingSchema = z.object({
  body: z.object({
    businessId: z.string(),
    title: z.string().min(3).max(150),
    description: z.string().min(10).max(2000),
    type: z.enum(['Product', 'Service', 'Buyer Requirement', 'Supplier Requirement', 'Distributor Request', 'Collaboration Opportunity', 'Investment Opportunity', 'Tender', 'Training Opportunity']),
    category: z.enum(BusinessCategories),
    subcategory: z.string().optional(),
    mediaUrls: z.array(z.string().url()).max(10).optional(),
    
    pricing: z.object({
      basePrice: z.number().min(0),
      currency: z.string().default('INR'),
      unit: z.string().min(1),
      minimumOrderQuantity: z.number().min(1).default(1),
      negotiable: z.boolean().default(false),
      priceVisibility: z.enum(['Public', 'Private']).default('Public')
    }),
    
    inventory: z.object({
      stock: z.number().min(0).default(0),
      availability: z.enum(['In Stock', 'Out of Stock', 'Preorder', 'On Demand']).default('On Demand'),
      leadTimeDays: z.number().min(0).optional(),
      deliveryRadiusKm: z.number().min(0).optional(),
      orderCapacityPerMonth: z.number().min(0).optional()
    })
  })
});
