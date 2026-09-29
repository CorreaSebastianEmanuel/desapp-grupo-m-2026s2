import { chromium } from 'playwright-core';
import { existsSync } from 'node:fs';
import assertDeep from 'node:assert/strict';

const base = process.argv[2];
const jwt = process.env.OPENAPI_TEST_JWT;
const key = process.env.OPENAPI_TEST_KEY;
const playerId = process.env.OPENAPI_TEST_PLAYER_ID;
const expectedList = process.env.OPENAPI_EXPECTED_LIST;
const expectedDetail = process.env.OPENAPI_EXPECTED_DETAIL;
if (!base || !jwt || !key || !playerId || !expectedList || !expectedDetail) throw new Error('Missing isolated browser-test input');

let browser;
const assert = (condition, message) => { if (!condition) throw new Error(message); };

try {
  const launchOptions = { headless: true, args: ['--no-sandbox'] };
  if (process.env.CHROMIUM_PATH) launchOptions.executablePath = process.env.CHROMIUM_PATH;
  else if (existsSync('/usr/bin/chromium')) launchOptions.executablePath = '/usr/bin/chromium';
  browser = await chromium.launch(launchOptions);
  const context = await browser.newContext();
  const page = await context.newPage();
  const requests = [];
  page.on('request', request => {
    const url = new URL(request.url());
    if (url.origin !== base) requests.push({ foreign: true });
    if (url.pathname === '/api/players' || /^\/api\/players\/[^/]+$/.test(url.pathname)) {
      const names = Object.keys(request.headers()).map(name => name.toLowerCase());
      requests.push({ jwt: names.includes('authorization'), key: names.includes('x-api-key'), safeUrl: !request.url().includes(jwt) && !request.url().includes(key), queryKeys: [...url.searchParams.keys()] });
    }
  });
  const started = Date.now();
  await page.goto(`${base}/docs`);
  await page.waitForFunction(() => document.documentElement.dataset.docsReady === 'true');
  assert(await page.locator('#docs-error').isHidden(), 'Documentation load error');
  assert(await page.locator('.opblock').count() === 2, 'Catalog operation discovery failed');
  const list = page.locator('.opblock').nth(0);
  const detail = page.locator('.opblock').nth(1);
  assert((await list.innerText()).includes('/api/players'), 'List operation missing');
  assert((await detail.innerText()).includes('/api/players/{player_id}'), 'Detail operation missing');
  await list.locator('.opblock-summary').click();
  await detail.locator('.opblock-summary').click();
  await page.waitForFunction(() => document.querySelector('.opblock')?.textContent.includes('page_size'));
  for (const name of ['page_size','cursor','league_id','team_id','position_id']) {
    assert((await list.innerText()).includes(name), `Missing parameter ${name}`);
  }
  await page.waitForFunction(() => [...document.querySelectorAll('.opblock')].every(block => block.querySelectorAll('.response-col_status').length >= 3));
  const listStatuses = (await list.locator('.response-col_status').allTextContents()).map(value => value.trim());
  const detailStatuses = (await detail.locator('.response-col_status').allTextContents()).map(value => value.trim());
  assert(['200','400','401'].every(value => listStatuses.includes(value)), 'List response status discovery failed');
  assert(['200','401','404'].every(value => detailStatuses.includes(value)), 'Detail response status discovery failed');
  assert(await list.getByText('Example Value').count() > 0, 'Response example discovery failed');
  assert(await page.locator('#credential-mode option').count() === 2, 'Credential choice discovery failed');
  const discoveryMs = Date.now() - started;
  assert(discoveryMs < 180000, 'Discovery exceeded three minutes');

  async function execute(block, expectedStatus, expectedHeader) {
    await block.locator('.try-out__btn').click();
    const responsePromise = page.waitForResponse(response => {
      const path = new URL(response.url()).pathname;
      return path === '/api/players' || /^\/api\/players\/[^/]+$/.test(path);
    });
    await block.locator('.execute').click();
    const response = await responsePromise;
    assert(response.status() === expectedStatus, `Unexpected catalog status ${response.status()}`);
    const last = requests.filter(item => !item.foreign).at(-1);
    assert(last?.safeUrl, 'Credential appeared in request URL');
    assert(last.jwt === (expectedHeader === 'jwt') && last.key === (expectedHeader === 'key'), 'Wrong outbound credential headers');
    const body = await response.json();
    const visible = await page.locator('body').innerText();
    assert(!visible.includes(jwt) && !visible.includes(key), 'Credential appeared in rendered request or response panel');
    await block.locator('.btn.cancel').click();
    return body;
  }

  await page.locator('#credential-value').fill(jwt);
  const listBody = await execute(list, 200, 'jwt');
  assert(listBody.data.length === 1 && listBody.data[0].id === playerId, `JWT list body mismatch (count ${listBody.data.length}, match ${listBody.data.some(player => player.id === playerId)}, query keys ${requests.at(-1)?.queryKeys.join(',')})`);
  assertDeep.deepEqual(listBody, JSON.parse(expectedList), 'JWT list differs from live endpoint comparison');
  await page.locator('#credential-mode').selectOption('api_key');
  assert(await page.locator('#credential-value').inputValue() === '', 'Mode switch retained credential');
  await page.locator('#credential-value').fill(key);
  await detail.locator('.try-out__btn').click();
  await detail.locator('input[placeholder="player_id"], input[aria-label="player_id"], input[name="player_id"]').first().fill(playerId);
  await detail.locator('.btn.cancel').click();
  const detailBody = await execute(detail, 200, 'key');
  assert(detailBody.data.id === playerId, 'API-key detail body mismatch');
  assertDeep.deepEqual(detailBody, JSON.parse(expectedDetail), 'API-key detail differs from live endpoint comparison');
  await page.locator('#credential-mode').selectOption('jwt');
  assert(await page.locator('#credential-value').inputValue() === '', 'Second mode switch retained credential');
  await page.locator('#credential-value').fill(jwt);
  await execute(list, 200, 'jwt');
  await page.locator('#credential-value').fill('');
  const denied = await execute(list, 401, 'none');
  assert(denied.error?.code === 'unauthenticated', 'No-credential error mismatch');

  const exposed = await page.evaluate(([jwt, key]) => {
    const storage = Object.values(localStorage).join(' ') + Object.values(sessionStorage).join(' ');
    const text = document.body.innerText;
    const configuration = [...document.scripts].map(script => script.textContent).join(' ');
    return [storage, text, location.href, configuration].some(item => item.includes(jwt) || item.includes(key));
  }, [jwt, key]);
  assert(!exposed, 'Credential visible or persisted in browser');
  assert(!requests.some(item => item.foreign), 'Off-origin browser request');

  await page.route('**/openapi.json', route => route.abort());
  await page.reload();
  assert(await page.locator('#docs-error').isVisible(), 'Broken contract load was not visible');
  await page.unroute('**/openapi.json');
  await page.route('**/api-docs/swagger-ui-bundle.js', route => route.abort());
  await page.reload();
  assert(await page.locator('#docs-error').isVisible(), 'Broken UI asset load was not visible');
  process.stdout.write(`Browser discovery completed in ${discoveryMs} ms; JWT, API key, 401, and load failures passed; credential headers reported by presence only.\n`);
} catch (error) {
  const safeMessage = String(error.message).replaceAll(jwt, '[redacted]').replaceAll(key, '[redacted]');
  process.stderr.write(`Browser acceptance failed: ${safeMessage}\n`);
  process.exitCode = 1;
} finally {
  await browser?.close();
}
