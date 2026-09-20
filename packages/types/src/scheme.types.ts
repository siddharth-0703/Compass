export type SchemeCategory = 
  | 'AGRICULTURE' 
  | 'ENTREPRENEURSHIP' 
  | 'FINANCE' 
  | 'EMPLOYMENT' 
  | 'EDUCATION' 
  | 'HOUSING' 
  | 'WOMEN' 
  | 'MSME' 
  | 'STARTUP' 
  | 'SOCIAL_WELFARE' 
  | 'DIGITAL' 
  | 'OTHER';

export type SchemeStatus = 
  | 'DRAFT' 
  | 'PENDING_REVIEW' 
  | 'VERIFIED' 
  | 'ACTIVE' 
  | 'ARCHIVED' 
  | 'REJECTED' 
  | 'PENDING_ARCHIVAL';

export type VerificationStatus =
  | 'UNVERIFIED'
  | 'PENDING_REVIEW'
  | 'VERIFIED'
  | 'REJECTED';

export interface SchemeProvenance {
  sourceId: string;
  sourceName: string;
  sourceUrl?: string;
  externalSchemeId?: string;

  fetchedAt: Date;
  lastVerifiedAt?: Date;

  sourceVersion?: string;
  sourceHash?: string;

  verificationStatus: VerificationStatus;

  verifiedBy?: string;
  verifiedAt?: Date;
}

export type EligibilityOperator = 
  | 'EQ' 
  | 'NEQ' 
  | 'GT' 
  | 'GTE' 
  | 'LT' 
  | 'LTE' 
  | 'IN' 
  | 'NOT_IN' 
  | 'BETWEEN' 
  | 'CONTAINS' 
  | 'EXISTS';

export interface EligibilityRule {
  field: string;
  operator: EligibilityOperator;
  value: any;
  logicalGroup?: 'AND' | 'OR';
  
  sourceText?: string;
  sourceUrl?: string;
  confidence?: 'EXACT' | 'STRUCTURED' | 'AMBIGUOUS';
  requiresReview?: boolean;
}

export interface Benefit {
  type: string;
  description: string;
  amount?: number;
  percentage?: number;
  currency?: string;
}

export interface IGovernmentScheme {
  id?: string;
  schemeCode: string;
  name: string;
  localizedName?: Record<string, string>; // e.g., { hi: '...', mr: '...' }
  shortDescription: string;
  description?: string;
  ministry?: string;
  department?: string;
  category: SchemeCategory;
  targetGroups: string[];
  benefits: Benefit[];
  eligibilityRules: EligibilityRule[];
  requiredDocuments: string[];
  applicationProcess?: string;
  officialSourceUrl: string;
  applicationUrl?: string;
  states?: string[];
  districts?: string[];
  languages: ('en' | 'hi' | 'mr')[];
  status: SchemeStatus;
  
  provenance?: SchemeProvenance;
  lastReviewedAt: Date;
  version: number;

  createdAt?: Date;
  updatedAt?: Date;
}

// Backwards compatibility alias if required by any legacy code
/** @deprecated Use IGovernmentScheme instead */
export interface IScheme extends IGovernmentScheme {}

// Normalized Eligibility Profile
export interface EligibilityProfile {
  // User profile derived
  age?: number;
  gender?: string;
  state?: string;
  district?: string;
  education?: string;
  socialCategory?: string;

  // Business profile derived
  businessType?: string;
  sector?: string;
  turnover?: number;
  businessStage?: string;
  employeeCount?: number;
  annualRevenue?: number;
  registrationStatus?: string;
  
  // Dynamic Questionnaire / Additional keys
  [key: string]: any;
}

export interface EligibilityResult {
  status: 'LIKELY_ELIGIBLE' | 'POTENTIALLY_ELIGIBLE' | 'NOT_ELIGIBLE' | 'INSUFFICIENT_INFORMATION';
  matchedRules: EligibilityRule[];
  failedRules: EligibilityRule[];
  missingFields: string[];
}

export interface SchemeDiscoveryResult {
  schemeName: string;
  category?: string;
  ministry?: string;
  description?: string;
  officialUrl?: string;
  discoveryReason?: string;
  aiConfidence: number;
}

export interface ResolvedScheme {
  schemeId?: string;
  schemeName: string;
  resolutionStatus:
    | "VERIFIED"
    | "UNVERIFIED"
    | "NOT_FOUND";
  source:
    | "CANONICAL_DATABASE"
    | "AI_DISCOVERED";
  aiConfidence?: number;
}

export interface RecommendationTrace {
  schemeId: string;
  profileSnapshot: EligibilityProfile;
  matchedRules: EligibilityRule[];
  failedRules: EligibilityRule[];
  score: number;
  eligibilityStatus: 'LIKELY_ELIGIBLE' | 'POTENTIALLY_ELIGIBLE' | 'NOT_ELIGIBLE' | 'INSUFFICIENT_INFORMATION' | 'UNVERIFIED';
  engineVersion: string;
  evaluatedAt: string;
}

export interface SchemeRecommendation {
  schemeId?: string;
  schemeName: string;
  category?: string;
  ministry?: string;
  shortDescription?: string;

  source: "VERIFIED" | "AI_DISCOVERED";

  eligibilityStatus:
    | "LIKELY_ELIGIBLE"
    | "POTENTIALLY_ELIGIBLE"
    | "NOT_ELIGIBLE"
    | "INSUFFICIENT_INFORMATION"
    | "UNVERIFIED";

  matchScore: number | null;

  matchedRules?: EligibilityRule[];
  failedRules?: EligibilityRule[];
  missingFields?: string[];

  aiConfidence?: number;
  officialUrl?: string;
  explanationAvailable: boolean;
  
  trace?: RecommendationTrace;

  freshness?: {
    lastVerifiedAt?: Date;
    status: 'CURRENT' | 'REVIEW_DUE' | 'EXPIRED';
  };
}

export interface SchemeRecommendationResponse {
  generatedAt: Date;
  profileVersion: string;
  engineVersion: string;

  verifiedRecommendations: SchemeRecommendation[];
  aiDiscoveredSchemes: SchemeRecommendation[];

  metadata: {
    totalVerified: number;
    totalDiscovered: number;
    fromCache: boolean;
    dataFreshness: 'FRESH' | 'STALE' | 'LIMITED';
    aiDiscoveryAvailable: boolean;
  };
}
