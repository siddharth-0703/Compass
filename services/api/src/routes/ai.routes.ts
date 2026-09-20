import { Router } from 'express';
import { AIController } from '../controllers/ai.controller';
import { requireAuth } from '../middlewares/auth.middleware';
import { aiLimiter } from '../middlewares/rateLimiter';

const router = Router();
const aiController = new AIController();

// Voice command parsing
router.post('/voice-command', requireAuth, aiLimiter, aiController.parseVoiceCommand);

// Scheme recommendation — Gemini discovers candidates, backend validates
router.post('/recommend-schemes', requireAuth, aiLimiter, aiController.recommendSchemes.bind(aiController));

// Scheme detail page — Gemini provides comprehensive scheme info
router.post('/scheme-details', requireAuth, aiLimiter, aiController.getSchemeDetails.bind(aiController));

// Scheme explanation — Gemini explains OUR engine's verdict in friendly language
router.post('/explain-scheme', requireAuth, aiLimiter, aiController.explainScheme.bind(aiController));

export default router;
