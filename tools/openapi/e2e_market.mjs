import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {join} from 'node:path';
const [base] = process.argv.slice(2);
const {E2E_EMAIL: email, E2E_PASSWORD: password, E2E_PLAYER: player,
  E2E_NAME: name, E2E_RANKING: ranking, E2E_FILTERS: filtersJson,
  E2E_STRATEGY: strategy, E2E_IPC: ipc} = process.env;
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
  await page.getByLabel('Correo electrónico', {exact: true}).fill(email);
  await page.getByLabel('Contraseña', {exact: true}).fill(password);
  await page.getByRole('button', {name: 'Iniciar sesión', exact: true}).click();
  await page.waitForSelector('.phx-connected #workspace');
  phase = 'catalog-link';
  await page.getByRole('link', {name: 'Jugadores', exact: true}).click();
  phase = 'catalog-search';
  await page.waitForSelector('.phx-connected #player-catalog-search');
  await page.getByLabel('Nombre del jugador', {exact: true}).fill(name);
  await page.getByRole('button', {name: 'Buscar jugadores', exact: true}).click();
  await page.waitForURL(url => url.searchParams.get('q') === name);
  phase = 'combined-catalog-filters';
  const filters = JSON.parse(filtersJson);
  await page.locator('#catalog-league').selectOption(filters.league_id);
  await page.locator('#catalog-team').selectOption(filters.team_id);
  await page.locator('#catalog-position').selectOption(filters.position_id);
  await page.locator('#catalog-page-size').selectOption('1');
  await page.getByRole('button', {name: 'Buscar jugadores', exact: true}).click();
  await page.waitForURL(url => url.searchParams.get('team_id') === filters.team_id);
  const searchUrl = page.url();
  for (const viewport of [{width: 1280, height: 800}, {width: 768, height: 1024}, {width: 390, height: 844}]) {
    await page.setViewportSize(viewport);
    await page.locator(`a[href^='/players?player_id=${player}']`).click();
    await page.waitForSelector('.phx-connected #player-card');
    await page.goBack();
    await page.waitForSelector('.phx-connected #player-catalog-search');
    assert.equal(page.url(), searchUrl);
    await page.reload();
    await page.waitForSelector('.phx-connected #player-catalog-search');
    for (const [key, value] of Object.entries(filters)) {
      assert.equal(await page.locator(`[name=${key}]`).inputValue(), value);
    }
    assert.equal(await page.locator('#player-search').inputValue(), name);
    assert.equal(await page.locator('#catalog-page-size').inputValue(), '1');
    assert.equal(await page.locator('#player-search-results tbody tr').count(), 1);
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
  }
  await page.setViewportSize({width: 1280, height: 800});
  phase = 'search-result';
  await page.locator(`a[href^='/players?player_id=${player}']`).click();
  await page.waitForSelector('.phx-connected #player-card');
  assert.match(await page.locator('#player-quote').innerText(), /Vigente desde/);
  assert.match(await page.locator('#player-statistics').innerText(), /Partidos registrados/);
  assert.equal(await page.locator('#quote-provenance').count(), 1);
  assert.equal(await page.locator('#quote-history').count(), 1);
  assert.equal(await page.locator('#player-freshness').count(), 1);
  await page.getByLabel('Buscar cotización al cierre de una fecha', {exact: true}).fill(new Date().toISOString().slice(0, 10));
  await page.getByRole('button', {name: 'Consultar fecha', exact: true}).click();
  await page.locator('#quote-history [role=status]').waitFor();
  phase = 'conditional-order';
  await page.locator('#player-card').getByRole('link', {name: 'Crear orden', exact: true}).click();
  await page.waitForSelector('.phx-connected #conditional-order-form');
  const selectedPlayer = await page.locator('#selected-player').innerText();
  assert.match(selectedPlayer, new RegExp(name));
  assert(!selectedPlayer.includes(player));
  await page.getByLabel('Cantidad', {exact: true}).fill('3');
  await page.getByLabel('Precio máximo por token (créditos)', {exact: true}).fill('10');
  await page.getByLabel('Vencimiento (fecha y hora UTC)', {exact: true}).fill(new Date(Date.now() + 3600000).toISOString());
  await page.getByRole('button', {name: 'Crear orden condicional', exact: true}).click();
  await page.waitForSelector('#order-notice');
  const portfolio = await context.newPage();
  await portfolio.goto(base + '/portfolio');
  await portfolio.waitForSelector('.phx-connected #no-positions');
  await writeFile(join(ipc, 'execute'), 'ready', {mode: 0o600});
  await portfolio.waitForSelector(`#portfolio-position-${player}`);
  assert.equal(await portfolio.locator(`#portfolio-position-${player} td`).first().innerText(), '3');
  await page.waitForFunction(() => document.querySelector('#order-list')?.textContent.includes('Ejecutada'));
  await page.locator('#order-list details summary').first().click();
  assert.match(await page.locator('#order-list').innerText(), /Cotización/);
  phase = 'sell-player-navigation';
  await portfolio.locator(`#portfolio-position-${player} a`).click();
  phase = 'sell-portfolio-card';
  await portfolio.waitForSelector('.phx-connected #trade-form');
  phase = 'sell-return-portfolio';
  await portfolio.goto(base + '/portfolio');
  phase = 'sell-portfolio-reloaded';
  await portfolio.waitForSelector('.phx-connected #portfolio-positions');
  phase = 'sell-direct-card';
  await page.goto(`${base}/players?player_id=${player}`);
  phase = 'sell-direct-form';
  await page.waitForSelector('.phx-connected #trade-form');
  phase = 'sell-submit';
  await page.getByLabel('Cantidad de tokens', {exact: true}).fill('1');
  await page.getByRole('button', {name: 'Vender tokens', exact: true}).click();
  phase = 'sell-confirmation';
  await page.waitForSelector('#trade-notice');
  await page.locator('#trade-confirmation summary').click();
  assert.match(await page.locator('#trade-confirmation').innerText(), /Cotización/);
  phase = 'sell-position';
  assert.match(await page.locator('#player-position-summary').innerText(), /2 tokens/);
  phase = 'sell-portfolio-sync';
  await portfolio.waitForFunction(id => document.querySelector(`#portfolio-position-${id} td`)?.textContent.trim() === '2', player);
  assert.equal(await portfolio.locator(`#portfolio-position-${player} td`).first().innerText(), '2');
  phase = 'ranking-navigation';
  await page.getByRole('link', {name: 'Ranking', exact: true}).click();
  phase = 'ranking-ready';
  await page.waitForSelector('.phx-connected #ranking-strategy');
  assert((await page.locator('#ranking-strategy').innerText()).includes(strategy));
  phase = 'ranking-entries';
  const visibleRanking = await page.locator('#ranking-entries li').evaluateAll(rows => rows.map(row => row.id.replace('ranking-player-', '')));
  assert.deepEqual(visibleRanking, JSON.parse(ranking));
  phase = 'transactions-navigation';
  await page.getByRole('link', {name: 'Operaciones', exact: true}).click();
  await page.waitForSelector('.phx-connected #transactions');
  phase = 'transactions-pagination';
  await page.locator('#transaction-size').selectOption('1');
  await page.waitForSelector('#transactions-next');
  assert.match(await page.locator('#transactions tbody').innerText(), /Compra|Venta/);
  assert.match(await page.locator('#transactions tbody').innerText(), new RegExp(name));
  assert.match(await page.locator('#transactions thead').innerText(), /Precio unitario.*Total.*Cotización.*Fecha/s);
  await page.getByRole('link', {name: 'Siguiente página', exact: true}).click();
  await page.waitForTimeout(100);
  assert.match(await page.locator('#transactions tbody').innerText(), /Compra|Venta/);
  phase = 'portfolio-analytics';
  await page.getByRole('link', {name: 'Portafolio', exact: true}).click();
  await page.waitForSelector('.phx-connected #portfolio-history-range');
  assert.equal(await page.locator('#portfolio-allocation-table').count(), 1);
  assert.equal(await page.locator('#portfolio-history-table').count(), 1);
  assert.match(await page.locator('#portfolio-allocation-table thead').innerText(), /Costo base.*Valor de mercado.*Peso/s);
  assert.match(await page.locator('#portfolio-history-table thead').innerText(), /Compras.*Ventas.*Realizada.*No realizada.*Jugadores sin cotización/s);
  phase = 'responsive-viewports';
  for (const viewport of [{width: 1280, height: 800}, {width: 768, height: 1024}, {width: 390, height: 844}]) {
    await page.setViewportSize(viewport);
    const dimensions = await page.evaluate(() => ({
      width: innerWidth,
      scrollWidth: document.documentElement.scrollWidth,
      overflowing: [...document.querySelectorAll('body *')]
        .filter(node => node.getBoundingClientRect().right > innerWidth + 1)
        .slice(0, 5)
        .map(node => {
          const parent = node.parentElement;
          return `${node.tagName.toLowerCase()}#${node.id}.${node.className} right=${node.getBoundingClientRect().right} parent=${parent?.tagName.toLowerCase()}#${parent?.id}.${parent?.className} parentRight=${parent?.getBoundingClientRect().right}`;
        })
    }));
    assert(dimensions.scrollWidth <= dimensions.width, `viewport overflow: ${JSON.stringify(dimensions)}`);
    assert.equal(await page.getByRole('navigation', {name: 'Espacio de trabajo'}).isVisible(), true);
  }
  await context.close();
  process.stdout.write('E2E_MARKET status=complete\n');
} catch {
  process.stderr.write(`E2E_MARKET status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
