import { EligibilityProfile, SchemeRecommendation, SchemeDiscoveryResult, SchemeRecommendationResponse } from '@rural/types';
import { AITaskRouter, MockProvider, GeminiProvider } from '@rural/ai-core';
import { SchemeRepository } from '../repositories/scheme.repository';
import { SchemeResolutionService } from './scheme-resolution.service';
import { RecommendationEngine } from '../domain/schemes/recommendation/recommendation.engine';
import { logger } from '@rural/logger';
import crypto from 'crypto';
import Redis from 'ioredis';

export class SchemeRecommendationService {
  private router: AITaskRouter;
  private schemeRepo: SchemeRepository;
  private resolutionService: SchemeResolutionService;
  
  private redisClient: Redis;
  private CACHE_TTL_S = 60 * 60 * 24; // 24 hours

  constructor() {
    this.schemeRepo = new SchemeRepository();
    this.resolutionService = new SchemeResolutionService();
    this.redisClient = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', { family: 0 });
    this.redisClient.on('error', (err) => logger.error({ err }, 'Redis SchemeRecommender Error'));

    const apiKey = process.env.GOOGLE_GENAI_API_KEY;
    const useMock = process.env.ENABLE_AI_MOCK === 'true' || !apiKey || apiKey === 'mock-key';
    const provider = useMock ? new MockProvider() : new GeminiProvider(apiKey);
    this.router = new AITaskRouter({ provider });
  }

  private generateCacheKey(profile: EligibilityProfile): string {
    const dataString = JSON.stringify(profile);
    const engineVersion = '1.0.0';
    const hash = crypto.createHash('sha256').update(dataString).digest('hex');
    return `rec_${engineVersion}_${hash}`;
  }

  private calculateFreshness(lastVerifiedAt?: Date): { status: 'CURRENT' | 'REVIEW_DUE' | 'EXPIRED', lastVerifiedAt?: Date } {
    if (!lastVerifiedAt) return { status: 'CURRENT', lastVerifiedAt };
    
    const now = new Date();
    const monthsDiff = (now.getTime() - new Date(lastVerifiedAt).getTime()) / (1000 * 60 * 60 * 24 * 30);
    
    if (monthsDiff < 6) return { status: 'CURRENT', lastVerifiedAt };
    if (monthsDiff <= 12) return { status: 'REVIEW_DUE', lastVerifiedAt };
    return { status: 'EXPIRED', lastVerifiedAt };
  }

  async getRecommendations(profile: any) {
    const eligibilityProfile: EligibilityProfile = {
      state: profile.state,
      age: parseInt(profile.age) || undefined,
      gender: profile.gender,
      socialCategory: profile.category,
      turnover: profile.income,
      sector: profile.activity
    };

    const cacheKey = this.generateCacheKey(eligibilityProfile);
    try {
      const cached = await this.redisClient.get(cacheKey);
      if (cached) {
        const data = JSON.parse(cached);
        data.metadata.fromCache = true;
        return { success: true, data };
      }
    } catch (err) {
      logger.warn({ err }, 'Redis cache get failed for recommendations');
    }

    try {
      // Step 1: AI Discovery (if Gemini is unavailable, this throws and goes to catch block)
      const discoveryResult = await this.router.runSchemeRecommendation(profile);
      const discoveries: SchemeDiscoveryResult[] = discoveryResult.recommendations;

      const verifiedRecommendations: SchemeRecommendation[] = [];
      const aiDiscoveredSchemes: SchemeRecommendation[] = [];

      // Step 2: Resolution & Deterministic Scoring
      for (const discovery of discoveries) {
        const resolved = await this.resolutionService.resolveScheme(discovery);

        if (resolved.resolutionStatus === 'VERIFIED' && resolved.schemeId) {
          const verifiedScheme = await this.schemeRepo.findById(resolved.schemeId);
          if (verifiedScheme) {
            const freshness = this.calculateFreshness(verifiedScheme.provenance?.lastVerifiedAt || verifiedScheme.lastReviewedAt);
            if (freshness.status === 'EXPIRED') {
              continue; // Do not recommend expired schemes
            }

            const detResult = RecommendationEngine.getRecommendations(
              [verifiedScheme.toJSON() as any], 
              eligibilityProfile, 
              1
            );
            
            const match = detResult.bestMatches[0] || detResult.potentiallyEligible[0];

            if (match) {
              verifiedRecommendations.push({
                schemeId: resolved.schemeId,
                schemeName: resolved.schemeName,
                category: verifiedScheme.category,
                ministry: verifiedScheme.ministry,
                shortDescription: verifiedScheme.shortDescription,
                source: 'VERIFIED',
                eligibilityStatus: match.eligibility.status,
                matchScore: match.score.total,
                aiConfidence: discovery.aiConfidence,
                officialUrl: discovery.officialUrl,
                explanationAvailable: true,
                trace: {
                  schemeId: resolved.schemeId,
                  profileSnapshot: eligibilityProfile,
                  matchedRules: match.eligibility.matchedRules,
                  failedRules: match.eligibility.failedRules,
                  score: match.score.total,
                  eligibilityStatus: match.eligibility.status,
                  engineVersion: '1.0.0',
                  evaluatedAt: new Date().toISOString()
                },
                freshness
              });
            }
          }
        } else {
          // AI Discovered - Unverified Opportunity
          aiDiscoveredSchemes.push({
            schemeName: discovery.schemeName,
            category: discovery.category,
            ministry: discovery.ministry,
            shortDescription: discovery.description,
            source: 'AI_DISCOVERED',
            eligibilityStatus: 'UNVERIFIED',
            matchScore: null,
            aiConfidence: discovery.aiConfidence,
            officialUrl: discovery.officialUrl,
            explanationAvailable: false
          });
        }
      }

      // Step 3: Sort verified recommendations
      verifiedRecommendations.sort((a, b) => {
        if (a.matchScore === b.matchScore) return 0;
        if (a.matchScore === null) return 1;
        if (b.matchScore === null) return -1;
        return b.matchScore - a.matchScore;
      });

      const responseData: SchemeRecommendationResponse = {
        generatedAt: new Date(),
        profileVersion: 'v1',
        engineVersion: '1.0.0',
        verifiedRecommendations,
        aiDiscoveredSchemes,
        metadata: {
          totalVerified: verifiedRecommendations.length,
          totalDiscovered: aiDiscoveredSchemes.length,
          fromCache: false,
          dataFreshness: verifiedRecommendations.some(r => r.freshness?.status === 'REVIEW_DUE') ? 'LIMITED' : 'FRESH',
          aiDiscoveryAvailable: true
        }
      };

      try {
        await this.redisClient.setex(cacheKey, this.CACHE_TTL_S, JSON.stringify(responseData));
      } catch (err) {
        logger.warn({ err }, 'Redis cache set failed for recommendations');
      }

      return { success: true, data: responseData };

    } catch (error) {
      logger.error({ err: error }, 'AI Discovery failed. Falling back to deterministic engine.');
      // Fallback: Pure deterministic recommendations
      return this.getFallbackRecommendations(eligibilityProfile, cacheKey);
    }
  }

