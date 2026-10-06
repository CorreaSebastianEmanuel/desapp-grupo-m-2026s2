# Tasks: Football Data API Adapter

**Input**: `specs/055-football-data-api-adapter/` design artifacts; actual branch `017-football-data-api-adapter`.

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/football-data.md, contracts/fixtures.md, quickstart.md, verification.json, ADR-0014 and ADR-0015. TASK-016 is completed. TASK-017 feedback 1 and feedback 2 are authoritative; preserve directly relevant TASK-016 feedback as stated in plan.md.

**Tests**: Required by FR-015/016, repository rules and this stage's test-first instruction. Preserve historical red/green work; write each new B1 assertion and observe meaningful failure before its production change. A missing-module failure can establish initial wiring, but must become behavioral assertions once the port exists. Each new ExUnit module has exactly one existing `:unit` or `:integration` module tag. All paths below are repository-relative.

**Organization**: Setup → foundation → four specification stories in priority order → final owner checks → independent gates. Unchanged completed implementation tasks retain their prior state; affected B1 tasks and every owner-check task reopen. Checked boxes are historical state, not evidence from this architecture session. All prior receipts are stale after canonical changes. Use `python3 scripts/agentflow_check.py CHECK_ID` for recorded owner checks; ordinary red/debug runs do not count as acceptance receipts. Only T045/T046 carry downstream gate tags.

## Phase 1: Setup

- [X] T001 Add exact TASK-017 scope/dependency/Mix-discovery assertions and protected existing-boundary/fixture expectations in `test/football_market/providers/football_data/scope_test.exs`; establish the red boundary test before new production files and preserve original guards' intent.
- [X] T002 Create independent synthetic exchange inventory, expected facts/errors/bindings and scenario metadata in `test/fixtures/football_data/exchanges.exs`, `test/fixtures/football_data/expected.exs` and `test/fixtures/football_data/cases.exs` covering every prefix in `specs/055-football-data-api-adapter/contracts/fixtures.md`, including 523-call and call-11 quota cases; do not derive expectations with production code.
- [X] T003 Create fixture loading, recording transport and provider-neutral assertion support in `test/support/providers/football_data/fixture_data.ex`, `test/support/providers/football_data/recording_transport.ex`, `test/support/providers/football_data/contract_case.ex` and selector bootstrap `test/football_data_offline.exs`; reuse existing FactOracle and controlled Runtime, require nonempty suites and reject application/external-service startup; leave old fixtures/bootstrap/helper unchanged.

## Phase 2: Foundational — blocks all stories

- [X] T004 [P] Write red trusted-state tests in `test/football_market/providers/football_data/configuration_test.exs` for enablement, token presence, redacted Inspect, required canonical vocabulary and explicit normalized four-role mappings; assert malformed/duplicate mappings, unknown targets and unsafe test/live settings refuse before transport.
- [X] T005 [P] Build synthetic certificate/ready-listener harness in `test/support/providers/football_data/tls_server.ex` and write red real-transport tests in `test/football_market/providers/football_data/transport_runtime_test.exs` for all fixed HTTP route kinds, approved token header, status/body assertions, same/cross-origin redirects, TLS trust/hostname refusal, bounded readiness, peer-observed socket closure and sentinel-free diagnostics. Foundation tests target the transport port directly; facade normalization assertions are added with T009/T022. No live network or external test services.
- [X] T006 Add direct Mint `~> 1.11` dependency and only the new fixture/bootstrap ignore paths in `mix.exs`; resolve and lock dependencies in `mix.lock`, preserving all unrelated project AST and actual test discovery.
- [X] T007 Implement redacted trusted state and pre-work configuration validation in `lib/football_market/providers/football_data/configuration.ex` according to `specs/055-football-data-api-adapter/contracts/football-data.md`, including exact canonical names, required broad mappings and test-only loopback capability; no Repo/seed lookup or startup exception.
- [X] T008 Define fixed-route private transport behavior in `lib/football_market/providers/football_data/transport.ex` and implement worker-owned Mint HTTP/1 in `lib/football_market/providers/football_data/mint_transport.ex`: verified TLS/hostname, OTP CA roots, fixed origin/numeric paths, no proxy/redirect/retry, remaining-budget VM-safe waits, status preservation without reading failing bodies, safe exceptions and close on every ordinary terminal path; turn foundational transport-port/configuration red tests green without requiring the later catalog facade.

