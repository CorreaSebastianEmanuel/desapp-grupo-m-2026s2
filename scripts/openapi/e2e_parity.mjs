import assert from 'node:assert/strict';
import {chromium} from 'playwright-core';

const [base] = process.argv.slice(2);
const fixture = JSON.parse(process.env.E2E_PARITY);
const viewports = [
  {width: 1280, height: 800},
  {width: 768, height: 1024},
  {width: 390, height: 844},
];

async function signIn(page, email, password) {
  await page.goto(base + '/sign-in');
  await page.getByLabel('Correo electrónico', {exact: true}).fill(email);
  await page.getByLabel('Contraseña', {exact: true}).fill(password);
  await page.getByRole('button', {name: 'Iniciar sesión', exact: true}).click();
  await page.waitForSelector('.phx-connected #workspace');
}

async function catalog(page) {
  await page.goto(base + '/players');
  await page.waitForSelector('.phx-connected #player-catalog-search');
  await page.locator('#player-search').fill(fixture.name);
  for (const [key, value] of Object.entries(fixture.filters)) {
    await page.locator(`[name=${key}]`).selectOption(value);
  }
  await page.locator('#catalog-page-size').selectOption('1');
  await page.getByRole('button', {name: 'Buscar jugadores'}).click();

  const next = page.locator('#catalog-next');
  await next.waitFor();
  assert.equal(await page.locator('#player-search-results tbody tr').count(), 1);
  await page.locator(`#player-search-results a[href^="/players?player_id=${fixture.player}"]`).waitFor();
  await next.click();
  await page.waitForURL(url => url.searchParams.has('cursor'));
  const continuation = page.url();
  const playerLink = page.locator(`#player-search-results a[href^="/players?player_id=${fixture.nextPlayer}"]`);

  for (const viewport of viewports) {
    await page.setViewportSize(viewport);
    await playerLink.click();
    await page.waitForSelector('.phx-connected #player-card');
    assert.equal(new URL(page.url()).searchParams.get('player_id'), fixture.nextPlayer);
    await page.goBack();
    assert.equal(page.url(), continuation);
    await page.reload();
    await page.waitForSelector('.phx-connected #player-catalog-search');
    assert.equal(await page.locator('#player-search').inputValue(), fixture.name);
    assert.equal(await page.locator('#catalog-page-size').inputValue(), '1');
    for (const [key, value] of Object.entries(fixture.filters)) {
      assert.equal(await page.locator(`[name=${key}]`).inputValue(), value);
    }
    assert.equal(await page.locator('#player-search-results tbody tr').count(), 1);
    await playerLink.waitFor();
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
  }
}

async function transactionIsolation(owner, spectator) {
  await owner.goto(base + '/transactions?page_size=1');
  const rows = owner.locator('#transactions tbody tr');
  const continuation = owner.locator('#transactions-next');
  await continuation.waitFor();
  assert.equal(await rows.count(), 1);
  const firstId = await rows.first().getAttribute('id');
  const nextPath = await continuation.getAttribute('href');
  await continuation.click();
  await owner.waitForURL(url => url.searchParams.has('cursor'));
  assert.equal(await rows.count(), 1);
  assert.notEqual(await rows.first().getAttribute('id'), firstId);

  await spectator.goto(base + '/transactions');
  await spectator.locator('#transactions-empty').waitFor();
  await spectator.goto(base + nextPath);
  await spectator.locator('#transactions [role="alert"]').waitFor();
  assert.equal(await spectator.locator('#transactions tbody tr').count(), 0);
}

async function portfolio(page, quantity, marketValue, sales) {
  await page.goto(base + `/portfolio?tab=details&from=${fixture.date}&to=${fixture.date}`);
  await page.waitForSelector('.phx-connected #portfolio-allocation-totals');
  const values = await page.locator('#portfolio-allocation-totals dd').allTextContents();
  assert.deepEqual(values.map(value => Number(value.trim())).slice(0, 8),
    [marketValue, marketValue, Number(fixture.tradingValue), sales, marketValue, 0, 0, 0]);
  if (quantity > 0) {
    assert.equal(await page.locator('#portfolio-allocation-table tbody td').first().innerText(), String(quantity));
  } else {
    assert.equal(await page.locator('#portfolio-allocation-table tbody tr').count(), 0);
  }

  await page.locator('#portfolio-history-details summary').click();
  const daily = page.locator('#portfolio-history-table tbody tr');
  assert.equal(await daily.count(), 1);
  assert.equal(await daily.locator('th').innerText(), fixture.date);
  const dailyValues = await daily.locator('td').allTextContents();
  assert.deepEqual(dailyValues.slice(1, 9).map(value => Number(value.trim())),
    values.slice(0, 8).map(value => Number(value.trim())));
}

const browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
let phase = 'sign-in';
try {
  const owner = await browser.newPage();
  const spectator = await browser.newPage();
  await signIn(owner, process.env.E2E_EMAIL, process.env.E2E_PASSWORD);
  await signIn(spectator, process.env.E2E_SPECTATOR_EMAIL, process.env.E2E_SPECTATOR_PASSWORD);
  phase = 'catalog';
  await catalog(owner);
  phase = 'transactions';
  await transactionIsolation(owner, spectator);
  phase = 'open-portfolio';
  const marketValue = Number(fixture.marketValue);
  await portfolio(owner, 2, marketValue, marketValue);
  phase = 'close-portfolio';
  await owner.goto(base + `/players?player_id=${fixture.player}`);
  await owner.waitForSelector('.phx-connected #trade-form');
  await owner.locator('#trade-form [name="quantity"]').fill('2');
  await owner.getByRole('button', {name: 'Vender tokens'}).click();
  await owner.locator('#trade-confirmation').waitFor();
  await portfolio(owner, 0, 0, Number(fixture.tradingValue));
  console.log('E2E_PARITY status=complete');
} catch (error) {
  console.error(`E2E_PARITY status=failed phase=${phase}`);
  throw error;
} finally {
  await browser.close();
}
