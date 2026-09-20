import { AIProvider, GenerateResponse } from '../providers/ai-provider.interface';

export enum AITask {
  MODERATION = 'moderation',
  TRANSLATION = 'translation',
  SUMMARIZATION = 'summarization'
}

export interface AIRouterConfig {
  provider: AIProvider;
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

export interface SchemeDetails {
  schemeName: string;
  category: string;
  ministry: string;
  overview: string;
  benefits: string[];
  eligibilityCriteria: string[];
  requiredDocuments: string[];
  applicationProcess: string;
  officialUrl: string;
  applicationUrl: string;
  targetGroups: string[];
}

export class AITaskRouter {
  private provider: AIProvider;

  constructor(config: AIRouterConfig) {
    this.provider = config.provider;
  }

  async runModeration(content: string): Promise<{ isApproved: boolean; reason: string }> {
    const response = await this.provider.generateContent({
      prompt: `Please review the following content and determine if it violates community guidelines (hate speech, illegal goods, explicit content): \n\n${content}`,
      systemInstruction: 'You are an expert content moderator for a rural e-commerce platform. Return a JSON object with two fields: isApproved (boolean) and reason (string).',
      temperature: 0.1,
      responseSchema: {
        type: 'object',
        properties: {
          isApproved: { type: 'boolean' },
          reason: { type: 'string' }
        },
        required: ['isApproved', 'reason']
      }
    });

    try {
      const match = response.text.match(/\{[\s\S]*\}/);
      if (!match) throw new Error('No JSON object found');
      return JSON.parse(match[0]);
    } catch (e) {
      return { isApproved: false, reason: 'AI Response Parsing Failed' };
    }
  }

  async runTranslation(content: string, targetLanguage: string): Promise<string> {
    const response = await this.provider.generateContent({
      prompt: `Translate the following text into ${targetLanguage}:\n\n${content}`,
      systemInstruction: 'You are an expert translator. Preserve the original meaning and tone. Only return the translated text.',
      temperature: 0.3
    });
    return response.text;
  }

  async runVoiceCommand(query: string, currentLanguage: string): Promise<{ action: string; path?: string; searchQuery?: string; entityId?: string; language: 'en' | 'hi' | 'mr'; speechResponse: string; entities?: Record<string, string>; missing?: string[]; confidence?: number }> {
    const response = await this.provider.generateContent({
      prompt: `User query: "${query}"\nApp configured language: "${currentLanguage}"`,
      systemInstruction: `You are an AI Voice Assistant for a rural entrepreneur platform.
Analyze the user query and output a JSON object with:
1. action: Choose from "NAVIGATE", "SEARCH", "OPEN_SCHEME", "OPEN_COURSE", "FIND_MENTOR", "CHECK_PRICE", or "UNKNOWN".
2. path: Choose only from "/dashboard", "/learning", "/mentorship", "/schemes", "/dashboard/mandi".
3. searchQuery: Extracted search query text (optional).
4. entityId: Extracted ID (optional).
5. language: Spoken query language detected ("en", "hi", "mr").
6. speechResponse: Friendly text response in the detected spoken language.
7. entities: An object of extracted entities (e.g. commodity, market, state) (optional).
8. missing: If action is CHECK_PRICE and 'commodity' is missing from the user query, add "commodity" to this array. If 'market' is missing, add "market" to this array.
9. confidence: Float between 0.0 and 1.0 representing confidence in the interpretation.

Constraints:
- UNKNOWN: path must be absent.
- NAVIGATE: path is required.
- SEARCH: path + searchQuery are required.
- OPEN_SCHEME: path must be "/schemes".
- OPEN_COURSE: path must be "/learning".
- FIND_MENTOR: path must be "/mentorship".
- CHECK_PRICE: path must be "/dashboard/mandi". Extract commodity and market into entities. If commodity or market is missing, note it in the 'missing' array.

Example Hindi (Price check):
Input: "नागपुर में प्याज का भाव क्या है?"
Output: {"action": "CHECK_PRICE", "path": "/dashboard/mandi", "language": "hi", "speechResponse": "नागपुर में प्याज का भाव चेक कर रहा हूँ।", "entities": {"commodity": "Onion", "market": "Nagpur"}, "confidence": 0.95}

Example English (Incomplete price check):
Input: "What is the price of onion?"
Output: {"action": "CHECK_PRICE", "path": "/dashboard/mandi", "language": "en", "speechResponse": "Which market would you like to check?", "entities": {"commodity": "Onion"}, "missing": ["market"], "confidence": 0.91}`,
      temperature: 0.1,
      responseSchema: {
        type: 'object',
        properties: {
          action: { type: 'string', enum: ['NAVIGATE', 'SEARCH', 'OPEN_SCHEME', 'OPEN_COURSE', 'FIND_MENTOR', 'CHECK_PRICE', 'UNKNOWN'] },
          path: { type: 'string', enum: ['/dashboard', '/learning', '/mentorship', '/schemes', '/dashboard/mandi'] },
          searchQuery: { type: 'string' },
          entityId: { type: 'string' },
          language: { type: 'string', enum: ['en', 'hi', 'mr'] },
          speechResponse: { type: 'string' },
          entities: {
            type: 'object',
            additionalProperties: { type: 'string' }
          },
          missing: { type: 'array', items: { type: 'string' } },
          confidence: { type: 'number' }
        },
        required: ['action', 'language', 'speechResponse', 'confidence']
      }
    });

    try {
      const match = response.text.match(/\{[\s\S]*\}/);
      if (!match) throw new Error('No JSON object found');
      return JSON.parse(match[0]);
    } catch (e) {
      console.error('Failed to parse AI response or AI threw error:', e, 'Raw Response:', response?.text);
      return {
        action: 'UNKNOWN',
        language: currentLanguage as any || 'en',
        speechResponse: 'Could you please repeat that?',
        confidence: 0
      };
    }
  }

