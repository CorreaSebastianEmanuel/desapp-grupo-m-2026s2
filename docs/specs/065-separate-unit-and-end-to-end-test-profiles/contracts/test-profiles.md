# Profile and evidence contract

## Developer commands

- `mix test.unit` / `sh scripts/test_profile.sh unit`: existing unit ExUnit plus assigned non-ExUnit unit cases, complete isolated result.
- `mix test.integration` / `sh scripts/test_profile.sh integration`: existing integration ExUnit plus assigned non-ExUnit integration cases, complete isolated result.
- `mix test.e2e` / `sh scripts/test_profile.sh e2e`: new complete real browser and asynchronous catalog journeys only.
- `python3 scripts/test_inventory.py check`: read-only discovery/assignment completeness check for all runners; no execution or inventory rewrite.
- `python3 scripts/test_inventory.py update`: explicit reviewed refresh preserving existing assignments; require an explicit profile for new cases. Unknown ownership must fail, never default silently.
- `scripts/ci_unit_tests.sh`: compatibility CI orchestrator for complete unit and integration profiles; preserves full-discovery marker and safe summaries. E2E is a separate required job.
- `mix test.cp1_coverage`: retained existing coverage report, threshold zero and original denominator/provenance; not an additional local CP2 gate.

Profile invocation selects exactly one scope, reports expected/discovered/executed/passed case totals and fails nonzero for invalid usage, audit mismatch, duplicates, skips, missing cases, no-start/no-terminal events, child failure/signal or missing prerequisites. Preserve CP1_PROFILE_OUTCOME/RECEIPT metadata consumed by existing tooling for unit/integration, adding versioned fields without weakening consumers. Missing browser/Node/database/Redis/worker/assets fails with a fixed actionable category. Signal handling returns failure (INT 130, TERM 143); child process-group cleanup must not emit complete. Profile receipts are bound to invocation nonce and inventory digest, never reused as another run's success.

Native runner adapters must expose expected discovery and actual per-case events; unknown/custom test entry points require explicit classification. Pure tests are unit; service/public-boundary tests integration; new full journeys E2E. Existing ExUnit unit/integration ownership stays intact. Named profile execution covers all assigned components. CI consumes component receipts to preserve existing workflow/OpenAPI quality categories without rerunning those components. No retained raw output, credentials or browser artifacts. Safe summaries use opaque case IDs.

## Existing application boundaries exercised (unchanged)

Reuse `specs/063-liveview-shell-authentication/contracts/browser.md`, ADR-0006 and `priv/static/openapi.json`; no new route or product response contract.

| Scenario | Executable E2E assertions | Acceptance mapping |
| --- | --- | --- |
| Browser protection | GET /portfolio unauthenticated: 303 sign-in location, no workspace; GET /sign-in 200 labelled form/no-store | US2.1 |
| Sign-in and connected shell | POST /sign-in with actual form CSRF: 303 Portfolio; GET /portfolio 200/no-store, correct account and Portfolio shell, connected LiveView | US2.2 |
| Sign-out | POST /sign-out actual form: 303 sign-in; later Portfolio redirects and session authority is revoked | US2.3 |
| Invalid/expired | Invalid credentials 422 generic/empty password; expired authority redirects with existing recovery and no shell | US2.4 |
| Async synchronization | request_catalog/2 returns accepted run_id before fixture release; real Oban processes; get_run/1 reaches succeeded within 30s | US3.1 |
| Catalog result | Authenticated GET /api/players: 200 application/json; exact expected fixture identities, each once across pages | US3.2 |
| Replay | Repeat same publication using trusted request; succeeded/replay outcome, same identities once and unchanged immutable financial rows | US3.3 |
| Invalid scopes | malformed/unsupported request returns invalid_request; no admitted run/job, unchanged catalog | US3.4 |
| API failures | GET /api/players no valid auth: 401 application/json/error.code=unauthenticated and WWW-Authenticate: Bearer realm="api"; authenticated invalid page_size: 400 error.code=invalid_page_size; no state mutation | US3.5 |

API authorization uses current Bearer JWT and API-key requirements, not a browser cookie. Synchronization request and inspection are trusted local Elixir interfaces, not HTTP endpoints. Use real queue consumers, not manual drain/worker calls. Readiness asserts SQL, Redis, live HTTP response and browser launch inside the runtime command itself. Fixed 30s startup/worker waits, 10s browser actions and 180s process ceiling must fail when unavailable.

## Inventory/quality acceptance

US1.1: all three independent profile positive runs compare exact expected/discovered/executed identities and separate outcomes. US1.2: controlled added/removed files/cases, duplicate assignment, skipped case, cross-profile event, empty/undiscovered case fail. US1.3: selected failure, signals, missing each prerequisite and hung child fail without complete receipt. US4.1: baseline assignment/source audit and unchanged regression population. US4.2: targeted report scope/provenance/threshold-zero contracts. US4.3: workflow behavior tests preserve baseline/analysis categories, supported triggers/services and mandatory E2E job with no skip/continue-on-error loopholes. Secret sentinels cover positive, failure, timeout and retained artifact paths.

Integration's existing Docker lifecycle assertions require Docker Engine/Compose and run sequentially against invocation-owned project/volumes/ports via test tooling, never the shared football_market_local project. Missing Docker or a legacy SKIP marker is failure. Native entry-point ownership prevents a shell child suite being independently rerun as the same cases. Test-only port-conflict fixtures use allocated ports/private files. Service component ceiling: 600s; integration ceiling: 1200s. CI baseline must provision this capability while retaining its existing pinned application service contracts.
