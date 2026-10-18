# Tasks: Separate Unit and End-to-End Test Profiles

**Input**: `specs/065-separate-unit-and-end-to-end-test-profiles/`; spec.md, plan.md, verification.json, applicable research/data-model/contracts/quickstart; authoritative feedback `backlog/feedback/TASK-063.md`.
**Branch**: `063-separate-unit-and-end-to-end-test-profiles` (keep the active feature directory numbered 065).
**Tests**: Required by repository rules and this feature. Write assertions first, demonstrate the intended red failure, then implement tooling and demonstrate green. Test-only changes are the product of this task; do not fix application behavior or add charts/orders. All tasks remain unchecked until implementation actually creates their deliverables and executes their checks.

## Phase 1: Setup

Goal: establish the actual current population and safe local prerequisites, without bootstrapping another application.

- [X] T001 Record the pre-change runner/CI/coverage audit in `docs/TEST_PROFILES.md`: enumerate actual automated-test entry points and native case counts/assignments, existing ExUnit tags, missing execution accounting, CI category commands, CP1 report scope/provenance/threshold zero and preserved integration-browser ownership; cite plan.md/ADR-0028 and verify exact toolchain/services/dependencies without using production data.

## Phase 2: Foundational prerequisites

Goal: build a reusable test-only runtime lifecycle that fails safely. These tasks block US2/US3 and the complete final E2E run; US1 controlled runner tests can use fake children.

- [X] T002 Write failing lifecycle tests in `test/ci/e2e_runtime_contract_test.exs` for safe database identity, unique schema/Oban prefix, actual queue-consumer configuration, no live provider, readiness failure, deadlines, owned-resource cleanup and no product/control-route changes; classify the suite integration and use controlled subprocess fixtures for failures.
- [X] T003 Implement the test-only lifecycle in `test/support/e2e/runtime.ex`: disposable BEAM, existing safe test DB plus unique migrated schema and normal SQL pool, real Endpoint on loopback, real Oban consumers, synchronization enabled/automatic schedules disabled, fixture-only sources, private IPC, asset/browser/SQL/Redis checks, 30s readiness and 180s process ceiling, signal-safe cleanup limited to owned resources; make T002 green without modifying product modules.

## Phase 3: US1 — Isolated complete test profiles (P1, infrastructure MVP)

Goal: each named profile proves exactly which assigned cases ran, and negative cases fail safely.
Independent test: controlled multi-runner fixtures plus positive unit/integration/E2E runs compare expected/discovered/started/passed identity sets; every failure/omission/signal case exits nonzero with no complete receipt. Full E2E membership becomes available after US2/US3, so US1 infrastructure is an MVP, not the finished CP2 deliverable.

### Tests first

- [X] T004 [P] [US1] Extend `test/ci/test_profile_audit_test.exs` with failing cases for independent-manifest removal/addition, missing file and missing same-module case, duplicate/unknown/test-level/indirect assignment, skips, parameterized discovery, fixture allowlist and cross-profile cases; preserve existing unit/integration audit regressions.
- [X] T005 [P] [US1] Extend `test/ci/test_profile_runner_contract_test.exs` with controlled fake-child assertions for failure, skip, empty/discovered-but-unstarted/unterminated/duplicate results, swapped equal-count identities, INT/TERM/hard termination, missing each prerequisite, hung worker/process, stale receipt invalidation and password/token/key/hash sentinels in stdout/stderr/private captures; assert safe categories and no complete receipt or retained raw data.
- [X] T006 [P] [US1] Add failing native-adapter/inventory tests in `test/scripts/test_inventory_test.py` and `test/scripts/test_profile_components_test.py` for Python, Node, validator and named shell cases: independent source enumeration, explicit update only, duplicate/missing/extra/skipped events, unavailable runner, nonzero child, shell entry-point/leaf ownership and exact native identity reconciliation; add failing isolation tests proving unique Docker project/volume/port/lock targets and no contact with the shared local project; classify pure controlled tests unit.

