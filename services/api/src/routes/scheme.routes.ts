import { Router } from 'express';
import { SchemeController } from '../controllers/scheme.controller';
import { validate } from '../middlewares/validate';
import { createSchemeSchema, recommendationParamsSchema } from '../validators/scheme.validator';
import { requireAuth, requireAdmin } from '../middlewares/auth.middleware';

const router = Router();
const schemeController = new SchemeController();

// Admin Only - Rule creation is locked down
router.post('/', requireAuth, requireAdmin, validate(createSchemeSchema), schemeController.createScheme);

// Authenticated User Routes
router.get('/recommendations/:businessId', requireAuth, validate(recommendationParamsSchema), schemeController.getRecommendations);

// Legacy fallback route for backwards compatibility
router.get('/match/:businessId', requireAuth, validate(recommendationParamsSchema), schemeController.matchSchemes);

export default router;
