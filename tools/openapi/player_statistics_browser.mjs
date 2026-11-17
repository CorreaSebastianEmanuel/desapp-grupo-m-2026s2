import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {writeFile, access} from 'node:fs/promises';
import {join} from 'node:path';

const [base, playerId] = process.argv.slice(2);
const {STATISTICS_EMAIL: email, STATISTICS_PASSWORD: password, STATISTICS_IPC: ipc} = process.env;
let browser;
let phase = 'launch';
try {
  browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
  const page = await browser.newPage();
  page.setDefaultTimeout(15000);
  phase = 'login';
  await page.goto(`${base}/sign-in`);
  await page.getByLabel('Correo electrónico', {exact: true}).fill(email);
  await page.getByLabel('Contraseña', {exact: true}).fill(password);
  await Promise.all([
    page.waitForResponse(r => r.request().method() === 'POST' && new URL(r.url()).pathname === '/sign-in'),
    page.getByRole('button', {name: 'Iniciar sesión', exact: true}).click()
  ]);
  phase = 'first-open';
  await page.goto(`${base}/players?player_id=${playerId}`);
  await page.waitForSelector('.phx-connected #workspace');
  if (ipc) {
    assert.match(await page.locator('#player-statistics-preparing').innerText(), /Preparando estadísticas verificadas/);
    phase = 'deadline';
    const opened = Date.now();
    await page.getByText('La preparación sigue en segundo plano.', {exact: false}).waitFor({timeout: 22000});
    assert(Date.now() - opened < 21500);
    await writeFile(join(ipc, 'deadline-visible'), 'ready', {mode: 0o600});
  }
  phase = 'accepted-values';
  await page.locator('#player-statistics').waitFor({timeout: 30000});
  const text = await page.locator('#player-statistics').innerText();
  assert.match(text, /Partidos registrados\s+[1-9]/);
  assert.match(text, /Minutos/);
  if (process.env.STATISTICS_EXPECTED) {
    const expected = JSON.parse(process.env.STATISTICS_EXPECTED);
    assert.equal(await page.locator('#player-statistics > div:first-child dd').innerText(), String(expected.recorded_match_count));
    for (const metric of ['minutes_played', 'goals', 'assists']) {
      assert.equal(await page.locator(`#player-statistics [data-metric="${metric}"] dd`).innerText(), String(expected[metric]));
    }
  }
  if (ipc) {
    await page.reload();
    await page.locator('#player-statistics').waitFor();
    assert.equal(await page.locator('#player-statistics-preparing').count(), 0);
    await writeFile(join(ipc, 'stored-visible'), 'ready', {mode: 0o600});
    phase = 'provider-failure';
    const deadline = Date.now() + 15000;
    while (true) {
      try { await access(join(ipc, 'failure-ready')); break; } catch {
        assert(Date.now() < deadline);
        await new Promise(resolve => setTimeout(resolve, 50));
      }
    }
    await page.reload();
    await page.locator('#player-scraping-status').filter({hasText: 'evidencia inconsistente'}).waitFor();
    assert.equal(await page.locator('#player-statistics').innerText(), text);
  }
  phase = 'navigation';
  await page.locator('nav a[href="/portfolio"]').click();
  await page.locator('#portfolio').waitFor();
  process.stdout.write('PLAYER_STATISTICS_BROWSER status=complete\n');
} catch {
  process.stderr.write(`PLAYER_STATISTICS_BROWSER status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