**Foundation criterion**: Ports/support load without application startup; configuration and raw HTTP exchange/lifecycle assertions pass. This is not yet an end-to-end catalog or complete HTTP acceptance receipt.

## Phase 3: US1 — Obtain a Season Catalog (P1, first increment)

**Goal**: Complete normalized current-season catalogs for all five leagues, without persistence or vendor interpretation by consumers.

**Independent test**: `adapter-catalog` exercises actual FootballData through Providers against independent expected facts/bindings; all five leagues preserve every supplied valid player, exact years and valid empty collections; malformed/duplicate/late-failed portions yield one error.

### Tests first

- [X] T009 [P] [US1] Write red complete/empty/five-league catalog and identity/mapping/provenance assertions FD-C01–C04 in `test/football_market/providers/football_data/catalog_test.exs`, including same-name distinct players, duplicated records, missing source fields, unmapped roles and excluded staff/coach sections; add real-TLS facade success assertions to `test/football_market/providers/football_data/transport_runtime_test.exs` for all outbound route kinds.
- [X] T010 [P] [US1] Write red exact-year/current-season, list/team/person agreement, historical refusal, rollover, calendar-year and one-sided stale-transfer assertions FD-C05/E01/E02 in `test/football_market/providers/football_data/scope_evidence_test.exs`; use documented fields only and assert source call order/count.

### Implementation

- [X] T011 [US1] Implement discovery/evidence checks in `lib/football_market/providers/football_data/scope.ex`: accessible season absence versus existing non-current refusal, coherent initial/final signatures, returned competition identity and team/person current-affiliation agreement; no guessed season fields or transfer repair.
- [X] T012 [US1] Implement complete candidate translation in `lib/football_market/providers/football_data/translator.ex`: supplied names/tla/roles, canonical league/position names, opaque result-local references, decimal safe bindings, duplicate-preserving lists and no raw payload fields; use unchanged whole-result Validator through the facade.
- [X] T013 [US1] Implement Adapter callbacks and sequential `3 + teams + players` collection in `lib/football_market/providers/football_data.ex`, with trusted config/capability preflight, initial/final discovery, every team/person portion, explicit empty versus malformed distinctions and fail-fast no-partial outcomes; no persistence/public routes.
- [X] T014 [US1] Execute `adapter-catalog` from `specs/055-football-data-api-adapter/verification.json` and inspect its canonical receipt `specs/055-football-data-api-adapter/handoffs/check-adapter-catalog.json`; require all US1 numbered scenarios and source-evidence adversarial cases to pass.

## Phase 4: US2 — Enable External Access Safely (P1)

**Goal**: Runtime opt-in, no provider credential needed for startup/reads, credential containment and consumer-first validation.

**Independent test**: `adapter-configuration`/`adapter-safety` assert refusal precedence, zero attempts for pre-work failures and zero secret exposure; `isolation` later proves defaults/startup/local-read independence with existing local services.

### Tests first

- [X] T015 [P] [US2] Write red FD-S03–S05 security/precedence assertions in `test/football_market/providers/football_data/security_test.exs`: invalid inputs under all configs, enabled missing/blank credentials for both operations, unsafe URLs/IDs, production test-override refusal, token-containment rejection and transport-generated exception/redirect diagnostics; capture outputs without suppressing Logger.
- [X] T016 [P] [US2] Extend `test/football_market/providers/football_data/configuration_test.exs` with red runtime configuration evaluation for dev/test/prod defaults, exact true/false/invalid enablement, missing credential without startup failure, trusted vocabulary and mapping extensions; supply unrelated existing prod settings synthetically, never live credentials.

### Implementation

