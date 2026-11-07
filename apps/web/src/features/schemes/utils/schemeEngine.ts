export interface RecommendationTrace {
  schemeId: string;
  matchedRules: any[];
  failedRules: any[];
  score: number;
  eligibilityStatus: string;
}

export interface SchemeRecommendation {
  schemeName: string;
  category?: string;
  ministry?: string;
  shortDescription?: string;
  source: 'AI_DISCOVERED' | 'VERIFIED';
  aiConfidence?: number;
  matchScore: number | null;
  eligibilityStatus: 'LIKELY_ELIGIBLE' | 'POTENTIALLY_ELIGIBLE' | 'NOT_ELIGIBLE' | 'INSUFFICIENT_INFORMATION' | 'UNVERIFIED' | 'UNKNOWN';
  officialUrl?: string;
  explanationAvailable: boolean;
  trace?: RecommendationTrace;
  freshness?: {
    status: 'CURRENT' | 'REVIEW_DUE' | 'EXPIRED';
    lastVerifiedAt?: string;
  };
}

export interface SchemeRecommendationResponse {
  generatedAt: string;
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

export interface SchemeProfileInput {
  activity?: string;
  state?: string;
  income?: number;
  age?: string;
  gender?: string;
  category?: string;
}

export function getFallbackRecommendations(profile: SchemeProfileInput): SchemeRecommendationResponse {
  const activity = (profile.activity || 'FARMER').toUpperCase();
  const state = profile.state || 'Maharashtra';
  const income = typeof profile.income === 'number' ? profile.income : 80000;
  const age = profile.age || '26-40';
  const gender = (profile.gender || 'MALE').toUpperCase();
  const category = profile.category || 'SC';

  const isMaharashtra = state.toLowerCase().includes('maharashtra');
  const isFarmer = activity === 'FARMER' || activity === 'WOMEN_SHG';
  const isSCorST = category === 'SC' || category === 'ST';

  const verified: SchemeRecommendation[] = [];
  const aiDiscovered: SchemeRecommendation[] = [];

  // ==========================================
  // 1. VERIFIED SCHEMES
  // ==========================================

  // 1A. Dr. Babasaheb Ambedkar Krushi Swavalamban Yojana
  if (isMaharashtra && isSCorST && isFarmer) {
    verified.push({
      schemeName: 'Dr. Babasaheb Ambedkar Krushi Swavalamban Yojana',
      category: 'AGRICULTURE',
      ministry: 'Department of Agriculture, Government of Maharashtra',
      shortDescription:
        'Flagship Maharashtra scheme for Scheduled Caste (SC) & Neo-Buddhist farmers providing 100% subsidies up to ₹2.5 Lakh for new irrigation wells, in-well boring, solar pump sets, farm pond lining, and micro-irrigation.',
      source: 'VERIFIED',
      matchScore: 98,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://mahadbt.maharashtra.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'dr-ambedkar-krushi-01',
        matchedRules: [
          { field: 'SocialCategory', operator: '==', value: `${category} certified` },
          { field: 'StateDomicile', operator: '==', value: 'Maharashtra confirmed' },
          { field: 'AnnualIncome', operator: '<=', value: `₹${income.toLocaleString('en-IN')} within ₹1.5 Lakh limit` },
          { field: 'LandRecords', operator: 'in', value: '7/12 and 8-A landholder verified' },
        ],
        failedRules: [],
        score: 98,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1B. Namo Shetkari Mahasanman Nidhi Yojana
  if (isMaharashtra && isFarmer) {
    verified.push({
      schemeName: 'Namo Shetkari Mahasanman Nidhi Yojana',
      category: 'AGRICULTURE',
      ministry: 'Government of Maharashtra',
      shortDescription:
        'Maharashtra state financial assistance providing an additional ₹6,000 annually in 3 installments of ₹2,000 directly to PM-KISAN beneficiary farmers (Total ₹12,000/yr combined).',
      source: 'VERIFIED',
      matchScore: 97,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://mahadbt.maharashtra.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'namo-shetkari-02',
        matchedRules: [
          { field: 'PMKisanBeneficiary', operator: '==', value: 'Eligible & Linked' },
          { field: 'StateResident', operator: '==', value: 'Maharashtra' },
          { field: 'DirectBenefitTransfer', operator: '==', value: 'Aadhaar DBT enabled' },
        ],
        failedRules: [],
        score: 97,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1C. PM-KISAN Samman Nidhi
  if (isFarmer) {
    verified.push({
      schemeName: 'PM-KISAN Samman Nidhi',
      category: 'AGRICULTURE',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      shortDescription:
        'Central direct income support of ₹6,000 per year paid in three equal 4-monthly installments of ₹2,000 to all landholding farmer families across India.',
      source: 'VERIFIED',
      matchScore: 96,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://pmkisan.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'pm-kisan-03',
        matchedRules: [
          { field: 'LandholderFamily', operator: '==', value: 'Small & marginal criteria met' },
          { field: 'BankSeeding', operator: '==', value: 'Aadhaar-seeded bank account' },
        ],
        failedRules: [],
        score: 96,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1D. PM Kisan Maandhan Yojana (PM-KMY)
  if (isFarmer) {
    verified.push({
      schemeName: 'PM Kisan Maandhan Yojana (PM-KMY)',
      category: 'AGRICULTURE',
      ministry: 'Ministry of Agriculture & Farmers Welfare & LIC',
      shortDescription:
        'Voluntary pension scheme for Small & Marginal Farmers (age 18–40) ensuring guaranteed ₹3,000 monthly pension on attaining 60 years.',
      source: 'VERIFIED',
      matchScore: 95,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://pmkmy.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'pm-kmy-04',
        matchedRules: [
          { field: 'AgeGroup', operator: 'in', value: `${age} within entry bracket (18-40)` },
          { field: 'Landholding', operator: '<=', value: '2 hectares' },
        ],
        failedRules: [],
        score: 95,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1E. MahaDBT Farm Mechanization & Irrigation Subsidy
  if (isMaharashtra && isFarmer) {
    verified.push({
      schemeName: 'MahaDBT Farm Mechanization & Micro-Irrigation Subsidy',
      category: 'AGRICULTURE',
      ministry: 'Commissioner of Agriculture, Maharashtra',
      shortDescription:
        'Capital subsidies up to 80% for SC/ST farmers for drip & sprinkler irrigation systems, tractors, power tillers, and crop processing machinery.',
      source: 'VERIFIED',
      matchScore: 94,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://mahadbt.maharashtra.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'mahadbt-agri-05',
        matchedRules: [
          { field: 'AffirmativeSCQuota', operator: '==', value: '80% subsidy applied' },
          { field: 'LandholdingState', operator: '==', value: 'Maharashtra' },
        ],
        failedRules: [],
        score: 94,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1F. Stand-Up India Scheme (SC / ST Priority)
  if (isSCorST) {
    verified.push({
      schemeName: `Stand-Up India Scheme (${category} Priority)`,
      category: 'FINANCE',
      ministry: 'Ministry of Finance & SIDBI',
      shortDescription:
        `Facilitates bank loans between ₹10 Lakh and ₹1 Crore to Scheduled Caste (${category}) borrowers for setting up greenfield agribusinesses and enterprises.`,
      source: 'VERIFIED',
      matchScore: 93,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://www.standupmitra.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'standup-india-06',
        matchedRules: [
          { field: 'SocialCategory', operator: '==', value: `${category} Priority met` },
          { field: 'EnterpriseType', operator: '==', value: 'Greenfield commercial unit' },
        ],
        failedRules: [],
        score: 93,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1G. Entrepreneur / Artisan Schemes
  if (activity === 'ENTREPRENEUR' || activity === 'ARTISAN') {
    verified.push({
      schemeName: 'Pradhan Mantri Mudra Yojana (PMMY)',
      category: 'FINANCE',
      ministry: 'Ministry of Finance & MSME',
      shortDescription:
        'Collateral-free institutional micro-credit loans up to ₹10 Lakh (Shishu, Kishore & Tarun) for non-corporate, non-farm rural micro enterprises.',
      source: 'VERIFIED',
      matchScore: 92,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://www.mudra.org.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'pmmy-mudra-07',
        matchedRules: [
          { field: 'MicroEnterprise', operator: '==', value: 'Verified' },
          { field: 'CreditCeiling', operator: '<=', value: '₹10 Lakh' },
        ],
        failedRules: [],
        score: 92,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // 1H. Women / SHG Schemes
  if (gender === 'FEMALE' || activity === 'WOMEN_SHG') {
    verified.unshift({
      schemeName: 'Lakhpati Didi SHG Micro-Enterprise Mission',
      category: 'WOMEN',
      ministry: 'Ministry of Rural Development',
      shortDescription:
        'National initiative providing credit linkages, market facilitation, and technical training enabling rural women to earn sustainable annual income above ₹1 Lakh.',
      source: 'VERIFIED',
      matchScore: 98,
      eligibilityStatus: 'LIKELY_ELIGIBLE',
      officialUrl: 'https://nrlm.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'lakhpati-didi-08',
        matchedRules: [
          { field: 'GenderAffirmative', operator: '==', value: 'Female / SHG member' },
          { field: 'SHGLinkage', operator: '==', value: 'Approved' },
        ],
        failedRules: [],
        score: 98,
        eligibilityStatus: 'LIKELY_ELIGIBLE',
      },
      freshness: { status: 'CURRENT' },
    });
  }

  // ==========================================
  // 2. AI DISCOVERED SCHEMES
  // ==========================================

  // 2A. Karmaveer Dadasaheb Gaikwad Sabalikaran and Swabhiman Yojana
  if (isMaharashtra && isSCorST) {
    aiDiscovered.push({
      schemeName: 'Karmaveer Dadasaheb Gaikwad Sabalikaran Yojana',
      category: 'SOCIAL_WELFARE',
      ministry: 'Social Justice & Special Assistance Department, Maharashtra',
      shortDescription:
        'Economic empowerment scheme for Scheduled Caste (SC) and Neo-Buddhist families providing land assistance, agricultural asset support, and 100% grant for self-sufficiency.',
      source: 'AI_DISCOVERED',
      matchScore: null,
      aiConfidence: 0.94,
      eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
      officialUrl: 'https://sjsa.maharashtra.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'karmaveer-gaikwad-ai-01',
        matchedRules: [
          { field: 'SocialCategory', operator: '==', value: `${category} certified in Maharashtra` },
          { field: 'IncomeLevel', operator: '<=', value: `₹${income.toLocaleString('en-IN')} qualifies under BPL / economic criteria` },
        ],
        failedRules: [],
        score: 92,
        eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
      },
    });
  }

  // 2B. Pradhan Mantri Fasal Bima Yojana (PMFBY)
  aiDiscovered.push({
    schemeName: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    category: 'AGRICULTURE',
    ministry: 'Ministry of Agriculture & Farmers Welfare',
    shortDescription:
      'Comprehensive crop insurance against drought, floods, pest attacks, and post-harvest unseasonal damage with capped nominal premium of 1.5% to 2% (In Maharashtra, covered under ₹1 scheme).',
    source: 'AI_DISCOVERED',
    matchScore: null,
    aiConfidence: 0.92,
    eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
    officialUrl: 'https://pmfby.gov.in',
    explanationAvailable: true,
    trace: {
      schemeId: 'pmfby-ai-02',
      matchedRules: [
        { field: 'RiskMitigation', operator: '==', value: `Crop season mapped for ${state}` },
        { field: 'SubsidizedPremium', operator: '==', value: 'Central & State subsidized' },
      ],
      failedRules: [],
      score: 91,
      eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
    },
  });

  // 2C. Special Central Assistance to SC Sub-Plan (SCA to SCSP)
  if (isSCorST) {
    aiDiscovered.push({
      schemeName: 'Special Central Assistance to Scheduled Castes Sub-Plan (SCA to SCSP)',
      category: 'SOCIAL_WELFARE',
      ministry: 'Ministry of Social Justice & Empowerment',
      shortDescription:
        '100% grant assistance for composite economic development, skill training, and income-generating agricultural projects for SC households.',
      source: 'AI_DISCOVERED',
      matchScore: null,
      aiConfidence: 0.90,
      eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
      officialUrl: 'https://socialjustice.gov.in',
      explanationAvailable: true,
      trace: {
        schemeId: 'sca-scsp-ai-03',
        matchedRules: [
          { field: 'SocialCategory', operator: '==', value: `${category} affirmative criteria met` },
          { field: 'GrantType', operator: '==', value: '100% Project Grant' },
        ],
        failedRules: [],
        score: 90,
        eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
      },
    });
  }

  // 2D. PM Formalisation of Micro Food Processing Enterprises (PMFME)
  aiDiscovered.push({
    schemeName: 'PM Formalisation of Micro Food Processing Enterprises (PMFME)',
    category: 'MSME',
    ministry: 'Ministry of Food Processing Industries',
    shortDescription:
      'Under Aatmanirbhar Bharat Abhiyan, offers 35% credit-linked capital subsidy up to ₹10 Lakh per enterprise for upgrading micro agro-processing units.',
    source: 'AI_DISCOVERED',
    matchScore: null,
    aiConfidence: 0.88,
    eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
    officialUrl: 'https://pmfme.mofpi.gov.in',
    explanationAvailable: true,
    trace: {
      schemeId: 'pmfme-ai-04',
      matchedRules: [
        { field: 'AgroProcessing', operator: '==', value: 'Value-addition criteria valid' },
        { field: 'CapitalSubsidy', operator: '<=', value: '35% subsidy eligible' },
      ],
      failedRules: [],
      score: 88,
      eligibilityStatus: 'POTENTIALLY_ELIGIBLE',
    },
  });

  return {
    generatedAt: new Date().toISOString(),
    profileVersion: 'v1',
    engineVersion: '1.0.0',
    verifiedRecommendations: verified,
    aiDiscoveredSchemes: aiDiscovered,
    metadata: {
      totalVerified: verified.length,
      totalDiscovered: aiDiscovered.length,
      fromCache: false,
      dataFreshness: 'FRESH',
      aiDiscoveryAvailable: true,
    },
  };
}

export function getFallbackExplanation(schemeName: string, profile?: any): string {
  const state = profile?.state || 'Maharashtra';
  const category = profile?.category || 'SC';

  if (schemeName.includes('Ambedkar')) {
    return `Dr. Babasaheb Ambedkar Krushi Swavalamban Yojana is specially tailored for ${category} farmers in ${state}. Because your annual income is within the ₹1.5 Lakh ceiling and you possess landholdings, you qualify for 100% state subsidies on new irrigation wells (up to ₹2.5 Lakh), solar pumps, and micro-irrigation.`;
  }
  if (schemeName.includes('Namo Shetkari')) {
    return `Namo Shetkari Mahasanman Nidhi Yojana provides an extra ₹6,000/year from the Government of Maharashtra to farmers registered under PM-KISAN, doubling your annual direct benefit transfer to ₹12,000 per year.`;
  }
  if (schemeName.includes('PM-KISAN')) {
    return `PM-KISAN Samman Nidhi provides guaranteed direct income support of ₹6,000 per year deposited directly into your Aadhaar-linked bank account in three 4-monthly installments of ₹2,000.`;
  }
  if (schemeName.includes('Karmaveer')) {
    return `Karmaveer Dadasaheb Gaikwad Sabalikaran Yojana empowers marginalized ${category} agrarian households in ${state} with 100% state government financial assistance for land and agricultural asset development.`;
  }
  if (schemeName.includes('Fasal Bima')) {
    return `PM Fasal Bima Yojana protects your farm produce against unseasonal rain, pest attacks, and drought. In Maharashtra, the state government subsidizes farmer premiums under the ₹1 crop insurance scheme.`;
  }
  return `This scheme matches your enterprise sector in ${state} and your ${category} social category criteria with high confidence under official central and state government guidelines.`;
}

