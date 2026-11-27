import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {join} from 'node:path';
const [base] = process.argv.slice(2);
let browser;
let phase = 'launch';
const screenshot = async (page, name) => {
  if (!process.env.ADMIN_SCREENSHOT_DIR) return;
  await mkdir(process.env.ADMIN_SCREENSHOT_DIR, {recursive: true});
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.screenshot({path: join(process.env.ADMIN_SCREENSHOT_DIR, name + '.png'), fullPage: true});
};
try {
  browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
  const page = await browser.newPage({viewport: {width: 1440, height: 1000}});
  phase = 'authentication';
  await page.goto(base + '/sign-in');
  await page.getByLabel('Correo electrónico', {exact: true}).fill(process.env.ADMIN_EMAIL);
  await page.getByLabel('Contraseña', {exact: true}).fill('correct-password-123');
  await page.getByRole('button', {name: 'Iniciar sesión', exact: true}).click();
  await page.waitForSelector('.phx-connected #workspace');
  await page.getByRole('link', {name: 'Administración', exact: true}).click();
  await page.waitForSelector('.phx-connected #administration');
  phase = 'automatic-fixed-formulas';
  assert.equal(await page.locator('#no-active-configuration').count(), 1);
  assert.equal(await page.locator('#administration article').count(), 2);
  assert.equal(await page.locator('#administration input, #administration select, #administration textarea').count(), 0);
  assert.equal(await page.locator('#provision-presets, #configuration-form, button[phx-click="edit"]').count(), 0);
  const balanced = await page.locator('#strategy-balanced article').getAttribute('id');
  const positional = await page.locator('#strategy-position_aware article').getAttribute('id');
  assert.equal(await page.locator('.active-configuration').count(), 0);
  phase = 'workspace-navigation';
  assert.equal(await page.locator('.workspace-sidebar a[href="/administration"]').getAttribute('aria-current'), 'page');
  const sidebar = await page.locator('.workspace-sidebar').boundingBox();
  const main = await page.locator('#workspace-main').boundingBox();
  assert.equal(sidebar.x, 0);
  assert(sidebar.width >= 200 && main.x >= sidebar.width);
  assert.match(await page.locator('.workspace-account').innerText(), new RegExp(process.env.ADMIN_EMAIL.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  assert.equal(await page.getByRole('button', {name: 'Cerrar sesión', exact: true}).count(), 1);
  await screenshot(page, 'administration-desktop');
  await page.getByRole('link', {name: 'Jugadores', exact: true}).click();
  await page.waitForSelector('.phx-connected #player-catalog');
  await page.getByRole('link', {name: 'Administración', exact: true}).click();
  await page.waitForSelector('.phx-connected #administration');
  assert.equal(await page.locator('#administration article').count(), 2);
  assert.equal(await page.locator('#strategy-balanced article').getAttribute('id'), balanced);
  phase = 'fixed-activation';
  await page.locator(`#${balanced} button[phx-click="activate"]`).click();
  await page.waitForSelector(`#${balanced} .active-configuration`);
  await page.locator(`#${positional} button[phx-click="activate"]`).click();
  await page.waitForSelector(`#${positional} .active-configuration`);
  await page.reload();
  await page.waitForSelector(`#${positional} .active-configuration`);
  assert.equal(await page.locator('.active-configuration').count(), 1);
  phase = 'responsive-rules';
  for (const width of [900, 390]) {
    await page.setViewportSize({width, height: 844});
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
    await page.locator(`#${positional} .strategy-rules > summary`).click();
    assert.equal(await page.locator(`#${positional} .strategy-rules table`).isVisible(), true);
    assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
    if (width === 390) await screenshot(page, 'administration-mobile');
    await page.locator(`#${positional} .strategy-rules > summary`).click();
  }
  process.stdout.write('ADMINISTRATION_BROWSER status=complete\n');
} catch {
  process.stderr.write(`ADMINISTRATION_BROWSER status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
