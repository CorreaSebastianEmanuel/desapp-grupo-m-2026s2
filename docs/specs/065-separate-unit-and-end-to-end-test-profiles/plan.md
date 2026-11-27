# Implementation Plan: Separate Unit and End-to-End Test Profiles

**Branch**: `063-separate-unit-and-end-to-end-test-profiles` | **Date**: 2026-10-16 | **Spec**: [spec.md](spec.md)

The active pointer selects `specs/065-separate-unit-and-end-to-end-test-profiles`. The setup script's directory-derived `065-…` branch alias is not the Git delivery branch; retain both identities and TASK-063.

## Summary

Extend the existing tagged ExUnit profiles with an independently reviewed per-test inventory, execution reconciliation and a separate real-browser/real-worker E2E profile. Preserve existing integration tests in integration, even those using a browser or HTTP. Add new complete journeys for the implemented TASK-046 shell and TASK-019 synchronization only. No product implementation, migrations, public control endpoints, provider access, charts or orders are in scope.

Current feedback in `backlog/feedback/TASK-063.md` is authoritative. All three critic findings are resolved: a committed inventory independent of discovery, a required E2E CI job, and bounded durable-worker polling. Durable changes to the TASK-014 test interface are recorded in [ADR-0028](../../docs/adr/0028-independent-test-inventory-and-e2e-profile.md).

## Technical Context

- Language/platform: Elixir 1.20.3 / OTP 29.0.6, Python 3, POSIX shell and Node 24 on local Linux and Ubuntu 24.04 CI.
- Dependencies: existing Phoenix 1.8.13, LiveView ~1.2, Ecto/PostgreSQL, Oban ~2.24.2; reuse locked Playwright Core 1.63.0 and Chromium in `tools/openapi`. No new runtime dependency or service.
- Storage: existing test PostgreSQL database plus a unique harness-owned schema per E2E invocation; committed JSON inventory and allowlisted execution summaries. No business schema changes.
- Testing: ExUnit formatter events, Python unittest results, Node test events/custom validator cases, explicit shell case events. All test-runner adapters reconcile case identities, not merely process exit or suite/module counts.
- Constraints: deterministic local fixture provider; no external network retrieval. No auth bypass or mocked HTTP responses in E2E. Docker Engine/Compose is also required for the existing service lifecycle regressions in integration; unavailable infrastructure fails rather than accepting their legacy SKIP output. Preflight 30 seconds; per browser action 10 seconds; each synchronization terminal wait 30 seconds; E2E process ceiling 180 seconds with process-group termination. Timeouts fail with a fixed safe category; do not alter product timing/retry semantics.
- Scope: three profiles and their developer/CI evidence, two implemented journeys. Performance goals are bounded test termination and exact inventory accounting, not new application throughput promises.

## Constitution Check

Pre-design: PASS. Spec and approved product decision settle behavior; local inspection resolves implementation questions without new product decisions. Existing technology and layering remain authoritative.

Post-design: PASS. Tests precede changes to runner behavior. Harness code remains under test/support and tools; controllers/domain/persistence/adapters retain their boundaries. All seven PRODUCT invariants remain intact: fixture synchronization changes only catalog/run state; verify unrelated financial/quote/performance tables unchanged, including API rejection and replay. No supply, money arithmetic, trading, audit, quote-history or valuation change. Sources are deterministic; local reads remain independent of provider access. QA and final review remain fresh downstream stages ending exactly `Verdict: PASS`.

## Project Structure and Ownership