### Implementation

- [X] T007 [US1] Define the committed inventory schema in `config/test_profiles.json` and implement read-only check/explicit reviewed update in `scripts/test_inventory.py` per data-model.md, including stable opaque IDs, runner/file/native-case/profile uniqueness, independently enumerated source roots, helper exclusions with reasons and explicit assignment for new cases; never regenerate expectations while checking.
- [X] T008 [US1] Extend `test/support/test_profile_audit.ex` and add `test/support/test_profile_formatter.ex` to discover compiled ExUnit cases (including generated cases), retain module-tag validation, compare the independent inventory and collect/reconcile started and terminal events; fail missing/extra/duplicate/skipped/cross-profile cases even when totals match.
- [X] T009 [US1] Implement `scripts/test_profile_components.py` and native reporter hooks in `test/scripts/`, `tools/openapi/validate.test.mjs` and `tools/openapi/workspace_session.test.mjs` as needed: enumerate and report individual Python/Node/custom-validator/shell assertions, classify every existing automated case once, preserve original assertions and forbid whole-process-success substitution; isolate actual Docker lifecycle cases using a private CLI wrapper/materialized Compose config with unique project/volume names/ports and test-only helper port/temp-file changes in `test/scripts/support/local_services_test_helpers.sh` and affected service scripts; fail legacy SKIP output, require Docker/Compose, execute lifecycle cases sequentially with 600s component/1200s integration ceilings, and make T006 green with controlled cases before full execution.
- [X] T010 [US1] Extend `scripts/test_profile.sh`, `mix.exs` and `test/test_helper.exs` with `mix test.e2e`, selected component orchestration, exact case reconciliation, count summaries, version-compatible CP1 unit/integration metadata, invocation/digest-bound atomic receipts and safe private capture/process-group timeout/signal handling; exclude E2E from default Mix/unit/integration and preserve performance-tag inclusion in existing profiles.
- [X] T011 [US1] Populate/review `config/test_profiles.json` from actual native discovery across every declared test root, retaining all baseline ExUnit assignments, adding new tooling cases, documenting shell/custom runner assignments and proving T004–T006 green; update `docs/TEST_PROFILES.md` with current counts and safe discrepancy/update instructions without inventing passing evidence for US2/US3.

## Phase 4: US2 — Authenticated browser shell journey (P1)

Goal: actual browser navigation/form submission proves the delivered authentication shell.
Independent test: real Chromium observes protected access before login, connected Portfolio after login and denied access after logout, plus invalid-credential and expired-session recovery. Assert network statuses/locations/no-store and visible identity, without browser artifacts or auth bypass.

### Tests first

- [X] T012 [US2] Write failing journey assertions in `test/e2e/browser_shell_test.exs` and `tools/openapi/e2e_browser.mjs` for US2.1–US2.4: unauthenticated Portfolio 303, sign-in form 200, valid CSRF POST 303, connected Portfolio 200/account shell, actual POST sign-out 303 and revoked access, invalid credentials 422/generic/empty password and server-authoritative expiry recovery; assign the owning ExUnit cases E2E and treat the JS driver as their helper, not duplicate test cases.

### Harness integration

- [X] T013 [US2] Add deterministic Accounts setup and test-clock preparation in `test/support/e2e/fixtures.ex`, using existing supported registration/session clock contracts; provision credentials through private memory/IPC, retain ordinary production routing/CSRF and no-store behavior, and never establish authority through a probe route.
- [X] T014 [US2] Wire the real browser process and private result transport into `test/support/e2e/runtime.ex` and `tools/openapi/e2e_browser.mjs`, with 10s action deadlines, connected LiveView evidence, revoked/expired session assertions and safe allowlisted summary output; make T012 green and verify credential-bearing traces/screenshots/storage/output are disabled.

