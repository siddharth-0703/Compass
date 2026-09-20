import { SchemeSourceAdapter, ValidationResult } from './SchemeSourceAdapter';
import { IGovernmentScheme } from '@rural/types';
import fs from 'fs';
import path from 'path';

export class ManualImportAdapter implements SchemeSourceAdapter {
  sourceId = 'manual_import';
  sourceName = 'Administrator Manual Import';

  async fetchSchemes(): Promise<any[]> {
    // Reads JSON dumps provided by admins from the data/manual-schemes directory.
    // This allows safe end-to-end testing without fabricating API endpoints.
    const importDir = path.resolve(process.cwd(), 'data/manual-schemes');
    
    if (!fs.existsSync(importDir)) {
      return [];
    }

    const files = fs.readdirSync(importDir).filter(f => f.endsWith('.json'));
    const schemes = [];

    for (const file of files) {
      const content = fs.readFileSync(path.join(importDir, file), 'utf-8');
      try {
        const parsed = JSON.parse(content);
        if (Array.isArray(parsed)) {
          schemes.push(...parsed);
        } else {
          schemes.push(parsed);
        }
      } catch (err) {
        console.error(`Failed to parse manual import file ${file}`, err);
      }
    }
    return schemes;
  }

  normalize(record: any): Partial<IGovernmentScheme> {
    // Manual imports are assumed to be close to the canonical model, 
    // but we enforce the mapping to guarantee safety.
    return {
      schemeCode: record.schemeCode || `MANUAL-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      name: record.name,
      shortDescription: record.shortDescription,
      description: record.description,
      category: record.category || 'OTHER',
      targetGroups: record.targetGroups || [],
      benefits: record.benefits || [],
      eligibilityRules: record.eligibilityRules || [],
      requiredDocuments: record.requiredDocuments || [],
      officialSourceUrl: record.officialSourceUrl,
      applicationUrl: record.applicationUrl,
      states: record.states || [],
      languages: record.languages || ['en']
    };
  }

  validate(record: Partial<IGovernmentScheme>): ValidationResult {
    const errors: string[] = [];
    
    if (!record.name) errors.push('Missing scheme name');
    if (!record.shortDescription) errors.push('Missing short description');
    if (!record.category) errors.push('Missing category');
    if (!record.officialSourceUrl) errors.push('Missing officialSourceUrl');
    
    return {
      isValid: errors.length === 0,
      errors
    };
  }
}
