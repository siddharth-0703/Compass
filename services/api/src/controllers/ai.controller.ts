import { Request, Response, NextFunction } from 'express';
import { aiService } from '../services/ai.service';

export class AIController {
  async parseVoiceCommand(req: Request, res: Response, next: NextFunction) {
    try {
      const { query, currentLanguage } = req.body;

      if (typeof query !== 'string' || query.length > 500) {
        return res.status(400).json({
          success: false,
          error: { code: 'BAD_REQUEST', message: 'Query must be a string less than 500 characters.' }
        });
      }

      const response = await aiService.parseVoiceCommand(query, currentLanguage || 'en');
      res.status(200).json({ success: true, data: response });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/ai/recommend-schemes
   * Body: { activity, state, income, age, gender, category }
   * Returns AI-discovered scheme candidates. NOT final eligibility decisions.
   */
  async recommendSchemes(req: Request, res: Response, next: NextFunction) {
    try {
      const { activity, state, income, age, gender, category } = req.body;

      // Input validation
      if (!activity || !state) {
        return res.status(400).json({
          success: false,
          error: { code: 'BAD_REQUEST', message: 'activity and state are required fields.' }
        });
      }

      const profile = {
        activity: String(activity).slice(0, 100),
        state: String(state).slice(0, 100),
        income: Number(income) || 0,
        age: String(age || 'Not specified').slice(0, 50),
        gender: String(gender || 'Not specified').slice(0, 50),
        category: String(category || 'General').slice(0, 50)
      };

      const result = await aiService.recommendSchemes(profile);
      res.status(result.success ? 200 : 500).json(result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/ai/scheme-details
   * Body: { schemeName }
   * Returns comprehensive scheme information from Gemini.
   */
  async getSchemeDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const { schemeName } = req.body;

      if (!schemeName || typeof schemeName !== 'string' || schemeName.length > 200) {
        return res.status(400).json({
          success: false,
          error: { code: 'BAD_REQUEST', message: 'schemeName is required (max 200 chars).' }
        });
      }

      const result = await aiService.getSchemeDetails(schemeName.trim());
      res.status(result.success ? 200 : 500).json(result);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/ai/explain-scheme
   * Body: { schemeName, trace, language }
   * Gemini explains our engine's verdict using the RecommendationTrace.
   */
  async explainScheme(req: Request, res: Response, next: NextFunction) {
    try {
      const { schemeName, trace, language } = req.body;

      if (!schemeName || typeof schemeName !== 'string') {
        return res.status(400).json({
          success: false,
          error: { code: 'BAD_REQUEST', message: 'schemeName is required.' }
        });
      }

      if (!trace || typeof trace !== 'object') {
        return res.status(400).json({
          success: false,
          error: { code: 'BAD_REQUEST', message: 'trace is required for verified schemes.' }
        });
      }

      const result = await aiService.explainScheme(
        schemeName.trim(),
        trace,
        language || 'en'
      );
      res.status(result.success ? 200 : 500).json(result);
    } catch (error) {
      next(error);
    }
  }
}
