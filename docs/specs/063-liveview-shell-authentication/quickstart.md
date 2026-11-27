# Validation run guide

This is a post-implementation guide; planned harness files are created by tasks.md. No behavior is claimed executed during architecture.

## Prerequisites

Use pinned Elixir/OTP, Node 24, PostgreSQL and Redis (existing local setup). Run `scripts/local_services.sh start` if needed, then `scripts/local_services.sh ready`. Install locked Mix dependencies and `npm ci --prefix tools/openapi`; install Chromium using `tools/openapi/node_modules/.bin/playwright-core install --with-deps --only-shell chromium`. Run `mix assets.build`. Use only the guarded football_market_test database for tests; never production/development fixtures. Tests create two accounts in isolated SQL sandbox state and run a real local ephemeral HTTP listener. They must fail if services, assets, browser or listener are unavailable, never skip.

## Implementation owner acceptance

After integrating TASK-019, prepare its locked Oban dependency and test migrations
before starting profile discovery: `mix deps.get` and `MIX_ENV=test mix test.prepare`.
The manifest preflight includes the guarded test preparation so a fresh test
database is ready before the audit starts the application.

Sandboxed agents need permission to bind/connect local TCP sockets (Mix locks,
PostgreSQL, Redis and the HTTP/browser harness). Establish those permissions
before running checks. If a command reports `:eperm`, request appropriate
escalation rather than repeating the command with the same denied permissions.
Keep workspace filesystem restrictions and automatic approval review enabled.

After finishing all edits, execute the following once each through the receipt helper:

```bash
python3 scripts/agentflow_check.py preflight --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py openapi --reuse
python3 scripts/agentflow_check.py unit --reuse
python3 scripts/agentflow_check.py integration --reuse
python3 scripts/agentflow_check.py foundation --reuse
python3 scripts/agentflow_check.py feature --reuse
python3 scripts/agentflow_check.py javascript --reuse
python3 scripts/agentflow_check.py ci --reuse
```

Integration is marked runtime and always runs. The shell runtime test checks readiness in the real listener, statuses, headers and bodies per contracts/browser.md, then exercises real Chromium. Profiles are not followed by a duplicate `mix test` or historical CP1 coverage report. Preserve existing CI/coverage implementation. After two unchanged failures stop and diagnose using helper evidence; do not bypass counters. QA repeats these independently with `--stage qa` and no `--reuse`.

PR #39 correction: the manifest now also runs the existing exact CI runner because
it exposed a missing-local-pointer failure that tagged-profile checks missed.
This is the specific exception to avoiding duplicate full-suite execution above;
no second CI job is introduced. `javascript` executes isolated lifecycle tests
and emits measured LCOV under ignored `cover/workspace`, with 100% module line,
branch and function thresholds. The Sonar workflow imports that report before
evaluating its existing Quality Gate; do not change or bypass its thresholds.

## Expected scenarios

- US1: normalize existing email only; correct exact password enters own workspace, malformed/unknown/wrong credentials all fail generically with cleared password; forged CSRF and tampered handle fail. Valid session reload/sign-in retains account/deadline. API credentials alone do not sign in.
- US3: frozen clock at deadline minus one microsecond authorizes, deadline and later deny; scheduler display convergence measured separately within two seconds. Two connected tabs terminate after committed logout/expiry, replay fails, independent browser/API credentials remain valid. Inject invalidation failure: safe retry with no success claim, retry later commits revocation. Stale sign-in form cannot switch accounts; parallel pre-login submissions yield at most one authenticated authority. Offline reconnection/history never restores ended content.
- US2: direct and selected destinations display correct heading, identity, one active item and honest placeholders. Only exact safe returns survive sign-in; all malformed/external variants land on Portfolio.
- US4: injected auth/read outage, disconnected transport, denied fixture and unknown route offer safe accessible recovery. Reconnect reads changed persisted account state; no queued action replays. Inspect text, addresses, decoded mount payloads, storage, logs/telemetry for secret sentinels. Keyboard-only 1280x800 journey checks labels, field associations, announcements, visible focus and document width.

See data-model.md for lifecycle, contracts/browser.md for HTTP assertions, and verification.json for the executable requirement map. Fixture controls and clock/failure injection exist only in test support, never production HTTP endpoints.

## Concrete development harness

`workspace_browser.mjs` has `http` and `browser` modes launched by the two
`workspace_*_test.exs` modules. `BrowserSessionCase` provides shared SQL sandbox,
a controllable UTC clock, ephemeral listener and a test-only wrapper with a random
control header. The production router has no fixture endpoints. Test endpoint
origins allow localhost/127.0.0.1 only; deployment origin validation remains enabled.
`BrowserCookie` caps emitted cookies to the server deadline; `BrowserOrigin`
adds explicit Origin rejection alongside CSRF. Two migrations create then align the
session schema with data-model.md without rewriting already-applied migrations.

The targeted `foundation` and `feature` checks support development regressions;
the feature check also exercises the three legacy scope suites adapted under current human feedback. They do not replace either complete tagged profile. Final source/design changes
invalidate earlier receipts. Full check output is referenced by each receipt in
`handoffs/check-*.json`; the sole prose development report is `handoffs/develop.md`.