  private async getFallbackRecommendations(profile: EligibilityProfile, cacheKey: string) {
    try {
      const candidates = await this.schemeRepo.findCandidateSchemes(profile);
      const detResult = RecommendationEngine.getRecommendations(
        candidates.map(c => c.toJSON() as any),
        profile,
        5
      );

      const verifiedRecommendations: SchemeRecommendation[] = detResult.bestMatches.map(match => {
        const freshness = this.calculateFreshness(match.scheme.provenance?.lastVerifiedAt || match.scheme.lastReviewedAt);
        return {
          schemeId: match.scheme.id,
          schemeName: match.scheme.name,
          category: match.scheme.category,
          ministry: match.scheme.ministry,
          shortDescription: match.scheme.shortDescription,
          source: 'VERIFIED' as const,
          eligibilityStatus: match.eligibility.status,
          matchScore: match.score.total,
          explanationAvailable: true,
          trace: {
            schemeId: match.scheme.id as string,
            profileSnapshot: profile,
            matchedRules: match.eligibility.matchedRules,
            failedRules: match.eligibility.failedRules,
            score: match.score.total,
            eligibilityStatus: match.eligibility.status,
            engineVersion: '1.0.0',
            evaluatedAt: new Date().toISOString()
          },
          freshness
        };
      }).filter(r => r.freshness.status !== 'EXPIRED');

      const responseData: SchemeRecommendationResponse = {
        generatedAt: new Date(),
        profileVersion: 'v1',
        engineVersion: '1.0.0',
        verifiedRecommendations,
        aiDiscoveredSchemes: [],
        metadata: {
          totalVerified: verifiedRecommendations.length,
          totalDiscovered: 0,
          fromCache: false,
          dataFreshness: verifiedRecommendations.some(r => r.freshness?.status === 'REVIEW_DUE') ? 'LIMITED' : 'FRESH',
          aiDiscoveryAvailable: false
        }
      };

      try {
        await this.redisClient.setex(cacheKey, this.CACHE_TTL_S, JSON.stringify(responseData));
      } catch (err) {
        logger.warn({ err }, 'Redis cache set failed for fallback recommendations');
      }
      return { success: true, data: responseData };
    } catch (fallbackError) {
      logger.error({ err: fallbackError }, 'Fallback recommendation also failed');
      return { success: false, error: { message: 'Failed to generate recommendations' } };
    }
  }

  private calculateCompleteness(profile: EligibilityProfile): number {
    let filled = 0;
    const keys = ['state', 'age', 'gender', 'socialCategory', 'turnover', 'sector'];
    keys.forEach(k => {
      if ((profile as any)[k] !== undefined && (profile as any)[k] !== null) filled++;
    });
    return Math.round((filled / keys.length) * 100) / 100;
  }
}
