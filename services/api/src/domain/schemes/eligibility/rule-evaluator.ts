import { EligibilityRule, EligibilityProfile } from '@rural/types';
import { Operators } from './operators';

export class RuleEvaluator {
  /**
   * Evaluates a single strict deterministic rule against a normalized profile.
   */
  static evaluate(rule: EligibilityRule, profile: EligibilityProfile): { passed: boolean; missing: boolean } {
    const profileValue = profile[rule.field];

    if (profileValue === undefined || profileValue === null) {
      // Missing fields fail the rule unless explicitly checking for non-existence
      if (rule.operator === 'EXISTS' && rule.value === false) {
        return { passed: true, missing: false };
      }
      return { passed: false, missing: true };
    }

    const opFunc = Operators[rule.operator];
    if (!opFunc) {
      throw new Error(`Unsupported operator: ${rule.operator}`);
    }

    const passed = opFunc(profileValue, rule.value);
    return { passed, missing: false };
  }
}
