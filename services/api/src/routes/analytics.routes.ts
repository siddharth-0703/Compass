import { Router } from 'express';
import { AnalyticsController } from '../controllers/analytics.controller';
import { validate } from '../middlewares/validate';
import { logMetricSchema } from '../validators/analytics.validator';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();
const analyticsController = new AnalyticsController();

router.use(requireAuth);

router.post('/metrics', validate(logMetricSchema), analyticsController.logMetric);
router.get('/dashboard/:businessId', analyticsController.getDashboard);
router.post('/forecast/:businessId', analyticsController.generateForecast);

export default router;
