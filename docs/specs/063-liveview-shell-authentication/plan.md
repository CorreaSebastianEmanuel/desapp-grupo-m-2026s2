# Implementation Plan: Authenticated Application Shell

**Branch**: `046-liveview-application-shell-and-authentication` | **Date**: 2026-10-15 | **Spec**: [spec.md](spec.md)
**Binding**: `.specify/feature.json` selects `specs/063-liveview-shell-authentication`; setup-plan reports the directory-derived alias `063-liveview-shell-authentication`, not the actual delivery branch. TASK-046 remains the only backlog task.

## Summary

Deliver existing-account browser sign-in and two protected LiveView placeholders, with authoritative revocation, fixed expiry, shared accessible feedback and real-browser isolation evidence. Reuse Accounts credential rules without issuing a JWT as a side effect. Resolve all four product-challenge findings via ADR-0026 and the contracts below. No feature-specific human feedback file exists; the product decision and current context/verification policies govern.

## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6, Node 24 for existing browser tooling.
**Dependencies**: Existing Phoenix 1.8.13, LiveView ~1.2, Ecto/Postgrex, Argon2, Phoenix PubSub, Tailwind; reuse locked playwright-core in tools/openapi. No new service or authentication framework.
**Storage**: PostgreSQL browser_sessions table; existing users/credentials. Redis remains unrelated disposable infrastructure.
**Testing**: ExUnit unit/integration module tags, ConnTest, LiveViewTest, existing Chromium/Playwright harness extended for this shell. Test-only injected clock and persistence failures; real HTTP listener and real browser.
**Platform/Type**: Local Linux modular web monolith; encrypted deployment transport, local HTTP permitted.
**Performance**: Exact exclusive 900-second authorization boundary, connected content removal within two seconds. Timer delivery is not authorization truth.
**Scope**: Sign-in/out, Portfolio and Conditional orders placeholders, shared error/accessibility behaviors; no financial operations, registration, recovery, remember-me, roles or global sign-out.

## Constitution Check

Pre-design: PASS. Spec defines behavior; product decision resolves challenge without an unresolved product choice. Existing monolith and PostgreSQL suffice. Every changed behavior gets tests before implementation; independent QA and review remain downstream.
Post-design: PASS. Web calls Accounts; only Accounts touches session persistence and credentials. Browser/API authorities remain independent. No money, supply, quote, trade, audit, worker or provider logic changes: all seven PRODUCT invariants remain intact. CP2 shell and its browser evidence are delivered; charts, orders, complete responsive UI and profile separation stay with their named owners in spec.md/CP2_ARCHITECTURE.md.

## Project Structure

Feature artifacts: plan.md, research.md, data-model.md, contracts/browser.md, quickstart.md, verification.json, tasks.md and concise handoffs/architecture.md and handoffs/tasks.md.

Source boundaries:
- `lib/football_market/accounts.ex`: factor credential verification into a reusable internal result with distinct invalid/unavailable outcomes; preserve existing login/1 JWT return and generic API errors.
- `lib/football_market/accounts/browser_sessions.ex`, `browser_session.ex`: Accounts-owned lifecycle and schema; trusted actor projection, fixed clock, validation/revocation and safe failure results.
- `priv/repo/migrations/*_create_browser_sessions.exs`: session table and constraints.
- `lib/football_market_web/plugs/browser_auth.ex`, `live/browser_auth.ex`: HTTP guard, return allowlist, connected mount and guarded lifecycle hooks.
- `lib/football_market_web/controllers/session_controller.ex`, `session_html.ex`, `session_html/new.html.heex`: ordinary CSRF-protected HTTP forms, safe failures.
- `lib/football_market_web/live/workspace_live.ex`, `components/workspace_components.ex`: common shell, destinations, feedback and honest placeholders.
- `lib/football_market_web/router.ex`, `endpoint.ex`, `config/{config,prod,test}.exs`: separate browser routing, cookie/websocket settings, log filtering and test clock config.
- `assets/js/app.js`, `assets/js/workspace_session.js`, `assets/css/app.css`: disconnect concealment, no-replay reconnect and history lifecycle; no authority in JS.
- Tests and runtime harness paths are specified in tasks.md; reuse `tools/openapi/node_modules/playwright-core` rather than installing a second toolchain.

## Session and Identity Design

See [ADR-0026](../../docs/adr/0026-revocable-browser-session-boundary.md) and [data model](data-model.md). Generate 32 random bytes for an opaque handle; only its SHA-256 digest is persisted. Carry the handle exclusively in encrypted/signed HttpOnly SameSite=Lax cookie transport, Secure in deployment. A nonsecret session UUID is a notification reference, never browser authority. Retain pre-login CSRF protection and rotate Plug session, CSRF token and handle on successful login; retire pre-login authority transactionally. Serialize concurrent submissions against the anonymous row: one transition wins; a stale retired handle never receives authenticated authority. An already-valid authenticated submission ignores supplied credentials and redirects to its current workspace, avoiding account replacement.

Factor the existing normalized-email/Argon2 verifier into Accounts; malformed/unknown/wrong credentials share generic errors and dummy verification where appropriate. Browser callers distinguish unavailable persistence from invalid credentials without API behavior changes. Verify passwords exactly; never trim them. Missing users invalidate sessions. Caller account IDs are never accepted as actor input.