  /**
   * Phase A+B: Gemini discovers relevant scheme candidates.
   * Gemini = discovery only. Scoring is NOT Gemini's job.
   * Returns AI_DISCOVERED schemes with reasons (not final eligibility decisions).
   */
  async runSchemeRecommendation(profile: {
    activity: string;
    state: string;
    income: number;
    age: string;
    gender: string;
    category: string;
  }): Promise<{ recommendations: SchemeDiscoveryResult[] }> {
    const profileSummary = `
- Primary activity: ${profile.activity}
- State: ${profile.state}
- Annual income/turnover: ₹${profile.income.toLocaleString('en-IN')}
- Age group: ${profile.age}
- Gender: ${profile.gender}
- Social category: ${profile.category}`.trim();

    const response = await this.provider.generateContent({
      prompt: `User profile:\n${profileSummary}\n\nFind the 5 most relevant Indian government schemes for this user.`,
      systemInstruction: `You are an expert on Indian government schemes, subsidies, and welfare programs.
Given a user's profile, identify the most relevant REAL Indian government schemes they may benefit from.

Return ONLY schemes that actually exist as of 2024. Include schemes from:
- Central government (PM-level schemes, ministry schemes)
- State-specific schemes if the state is mentioned
- Agriculture, MSME, women empowerment, SC/ST, startup schemes as relevant

For each scheme, provide:
- schemeName: Official name of the scheme
- category: One of AGRICULTURE, ENTREPRENEURSHIP, FINANCE, EMPLOYMENT, EDUCATION, HOUSING, WOMEN, MSME, STARTUP, SOCIAL_WELFARE, DIGITAL, OTHER
- ministry: The responsible ministry/department
- description: 1-2 sentence description of what the scheme provides
- officialUrl: The real official government URL (myscheme.gov.in, ministry websites etc.)
- discoveryReason: A short sentence explaining WHY this scheme was discovered for this user
- aiConfidence: Number between 0.6 and 1.0 indicating how confident you are in this discovery

IMPORTANT: Do not invent schemes. Only return real schemes with real official URLs.
Identify potentially relevant government schemes and provide supporting information. Do not invent, infer, or generate authoritative eligibility rules. Eligibility rules will be obtained from the platform's verified government scheme database.`,
      temperature: 0.2,
      responseSchema: {
        type: 'object',
        properties: {
          recommendations: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                schemeName: { type: 'string' },
                category: { type: 'string' },
                ministry: { type: 'string' },
                description: { type: 'string' },
                officialUrl: { type: 'string' },
                discoveryReason: { type: 'string' },
                aiConfidence: { type: 'number' }
              },
              required: ['schemeName', 'description', 'aiConfidence']
            }
          }
        },
        required: ['recommendations']
      }
    });

    try {
      const match = response.text.match(/\{[\s\S]*\}/);
      if (!match) throw new Error('No JSON object found');
      const parsed = JSON.parse(match[0]);
      // Validate and sanitize
      const recommendations = (parsed.recommendations || []).map((r: any) => ({
        ...r,
        aiConfidence: Math.min(1.0, Math.max(0.0, Number(r.aiConfidence) || 0.7))
      }));
      return { recommendations };
    } catch (e) {
      return { recommendations: [] };
    }
  }

  /**
   * Phase D: Gemini explains a recommendation using OUR engine's results.
   * Gemini receives matched/failed rules and generates a human-friendly explanation.
   * Gemini does NOT decide eligibility here — it explains the engine's verdict.
   */
  async runSchemeExplanation(
    schemeName: string,
    profile: Record<string, any>,
    matchedReasons: string[],
    language: string = 'en'
  ): Promise<string> {
    const reasonsList = matchedReasons.length > 0
      ? matchedReasons.map(r => `• ${r}`).join('\n')
      : '• General relevance based on your profile';

    const languageMap: Record<string, string> = { en: 'English', hi: 'Hindi', mr: 'Marathi' };
    const targetLang = languageMap[language] || 'English';

    const response = await this.provider.generateContent({
      prompt: `Scheme: ${schemeName}\n\nUser profile summary: ${JSON.stringify(profile)}\n\nMatched criteria:\n${reasonsList}`,
      systemInstruction: `You are an explanation generator explaining why a government scheme was recommended.
Use ONLY the supplied verified scheme information and deterministic recommendation evidence.
Output the explanation in ${targetLang}.

Do not:
- determine eligibility
- modify the score
- create eligibility requirements
- add benefits not provided
- invent application procedures
- invent government sources

If information is unavailable, explicitly say it is unavailable. Write a friendly, clear 2-3 sentence explanation based ONLY on the matched criteria provided.`,
      temperature: 0.1
    });

    return response.text.trim();
  }

  /**
   * Phase D: Fetch comprehensive details for a specific scheme.
   * Returns structured information for the scheme detail page.
   */
  async runSchemeDetails(schemeName: string): Promise<SchemeDetails> {
    const response = await this.provider.generateContent({
      prompt: `Provide comprehensive details for this Indian government scheme: "${schemeName}"`,
      systemInstruction: `You are an expert on Indian government schemes. Provide accurate, detailed information about the specified scheme.
Only include information that is factually accurate as of 2024. If you are unsure about specific details, provide what is generally known.
For officialUrl and applicationUrl, use real government portal URLs (myscheme.gov.in, ministry websites, etc.).`,
      temperature: 0.1,
      responseSchema: {
        type: 'object',
        properties: {
          schemeName: { type: 'string' },
          category: { type: 'string' },
          ministry: { type: 'string' },
          overview: { type: 'string' },
          benefits: { type: 'array', items: { type: 'string' } },
          eligibilityCriteria: { type: 'array', items: { type: 'string' } },
          requiredDocuments: { type: 'array', items: { type: 'string' } },
          applicationProcess: { type: 'string' },
          officialUrl: { type: 'string' },
          applicationUrl: { type: 'string' },
          targetGroups: { type: 'array', items: { type: 'string' } }
        },
        required: ['schemeName', 'category', 'ministry', 'overview', 'benefits', 'eligibilityCriteria', 'officialUrl']
      }
    });

    try {
      return JSON.parse(response.text);
    } catch (e) {
      return {
        schemeName,
        category: 'OTHER',
        ministry: 'Government of India',
        overview: 'Details could not be loaded at this time.',
        benefits: [],
        eligibilityCriteria: [],
        requiredDocuments: [],
        applicationProcess: '',
        officialUrl: 'https://myscheme.gov.in',
        applicationUrl: 'https://myscheme.gov.in',
        targetGroups: []
      };
    }
  }
}
