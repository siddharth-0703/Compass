import { IGovernmentScheme, EligibilityProfile, EligibilityResult } from '@rural/types';

export interface ScoreDetails {
  eligibilityScore: number;
  categoryScore: number;
  locationScore: number;
  targetGroupScore: number;
  benefitScore: number;
}

export interface RecommendationScore {
  total: number;
  version: string;
  details: ScoreDetails;
}

export class ScoringEngine {
  public static readonly VERSION = 'v1';

  /**
   * Deterministically calculates a Match Score (0-100) for a scheme against a profile.
   * This score represents relevance and match quality, NOT probability of approval.
   */
  static calculateScore(
    scheme: IGovernmentScheme, 
    profile: EligibilityProfile, 
    eligibility: EligibilityResult
  ): RecommendationScore {
    // Zero score for ineligible schemes
    if (eligibility.status === 'NOT_ELIGIBLE') {
      return { 
        total: 0, 
        version: this.VERSION, 
        details: { eligibilityScore: 0, categoryScore: 0, locationScore: 0, targetGroupScore: 0, benefitScore: 0 } 
      };
    }

    // 1. Base Eligibility Match (Max 50)
    let eligibilityScore = 0;
    if (eligibility.status === 'LIKELY_ELIGIBLE') {
      eligibilityScore = 50;
    } else if (eligibility.status === 'INSUFFICIENT_INFORMATION' || eligibility.status === 'POTENTIALLY_ELIGIBLE') {
      eligibilityScore = 30;
    }

    // 2. Goal / Category Match (Max 20)
    let categoryScore = 0;
    if (scheme.category === profile.sector || scheme.category === profile.businessType) {
      categoryScore = 20;
    } else if (scheme.category === 'OTHER' || !scheme.category) {
      categoryScore = 10; // Neutral category
    }

    // 3. Location Relevance (Max 10)
    let locationScore = 0;
    if (scheme.states && scheme.states.length > 0) {
      if (profile.state && scheme.states.includes(profile.state)) {
        locationScore = 10;
      }
    } else {
      // Central scheme, universally applicable
      locationScore = 10;
    }

    // 4. Target Group Match (Max 10)
    let targetGroupScore = 0;
    if (scheme.targetGroups && scheme.targetGroups.length > 0) {
      const matchFound = scheme.targetGroups.some(group => {
        const g = group.toUpperCase();
        if (g === 'WOMEN' && profile.gender === 'FEMALE') return true;
        if (profile.socialCategory && g.includes(profile.socialCategory.toUpperCase())) return true;
        if (profile.businessType && g.includes(profile.businessType.toUpperCase())) return true;
        return false;
      });
      targetGroupScore = matchFound ? 10 : 5;
    } else {
      targetGroupScore = 10; // Open to all groups
    }

    // 5. Benefit Relevance (Max 10)
    const benefitScore = scheme.benefits && scheme.benefits.length > 0 ? 10 : 0;

    const total = eligibilityScore + categoryScore + locationScore + targetGroupScore + benefitScore;

    return {
      total,
      version: this.VERSION,
      details: { eligibilityScore, categoryScore, locationScore, targetGroupScore, benefitScore }
    };
  }
}