- [X] T017 [US2] Add disabled source defaults in `config/config.exs` and runtime opt-in/token injection in `config/runtime.exs`, selecting the adapter/state only per the contract; keep provider nil by default and preserve other app/JWT/database behavior, with no startup retrieval or credential-printing errors.
- [X] T018 [US2] Complete consumer-safe configuration/capability precedence and known-token exclusion in `lib/football_market/providers/football_data/configuration.ex` and `lib/football_market/providers/football_data.ex`, using tests T015/T016; enabled missing token returns authentication-failed, malformed non-secret config invalid-request and valid performance unsupported before outbound work.
- [X] T019 [US2] Complete tested credential/destination/diagnostic hardening in `lib/football_market/providers/football_data/mint_transport.ex` and `lib/football_market/providers/football_data/translator.ex`; close/refuse both redirect types, do not send hostile IDs, leak inspected state or forward credentials, and preserve token-free provenance.
- [X] T020 [US2] Execute `adapter-configuration` and `adapter-safety` from `specs/055-football-data-api-adapter/verification.json`; inspect their receipts under `specs/055-football-data-api-adapter/handoffs/` and confirm FD-S01–S05 assertions rather than bare request success.

## Phase 5: US3 — Report Coverage and Failure Honestly (P1)

**Goal**: Correct safe categories/delays, explicit unsupported coverage, one deadline/cleanup and unchanged local state.

**Independent test**: `adapter-errors`, `retry-expiry`, `adapter-deadline`, `transport-runtime` and `isolation` prove all US3 scenarios, with exact controlled-time oracles plus independently observed real socket cleanup.

### Tests first

- [X] T021 [P] [US3] Write red FD-E01–E06 status/body/delay and complete league-sized quota assertions in `test/football_market/providers/football_data/errors_test.exs`, covering every contract status/category, historical/performance zero-work refusal, unreadable bodies and protocol failures after observed statuses, Retry-After/date/reset validity/expiry/duplicates and no waiting/retry/partial facts; keep direct parser assertions and add complete-boundary assertions in T024.
- [X] T022 [P] [US3] Write red FD-D01/D02 shared-budget/readiness assertions in `test/football_market/providers/football_data/deadline_test.exs` and extend `test/football_market/providers/football_data/transport_runtime_test.exs` with blocked portion/handshake/header/body/caller-exit closure checks, huge valid timeouts and no late results or detached retrievals. Add real HTTPS delta/date/reset positive and expired waits with parser and post-parser time independently consumed; retain Retry-After:1 + 1200-ms normalization pause -> nil and direct peer closure. Preserve original /tmp QA probes unchanged.
- [X] T023 [P] [US3] Write FD-I01 and default-startup/local-read integration assertions in `test/football_market/providers/football_data/isolation_test.exs`, snapshotting all Catalog/Statistics tables and read values around actual adapter success, all eight safe categories and cancellation; observe zero provider calls from application startup/local reads.

- [X] T024 [P] [US3] Write red full-facade expiry matrix and port the independent QA controlled-time oracle into `test/football_market/providers/football_data/retry_expiry_test.exs`: delta seconds/HTTP-date/reset, fixed nonzero receipt anchor, parsing-only/post-parsing-only/both time consumption, readiness 0/1/2/3 seconds after receipt -> 2000/1000/nil/nil for a two-second wait, positive overstated and sub-ms waits, invalid/missing receipt evidence, changing later wall clock, legacy adapter exact equality, recorded-then-success/non-rate/malformed/exception, repeated registrations/calls and no public metadata; execute each deterministic expiry case twice with identical independent expected outcomes. Add feedback-2 fractional HTTP-date receipt assertions with independent UTC/monotonic origins, separate parsing/normalization costs and literal positive/exact-1-ms/sub-ms/expired expectations. Update `test/football_data_offline.exs` with nonempty retry-expiry selection included in all; exactly one unit tag. Observe actual B1 failure before production edits; use independent expected values, never production expiry helpers.
- [X] T025 [US3] Add constrained Runner AST-delta and independent semantic guards in `test/football_market/providers/football_data/scope_test.exs`: permit only run/4 and new with_retry_window/1/refine_retry_delay/3 forms; retain work/4 and every other original form, pure dependencies, unchanged strict readiness/deadline/cancel/close, no vendor branch/new process, and every other protected byte/fingerprint assertion. Add only runner.ex to active TASK-017 allowance in `test/football_market/statistics/scope_test.exs`; assert the new retry_expiry_test.exs discovery/tag entry without allowing a directory wildcard. Keep existing provider scope assertions. These guards must precede the seam implementation.

