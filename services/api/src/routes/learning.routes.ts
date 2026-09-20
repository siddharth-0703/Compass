import { Router } from 'express';
import { LearningController } from '../controllers/learning.controller';
import { validate } from '../middlewares/validate';
import { createResourceSchema, enrollSchema, updateProgressSchema } from '../validators/learning.validator';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();
const learningController = new LearningController();

router.use(requireAuth);

router.get('/resources', learningController.getAllResources);
router.post('/resources', validate(createResourceSchema), learningController.createResource);
router.get('/recommend/:businessId', learningController.recommendResources);
router.post('/enroll', validate(enrollSchema), learningController.enroll);
router.patch('/progress', validate(updateProgressSchema), learningController.updateProgress);
router.get('/courses/:courseId/progress', learningController.getCourseProgress);

export default router;
