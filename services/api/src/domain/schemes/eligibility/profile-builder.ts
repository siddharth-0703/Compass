import { EligibilityProfile } from '@rural/types';

export class ProfileBuilder {
  /**
   * Constructs a normalized EligibilityProfile using data from the User model,
   * Business model, and any explicit dynamic questionnaire answers.
   */
  static buildEligibilityProfile(
    user?: any, // IUserDocument
    business?: any, // IBusinessDocument
    questionnaireAnswers?: Record<string, any>
  ): EligibilityProfile {
    const profile: EligibilityProfile = {};

    // 1. Map User Data
    if (user) {
      profile.age = user.age;
      profile.gender = user.gender;
      profile.education = user.education;
      profile.socialCategory = user.socialCategory;
      if (user.state) profile.state = user.state;
      if (user.district) profile.district = user.district;
    }

    // 2. Map Business Data (Overrides user geography if present)
    if (business) {
      if (business.location?.state) profile.state = business.location.state;
      if (business.location?.district) profile.district = business.location.district;
      
      profile.businessType = business.registrationType;
      profile.sector = business.category;
      profile.turnover = business.financials?.annualTurnover;
      profile.businessStage = business.stage;
      profile.employeeCount = business.employees;
      profile.annualRevenue = business.financials?.annualTurnover;
      profile.registrationStatus = business.status;
      
      // Derived business fields
      if (business.womenOwned) {
        profile.gender = 'FEMALE';
      }
    }

    // 3. Map Explicit Questionnaire Answers (Overrides everything)
    if (questionnaireAnswers) {
      Object.assign(profile, questionnaireAnswers);
    }

    return profile;
  }
}
