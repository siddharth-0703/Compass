import { AITaskRouter, MockProvider, GeminiProvider } from '@rural/ai-core';
import { logger } from '@rural/logger';
import { SchemeRepository } from '../repositories/scheme.repository';
import { RecommendationEngine } from '../domain/schemes/recommendation/recommendation.engine';
import { EligibilityProfile, RecommendationTrace } from '@rural/types';
import { SchemeRecommendationService } from './scheme-recommendation.service';

class AIService {
  private router: AITaskRouter;
  private voiceRouter: AITaskRouter;
  private schemeRepo: SchemeRepository;
  private schemeRecommendationService: SchemeRecommendationService;

  constructor() {
    this.schemeRepo = new SchemeRepository();
    this.schemeRecommendationService = new SchemeRecommendationService();
    const apiKey = process.env.GOOGLE_GENAI_API_KEY;
    const useMock = process.env.ENABLE_AI_MOCK === 'true' || !apiKey || apiKey === 'mock-key';
    const provider = useMock ? new MockProvider() : new GeminiProvider(apiKey);
    this.router = new AITaskRouter({ provider });

    // Voice specific router using multiple keys
    const voiceKeys = process.env.GOOGLE_GENAI_VOICE_KEYS 
      ? process.env.GOOGLE_GENAI_VOICE_KEYS.split(',')
      : (apiKey ? [apiKey] : []);
    const voiceProvider = useMock ? new MockProvider() : new GeminiProvider(voiceKeys);
    this.voiceRouter = new AITaskRouter({ provider: voiceProvider });

    logger.info(`AIService initialized with provider: ${useMock ? 'mock' : 'gemini'}`);
  }

  async moderateListing(content: string) {
    if (process.env.ENABLE_AI !== 'true') return { isApproved: true, reason: 'AI Disabled' };
    return this.router.runModeration(content);
  }

  async translateText(content: string, targetLanguage: string) {
    if (process.env.ENABLE_AI !== 'true') return content;
    return this.router.runTranslation(content, targetLanguage);
  }

  async parseVoiceCommand(query: string, currentLanguage: string) {
    if (!query || query.trim().length === 0) {
      return {
        action: 'UNKNOWN',
        language: currentLanguage || 'en',
        speechResponse: 'Query cannot be empty.',
        confidence: 0.0
      };
    }

    try {
      const aiResponse = await this.voiceRouter.runVoiceCommand(query, currentLanguage);

      // Deterministic Confidence Calculation
      let confidence = 0.0;

      if (aiResponse.action && aiResponse.action !== 'UNKNOWN') confidence += 0.40;

      const allowedPaths = ['/dashboard', '/learning', '/mentorship', '/schemes'];
      if (aiResponse.path && allowedPaths.includes(aiResponse.path)) confidence += 0.20;

      if (aiResponse.action === 'SEARCH' && aiResponse.searchQuery && aiResponse.searchQuery.trim().length > 0) {
        confidence += 0.20;
      } else if (aiResponse.action !== 'SEARCH' && aiResponse.action !== 'UNKNOWN') {
        confidence += 0.20;
      }

      if (aiResponse.language === 'en' || aiResponse.language === 'hi' || aiResponse.language === 'mr') confidence += 0.10;
      confidence += 0.10;

      let validatedPath = aiResponse.path;
      if (validatedPath && !allowedPaths.includes(validatedPath)) validatedPath = undefined;
      if (aiResponse.action === 'UNKNOWN') validatedPath = undefined;

      return {
        action: aiResponse.action,
        path: validatedPath,
        searchQuery: aiResponse.searchQuery,
        entityId: aiResponse.entityId,
        language: aiResponse.language,
        speechResponse: aiResponse.speechResponse,
        confidence: Math.round(confidence * 100) / 100
      };
    } catch (error) {
      logger.error({ err: error }, 'Failed to parse voice command using AI Core Router');
      return {
        action: 'UNKNOWN',
        language: currentLanguage || 'en',
        speechResponse: 'An error occurred while processing the voice command.',
        confidence: 0.0
      };
    }
  }

  /**
   * Phase A: Gemini discovers scheme candidates from user profile.
   * Returns structured JSON with AI_DISCOVERED source tags.
   * Scoring is done separately by the deterministic engine.
   */
  async recommendSchemes(profile: {
    activity: string;
    state: string;
    income: number;
    age: string;
    gender: string;
    category: string;
  }) {
    return this.schemeRecommendationService.getRecommendations(profile);
  }

  /**
   * Phase D: Gemini explains WHY a scheme was recommended, given the
   * matched/failed eligibility rules from our deterministic engine.
   */
  async explainScheme(schemeName: string, trace: RecommendationTrace, language: string = 'en') {
    try {
      const matchedReasons = trace.matchedRules.map(r => `${r.field} ${r.operator} ${r.value}`);
      const explanation = await this.router.runSchemeExplanation(schemeName, trace.profileSnapshot, matchedReasons, language);
      return { success: true, data: { explanation } };
    } catch (error) {
      logger.error({ err: error }, 'Scheme explanation failed');
      return { success: false, error: { message: 'Failed to generate explanation' } };
    }
  }

  /**
   * Fetch detailed information for a specific scheme.
   * Checks cache first, then calls Gemini if not found.
   */
  async getSchemeDetails(schemeName: string) {
    try {
      const details = await this.router.runSchemeDetails(schemeName);
      return { success: true, data: details };
    } catch (error) {
      logger.error({ err: error }, 'Scheme details fetch failed');
      return { success: false, error: { message: 'Failed to fetch scheme details' } };
    }
  }
}

export const aiService = new AIService();
