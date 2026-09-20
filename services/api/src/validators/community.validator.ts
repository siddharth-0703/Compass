import { z } from 'zod';

export const createGroupSchema = z.object({
  body: z.object({
    name: z.string().min(3).max(100),
    description: z.string().min(10).max(1000),
    type: z.enum(['location', 'industry', 'government', 'learning', 'private', 'public', 'hybrid']),
    visibility: z.enum(['Public', 'Private', 'Invite Only', 'Verified Only']).default('Public'),
    tags: z.array(z.string()).max(10).optional(),
    industry: z.string().optional()
  })
});

export const createPostSchema = z.object({
  body: z.object({
    groupId: z.string(),
    postType: z.enum(['Question', 'Discussion', 'Success Story', 'Announcement', 'Business Opportunity', 'Marketplace Promotion', 'Learning Resource', 'Government Update', 'Poll']),
    content: z.string().min(5).max(5000),
    tags: z.array(z.string()).max(5).optional(),
    language: z.string().default('en')
  })
});
