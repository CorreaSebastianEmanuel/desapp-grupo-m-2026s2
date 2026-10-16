import {chromium, request} from '/home/sebo/desapp-grupo-m-2026s2/tools/openapi/node_modules/playwright-core/index.mjs';
import assert from 'node:assert/strict';
const base=process.argv[2], email=process.env.WORKSPACE_EMAIL, password=process.env.WORKSPACE_PASSWORD;
const change=async()=>{const r=await fetch(`${base}/__test/control?advance=900000000`,{headers:{'x-test-control':process.env.WORKSPACE_CONTROL}});assert.equal(r.status,200)};
let browser;
try {
 const http=await request.newContext({baseURL:base});
 const direct=await http.get('/sign-in');assert.equal(direct.status(),200);assert(!(await direct.text()).includes('Your session ended'));
 for(const path of ['/portfolio','/conditional-orders']) {
  for(const bad of [false,true]) {
   const fresh=await request.newContext({baseURL:base});
   const r=await fresh.get(path,{maxRedirects:0,headers:bad?{cookie:'_football_market_key=tampered'}:{}});
   assert.equal(r.status(),303);assert.equal(r.headers()['cache-control'],'no-store');
   assert.equal(r.headers().location,`/sign-in?return_to=${encodeURIComponent(path)}&notice=ended`);
   assert(!(await r.text()).includes(email));await fresh.dispose();
  }
 }
 await http.dispose();
 browser=await chromium.launch({headless:true,args:['--no-sandbox']});
 const ctx=await browser.newContext();const page=await ctx.newPage();
 const login=async()=>{await page.getByLabel('Email',{exact:true}).fill(email);await page.getByLabel('Password',{exact:true}).fill(password);await page.getByRole('button',{name:'Sign in',exact:true}).click();await page.waitForSelector('.phx-connected #workspace')};
 for(const path of ['/portfolio','/conditional-orders']) {
  await page.goto(`${base}/sign-in`);await login();
  await ctx.setOffline(true);await page.waitForFunction(e=>!document.body.innerText.includes(e),email);
  await change();await ctx.clearCookies({name:'_football_market_key'});assert(!(await ctx.cookies()).some(c=>c.name==='_football_market_key'));
  await ctx.setOffline(false);await page.goto(`${base}${path}`);await page.waitForURL(/\/sign-in\?.*notice=ended/);
  assert((await page.getByRole('alert').innerText()).includes('Your session ended'));assert(!(await page.locator('body').innerText()).includes(email));
  await login();assert.equal(new URL(page.url()).pathname,path);await page.getByRole('button',{name:'Sign out',exact:true}).click();
 }
 await ctx.close();process.stdout.write('B1_QA both-destinations missing/tampered HTTP and removed-cookie Chromium recovery PASS\n');
} catch {process.stderr.write('B1_QA FAIL\n');process.exitCode=1} finally {await browser?.close()}
