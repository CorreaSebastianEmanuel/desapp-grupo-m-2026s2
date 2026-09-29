import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { validate } from './validate.mjs';

const source = fileURLToPath(new URL('../../priv/static/openapi.json', import.meta.url));

test('published contract is valid OpenAPI 3', async () => {
  const document = await validate(source);
  assert.equal(document.openapi, '3.0.3');
});

test('malformed and incomplete disposable contracts are rejected', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'openapi-test-'));
  try {
    const document = JSON.parse(await readFile(source, 'utf8'));
    for (const [name, mutation] of [
      ['version', copy => { copy.openapi = '2.0'; }],
      ['schema', copy => { delete copy.components.schemas.Player.properties.id; }],
      ['malformed', () => null]
    ]) {
      const path = join(dir, `${name}.json`);
      const copy = structuredClone(document);
      mutation(copy);
      await writeFile(path, name === 'malformed' ? '{' : JSON.stringify(copy));
      await assert.rejects(validate(path));
    }
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});