## Phase 5: US3 — API and durable catalog background journey (P1)

Goal: accepted trusted local work becomes a persisted terminal result and exact API-visible catalog through real background consumers.
Independent test: fixture-release barrier proves admission precedes retrieval; bounded get_run polling reaches succeeded; HTTP returns fixture identities once, replay remains idempotent, invalid scope/auth/input leave state unchanged.

### Tests first

- [X] T015 [US3] Write failing real-runtime assertions in `test/e2e/catalog_sync_test.exs` for US3.1–US3.5: accepted run before fixture release, real Oban terminal completion within 30s, authenticated GET /api/players 200/application-json and exact paginated identity set, duplicate-free replay, malformed/unsupported scope rejected before jobs/runs grow, 401/application-json/error.code=unauthenticated with WWW-Authenticate Bearer challenge, and 400/application-json/error.code=invalid_page_size with unchanged catalog/run/financial snapshots.

### Harness integration

- [X] T016 [US3] Implement the deterministic fixture provider/release barrier in `test/support/e2e/fixture_adapter.ex` and extend `test/support/e2e/fixtures.ex` using the existing TASK-019 source/fixture and Accounts API credential interfaces; expose no public control route, live provider, production credentials or prepopulated expected final catalog.
- [X] T017 [US3] Extend `test/support/e2e/runtime.ex` to request/inspect through `Synchronization.request_catalog/2` and `get_run/1`, release fixture retrieval, wait on real durable consumers with monotonic deadlines and fail terminal errors/timeouts; add real HTTP catalog assertions/private credential handling and immutable-state comparisons, make T015 green without perform/drain_queue shortcuts or synchronization behavior edits.

## Phase 6: US4 — Regression, coverage and mandatory CI quality (P2)

Goal: retain required categories and legacy report availability while adding non-optional E2E CI.
Independent test: targeted workflow/report/entry-point contracts and positive final profiles show unchanged regression ownership, coverage scope/provenance/threshold zero, preserved baseline/Sonar checks and mandatory E2E execution. Historical combined coverage-report execution is not an extra CP2 gate.

### Tests first

- [X] T018 [P] [US4] Add failing required-category/E2E workflow assertions in `test/ci/test_profiles_quality_contract_test.exs` and update `test/scripts/ci_unit_tests_test.sh`: preserve PR/main triggers, pinned services/toolchain, format/compile/OpenAPI/workflow/unit/integration/Sonar contracts and complete-discovery marker; require E2E job with browser/assets/worker readiness, Docker/Compose isolation capability for existing baseline service tests, timeout, safe failure summary and no optional/skip/continue-on-error path; assert no duplicate full profile invocations.
- [X] T019 [P] [US4] Extend `test/ci/coverage_report_contract_test.exs` and `test/ci/cp1_coverage_inventory_test.exs` with failing compatibility assertions where runner interfaces change: CP1 source/module denominator, native report/HTML and snapshot provenance preserved, threshold remains zero, E2E excluded from historical report, informational report remains runnable and no historical CP1 local gate added.
- [X] T020 [P] [US4] Add feature-boundary regressions in `test/ci/test_profiles_scope_test.exs` asserting declared test-tooling/CI paths only, production auth/trading/valuation/catalog/worker interfaces unchanged, no public control endpoint/new business dependency, no unfinished chart/order claims and deterministic fixture-only sources; update existing exact scope/byte oracles only at the specific expectations affected by the declared plan.

### Implementation

