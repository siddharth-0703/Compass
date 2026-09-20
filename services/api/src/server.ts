import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { connectDatabase, UserModel, LearningResourceModel } from '@rural/database';
import { hashPassword } from '@rural/auth';
import { logger, httpLogger } from '@rural/logger';
import { errorHandler } from './middlewares/errorHandler';
import authRoutes from './routes/auth.routes';
import businessRoutes from './routes/business.routes';
import communityRoutes from './routes/community.routes';
import schemeRoutes from './routes/scheme.routes';
import mentorshipRoutes from './routes/mentorship.routes';
import learningRoutes from './routes/learning.routes';
import aiRoutes from './routes/ai.routes';
import notificationRoutes from './routes/notification.routes';
import reputationRoutes from './routes/reputation.routes';
import analyticsRoutes from './routes/analytics.routes';
import adminRoutes from './routes/admin.routes';
import mandiRoutes from './routes/mandi.routes';
import userRoutes from './routes/user.routes';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './swagger';
import { globalLimiter, authLimiter, adminLimiter } from './middlewares/rateLimiter';

const app = express();
const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/rural_dev';

// Security Headers (Rec 4)
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"], // Swagger UI needs unsafe-inline
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
    },
  },
  crossOriginEmbedderPolicy: false
}));

// CORS Configuration
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps)
    if (!origin) return callback(null, true);
    
    // Allow any localhost port during development (for Flutter Web)
    if (process.env.NODE_ENV !== 'production' && (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:'))) {
      return callback(null, true);
    }
    
    const allowedOrigin = process.env.FRONTEND_URL || 'http://localhost:5173';
    if (origin === allowedOrigin) {
      return callback(null, true);
    }
    
    callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Request Limits (Rec 10)
app.use(express.json({ limit: '1mb' })); // Prevent oversized JSON payloads

// Attach HTTP Logger (pino-http)
app.use(httpLogger);

// Apply Global Rate Limiter
app.use(globalLimiter);

// Initialize Database Connection and Seed Admin
connectDatabase(MONGO_URI).then(async () => {
  try {
    const adminExists = await UserModel.findOne({ email: 'admin@ruralplatform.com' });
    if (!adminExists) {
      const passwordHash = await hashPassword('Admin@123');
      await UserModel.create({
        email: 'admin@ruralplatform.com',
        phone: '+1234567890',
        name: 'System Admin',
        roles: ['admin'],
        passwordHash,
        isVerified: true,
        isActive: true,
        accountStatus: 'active',
        profileCompletion: 100,
        failedLoginAttempts: 0
      });
      logger.info('Default admin user successfully seeded.');
    }

    // Seed structured courses if empty
    const coursesCount = await LearningResourceModel.countDocuments();
    if (coursesCount === 0) {
      await LearningResourceModel.create([
        {
          title: 'Modern Organic Farming',
          description: 'Learn modern pest control, soil enrichment, and certifications.',
          categories: ['Agriculture'],
          difficulty: 'Beginner',
          thumbnailUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&q=80&w=400',
          modules: [
            {
              id: 'm1',
              title: 'Fundamentals',
              description: 'Basics of soil and compost preparation.',
              order: 1,
              lessons: [
                {
                  id: 'm1-l1',
                  title: 'What is Organic Farming?',
                  description: 'Introduction to soil biology and organic principles.',
                  durationSeconds: 180,
                  media: {
                    en: {
                      contentUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                      provider: 'MP4',
                      contentType: 'VIDEO'
                    }
                  },
                  resources: ['organic_farming_principles.pdf'],
                  order: 1,
                  isPublished: true,
                  contentStatus: 'VERIFIED'
                },
                {
                  id: 'm1-l2',
                  title: 'Soil Health & Compost',
                  description: 'Methods of creating premium organic manure.',
                  durationSeconds: 240,
                  media: {
                    hi: {
                      contentUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
                      provider: 'MP4',
                      contentType: 'VIDEO'
                    }
                  },
                  resources: ['soil_compost_guide.pdf'],
                  order: 2,
                  isPublished: true,
                  contentStatus: 'VERIFIED'
                }
              ]
            },
            {
              id: 'm2',
              title: 'Pest Management',
              description: 'Sustainable controls without chemicals.',
              order: 2,
              lessons: [
                {
                  id: 'm2-l1',
                  title: 'Natural Pest Controls',
                  description: 'Fostering predatory insects and neem sprays.',
                  durationSeconds: 300,
                  media: {
                    mr: {
                      contentUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
                      provider: 'MP4',
                      contentType: 'VIDEO'
                    }
                  },
                  resources: ['pest_management_chart.pdf'],
                  order: 1,
                  isPublished: true,
                  contentStatus: 'VERIFIED'
                },
                {
                  id: 'm2-l2',
                  title: 'Disease Management',
                  description: 'Managing crop rusts and fungal outbreaks naturally.',
                  durationSeconds: 200,
                  resources: [],
                  order: 2,
                  isPublished: true,
                  contentStatus: 'NOT_CONFIGURED'
                }
              ]
            }
          ]
        },
        {
          title: 'Financial Literacy Basics',
          description: 'Master inflation, banking metrics, and cash flow bookkeeping.',
          categories: ['Finance'],
          difficulty: 'Intermediate',
          thumbnailUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&q=80&w=400',
          modules: [
            {
              id: 'fin-m1',
              title: 'Inflation & Savings',
              description: 'Understand macroeconomics for business planning.',
              order: 1,
              lessons: [
                {
                  id: 'fin-m1-l1',
                  title: 'Understanding Inflation',
                  description: 'Why purchasing power declines and how to hedge against it.',
                  durationSeconds: 150,
                  media: {
                    en: {
                      contentUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                      provider: 'MP4',
                      contentType: 'VIDEO'
                    },
                    hi: {
                      contentUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
                      provider: 'MP4',
                      contentType: 'VIDEO'
                    }
                  },
                  resources: ['inflation_overview.pdf'],
                  order: 1,
                  isPublished: true,
                  contentStatus: 'VERIFIED'
                },
                {
                  id: 'fin-m1-l2',
                  title: 'Banking & Savings',
                  description: 'Using commercial bank deposits and checking accounts.',
                  durationSeconds: 180,
                  resources: [],
                  order: 2,
                  isPublished: true,
                  contentStatus: 'NOT_CONFIGURED'
                }
              ]
            }
          ]
        }
      ]);
      logger.info('Structured learning courses seeded.');
    }
  } catch (err) {
    logger.error({ err }, 'Failed to seed defaults');
  }
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', service: 'core-api' });
});

// Swagger Documentation (Phase 15 Rec 2)
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, { customCss: '.swagger-ui .topbar { display: none }' }));
app.get('/openapi.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// API Routing with specialized limits (Rec 2, 3)
app.use('/api/v1/auth', authLimiter, authRoutes);
app.use('/api/v1/businesses', businessRoutes);
app.use('/api/v1/community', communityRoutes);
app.use('/api/v1/schemes', schemeRoutes);
app.use('/api/v1/mentors', mentorshipRoutes);
app.use('/api/v1/learning', learningRoutes);
app.use('/api/v1/ai', aiRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/reputation', reputationRoutes);
app.use('/api/v1/mandi', mandiRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/admin', adminLimiter, adminRoutes);

// Global Error Handler (Rec 10)
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Core API Service listening on port ${PORT}`);
});