### Implementation

- [X] T026 [US3] Implement numeric status and known-future delay translation in `lib/football_market/providers/football_data/errors.ex`, classify observed failures before JSON bodies, use original receipt UTC/monotonic expiry, register immutable expiry through private context.record_retry_not_before, retain existing failure keys/positive integer ms; no Error allowlist change, message matching or quota waiting. Preserve HTTP-date microseconds in fixed source expiry and floor only remaining public milliseconds; missing/incoherent receipt gives nil; include parsing cost and preserve status/fallback/duplicate semantics.
- [X] T027 [US3] Integrate status/delay/fail-fast collection and remaining-deadline handling in `lib/football_market/providers/football_data.ex` and `lib/football_market/providers/football_data/mint_transport.ex`; capture received_us/received_utc at first complete failure headers before close/return/parsing; preserve them after a failing status/protocol error, never refresh at parser entry. Update private response support in `test/support/providers/football_data/recording_transport.ex` to model the same event. Satisfy T021/T022/T024 without changing Runtime, Error, Adapter behavior or public request/error keys, imposing a ceiling, detaching work or returning late partial data.
- [X] T028 [US3] Implement only ADR-0015 run/4 wiring plus private with_retry_window/1 and refine_retry_delay/3 in `lib/football_market/providers/runner.ex`: fresh-reference worker-local integer expiry recording with earliest-registration retention and unconditional cleanup, context callback, opaque outcome+expiry packaging after unchanged work/4 normalization, refine valid rate_limited only using existing accepted ready_us, nil after expiry/sub-ms, deadline/cancel precedence and byte-equivalent unregistered adapter outcomes. No additional UTC/clock sample, provider-specific branch or new process. Turn T024/T025 and existing independent QA assertions green; do not edit work/4, Error, Runtime or original fixtures.
- [X] T029 [US3] Exercise the actual read-only boundary in `test/football_market/providers/football_data/isolation_test.exs` with synthetic successful/failing/cancelled adapter exchanges; finish test support only as needed for T023 and verify source collection never acquires persistence/domain/web dependencies. No production local-read changes.
- [X] T030 [US3] Execute `adapter-errors`, `retry-expiry` and `adapter-deadline` from `specs/055-football-data-api-adapter/verification.json`; inspect receipts and reconcile every US3 scenario to FD-E/FD-D/FD-I assertions, reserving service-dependent isolation and real TLS execution for final owner checks.

## Phase 6: US4 — Prove Compatibility Offline (P2)

**Goal**: Repeatable offline actual-adapter acceptance with unchanged original contract, independent oracles and honest capability documentation.

**Independent test**: `adapter-fixtures` executes every case twice with equal facts/errors/provenance and zero live/service use; `provider-contract` runs the original suite unchanged. Documentation assertions prove configuration names, restrictions and safe operator actions exist without secrets.

### Tests first

- [X] T031 [US4] Write red inventory/repeatability/independent-oracle/documentation assertions FD-O01 in `test/football_market/providers/football_data/fixtures_test.exs`, requiring all scenario prefixes, explicit unsupported declarations, stable five-league/two-season data, every expected binding, operator settings/limitations/actions and zero live destinations/real tokens; require the B1 full-boundary matrix alongside all existing FD-E05 cases, without changing TASK-016 fixtures.

### Implementation/support

