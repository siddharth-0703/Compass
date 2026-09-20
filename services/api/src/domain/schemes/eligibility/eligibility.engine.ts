import { EligibilityRule, EligibilityProfile, EligibilityResult } from '@rural/types';
import { RuleEvaluator } from './rule-evaluator';

export class EligibilityEngine {
  /**
   * Evaluates a set of scheme rules against a user/business profile.
   * Returns a categorical result: LIKELY_ELIGIBLE, NOT_ELIGIBLE, or INSUFFICIENT_INFORMATION.
   */
  static evaluateProfile(rules: EligibilityRule[], profile: EligibilityProfile): EligibilityResult {
    const matchedRules: EligibilityRule[] = [];
    const failedRules: EligibilityRule[] = [];
    const missingFieldsSet = new Set<string>();
    
    for (const rule of rules) {
      const { passed, missing } = RuleEvaluator.evaluate(rule, profile);
      
      if (missing) {
        missingFieldsSet.add(rule.field);
      } else if (passed) {
        matchedRules.push(rule);
      } else {
        failedRules.push(rule);
      }
    }

    let status: EligibilityResult['status'] = 'LIKELY_ELIGIBLE';

    if (failedRules.length > 0) {
      status = 'NOT_ELIGIBLE';
    } else if (missingFieldsSet.size > 0) {
      status = 'INSUFFICIENT_INFORMATION';
    }

    return {
      status,
      matchedRules,
      failedRules,
      missingFields: Array.from(missingFieldsSet)
    };
  }
}
