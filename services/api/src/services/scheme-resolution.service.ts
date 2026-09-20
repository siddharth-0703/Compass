import { SchemeDiscoveryResult, ResolvedScheme } from '@rural/types';
import { SchemeRepository } from '../repositories/scheme.repository';
import { logger } from '@rural/logger';

export class SchemeResolutionService {
  private schemeRepo: SchemeRepository;

  constructor() {
    this.schemeRepo = new SchemeRepository();
  }

  /**
   * Resolves an AI-discovered scheme against the canonical database.
   * Priority: Exact canonical name -> Normalized name.
   */
  async resolveScheme(discovery: SchemeDiscoveryResult): Promise<ResolvedScheme> {
    try {
      // 1. Exact Name Match (Canonical)
      const exactMatch = await this.schemeRepo.findVerifiedActiveByNormalizedName(discovery.schemeName);
      
      if (exactMatch) {
        return {
          schemeId: exactMatch.id,
          schemeName: exactMatch.name,
          resolutionStatus: 'VERIFIED',
          source: 'CANONICAL_DATABASE',
          aiConfidence: discovery.aiConfidence
        };
      }

      // 2. Fallback: Normalized/Alias Matching
      // In a production system, this could check an alias mapping table or use tighter fuzzy matching.
      // For now, if exact case-insensitive match fails, it's UNVERIFIED.
      
      return {
        schemeName: discovery.schemeName,
        resolutionStatus: 'NOT_FOUND',
        source: 'AI_DISCOVERED',
        aiConfidence: discovery.aiConfidence
      };

    } catch (error) {
      logger.error({ err: error, schemeName: discovery.schemeName }, 'Failed to resolve scheme identity');
      return {
        schemeName: discovery.schemeName,
        resolutionStatus: 'NOT_FOUND',
        source: 'AI_DISCOVERED',
        aiConfidence: discovery.aiConfidence
      };
    }
  }
}
