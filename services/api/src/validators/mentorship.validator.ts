import { z } from 'zod';

export const createMentorProfileSchema = z.object({
  body: z.object({
    headline: z.string().min(10).max(150),
    bio: z.string().min(50).max(1000),
    
    expertise: z.object({
      industries: z.array(z.string()).min(1),
      businessStages: z.array(z.enum(['idea', 'early', 'growth', 'mature'])).min(1),
      businessFunctions: z.array(z.string()).min(1),
      technicalSkills: z.array(z.string()).optional(),
      softSkills: z.array(z.string()).optional(),
      languages: z.array(z.string()).min(1),
      experienceYears: z.number().min(1)
    }),

    availability: z.object({
      timezone: z.string().default('Asia/Kolkata'),
      availableDays: z.array(z.enum(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])).min(1),
      timeSlots: z.array(z.string()).min(1), // e.g., '10:00-12:00'
      sessionDurationMinutes: z.number().min(15).max(120).default(45),
      bufferTimeMinutes: z.number().min(0).max(60).default(15),
      maxSessionsPerWeek: z.number().min(1).default(5)
    }),
    
    sessionType: z.enum(['Free', 'Paid', 'Sponsored']).default('Free')
  })
});

export const scheduleSessionSchema = z.object({
  body: z.object({
    mentorId: z.string(),
    businessId: z.string(),
    scheduledAt: z.string().datetime(), // ISO string
    goals: z.array(z.string()).min(1)
  })
});
