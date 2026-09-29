import SwaggerParser from '@apidevtools/swagger-parser';
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';

export async function validate(path) {
  const document = JSON.parse(await readFile(path, 'utf8'));
  if (!/^3\.0\.\d+$/.test(document.openapi || '')) {
    throw new Error('Expected an OpenAPI 3.0 document');
  }
  await SwaggerParser.validate(document);
  for (const [name, schema] of Object.entries(document.components?.schemas || {})) {
    for (const field of schema.required || []) {
      if (!Object.hasOwn(schema.properties || {}, field)) {
        throw new Error(`${name} requires undefined field ${field}`);
      }
    }
  }
  return document;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    await validate(process.argv[2] || 'priv/static/openapi.json');
    process.stdout.write('OpenAPI 3 validation passed\n');
  } catch (error) {
    process.stderr.write(`OpenAPI validation failed: ${error.message}\n`);
    process.exitCode = 1;
  }
}
