import { Router } from 'express';
import { getStates, getCommodities, getMarkets, getPrices, getHistory } from '../controllers/mandi.controller';
import { requireAuth } from '../middlewares/auth.middleware';

const router = Router();

// Routes for Mandi API integration
router.get('/states', requireAuth, getStates);
router.get('/commodities', requireAuth, getCommodities);
router.get('/markets', requireAuth, getMarkets);
router.get('/prices', requireAuth, getPrices);
router.get('/prices/history', requireAuth, getHistory);

export default router;