- `scripts/test_profile.sh`, `mix.exs`, `test/test_helper.exs`: retain unit/integration entry points and add `mix test.e2e`; choose exactly one profile without injecting E2E into default Mix runs.
- `config/test_profiles.json`: committed expected test IDs, profile and runner assignments; explicit update only, never regenerated during validation.
- `test/support/test_profile_audit.ex`, `test/support/test_profile_formatter.ex`: source/compiled discovery and per-test execution events for ExUnit.
- `scripts/test_inventory.py`, `scripts/test_profile_components.py`: inventory validation and native non-ExUnit runner adapters; no business logic.
- `test/ci/*profile*_test.exs`, `test/scripts/test_inventory_test.py`, `test/scripts/test_profile_components_test.py`: deterministic negative runner/CI/coverage contracts.
- `test/support/e2e/runtime.ex`, `fixtures.ex`, `fixture_adapter.ex`, `test/e2e/browser_shell_test.exs`, `catalog_sync_test.exs`, `tools/openapi/e2e_browser.mjs`: test-only lifecycle, fixtures and complete journeys.
- `.github/workflows/quality-baseline.yml`, `scripts/ci_unit_tests.sh`: preserve required quality categories, add mandatory `End-to-end profile` job; existing Sonar workflow and coverage infrastructure retain their contracts.
- `docs/TEST_PROFILES.md`: commands, assignment/update procedure, prerequisites, safe diagnostics and CI evidence.
- This feature: research.md, data-model.md, contracts/test-profiles.md, quickstart.md, verification.json, tasks.md and delta handoffs.

## Phase 0: Focused Findings

See [research.md](research.md) for the local audit and rejected alternatives. Existing `TestProfileAudit` compares module tags with a filesystem glob, not a separately reviewed inventory or actual per-test results. Existing runner checks a profile sentinel and a nonzero textual summary, which cannot prove every expected test ran. Integration already requires Chromium and includes HTTP/browser regressions; those remain integration. The quality-baseline job runs default `mix test` through `ci_unit_tests.sh` and separately runs Python/shell/OpenAPI tests. Sonar also runs workspace JavaScript coverage. Preserve these obligations while removing duplicate profile execution; no live documentation research is needed.

## Phase 1: Profile and Execution Design

The authoritative assignment is a committed per-test inventory (schema in data-model.md). Independently enumerate source roots and native discovery to catch newly added files/cases; compare to the committed inventory before execution. Reconcile expected, discovered, started and terminal passed IDs after execution, failing on extras, omissions, duplicates, skips, failed cases, no result and unexpected profile execution. Inventory update is an explicit contributor command with a reviewable diff; normal runs are read-only. Never derive expected IDs from the just-discovered set. Fixture/helper files are an explicit non-test allowlist with rationale; historical specs/QA evidence and dependency trees are outside product automated-test roots.

The native adapters distinguish actual cases from orchestration/helper files. A shell acceptance script invoked by a larger lifecycle scenario is not also launched as a second standalone copy of the same cases; the reviewed entry-point graph records leaf ownership and contextual repeated-cycle assertions. Tests of runner behavior use controlled child populations, preventing recursive full-profile launches.

Existing service scripts have a concrete isolation hazard: `scripts/local_services.sh` hardcodes project football_market_local, compose.yaml names shared volumes explicitly, and legacy failure tests bind default 5432/6379 and write fixed /tmp paths. The integration component must run those original scripts via a test-only Docker CLI wrapper that substitutes a unique project and a materialized Compose config with unique volume names and reserved loopback ports. Preserve image/service/healthcheck definitions; never target the real local project/volumes. Amend test-only helpers to use allocated ports/private temporary paths (including bind-conflict assertions), not to skip those assertions. Require actual Docker/Compose readiness and isolate TMPDIR/lock paths; no changes to the production local-services interface are needed. Run service lifecycle cases sequentially before ExUnit runtime cases and tear down only invocation-owned resources. Prove with contract tests that existing local containers/volumes are untouched. Give service components a 600-second ceiling and the full integration profile a 1200-second ceiling; E2E retains its 180-second ceiling.

The legacy `test/integration/*_test.sh` infrastructure-verification and Redis-disposability suites also belong to the isolated service component; discovery recursively enumerates shell suites under `test/`. Their test-mode database selection follows the configured partition.

