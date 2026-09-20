import { IGovernmentScheme } from '@rural/types';

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

export interface SchemeSourceAdapter {
  sourceId: string;
  sourceName: string;

  /**
   * Fetches the raw records from the government source.
   * If credentials are not available, this MUST throw 'SOURCE_NOT_CONFIGURED'.
   */
  fetchSchemes(): Promise<any[]>;

  /**
   * Transforms a single raw source object into our canonical IGovernmentScheme format.
   * This handles the mapping, but does NOT perform the database saving.
   */
  normalize(record: any): Partial<IGovernmentScheme>;

  /**
   * Validates the normalized scheme against our strict schema requirements.
   */
  validate(record: Partial<IGovernmentScheme>): ValidationResult;
}
