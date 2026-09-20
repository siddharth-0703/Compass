import { Request, Response } from 'express';
import { logger } from '@rural/logger';
import { mandiService } from '../services/mandi.service';

export const getStates = async (req: Request, res: Response) => {
  try {
    const states = await mandiService.getStates();
    res.status(200).json({ success: true, data: states });
  } catch (error: any) {
    if (error.message === 'PRICE_SERVICE_UNAVAILABLE') {
      res.status(503).json({ success: false, error: { message: 'PRICE_SERVICE_UNAVAILABLE' } });
    } else {
      logger.error({ error }, 'Failed to get mandi states');
      res.status(500).json({ success: false, error: { message: 'Internal Server Error' } });
    }
  }
};

export const getCommodities = async (req: Request, res: Response) => {
  try {
    const { state, market } = req.query;
    const commodities = await mandiService.getCommodities(state as string, market as string);
    res.status(200).json({ success: true, data: commodities });
  } catch (error: any) {
    if (error.message === 'PRICE_SERVICE_UNAVAILABLE') {
      res.status(503).json({ success: false, error: { message: 'PRICE_SERVICE_UNAVAILABLE' } });
    } else {
      logger.error({ error }, 'Failed to get mandi commodities');
      res.status(500).json({ success: false, error: { message: 'Internal Server Error' } });
    }
  }
};

export const getMarkets = async (req: Request, res: Response) => {
  try {
    const { state } = req.query;
    if (!state) {
      return res.status(400).json({ success: false, error: { message: 'State parameter is required' } });
    }
    const markets = await mandiService.getMarkets(state as string);
    res.status(200).json({ success: true, data: markets });
  } catch (error: any) {
    if (error.message === 'PRICE_SERVICE_UNAVAILABLE') {
      res.status(503).json({ success: false, error: { message: 'PRICE_SERVICE_UNAVAILABLE' } });
    } else {
      logger.error({ error }, 'Failed to get mandi markets');
      res.status(500).json({ success: false, error: { message: 'Internal Server Error' } });
    }
  }
};

export const getPrices = async (req: Request, res: Response) => {
  try {
    const { state, commodity, market } = req.query;
    if (!state && !commodity) {
      return res.status(400).json({ success: false, error: { message: 'Either state or commodity is required' } });
    }
    const prices = await mandiService.getPrices(state as string, commodity as string, market as string);
    res.status(200).json({ success: true, data: prices, timestamp: new Date().toISOString() });
  } catch (error: any) {
    if (error.message === 'PRICE_SERVICE_UNAVAILABLE') {
      res.status(503).json({ success: false, error: { message: 'PRICE_SERVICE_UNAVAILABLE' } });
    } else {
      logger.error({ error }, 'Failed to get mandi prices');
      res.status(500).json({ success: false, error: { message: 'Internal Server Error' } });
    }
  }
};

export const getHistory = async (req: Request, res: Response) => {
  try {
    const { state, commodity, market, from, to } = req.query;
    if (!state || !commodity) {
      return res.status(400).json({ success: false, error: { message: 'Both state and commodity are required for history' } });
    }
    const history = await mandiService.getHistory(state as string, commodity as string, market as string, from as string, to as string);
    res.status(200).json({ success: true, data: history, timestamp: new Date().toISOString() });
  } catch (error: any) {
    if (error.message === 'PRICE_SERVICE_UNAVAILABLE') {
      res.status(503).json({ success: false, error: { message: 'PRICE_SERVICE_UNAVAILABLE' } });
    } else {
      logger.error({ error }, 'Failed to get mandi history');
      res.status(500).json({ success: false, error: { message: 'Internal Server Error' } });
    }
  }
};
