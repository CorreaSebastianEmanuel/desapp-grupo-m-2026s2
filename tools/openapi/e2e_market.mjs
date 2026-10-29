import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {join} from 'node:path';
const [base] = process.argv.slice(2);
const {E2E_EMAIL: email, E2E_PASSWORD: password, E2E_PLAYER: player,
  E2E_NAME: name, E2E_RANKING: ranking, E2E_STRATEGY: strategy, E2E_IPC: ipc} = process.env;
let browser;
let phase = 'prerequisites';
try {
  browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
  const context = await browser.newContext();
  context.setDefaultTimeout(15000);
  const page = await context.newPage();
  phase = 'authentication';
  for (const path of ['/players', '/ranking', '/portfolio']) {
    const denied = await context.request.get(base + path, {maxRedirects: 0});
    assert.equal(denied.status(), 303);
    assert.match(denied.headers().location, /^\/sign-in/);
  }
  await page.goto(base + '/sign-in');
  await page.getByLabel('Email', {exact: true}).fill(email);
  await page.getByLabel('Password', {exact: true}).fill(password);
  await page.getByRole('button', {name: 'Sign in', exact: true}).click();
  await page.waitForSelector('.phx-connected #workspace');
  phase = 'search-card';
  await page.getByRole('link', {name: 'Players', exact: true}).click();
  await page.waitForSelector('.phx-connected #player-catalog-search');
  await page.getByLabel('Player name', {exact: true}).fill(name);
  await page.getByRole('button', {name: 'Search players', exact: true}).click();
  await page.locator(`a[href='/players?player_id=${player}']`).click();
  await page.waitForSelector('.phx-connected #player-card');
  assert.match(await page.locator('#player-quote').innerText(), /Effective at/);
  assert.match(await page.locator('#player-statistics').innerText(), /Recorded matches/);
  phase = 'conditional-order';
  await page.locator('#player-card').getByRole('link', {name: 'Create order', exact: true}).click();
  await page.waitForSelector('.phx-connected #conditional-order-form');
  assert.match(await page.locator('#selected-player').innerText(), new RegExp(player));
  await page.getByLabel('Quantity', {exact: true}).fill('3');
  await page.getByLabel('Maximum unit price', {exact: true}).fill('10');
  await page.getByLabel('Expiry in UTC', {exact: true}).fill(new Date(Date.now() + 3600000).toISOString());
  await page.getByRole('button', {name: 'Create order', exact: true}).click();
  await page.waitForSelector('#order-notice');
  const portfolio = await context.newPage();
  await portfolio.goto(base + '/portfolio');
  await portfolio.waitForSelector('.phx-connected #no-positions');
  await writeFile(join(ipc, 'execute'), 'ready', {mode: 0o600});
  await portfolio.waitForSelector(`#portfolio-position-${player}`);
  assert.equal(await portfolio.locator(`#portfolio-position-${player} td`).first().innerText(), '3');
  await page.waitForFunction(() => document.querySelector('#order-list')?.textContent.includes('executed'));
  phase = 'sell';
  await portfolio.locator(`a[href='/players?player_id=${player}']`).click();
  await portfolio.waitForSelector('.phx-connected #trade-form');
  await portfolio.goto(base + '/portfolio');
  await portfolio.waitForSelector('.phx-connected #portfolio-positions');
  await page.goto(`${base}/players?player_id=${player}`);
  await page.waitForSelector('.phx-connected #trade-form');
  await page.getByLabel('Action', {exact: true}).selectOption('sell');
  await page.getByLabel('Token quantity', {exact: true}).fill('1');
  await page.getByRole('button', {name: 'Confirm trade', exact: true}).click();
  await page.waitForSelector('#trade-notice');
  assert.match(await page.locator(`#trade-position-${player}`).innerText(), /2 tokens/);
  await portfolio.waitForFunction(id => document.querySelector(`#portfolio-position-${id} td`)?.textContent.trim() === '2', player);
  assert.equal(await portfolio.locator(`#portfolio-position-${player} td`).first().innerText(), '2');
  phase = 'ranking';
  await page.getByRole('link', {name: 'Ranking', exact: true}).click();
  await page.waitForSelector('.phx-connected #ranking-strategy');
  assert((await page.locator('#ranking-strategy').innerText()).includes(strategy));
  assert.deepEqual(await page.locator('#ranking-entries li').evaluateAll(rows => rows.map(row => row.id.replace('ranking-player-', ''))), JSON.parse(ranking));
  await context.close();
  process.stdout.write('E2E_MARKET status=complete\n');
} catch {
  process.stderr.write(`E2E_MARKET status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
