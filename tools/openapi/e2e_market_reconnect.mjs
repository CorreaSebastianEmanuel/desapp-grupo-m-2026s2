import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {access, writeFile} from 'node:fs/promises';
import {join} from 'node:path';

const [base] = process.argv.slice(2);
const {E2E_EMAIL: email, E2E_PASSWORD: password, E2E_PLAYER: player, E2E_NAME: name,
  E2E_IPC: ipc} = process.env;
let browser;
let phase = 'prerequisites';

async function waitForFile(path) {
  const deadline = Date.now() + 30_000;
  while (Date.now() < deadline) {
    try {
      await access(path);
      return;
    } catch {
      await new Promise(resolve => setTimeout(resolve, 25));
    }
  }
  throw new Error('browser reconnect deadline');
}

try {
  browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
  const context = await browser.newContext();
  context.setDefaultTimeout(15000);
  const page = await context.newPage();
  phase = 'authentication';
  await page.goto(base + '/sign-in');
  await page.getByLabel('Email', {exact: true}).fill(email);
  await page.getByLabel('Password', {exact: true}).fill(password);
  await page.getByRole('button', {name: 'Sign in', exact: true}).click();
  await page.waitForSelector('.phx-connected #workspace');

  phase = 'create-order';
  await page.goto(`${base}/players?player_id=${player}`);
  await page.waitForSelector('.phx-connected #player-card');
  assert.match(await page.locator('#player-card').innerText(), new RegExp(name));
  await page.locator('#player-card').getByRole('link', {name: 'Create order', exact: true}).click();
  await page.waitForSelector('.phx-connected #conditional-order-form');
  await page.getByLabel('Quantity', {exact: true}).fill('3');
  await page.getByLabel('Maximum unit price', {exact: true}).fill('10.00');
  await page.getByLabel('Expiry in UTC', {exact: true}).fill(new Date(Date.now() + 3600000).toISOString());
  await page.getByRole('button', {name: 'Create order', exact: true}).click();
  await page.waitForSelector('#order-notice');

  phase = 'offline-commit';
  await context.setOffline(true);
  await writeFile(join(ipc, 'execute'), 'ready', {mode: 0o600});
  await waitForFile(join(ipc, 'committed'));

  phase = 'reconnect-recovery';
  await context.setOffline(false);
  await page.goto(base + '/conditional-orders');
  await page.waitForSelector('.phx-connected #order-list');
  assert.match(await page.locator('#order-list').innerText(), /executed/);
  await page.reload();
  await page.waitForSelector('.phx-connected #order-list');
  assert.match(await page.locator('#order-list').innerText(), /executed/);

  await page.goto(base + '/portfolio');
  await page.waitForSelector('.phx-connected #portfolio-positions');
  assert.equal(await page.locator(`#portfolio-position-${player} td`).first().innerText(), '3');
  await page.reload();
  await page.waitForSelector('.phx-connected #portfolio-positions');
  assert.equal(await page.locator(`#portfolio-position-${player} td`).first().innerText(), '3');

  await context.close();
  process.stdout.write('E2E_MARKET_RECONNECT status=complete\n');
} catch {
  process.stderr.write(`E2E_MARKET_RECONNECT status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