- [X] T032 [US4] Complete reusable source-neutral outcome/binding assertions in `test/support/providers/football_data/contract_case.ex` and inventory coverage in `test/support/providers/football_data/fixture_data.ex`; use existing FactOracle with explicit independently authored correspondence and expectations, never adapter-generated success/error oracles.
- [X] T033 [US4] Finish nonempty selector and repeat-two-runs execution in `test/football_data_offline.exs`, including `retry-expiry` in pure all and `transport-runtime` as a separate actual-TLS selector and `all` for pure fixture suites; assert no FootballMarket/Ecto/Postgrex/Redix/Phoenix startup or live socket use during pure selectors and retain original `test/provider_contract_offline.exs` unchanged.
- [X] T034 [US4] Create operator setup/enablement/non-secret settings/credential-injection/capability/error guide in `docs/FOOTBALL_DATA.md`, with placeholder-only examples, explicit request-count/latency/roster limitations and optional explicitly enabled internal live smoke; link `specs/055-football-data-api-adapter/quickstart.md` without claiming usable CP2 valuation ingestion.
- [X] T035 [US4] Execute `adapter-fixtures`, `adapter-all` and `provider-contract` from `specs/055-football-data-api-adapter/verification.json`; inspect their receipts and require repeated deterministic results plus unchanged original 217-case fingerprints and huge-timeout/invalid-timeout-scope regressions.

## Phase 7: Polish and complete owner evidence

All implementation/test/support/documentation work must complete here before independent gates. Existing receipt freshness binds final source and canonical artifacts: earlier incremental passing receipts must be rerun once final source stabilizes.

- [X] T036 Reconcile exact active-feature allowances in `test/football_market/providers/scope_test.exs` and `test/football_market/statistics/scope_test.exs` with `test/football_market/providers/football_data/scope_test.exs`; preserve original pure-module/invariant/Mix AST assertions, allow only named TASK-017 files, the ADR-0015 Runner AST exception and Mint/bootstrap deltas, preserving all other byte guards/217 fingerprints; rerun original /tmp QA probes unchanged if present, require their tracked portable equivalents, and execute `scope` from `specs/055-football-data-api-adapter/verification.json`.
- [X] T037 Execute `transport-runtime` from `specs/055-football-data-api-adapter/verification.json`; inspect `specs/055-football-data-api-adapter/handoffs/check-transport-runtime.json` and require asserted local TLS readiness, all affected outbound routes/status/header/body outcomes, no credential forwarding and independent peer closure on every cancellation path.
- [X] T038 Execute `service-preflight` and `isolation` from `specs/055-football-data-api-adapter/verification.json`; inspect canonical receipts and require local PostgreSQL/Redis readiness plus exact unchanged Catalog/Statistics state and zero startup/read provider work.
- [X] T039 Execute `toolchain`, `format` and `compile` from `specs/055-football-data-api-adapter/verification.json`; correct only in-scope failures and leave no formatting/compiler warnings.
- [X] T040 Execute `regression` from `specs/055-football-data-api-adapter/verification.json`, preserving every existing auth/catalog/OpenAPI/statistics/provider behavioral assertion; inspect the receipt for actual full test completion.
- [X] T041 Execute `unit-profile` and `integration-profile` from `specs/055-football-data-api-adapter/verification.json`, with existing browser prerequisites; require nonempty, unskipped independent profiles rather than fixture-only substitutes.
- [X] T042 Reconcile named outputs, scenario/FR/SC mappings and checkpoint limitations in `specs/055-football-data-api-adapter/verification.json`, `specs/055-football-data-api-adapter/tasks.md` and `docs/FOOTBALL_DATA.md`; create final `specs/055-football-data-api-adapter/handoffs/develop.md` under 400 words with deltas/risks and references to canonical check receipts, then stage all new source/artifact files for coverage's existing snapshot requirement without committing/publishing.
- [X] T043 After final source/canonical stabilization, execute every check in `specs/055-football-data-api-adapter/verification.json` through `scripts/agentflow_check.py`, including `coverage`; require all 20 fresh passing canonical receipts, no missing source outputs and existing snapshot-bound profile/coverage evidence. Do not manufacture receipts or weaken checks.
- [X] T044 Audit every completed task against its named files and all implementation/test/check tasks in `specs/055-football-data-api-adapter/tasks.md`; mark only actually completed work and run `python3 scripts/workflow_artifact_probe.py develop --readiness` with final `specs/055-football-data-api-adapter/handoffs/develop.md` present. A failure reopens the affected task/check; only T045/T046 may remain unchecked.
- [ ] T045 [gate:qa] Independent QA reruns all manifest checks, challenges B1 source-anchored complete-readiness expiry, preserved QA probes and legacy/guard invariants plus source-scope/transfer/quota/diagnostic/peer-cleanup oracles and product/checkpoint mapping, and writes `specs/055-football-data-api-adapter/qa-report.md` plus `specs/055-football-data-api-adapter/handoffs/qa.md`; report must end `Verdict: PASS` before review, with no implementation edits.
- [ ] T046 [gate:review] Final review assesses fresh QA evidence, exact constrained Runner AST/legacy-behavior/expiry protection plus scope/dependency/fixture protection and residual live-feasibility/CP2 risk; run targeted uncovered-risk checks and write `specs/055-football-data-api-adapter/review-report.md` plus `specs/055-football-data-api-adapter/handoffs/review.md`, ending `Verdict: PASS`; no implementation edits/merge/publication.