Every repository-owned automated case under `test/`, `tools/openapi/` and existing CI test entry points is assigned once. Existing ExUnit module tags remain compatible, and a module cannot split profiles. Include generated/parameterized case IDs via native runner discovery. Non-ExUnit suites use their native case identities (Python TestCase ID, Node test path/name, validator named cases, shell named assertions); add structured case events where a current custom runner lacks them. Do not treat a whole process success as all cases passing. Unsupported new test entry points fail inventory review rather than silently disappearing. These adapters are test infrastructure, not another testing framework.

Profiles own assigned component execution as well as ExUnit tests. Pure runner/workflow/JavaScript/OpenAPI-validator tests belong to unit; persistence/HTTP/browser and service lifecycle tests belong to integration; only the new full journeys belong to E2E. Existing ExUnit assignments do not move. The unit/integration audit documents non-ExUnit assignments and commands explicitly. Each profile prints expected/discovered/executed/passed totals and an allowlisted complete/failure result; raw test names/arguments are not published. Stable opaque inventory IDs can identify discrepancies without credential-bearing names.

Use the existing private-capture approach, expanded to all children: close stdin, restrict temporary files (0700 directory/0600 files), no inherited trace/verbose logging, retain only allowlisted category/count/check-ID summaries, delete raw captures on all exits. Browser traces, videos, screenshots, storage states and response dumps are disabled. Never retain headers, HTML, cookie handles, tokens or environment. Controlled secret/hash sentinels exercise stdout/stderr, failures, signals and artifacts. Replace any old success receipt before launch. EXIT/INT/TERM terminate children and prevent partial success; a hard-killed run cannot leave a current complete receipt. Receipts bind run nonce plus inventory digest and are published atomically only after exact execution reconciliation.

## Runtime Design

QA B1 correction: before creating an owned schema, the runtime atomically registers its schema/database/partition and per-child ownership nonce in a private supervisor-owned registry. The Python supervisor always invokes a separate minimal Ecto cleanup process after terminating the child, including timeout and catchable-signal paths. Cleanup validates every record before starting its repository and drops only registered schemas in the exact configured test partition. It does not depend on a killed BEAM executing `after`. Actual timeout/termination regressions preserve a separate control schema. This extends the existing test-only lifecycle; no production interface or persistence model changes.

E2E uses a disposable BEAM process, real Endpoint HTTP/WebSocket listener on loopback and a real headless Chromium instance. Require PostgreSQL SELECT 1 and Redis PING (preserve infrastructure baseline), migrated owned schema, assets and browser launch before scenarios. Verify the configured database remains the existing safe `football_market_test` plus partition identity. Use a unique owned schema/search_path and Oban prefix; no database resets, shared-table deletes or sandbox transaction masking worker visibility. Restore configuration and clean up only owned resources on completion/failure. A failed setup is a failed profile.

Start the application under test-only configuration with a normal SQL pool and Oban testing disabled for E2E (real queue consumers), synchronization enabled, automatic schedules disabled and fixture source only. Reuse the existing TASK-019 fixture provider boundary and source structure; use a test-only release barrier in the fixture adapter to prove admission returns before retrieval completes. Request via `Synchronization.request_catalog/2`, release the barrier, poll `Synchronization.get_run/1` with a monotonic 30-second deadline until `succeeded`; `failed`/`cancelled` or deadline is an immediate test failure. Never call worker.perform, drain_queue, or directly populate the expected final catalog in lieu of processing. Local control uses in-process calls or private IPC, never a new HTTP route.

US2: deterministic account via existing Accounts setup. Real browser requests protected Portfolio, submits the CSRF form, waits for connected LiveView shell, signs out via POST form, and re-requests Portfolio. Also test generic invalid credentials and an expired server-authoritative session using the existing test clock injection without changing production expiry. Assert relevant 303 locations, 200/422 statuses and no-store headers using browser network responses, with shell identity assertions. GET /sign-out remains safe 404; sign-out uses POST. No test-only route supplies authentication.

