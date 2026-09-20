import { z } from 'zod';

const LearningCategories = ['Marketing', 'Finance', 'Accounting', 'GST', 'FSSAI', 'MSME', 'Digital Marketing', 'Export', 'Branding', 'Packaging', 'Business Planning', 'Agriculture', 'Food Processing', 'Handicrafts', 'Manufacturing', 'Leadership', 'Technology', 'AI Tools'] as const;

export const createResourceSchema = z.object({
  body: z.object({
    title: z.string().min(5).max(200),
    description: z.string().min(20).max(2000),
    categories: z.array(z.enum(LearningCategories)).min(1),
    format: z.enum(['Video', 'Article', 'PDF', 'Audio', 'Interactive Lesson', 'Quiz', 'Case Study', 'Government Guide', 'Business Template', 'Checklist', 'Workshop', 'Webinar']),
    difficulty: z.enum(['Beginner', 'Intermediate', 'Advanced', 'Expert']),
    language: z.string().min(2),
    durationMinutes: z.number().min(1),
    skillsTaught: z.array(z.string()).min(1),
    contentUrl: z.string().url(),
    storageProvider: z.string().optional(),
    thumbnailUrl: z.string().url().optional()
  })
});

export const enrollSchema = z.object({
  body: z.object({
    courseId: z.string()
  })
});

export const updateProgressSchema = z.object({
  body: z.object({
    courseId: z.string(),
    moduleId: z.string(),
    lessonId: z.string(),
    positionSeconds: z.number().min(0),
    durationSeconds: z.number().min(1),
    percentage: z.number().min(0).max(100),
    completed: z.boolean(),
    clientUpdatedAt: z.string().optional()
  })
});
