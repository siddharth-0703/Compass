import { Router } from 'express';
import { MentorshipController } from '../controllers/mentorship.controller';
import { validate } from '../middlewares/validate';
import { createMentorProfileSchema, scheduleSessionSchema } from '../validators/mentorship.validator';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();
const mentorshipController = new MentorshipController();

router.use(requireAuth);

router.post('/', validate(createMentorProfileSchema), mentorshipController.createProfile);
router.post('/match', mentorshipController.matchMentors);
router.get('/mentors/:mentorId', mentorshipController.getMentorDetails);
router.get('/mentors/:mentorId/availability', mentorshipController.getMentorAvailability);
router.post('/sessions', validate(scheduleSessionSchema), mentorshipController.scheduleSession);
router.get('/sessions', mentorshipController.getMySessions);
router.post('/sessions/:sessionId/cancel', mentorshipController.cancelSession);
router.post('/sessions/:sessionId/reschedule', mentorshipController.rescheduleSession);
router.post('/sessions/:sessionId/feedback', mentorshipController.submitFeedback);
router.post('/matches/:mentorId/explain', mentorshipController.explainMatch);

export default router;