- [X] T021 [US4] Refactor `scripts/ci_unit_tests.sh` to orchestrate complete unit/integration profiles once and validate their reconciled full-discovery/component evidence with safe output; remove raw child output and preserve CI failure semantics and required discovery marker, making its controlled contract tests green.
- [X] T022 [US4] Update `.github/workflows/quality-baseline.yml` to preserve required baseline/category execution and add a mandatory `End-to-end profile` job with existing pinned PostgreSQL/Redis/BEAM/Node dependencies, Chromium/assets and bounded runtime, plus Docker/Compose preflight for the baseline integration service component; consume profile component receipts for workflow/OpenAPI category evidence instead of repeating their tests, retain existing `.github/workflows/sonarcloud.yml` analysis/LCOV/native/CP1 behavior and make T018 green.
- [X] T023 [US4] Reconcile narrowly affected assertions in `test/ci/test_profiles_quality_contract_test.exs`, `test/ci/coverage_report_contract_test.exs` and existing scope/CI contract suites, preserving their actual security/coverage checks; demonstrate T019–T020 green, update `docs/TEST_PROFILES.md` with the before/after category map, unchanged report command and exact E2E evidence boundary.

## Phase 7: Polish and developer verification

All applicable implementation and developer checks below precede independent QA; none is a deferred gate. Complete source/design edits and inventory updates before final check execution. All manifest checks use `python3 scripts/agentflow_check.py CHECK_ID --reuse`; service/runtime checks configured reuse=false always execute. QA never reuses developer receipts. Stop after two unchanged failed attempts per docs/AGENT_VERIFICATION.md.

- [X] T024 Reconcile `config/test_profiles.json`, `docs/TEST_PROFILES.md` and `specs/065-separate-unit-and-end-to-end-test-profiles/verification.json` against all newly added native cases, exact test-first regressions and every FR/SC/US acceptance scenario; update quickstart.md only for actual tooling corrections, preserving ADR decisions and no product scope expansion.
- [X] T025 Execute manifest toolchain, service-preflight, format, compile, database-prepare and assets checks in `specs/065-separate-unit-and-end-to-end-test-profiles/verification.json` after all edits; resolve failures through authorized tooling changes and record real outcomes, not assumed success.
- [X] T026 Execute manifest inventory, openapi-contract and unit checks from `specs/065-separate-unit-and-end-to-end-test-profiles/verification.json`; require all audit/native-adapter/runner-negative/secret/coverage/CI contracts and expected-discovered-executed membership checks to pass, with unit profile run once in final verification.
- [X] T027 Execute manifest integration and e2e checks from `specs/065-separate-unit-and-end-to-end-test-profiles/verification.json`; integration runs once and new E2E starts its own services/listener/browser/workers with assertion-based real HTTP evidence, invalid-scope/auth/page-size checks, replay invariants, timeouts and no retained secrets; follow quickstart.md without adding a second full-profile/combined-coverage pass.
- [X] T028 Validate complete spec/plan/tasks/manifest alignment and developer readiness using `python3 scripts/workflow_artifact_probe.py develop` (structural check; readiness follows completion of this phase) after reconciling completed implementation tasks and creating `specs/065-separate-unit-and-end-to-end-test-profiles/handoffs/develop.md`; confirm current check receipts and named artifacts exist, and record any unresolved developer obligation before QA.
- [X] T029 Finalize the single concise `specs/065-separate-unit-and-end-to-end-test-profiles/handoffs/develop.md` (under 400 words) with actual changes, command outcomes/evidence references, elapsed check time/failure count if applicable, residual risks and exact independent QA guidance; no duplicate evidence handoff, commit or publication.

After T001–T029 have actually completed and their checkboxes are reconciled, execute `python3 scripts/workflow_artifact_probe.py develop --readiness` as the stage-transition check before starting T030. This placement prevents the readiness check from depending on its own still-unchecked task. Record its result in the existing development handoff; handoff-only edits do not invalidate receipts. A failed transition blocks QA.

## Phase 8: Downstream independent verification

