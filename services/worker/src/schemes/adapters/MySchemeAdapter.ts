import { SchemeSourceAdapter, ValidationResult } from './SchemeSourceAdapter';
import { IGovernmentScheme } from '@rural/types';

export class MySchemeAdapter implements SchemeSourceAdapter {
  sourceId = 'myscheme_gov_in';
  sourceName = 'Official myscheme.gov.in API';

  async fetchSchemes(): Promise<any[]> {
    const apiKey = process.env.MYSCHEME_API_KEY;
    const apiUrl = process.env.MYSCHEME_API_URL;

    if (!apiKey || !apiUrl) {
      // NON-NEGOTIABLE RULE: Do not fabricate endpoints or bypass protections.
      // Gracefully halt the sync run by throwing the specific configuration error.
      throw new Error('SOURCE_NOT_CONFIGURED');
    }

    // In a real run with keys:
    // const response = await axios.get(apiUrl, { headers: { Authorization: `Bearer ${apiKey}` } });
    // return response.data.schemes;
    
    return [];
  }

  normalize(record: any): Partial<IGovernmentScheme> {
    return {
      schemeCode: record.id,
      name: record.schemeName,
      shortDescription: record.brief,
      category: 'OTHER', // Placeholder for actual external mapping logic
      officialSourceUrl: `https://myscheme.gov.in/schemes/${record.id}`,
      languages: ['en']
    };
  }

  validate(record: Partial<IGovernmentScheme>): ValidationResult {
    const errors: string[] = [];
    if (!record.schemeCode) errors.push('Missing external ID (schemeCode)');
    return { isValid: errors.length === 0, errors };
  }
}
