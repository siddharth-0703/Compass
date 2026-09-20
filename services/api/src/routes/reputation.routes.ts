import { Router } from 'express';
import { ReputationController } from '../controllers/reputation.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import { validate } from '../middlewares/validate';
import { z } from 'zod';

const router = Router();
const reputationController = new ReputationController();

const awardSchema = z.object({
  body: z.object({
    points: z.number().min(1),
    action: z.string().min(5)
  })
});

router.use(requireAuth);

router.get('/leaderboard', reputationController.getLeaderboard);
router.get('/:userId', reputationController.getReputation);
router.post('/:userId/award', validate(awardSchema), reputationController.awardPoints);

export default router;
