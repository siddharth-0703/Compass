import { IGovernmentScheme, EligibilityProfile, EligibilityResult } from '@rural/types';
import { EligibilityEngine } from '../eligibility/eligibility.engine';
import { ScoringEngine, RecommendationScore } from '../scoring/scoring.engine';

export interface RecommendedScheme {
  scheme: IGovernmentScheme;
  eligibility: EligibilityResult;
  score: RecommendationScore;
  category: 'BEST_MATCHES' | 'POTENTIALLY_ELIGIBLE';
}

export class RecommendationEngine {
  /**
   * Pipeline for filtering, evaluating, scoring, and ranking candidate schemes.
   */
  static getRecommendations(
    candidateSchemes: IGovernmentScheme[],
    profile: EligibilityProfile,
    limit: number = 5
  ): { bestMatches: RecommendedScheme[], potentiallyEligible: RecommendedScheme[] } {
    
    const results: RecommendedScheme[] = [];

    // Pipeline Execution
    for (const scheme of candidateSchemes) {
      // 1. Evaluate Eligibility
      const eligibility = EligibilityEngine.evaluateProfile(scheme.eligibilityRules || [], profile);
      
      // 2. Remove clearly NOT_ELIGIBLE schemes
      if (eligibility.status === 'NOT_ELIGIBLE') continue;

      // 3. Score remaining schemes deterministically
      const score = ScoringEngine.calculateScore(scheme, profile, eligibility);

      // 4. Categorize outcome
      const category = (eligibility.status === 'LIKELY_ELIGIBLE' && score.total >= 70) 
        ? 'BEST_MATCHES' 
        : 'POTENTIALLY_ELIGIBLE';

      results.push({
        scheme,
        eligibility,
        score,
        category
      });
    }

    // 5. Rank by deterministic total score
    results.sort((a, b) => b.score.total - a.score.total);

    // 6. Split and limit
    const bestMatches = results.filter(r => r.category === 'BEST_MATCHES').slice(0, limit);
    const potentiallyEligible = results.filter(r => r.category === 'POTENTIALLY_ELIGIBLE').slice(0, limit);

    return {
      bestMatches,
      potentiallyEligible
    };
  }
}
