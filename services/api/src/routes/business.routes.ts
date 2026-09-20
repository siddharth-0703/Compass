import { Router } from 'express';
import { BusinessController } from '../controllers/business.controller';
import { validate } from '../middlewares/validate';
import { createBusinessSchema, updateBusinessSchema } from '../validators/business.validator';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();
const businessController = new BusinessController();

// All business routes require authentication
router.use(requireAuth);

router.post('/', validate(createBusinessSchema), businessController.create);
router.get('/me', businessController.getMyBusinesses);
router.get('/:id', businessController.getById);
router.patch('/:id', validate(updateBusinessSchema), businessController.update);
router.delete('/:id', businessController.delete);

export default router;