Validate PostgreSQL status and now < expires_at on protected HTTP access, connected mount/reconnect, handle_params, handle_event, and any private async/info result before use. Authorize future domain actions at the context boundary too; lifecycle hooks alone are not transactional authorization for later trading features. Use an injectable UTC microsecond clock with production wall time, no skew/sliding renewal. Server timers remove state at expiry; periodic <=1-second authoritative validation also detects revocation when PubSub delivery fails and fails closed on storage outages. Subscribe then revalidate to close the mount/revoke race. Timers recheck the authoritative deadline; they never extend it.

Do not serialize the handle into LiveView session attributes, DOM, JS, telemetry or socket assigns/Inspect. A router live_session callback passes only nonsecret reference/display projection after HTTP validation for disconnected rendering. Connected mount obtains authority from server-side connect_info session cookie and revalidates it; nonsecret mount parameters alone cannot authenticate a connection. Keep only trusted session reference/actor after validation; internal by-reference checks are inaccessible to browser input. Test decoded LiveView mount payloads as well as HTML/storage/logs.

## Termination, Recovery and Browser State

Revocation updates the row before acknowledging success or broadcasting on a session-UUID topic. Idempotent sign-out only affects that row; do not revoke API keys/JWTs or independent browser sessions. Subscribers clear actor/private assigns and use a full redirect to sign-in. Periodic checks cover missed notifications. Revocation failure returns a safe 503 retry view, conceals local content and retains HttpOnly authority solely to retry: do not claim successful sign-out or clear the only revocation handle. Other connected tabs fail closed if validation is unavailable; if invalidation alone fails while reads work, the session remains active until retry/expiry, explicitly tested.

Protected responses use Cache-Control: no-store. pagehide conceals and removes private DOM, and pageshow (including bfcache) keeps it concealed until a full server reload validates the cookie. Disconnect immediately conceals private content, disables dependent controls and marks the workspace for full reload after connectivity returns; tear down the old LiveSocket before reload so queued events cannot replay. Cookie/account changes therefore cannot revive old mounted identity. No browser caches, localStorage or sessionStorage hold private content/authority. Placeholders contain no mutations; use test-only lifecycle probes for guarded actions, never production probe routes.

All private mounts refresh from Accounts/current persisted state. Shared safe not-found/access-denied components are tested with test-only owned-resource probes (there is no new resource API). Unknown routes use safe 404 with sign-in or Portfolio link according to validated identity. Invalid credentials are generic; unavailable authentication yields 503 and retry; expired access redirects with a nonsecret allowlisted ended notice. All untrusted email/text uses HEEx escaping. Accessible labels, field associations, live regions, focus and keyboard controls are tested at 1280x800.

Expiry recovery also covers transport already removed by the browser. Since a
missing cookie cannot distinguish an initial visit from an expired closed visit,
protected-route authentication denial consistently includes the existing ended
notice for missing, invalid and expired authority. Direct public sign-in stays
notice-free. No extra identifying marker is retained, cookie retention is not
extended, and the exclusive server deadline remains authoritative. Regressions
cover both protected destinations without transport and actual Chromium cookie
removal while disconnected, followed by visible recovery and successful sign-in.

## Verification and Delivery Boundary

`verification.json` maps all 15 FR and six SC IDs (spec has no AC IDs). Run preflight then formatting/compilation, locked OpenAPI checks, one unit profile and one integration profile. New unit suites carry :unit; DB/HTTP/LiveView/browser suites carry :integration, so each suite runs once in final verification. Runtime is the integration profile containing real-listener HTTP assertions and actual Chromium journeys, with its own readiness check in the harness. Do not add `coverage_report.sh` or repeat the full suite separately. Preserve coverage infrastructure/CI. Existing API/public-page policy regressions run through those profiles. Run feature suites during red/green development as needed, then freeze edits before final manifest checks.

Implementation owner executes every manifest check through agentflow_check.py before QA. QA reruns independently, with no developer receipt reuse. Only QA/review tasks are tagged gates. Use workflow_artifact_probe.py plan/tasks --readiness for structural planning gates; those gates do not prove implementation behavior. No implementation, test execution claims, commit or publication in this stage.

## Complexity Tracking

## PR #39 CI correction

CI exposed an optional local feature-pointer read in the Market scope test. Read
missing, malformed or unexpected local metadata fail-closed as nil; exercise that
reader with independent temporary fixtures. Never commit or synthesize an active
feature pointer just to satisfy CI. Preserve both features' exact scope controls.

SonarCloud requires measured coverage for the new browser JavaScript. Isolate
workspace lifecycle state behind a dependency-injected factory while retaining
the browser export and real Chromium acceptance. Test concealment, socket
disposal, safe-read retry, duplicate-event suppression, history and connectivity
events with Node's built-in runner. Generate genuine native LCOV under ignored
cover/workspace, require 100% module lines/branches/functions, and import it in
the existing immutable-action Sonar workflow. Handle the intentionally detached,
internally caught retry promise explicitly with void. Do not reduce Sonar gates
or exclude production code from its analysis. Keep scanner credentials confined
to scanner/gate steps, outside JavaScript execution.

Additional owned paths: tools/openapi/workspace_session.test.mjs,
tools/openapi/workspace_coverage.mjs, sonar-project.properties,
.github/workflows/sonarcloud.yml and test/ci/sonarcloud_contract_test.exs. The exact
feature-specific allowance grows from 34 to 36 only for the latter two filtered
paths. Quality baseline workflow and its byte oracle remain intact. Add the
JavaScript check and exact CI runner to the manifest: the latter deliberately
repeats the profiles here because an actual CI-only failure requires independent
verification of that entry point, not just the tagged profiles.

No constitutional violation. ADR-0026 records the necessary durable browser-session addition and retirement of cookie-only authority; existing infrastructure is reused.
