import { SchemeRepository } from '../repositories/scheme.repository';
import { BusinessRepository } from '../repositories/business.repository';
import { ProfileBuilder } from '../domain/schemes/eligibility/profile-builder';
import { RecommendationEngine } from '../domain/schemes/recommendation/recommendation.engine';
import { logger } from '@rural/logger';
import { Queue } from 'bullmq';

const aiQueue = new Queue('ai-tasks', { connection: { host: 'localhost', port: 6379 } });

export class SchemeService {
  private schemeRepo: SchemeRepository;
  private businessRepo: BusinessRepository;

  constructor() {
    this.schemeRepo = new SchemeRepository();
    this.businessRepo = new BusinessRepository();
  }

  async createScheme(data: any) {
    const scheme = await this.schemeRepo.createScheme({
      ...data,
      status: 'ACTIVE',
      lastReviewedAt: new Date(),
      version: 1
    });

    // Semantic Text for Qdrant (Preserving existing logic)
    const semanticText = `Scheme: ${scheme.name}. Department: ${scheme.department}. Description: ${scheme.shortDescription}.`;
    
    await aiQueue.add('generate-embedding', {
      postId: scheme.id, 
      content: semanticText,
      collection: 'government_schemes',
      payload: { 
        schemeId: scheme.id,
        department: scheme.department,
        category: scheme.category,
        status: scheme.status
      }
    });

    logger.info(`Scheme Created and queued for Embedding: ${scheme.id}`);
    return { success: true, data: scheme };
  }

  /**
   * Main Recommendation Pipeline execution.
   */
  async getRecommendations(businessId: string, user: any) {
    const business = await this.businessRepo.findById(businessId);
    if (!business) {
      return { success: false, error: { code: 'NOT_FOUND', message: 'Business not found' } };
    }

    // 1. Normalize Eligibility Profile
    const profile = ProfileBuilder.buildEligibilityProfile(user, business);

    // 2. Candidate Retrieval
    const candidates = await this.schemeRepo.findCandidateSchemes(profile);

    // 3. Deterministic Pipeline (Filter, Evaluate, Score, Rank, Categorize)
    const recommendations = RecommendationEngine.getRecommendations(
      candidates.map(c => c.toJSON() as any) as unknown as any[], 
      profile,
      5 // limit Top 5
    );

    return { success: true, data: recommendations };
  }

  // Backwards compatibility for existing routes that haven't migrated yet
  async matchSchemesToBusiness(businessId: string) {
    return this.getRecommendations(businessId, undefined);
  }
}
