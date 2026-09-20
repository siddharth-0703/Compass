import crypto from 'crypto';

// --- MOCK DATABASE MODELS ---
let ingestions: any[] = [];
let schemes: any[] = [];

const SchemeIngestionModel = {
  findOne: async (query: any) => ingestions.find(i => i.sourceId === query.sourceId && i.payloadHash === query.payloadHash),
  create: async (data: any) => { ingestions.push(data); return { ...data, save: async () => {} }; }
};

const SchemeModel = {
  findOne: async (query: any) => schemes.find(s => s.provenance?.sourceId === query['provenance.sourceId'] && s.provenance?.externalSchemeId === query['provenance.externalSchemeId']),
  create: async (data: any) => { schemes.push(data); return { ...data, save: async () => {} }; }
};

// --- MOCK ADAPTER ---
class ManualImportAdapter {
  sourceId = 'manual_import';
  sourceName = 'Administrator Manual Import';
  async fetchSchemes() {
    return [
      {
        "schemeCode": "PMEGP-001",
        "name": "Prime Minister's Employment Generation Programme",
        "shortDescription": "Credit-linked subsidy program",
        "category": "EMPLOYMENT",
        "officialSourceUrl": "https://www.kviconline.gov.in/",
        "eligibilityRules": [
          { "field": "age", "operator": "GTE", "value": 18, "confidence": "EXACT" },
          // Notice this rule is 'AMBIGUOUS' and 'requiresReview'
          { "field": "education", "operator": "EQ", "value": "8th Pass", "requiresReview": true, "confidence": "AMBIGUOUS" }
        ]
      }
    ];
  }
  normalize(record: any) { return record; }
  validate(record: any) { return { isValid: true, errors: [] }; }
}

// --- CORE PIPELINE LOGIC (from SchemePipeline.ts) ---
class SchemePipeline {
  constructor(private adapter: any) {}
  public async runSync(syncJobId: string): Promise<any> {
    const stats = { fetched: 0, created: 0, updated: 0, unchanged: 0 };
    const rawRecords = await this.adapter.fetchSchemes();
    stats.fetched = rawRecords.length;
    
    for (const raw of rawRecords) {
      // 1. Hash the payload
      const payloadHash = crypto.createHash('sha256').update(JSON.stringify(raw)).digest('hex');
      
      // 2. Exact Deduplication
      const existingIngestion = await SchemeIngestionModel.findOne({ sourceId: this.adapter.sourceId, payloadHash });
      if (existingIngestion) { stats.unchanged++; continue; }
      
      const normalized = this.adapter.normalize(raw);
      let requiresReview = normalized.eligibilityRules.some((r: any) => r.confidence === 'AMBIGUOUS' || r.requiresReview);

      // 3. Version Control
      const existingScheme = await SchemeModel.findOne({ 'provenance.sourceId': this.adapter.sourceId, 'provenance.externalSchemeId': normalized.schemeCode });
      if (existingScheme) {
        if (existingScheme.provenance?.sourceHash === payloadHash) { stats.unchanged++; continue; }
        existingScheme.version = (existingScheme.version || 1) + 1;
        existingScheme.status = 'PENDING_REVIEW';
        existingScheme.provenance.sourceHash = payloadHash;
        stats.updated++;
      } else {
        await SchemeModel.create({
          ...normalized,
          status: requiresReview ? 'PENDING_REVIEW' : 'DRAFT',
          provenance: { sourceId: this.adapter.sourceId, externalSchemeId: normalized.schemeCode, sourceHash: payloadHash, verificationStatus: 'UNVERIFIED' },
          version: 1
        });
        stats.created++;
      }
      await SchemeIngestionModel.create({ sourceId: this.adapter.sourceId, payloadHash });
    }
    return stats;
  }
}

// --- RUN TEST ---
async function runTest() {
  console.log('--- ISOLATED PIPELINE TEST ---\n');
  const adapter = new ManualImportAdapter();
  const pipeline = new SchemePipeline(adapter);

  console.log('▶ RUNNING SYNC 1');
  console.log('  Expected: Should fetch 1 scheme, normalize it, and CREATE it in the database.');
  let stats = await pipeline.runSync('test-job-1');
  console.log('  Result:', stats);

  console.log('\n▶ RUNNING SYNC 2 (Idempotency Test)');
  console.log('  Expected: Should fetch 1 scheme, hash the payload, realize it is identical to Sync 1, and mark it UNCHANGED.');
  stats = await pipeline.runSync('test-job-2');
  console.log('  Result:', stats);

  console.log('\n▶ VERIFYING BOUNDARY SAFETY');
  const scheme = schemes[0];
  console.log(`  Scheme Name: ${scheme?.name}`);
  console.log(`  Recommendation Status: ${scheme?.status} (MUST BE DRAFT OR PENDING_REVIEW)`);
  console.log(`  Provenance Status: ${scheme?.provenance?.verificationStatus}`);
  
  if (scheme?.status === 'PENDING_REVIEW') {
    console.log('\n✅ SUCCESS: The ambiguous eligibility rule correctly forced the scheme into PENDING_REVIEW! It will NOT reach the recommendation engine until verified.');
  }
}

runTest().catch(console.error);
