import { Router } from 'express';
import { CommunityController } from '../controllers/community.controller';
import { validate } from '../middlewares/validate';
import { createGroupSchema, createPostSchema } from '../validators/community.validator';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();
const communityController = new CommunityController();

router.use(requireAuth);

router.post('/groups', validate(createGroupSchema), communityController.createGroup);
router.post('/posts', validate(createPostSchema), communityController.createPost);
router.get('/groups/:groupId/posts', communityController.getGroupPosts);

export default router;
