import { SchemeModel, ISchemeDocument } from '@rural/database';
import { IGovernmentScheme, EligibilityProfile } from '@rural/types';

export class SchemeRepository {
  async createScheme(data: Partial<IGovernmentScheme>): Promise<ISchemeDocument> {
    const scheme = new SchemeModel(data);
    return scheme.save();
  }

  async findSchemes(query: any = {}) {
    return SchemeModel.find(query).sort({ createdAt: -1 }).limit(100);
  }

  async findById(id: string): Promise<ISchemeDocument | null> {
    return SchemeModel.findById(id);
  }

  async findByName(name: string): Promise<ISchemeDocument | null> {
    // Case insensitive regex search for the scheme name
    return SchemeModel.findOne({ name: { $regex: new RegExp(`^${name}$`, 'i') } });
  }

  /**
   * Identity Resolution helper.
   * Matches scheme name case-insensitively, strictly enforcing ACTIVE and VERIFIED status.
   */
  async findVerifiedActiveByNormalizedName(name: string): Promise<ISchemeDocument | null> {
    return SchemeModel.findOne({
      name: { $regex: new RegExp(`^${name}$`, 'i') },
      status: 'ACTIVE',
      'provenance.verificationStatus': 'VERIFIED'
    });
  }

  /**
   * 1. CANDIDATE RETRIEVAL
   * Retrieves active schemes using cheap database filters (indexes).
   * Does NOT interpret eligibility rules.
   */
  async findCandidateSchemes(profile: EligibilityProfile): Promise<ISchemeDocument[]> {
    // STRICT BOUNDARY (Phase 2): Only ever retrieve Active AND Verified schemes.
    // Unverified drafts or pending revisions are completely hidden from the recommender.
    const query: any = { 
      status: 'ACTIVE',
      'provenance.verificationStatus': 'VERIFIED' 
    }; 
    // Cheap indexed filter: State matching
    if (profile.state) {
      query['$or'] = [
        { states: { $size: 0 } }, // Central scheme
        { states: { $exists: false } }, // Legacy fallback
        { states: profile.state } // Exact state match
      ];
    }
    
    // We intentionally DO NOT query the eligibilityRules array here.
    return SchemeModel.find(query);
  }
}
