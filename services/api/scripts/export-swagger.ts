import * as fs from 'fs';
import * as path from 'path';
import { swaggerSpec } from '../src/swagger';

const outputPath = path.resolve(__dirname, '../openapi.json');
fs.writeFileSync(outputPath, JSON.stringify(swaggerSpec, null, 2));

console.log(`Successfully exported OpenAPI spec to ${outputPath}`);
