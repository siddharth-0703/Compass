import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();
const userController = new UserController();

// In a real app we'd enforce authentication here
// router.use(requireAuth);

router.post('/me/saved-schemes', userController.saveScheme.bind(userController));
router.delete('/me/saved-schemes/:schemeId', userController.removeSavedScheme.bind(userController));
router.get('/me/saved-schemes', userController.getSavedSchemes.bind(userController));

export default router;
