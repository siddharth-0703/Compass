import { IGovernmentScheme } from '@rural/types';
import crypto from 'crypto';
import { SchemeModel, SchemeIngestionModel } from '@rural/database';
import { SchemeSourceAdapter } from './adapters/SchemeSourceAdapter';

export class SchemePipeline {
  constructor(private adapter: SchemeSourceAdapter) {}

  public async runSync(syncJobId: string): Promise<any> {
    const stats = { fetched: 0, created: 0, updated: 0, unchanged: 0, rejected: 0, failed: 0 };
    
    // 1. Fetch
    const rawRecords = await this.adapter.fetchSchemes();
    stats.fetched = rawRecords.length;

    // Process each record independently so a single failure doesn't ruin the batch
    for (const raw of rawRecords) {
      try {
        await this.processRecord(raw, syncJobId, stats);
      } catch (err) {
        console.error(`Failed to process record in sync ${syncJobId}:`, err);
        stats.failed++;
      }
    }

    return stats;
  }

  private async processRecord(raw: any, syncJobId: string, stats: any) {
    // 2. Hash raw payload
    const payloadHash = this.hashPayload(raw);

    // 3. Deduplicate (Skip if we already ingested this exact payload from this source)
    const existingIngestion = await SchemeIngestionModel.findOne({ sourceId: this.adapter.sourceId, payloadHash });
    if (existingIngestion) {
       stats.unchanged++;
       return;
    }

    // Determine external ID if possible to store in IngestionRecord safely
    const tempNormalized = this.adapter.normalize(raw);
    const externalId = tempNormalized.schemeCode || `unknown-${Date.now()}`;

    // Create raw ingestion record (Preserve Provenance)
    const ingestion = new SchemeIngestionModel({
      sourceId: this.adapter.sourceId,
      externalSchemeId: externalId,
      rawPayload: raw,
      payloadHash,
      fetchedAt: new Date(),
      syncJobId,
      processingStatus: 'RECEIVED'
    });
    await ingestion.save();

    // 4. Normalize
    const normalized = this.adapter.normalize(raw);
    ingestion.processingStatus = 'TRANSFORMED';
    await ingestion.save();

    // 5. Validate
    const validation = this.adapter.validate(normalized);
    if (!validation.isValid) {
      ingestion.processingStatus = 'REJECTED';
      ingestion.validationErrors = validation.errors;
      await ingestion.save();
      stats.rejected++;
      return;
    }
    
    ingestion.processingStatus = 'VALIDATED';
    await ingestion.save();

    // 6. Deterministic Rule Confidence check
    let requiresReview = false;
    for (const rule of normalized.eligibilityRules || []) {
      if (rule.confidence === 'AMBIGUOUS' || rule.requiresReview) {
        requiresReview = true;
      }
    }

    // 7. Versioning & Update Detection
    const existingScheme = await SchemeModel.findOne({ 
      'provenance.sourceId': this.adapter.sourceId, 
      'provenance.externalSchemeId': normalized.schemeCode 
    });

    const normalizedHash = this.hashPayload(normalized);

    if (existingScheme) {
      if (existingScheme.provenance?.sourceHash === normalizedHash) {
        // No meaningful changes after normalization
        stats.unchanged++;
        ingestion.processingStatus = 'IMPORTED';
        await ingestion.save();
        return;
      }

      // Changes detected -> Create a Revision.
      existingScheme.name = normalized.name!;
      existingScheme.shortDescription = normalized.shortDescription!;
      existingScheme.description = normalized.description;
      existingScheme.benefits = normalized.benefits || [];
      existingScheme.eligibilityRules = normalized.eligibilityRules || [];
      
      existingScheme.provenance!.sourceHash = normalizedHash;
      existingScheme.provenance!.fetchedAt = new Date();
      existingScheme.version += 1;
      
      // Safety Boundary: Any update to an existing scheme pushes it back into PENDING_REVIEW.
      // It is immediately removed from the active recommender engine until verified.
      existingScheme.status = 'PENDING_REVIEW';
      existingScheme.provenance!.verificationStatus = 'PENDING_REVIEW';

      await existingScheme.save();
      stats.updated++;
    } else {
      // Create new draft
      const newScheme = new SchemeModel({
        ...normalized,
        status: 'DRAFT',
        provenance: {
          sourceId: this.adapter.sourceId,
          sourceName: this.adapter.sourceName,
          sourceUrl: normalized.officialSourceUrl,
          externalSchemeId: normalized.schemeCode,
          fetchedAt: new Date(),
          sourceHash: normalizedHash,
          verificationStatus: 'UNVERIFIED'
        },
        lastReviewedAt: new Date(),
        version: 1
      });
      await newScheme.save();
      stats.created++;
    }

    ingestion.processingStatus = 'IMPORTED';
    await ingestion.save();
  }

  private hashPayload(payload: any): string {
    return crypto.createHash('sha256').update(JSON.stringify(payload)).digest('hex');
  }
}