- [X] T030 Independent QA [gate:qa] rerun applicable manifest checks without receipt reuse, independently challenge every FR/SC/US acceptance and real HTTP/browser/worker outcome, inspect secret safety and inventory negatives, write `specs/065-separate-unit-and-end-to-end-test-profiles/qa-report.md` and `specs/065-separate-unit-and-end-to-end-test-profiles/handoffs/qa.md`, ending the report exactly `Verdict: PASS` only on full acceptance.
- [X] T031 Final review [gate:review] assess the diff, architecture/product invariants, checkpoint scope and fresh QA evidence, run only targeted checks for uncovered risks, write `specs/065-separate-unit-and-end-to-end-test-profiles/review-report.md` with one Backlog impact entry and `specs/065-separate-unit-and-end-to-end-test-profiles/handoffs/review.md`, ending the report exactly `Verdict: PASS` only when ready for human merge.

## Dependencies and execution order

T001 -> T002 -> T003. US1 tests T004/T005/T006 may be authored together after T001; implementations T007–T011 depend on their failing regressions and finish before full profile use. US2 T012 -> T013 -> T014 and US3 T015 -> T016 -> T017 depend on T003 and the US1 E2E runner. US2 and US3 scenario assertions can be authored independently; edits to shared runtime.ex/fixtures.ex serialize. US4 test files T018/T019/T020 can be authored together after the baseline audit; implementation T021–T023 follows US1 and complete journey wiring. T024–T029 require US1–US4. T030 requires every T001–T029 complete and current successful developer receipts; T031 requires fresh independent QA PASS. Only T030/T031 appear in verification.json.task_stages.

Within each story, run new tests red before implementation, then green; a red failure must concern the intended missing behavior rather than a syntax/prerequisite failure. Add inventory entries as tests are added; final T024 reconciles all changes before evidence freezes. Assertions inspect application behavior; harness code cannot manufacture passing case events.

## Parallel examples

These are file-independent opportunities, not instructions to launch agents in this architecture session.

- US1: author T004 audit tests, T005 runner tests and T006 native-adapter tests together. T007–T010 share inventory/runtime contracts and proceed in dependency order.
- US2: once T012 asserts the journey, browser-driver assertions in tools/openapi/e2e_browser.mjs and account/clock fixtures in test/support/e2e/fixtures.ex can be edited independently; complete both before T014 runtime wiring.
- US3: draft catalog_sync_test.exs assertions and fixture_adapter.ex barrier contract independently after the shared runtime contract is fixed; sequence T015 red, then T016/T017. Do not edit shared fixtures/runtime concurrently with US2.
- US4: T018 workflow, T019 coverage and T020 scope regressions use different files and may be authored together. CI wrapper changes precede workflow integration.

## Implementation strategy and acceptance map

MVP: US1 infrastructure with independently runnable profiles and controlled completeness/failure cases. This is an incremental checkpoint; do not claim TASK-063 or CP2 E2E complete until US2, US3 and US4 plus independent gates pass. Incrementally add real shell journey, real durable API journey, then required CI quality evidence. No deployment/publishing is part of these tasks.

| Story | Tasks | Acceptance/evidence |
| --- | --- | --- |
| US1 | T004–T011 (8) | US1.1 exact isolated positive runs; US1.2 inventory/discovery/runtime negatives; US1.3 signals/prerequisites safe failure. FR-001–004, FR-009–011; SC-001/004/007. |
| US2 | T012–T014 (3) | US2.1–4 real browser/status/header/body and expiry assertions. FR-005/009/011/015; SC-002/007. |
| US3 | T015–T017 (3) | US3.1–5 admission-to-persisted-to-HTTP result, replay and rejection snapshots. FR-006–009/011/015; SC-003/007. |
| US4 | T018–T023 (6) | US4.1 unchanged ownership, US4.2 report contract, US4.3 required categories/E2E job; no product changes. FR-002/012–014; SC-005/006. |

31 total tasks: 20 story tasks, 3 setup/foundation, 6 developer polish/checks and 2 downstream gates. Every task has a sequential ID and named paths; only story phases carry US labels. See verification.json for executable FR/SC mapping; the spec declares no AC identifiers.
