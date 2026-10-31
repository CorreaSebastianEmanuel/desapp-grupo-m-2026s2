import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {join} from 'node:path';

const [base] = process.argv.slice(2);
const {E2E_EMAIL: email, E2E_PASSWORD: password, E2E_IPC: ipc} = process.env;
let browser;
let phase = 'prerequisites';

try {
  assert(base && email && password && ipc);
  browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
  const page = await browser.newPage();
  page.setDefaultTimeout(15000);

  phase = 'login';
  assert.equal((await page.goto(`${base}/sign-in`)).status(), 200);
  await page.getByLabel('Email', {exact: true}).fill(email);
  await page.getByLabel('Password', {exact: true}).fill(password);
  const login = page.waitForResponse(r => r.request().method() === 'POST' && new URL(r.url()).pathname === '/sign-in');
  await page.getByRole('button', {name: 'Sign in', exact: true}).click();
  assert.equal((await login).status(), 303);

  phase = 'search';
  assert.equal((await page.goto(`${base}/players`)).status(), 200);
  await page.waitForSelector('.phx-connected #workspace');
  await page.getByLabel('Player name').fill('Alex');
  await page.getByRole('button', {name: 'Search players'}).click();
  await page.getByText('Searching the configured catalog sources in the background. Search again shortly.').waitFor();
  await writeFile(join(ipc, 'scouting-visible'), 'ready', {mode: 0o600});

  phase = 'publication';
  await page.locator('#player-search-results').getByText('Alex', {exact: true}).waitFor({timeout: 30000});
  assert.match(await page.locator('#player-search-results').innerText(), /Alpha/);
  process.stdout.write('E2E_CATALOG_SCOUT status=complete\n');
} catch {
  process.stderr.write(`E2E_CATALOG_SCOUT status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
