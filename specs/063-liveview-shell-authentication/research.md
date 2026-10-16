# Focused design findings

## Revocation and interactive lifetime
- Decision: Persist revocable browser authority in PostgreSQL and use PubSub plus authoritative periodic validation for connected convergence; see ADR-0026.
- Rationale: Existing signed cookie sessions in endpoint.ex cannot invalidate a replay after logout. API JWTs intentionally have an independent lifecycle and Accounts.login/1 masks backend failures as invalid credentials. Browser authentication therefore needs reusable credential verification with safe distinct unavailable results, not a JWT wrapper.
- Alternatives considered: cookie deletion cannot meet FR-004; JWT blacklisting changes API policy; Redis adds an unnecessary authoritative dependency. No external technology research is required.

## Lifecycle and browser evidence
- Decision: Use on_mount and attach_hook for params/events plus explicit info/async guards, subscribe/revalidate, expiry timer and <=1-second validation. Conceal on disconnect/pagehide and fully reload on recovery/history restoration.
- Rationale: Locally installed LiveView lifecycle.ex exposes these hooks; timers alone cannot enforce exclusive expiry. Existing tools/openapi/browser.mjs and OpenAPIBrowserTest already demonstrate a real Chromium listener under a shared SQL sandbox; reuse that pattern with isolated shell fixtures.
- Alternatives considered: server-rendered tests alone cannot demonstrate bfcache/tab clearing; native LiveSocket reconnect may replay buffered events. No separate browser dependency or new global testing profile is necessary (TASK-063 owns profile separation).

## Settled decisions

Reuse docs/ARCHITECTURE.md, ADR-0003 (email/password), ADR-0006 (API separation), ADR-0017 (CP2 feature ownership), existing lockfiles and profile audit. No unsettled material unknowns remain. Critic findings map to transactional revocation/failure tests, authenticated stale-form redirect/concurrent pre-login serialization, exact-clock versus convergence tests, and real-browser history/two-tab evidence respectively. No TASK-046 feedback file exists.