## Dependencies and execution order

```text
T001 → T002 → T003
Setup → (T004 || T005) → T006 → T007 → T008
Foundation → (T009 || T010) → T011 → T012 → T013 → T014 [US1]
US1 → (T015 || T016) → T017 → T018 → T019 → T020 [US2]
US2 → (T021 || T022 || T023 || T024) → T025 → T026 → T027 → T028 → T029 → T030 [US3]
US3 → T031 → T032 → T033 → T034 → T035 [US4]
All stories → T036 → T037 → T038 → T039 → T040 → T041 → T042 → T043 → T044
Owner readiness → T045 [QA] → T046 [review]
```

US2/US3 share production files with US1 and therefore follow it sequentially; each has its own independent acceptance suite. US4 validates the completed capabilities, so follows all P1 increments. Test-first is mandatory even when a test file was introduced earlier: add the new assertion and observe its failure before implementing that increment. Run ordinary targeted red/debug commands before a selector is complete; do not weaken a manifest selector to obtain an early receipt.

### Parallel examples

- Foundation: T004 configuration tests and T005 TLS harness/runtime tests edit different files after T003.
- US1: T009 catalog and T010 scope-evidence test authoring after foundation; production modules remain sequential.
- US2: T015 security and T016 configuration-runtime tests after US1.
- US3: T021 status/delay, T022 deadline/transport extension, T023 isolation and T024 expiry/bootstrap tests after US2 edit distinct files; T025 guard changes follow test authoring, before production correction.
- US4: T031/T032/T033 depend on one another; no safe parallel task within this story. After T031 exists, its pending guide assertions can be inspected independently while T032 finishes; T034 still executes after T033. There is no [P] marker for dependent guide work.

[P] identifies optional scheduling opportunity only; the implementation stage has one code owner and does not authorize spawning agents.

## Implementation strategy and traceability

US1 is the first MVP increment: demonstrate complete conditional catalogs via the unchanged facade and stop to validate T014 locally. Continue US2–US4 before independent QA; no deployment/publication is in this checklist. Do not add HTTP application routes, reconciliation, writes, jobs, performance inference, valuation or subscriptions.

| Story | Task count | Requirement emphasis | Independent checks |
| --- | --- | --- | --- |
| US1 | 6 | FR-001–005/007/013; SC-001/002 | adapter-catalog |
| US2 | 6 | FR-008/009; SC-003/006 | adapter-configuration, adapter-safety, isolation |
| US3 | 10 | FR-005/006/010–014; SC-002/004 | adapter-errors, retry-expiry, adapter-deadline, transport-runtime, isolation |
| US4 | 5 | FR-015/016; SC-005/006 | adapter-fixtures, adapter-all, provider-contract |
| Setup/foundation/final | 19 | FR-017, all checkpoint/regression obligations | scope, toolchain/format/compile, preflight, regression, profiles, coverage, readiness, independent gates |

Total: 46 tasks; all use standard checklist IDs, explicit file paths and required story labels. B1 adds three tasks inside US3; existing downstream IDs shift by three. Scenario coverage lives in contracts/fixtures.md; all canonical 23 FR/SC identifiers map exactly in verification.json. T045/T046 alone map to qa/review in task_stages.
