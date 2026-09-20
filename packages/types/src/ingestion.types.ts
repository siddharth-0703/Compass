export interface SchemeSourceConfig {
  sourceId: string;
  sourceName: string;
  type: 'API' | 'JSON' | 'CSV' | 'MANUAL';
  enabled: boolean;

  baseUrl?: string;
  credentialsConfigured: boolean;

  lastSyncAt?: Date;
  lastSuccessfulSyncAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export interface SchemeIngestionRecord {
  id?: string;
  sourceId: string;
  externalSchemeId?: string;

  rawPayload: any;
  payloadHash: string;

  fetchedAt: Date;
  syncJobId?: string;

  processingStatus: 'RECEIVED' | 'TRANSFORMED' | 'VALIDATED' | 'REJECTED' | 'IMPORTED';
  validationErrors?: string[];

  createdAt?: Date;
  updatedAt?: Date;
}
