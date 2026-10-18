import {chromium} from 'playwright-core';
import assert from 'node:assert/strict';
import {writeFile, access} from 'node:fs/promises';
import {join} from 'node:path';
const [base] = process.argv.slice(2);
const {E2E_EMAIL: email, E2E_PASSWORD: password, E2E_IPC: ipc} = process.env;
let browser;
let phase = 'prerequisites';
try {
  assert(base && email && password && ipc);
  browser = await chromium.launch({headless: true, args: ['--no-sandbox'], timeout: 10000});
  const context = await browser.newContext();
  context.setDefaultTimeout(10000);
  const page = await context.newPage();
  phase = 'protection';
  const denied = await context.request.get(`${base}/portfolio`, {maxRedirects: 0});
  assert.equal(denied.status(), 303);
  assert.match(denied.headers().location, /^\/sign-in/);
  assert(!(await denied.text()).includes('id="workspace"'));
  phase = 'form';
  const form = await page.goto(`${base}/sign-in`);
  assert.equal(form.status(), 200);
  assert.equal(form.headers()['cache-control'], 'no-store');
  await page.getByLabel('Email', {exact: true}).fill(email);
  await page.getByLabel('Password', {exact: true}).fill('invalid-password');
  phase = 'invalid';
  const badResponse = page.waitForResponse(r => r.request().method() === 'POST' && new URL(r.url()).pathname === '/sign-in');
  await page.getByRole('button', {name: 'Sign in', exact: true}).click();
  assert.equal((await badResponse).status(), 422);
  await page.getByRole('alert').waitFor();
  assert.match(await page.getByRole('alert').innerText(), /Unable to sign in/);
  assert.equal(await page.getByLabel('Password', {exact: true}).inputValue(), '');
  phase = 'login';
  const login = async () => {
    await page.goto(`${base}/sign-in`);
    await page.getByLabel('Email', {exact: true}).fill(email);
    await page.getByLabel('Password', {exact: true}).fill(password);
    const response = page.waitForResponse(r => r.request().method() === 'POST' && new URL(r.url()).pathname === '/sign-in');
    const portfolio = page.waitForResponse(r => r.request().isNavigationRequest() && new URL(r.url()).pathname === '/portfolio');
    await page.getByRole('button', {name: 'Sign in', exact: true}).click();
    const signed = await response;
    assert.equal(signed.status(), 303);
    assert.equal(signed.headers().location, '/portfolio');
    const shell = await portfolio;
    assert.equal(shell.status(), 200);
    assert.equal(shell.headers()['cache-control'], 'no-store');
    await page.waitForSelector('.phx-connected #workspace');
    assert((await page.locator('#workspace').innerText()).includes(email));
    assert.equal(await page.getByRole('heading', {name: 'Portfolio', exact: true}).count(), 1);
  };
  await login();
  phase = 'logout';
  const logout = page.waitForResponse(r => r.request().method() === 'POST' && new URL(r.url()).pathname === '/sign-out');
  await page.getByRole('button', {name: 'Sign out', exact: true}).click();
  assert.equal((await logout).status(), 303);
  await page.waitForURL(url => url.pathname === '/sign-in');
  assert.equal((await context.request.get(`${base}/portfolio`, {maxRedirects: 0})).status(), 303);
  assert.equal((await context.request.get(`${base}/sign-out`)).status(), 404);
  await login();
  phase = 'expiry';
  await writeFile(join(ipc, 'expire'), 'request', {mode: 0o600});
  const deadline = Date.now() + 10000;
  while (true) {
    try { await access(join(ipc, 'expired')); break; } catch {}
    assert(Date.now() < deadline);
    await new Promise(resolve => setTimeout(resolve, 20));
  }
  const expired = await context.request.get(`${base}/portfolio`, {maxRedirects: 0});
  assert.equal(expired.status(), 303);
  assert.match(expired.headers().location, /^\/sign-in/);
  await page.goto(`${base}/portfolio`);
  assert.equal(await page.locator('#workspace').count(), 0);
  await page.getByRole('heading', {name: 'Sign in', exact: true}).waitFor();
  await context.close();
  process.stdout.write('E2E_BROWSER status=complete\n');
} catch {
  process.stderr.write(`E2E_BROWSER status=failed category=${phase}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