US3: use valid supported PL fixture scope, admission before release, durable terminal inspection and real authenticated GET /api/players. Use existing JWT/API-key policy from ADR-0006 and `AuthenticateAPI`, issuing local credentials through supported Accounts setup; keep values in memory/private IPC. Assert 200 JSON content type and exact fixture identities (all pages if needed), repeat publication/delivery through the trusted interface, and assert identities once. Reject malformed and unsupported scopes with existing invalid_request result before jobs/runs grow. Assert unauthenticated 401/application-json with WWW-Authenticate: Bearer realm="api" and error.code=unauthenticated, and authenticated page_size=invalid 400/application-json/error.code=invalid_page_size; compare catalog/run and financial snapshots around rejected requests. Assert replay changes no immutable financial/quote records. No live provider or public synchronization HTTP route.

## CI and Existing Quality Contracts

Keep required `Quality baseline` and `SonarCloud analysis and CP1 gate` jobs/triggers and the latter's analysis/threshold/LCOV behavior. Keep exact BEAM, Node, locked dependencies, PostgreSQL/Redis services, formatting, warnings-as-errors, OpenAPI validator tests/contract validation, workflow behavior tests and complete unit/integration execution categories. Add non-optional `End-to-end profile` on PR/main triggers with the same pinned services/toolchains and Chromium/assets setup, Docker/Compose availability for the baseline integration component, job timeout and safe summary always emitted. Do not use continue-on-error, path filters or conditional success for missing prerequisites. Hosted branch-protection settings remain human-admin territory; the workflow job itself must block a failed build.

Refactor `ci_unit_tests.sh` into a compatibility orchestration entry point for unit and integration profiles; preserve complete-discovery sentinel semantics with reconciled per-case execution. Move existing workflow/OpenAPI test invocations under their assigned profile component rather than running them twice. Preserve visible workflow/OpenAPI category evidence by validating the profile component receipts in the required job. Node workspace coverage remains generated for Sonar; keep coverage-mode assertions on the same assigned JavaScript cases. A separate Sonar job may necessarily execute its existing JS coverage command; do not add duplicate full unit/integration runs locally.

Preserve `coverage_report.sh`, `mix test.cp1_coverage`, CP1 scope, native report/HTML, snapshot provenance and threshold zero (ADR-0009). Add targeted compatibility tests for these contracts. Do not run the historical combined CP1 report as an extra CP2 local gate or change its denominator. Existing strict byte/scope oracles need narrow reviewed updates for declared runner/CI paths, not blanket removal or scope expansion.

## Verification and Traceability

`verification.json` maps every FR/SC (no AC IDs declared in spec). US acceptance scenarios are linked in contracts/test-profiles.md. Implementation owner writes negative tests before each infrastructure change and executes each final manifest command through `agentflow_check.py` after all edits. Unit, integration and E2E execute once each; target tests during red/green are allowed. Preflight runs before compile/profile checks. Runtime readiness is also inside E2E; external preflight alone is insufficient. QA independently reruns all applicable manifest checks and challenges mappings, including real HTTP/browser/worker outcomes. Review uses fresh QA evidence and only targeted additional checks. No developer receipt authorizes QA reuse.

CP2's remaining profile requirement is covered by US1 plus mandatory actual US2/US3 E2E CI; US4 preserves engineering safeguards. Broader CP2 charts/orders/demos stay with TASK-034 and their owning tasks. Final tasks are only Independent QA and Final review with explicit gate mapping; every other task and developer check must complete first.

## Complexity Tracking

No constitutional exception. ADR-0028 explicitly extends the old two-profile contract and summary accounting. Do not introduce new infrastructure or change product contracts to make tests pass.

## Supporting Artifact Applicability

```json artifact-applicability
{"schema_version":1,"research":{"required":true,"reason":"Concrete local gaps in discovery, CI execution and real-worker setup need recorded resolutions."},"data_model":{"required":true,"reason":"Committed test inventory and per-case execution/receipt structures change."},"contracts":{"required":true,"reason":"Developer profile CLI, inventory and CI evidence interfaces change."},"quickstart":{"required":true,"reason":"Real browser and worker E2E requires isolated local setup and bounded demo instructions."}}
```
