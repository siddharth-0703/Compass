import { z } from 'zod';

// Strong password policy (Rec 9)
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$/;

export const registerSchema = z.object({
  body: z.object({
    phone: z.string().regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number format'),
    email: z.string().email('Invalid email address').optional(),
    password: z.string().regex(passwordRegex, 'Password must be at least 8 characters, include uppercase, lowercase, number, and special character.'),
    name: z.string().min(2, 'Name must be at least 2 characters').optional(),
    role: z.enum(['entrepreneur', 'mentor', 'ngo', 'investor']).default('entrepreneur')
  })
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address').optional(),
    phone: z.string().regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number format').optional(),
    password: z.string()
  }).refine(data => data.email || data.phone, {
    message: "Either email or phone must be provided",
    path: ["email"]
  })
});

export const verifyOtpSchema = z.object({
  body: z.object({
    phone: z.string(),
    otp: z.string().length(6)
  })
});
