import test from 'node:test';
import assert from 'node:assert/strict';

let factory;

async function harness(t, {failures = 0, workspace = true, notice = true, socket = true} = {}) {
  const calls = {disconnect: 0, requests: [], reload: 0, timers: []};
  const elements = [1, 2].map(() => ({hidden: false, children: ['private'],
    replaceChildren() { this.children = []; }}));
  const message = {hidden: true};
  const listeners = new Map();
  const state = {workspace};
  const window = {
    liveSocket: socket ? {disconnect() { calls.disconnect++; }} : undefined,
    addEventListener(name, handler) { listeners.set(name, handler); }
  };
  const document = {
    querySelectorAll(selector) { assert.equal(selector, '[data-private-workspace]'); return elements; },
    querySelector(selector) {
      if (selector === '#connection-notice') return notice ? message : null;
      assert.equal(selector, '#workspace');
      return state.workspace ? {} : null;
    }
  };
  const location = {pathname: '/portfolio', reload() { calls.reload++; }};
  window.fetch = async (...args) => {
    calls.requests.push(args);
    if (calls.requests.length <= failures) throw new Error('offline');
    return {};
  };
  window.setTimeout = (callback, delay) => { calls.timers.push({callback, delay}); };
  const environment = {window, document, location, fetch: window.fetch, setTimeout: window.setTimeout};
  let hook;
  if (factory) {
    hook = factory(environment);
  } else {
    // Exercise the browser export once, then inject isolated environments.
    // Never replace Node's global timers or fetch, which its test runner uses.
    const original = new Map(['window', 'document', 'location']
      .map(key => [key, Object.getOwnPropertyDescriptor(globalThis, key)]));
    Object.assign(globalThis, {window, document, location});
    try {
      const module = await import('../../assets/js/workspace_session.js');
      factory = module.createWorkspaceSession;
      hook = module.WorkspaceSession;
    } finally {
      for (const [key, descriptor] of original) {
        if (descriptor) Object.defineProperty(globalThis, key, descriptor);
        else delete globalThis[key];
      }
    }
  }
  return {hook, calls, elements, message, listeners, state};
}

const settle = () => new Promise(resolve => setImmediate(resolve));

test('disconnect removes private content before reloading authoritative state', async t => {
  const h = await harness(t);
  h.hook.reconnected();
  assert.equal(h.calls.disconnect, 0);
  h.hook.disconnected();
  for (const element of h.elements) {
    assert.deepEqual(element.children, []);
    assert.equal(element.hidden, true);
  }
  assert.equal(h.message.hidden, false);
  assert.equal(h.calls.disconnect, 1);
  await settle();
  assert.deepEqual(h.calls.requests, [['/portfolio', {
    cache: 'no-store', credentials: 'same-origin', redirect: 'manual'
  }]]);
  assert.equal(h.calls.reload, 1);
});

test('repeated disconnect and reconnect dispose sockets without replaying requests', async t => {
  const h = await harness(t);
  h.hook.disconnected();
  h.hook.disconnected();
  h.hook.reconnected();
  await settle();
  assert.equal(h.calls.disconnect, 3);
  assert.equal(h.calls.requests.length, 1);
  assert.equal(h.calls.reload, 1);
  assert.deepEqual(h.calls.timers, []);
});

test('failed connectivity retries only the safe read after 500 milliseconds', async t => {
  const h = await harness(t, {failures: 1});
  h.hook.disconnected();
  await settle();
  assert.equal(h.calls.reload, 0);
  assert.equal(h.calls.timers.length, 1);
  assert.equal(h.calls.timers[0].delay, 500);
  await h.calls.timers[0].callback();
  assert.equal(h.calls.requests.length, 2);
  assert.deepEqual(h.calls.requests[1], h.calls.requests[0]);
  assert.equal(h.calls.reload, 1);
});

test('history hides content and restores persisted pages through fresh authentication', async t => {
  const h = await harness(t);
  h.listeners.get('pagehide')();
  assert(h.elements.every(element => element.hidden && element.children.length === 0));
  assert.equal(h.calls.disconnect, 0);
  h.listeners.get('pageshow')({persisted: false});
  assert.equal(h.calls.requests.length, 0);
  h.listeners.get('pageshow')({persisted: true});
  await settle();
  assert.equal(h.calls.disconnect, 1);
  assert.equal(h.calls.reload, 1);
});

test('online and offline events act only on a workspace', async t => {
  const h = await harness(t, {workspace: false});
  h.listeners.get('online')();
  h.listeners.get('offline')();
  assert.equal(h.calls.requests.length, 0);
  h.state.workspace = true;
  h.listeners.get('offline')();
  h.listeners.get('online')();
  await settle();
  assert.equal(h.calls.disconnect, 2);
  assert.equal(h.calls.requests.length, 1);
  assert.equal(h.calls.reload, 1);
});

test('recovery tolerates pages without an active socket or connection notice', async t => {
  const h = await harness(t, {socket: false, notice: false});
  h.hook.disconnected();
  await settle();
  assert.equal(h.calls.disconnect, 0);
  assert(h.elements.every(element => element.hidden && element.children.length === 0));
  assert.equal(h.calls.reload, 1);
});
