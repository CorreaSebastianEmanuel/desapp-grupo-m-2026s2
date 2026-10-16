import {mkdirSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const root = fileURLToPath(new URL('../../', import.meta.url));
mkdirSync(new URL('../../cover/workspace/', import.meta.url), {recursive: true});
const result = spawnSync(process.execPath, [
  '--test', '--experimental-test-coverage',
  '--test-coverage-include=assets/js/workspace_session.js',
  '--test-coverage-lines=100', '--test-coverage-branches=100', '--test-coverage-functions=100',
  '--test-reporter=spec', '--test-reporter-destination=stdout',
  '--test-reporter=lcov', '--test-reporter-destination=cover/workspace/lcov.info',
  'tools/openapi/workspace_session.test.mjs'
], {cwd: root, stdio: 'inherit'});
if (result.error) {
  console.error('Workspace JavaScript coverage could not start.');
}
process.exitCode = result.status ?? 1;
