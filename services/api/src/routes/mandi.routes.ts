import { Router } from 'express';
import { getStates, getCommodities, getMarkets, getPrices, getHistory } from '../controllers/mandi.controller';

const router = Router();

// Routes for Mandi API integration - public agricultural market data
router.get('/states', getStates);
router.get('/commodities', getCommodities);
router.get('/markets', getMarkets);
router.get('/prices', getPrices);
router.get('/prices/history', getHistory);

export default router;
