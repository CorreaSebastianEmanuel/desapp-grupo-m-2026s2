# Tasks: External Football Provider Contract

**Input**: `specs/016-external-football-provider-contract/`; plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md and verification.json.

**Tests**: Required by FR-013, the constitution and repository rules. Before implementing a behavior, write its tests and obtain a failure for the intended assertion. Minimal compilable skeletons/test stubs are allowed to make that assertion executable; missing dependencies or compile errors alone are not TDD evidence. Use hand-declared expected values, not production validators, to construct oracles.

**Organization**: Story phases follow spec priority. Paths are repository-relative. `[P]` means independent file work after stated prerequisites; it does not authorize extra agents. One implementation owner completes T001–T038. Only T039/T040 are independent verification gates. No source/policy expansion, commit, push, PR or merge in development.

## Phase 1: Setup

**Purpose**: Prepare existing project/test infrastructure without adding dependencies or services.

- [X] T001 Confirm the pinned toolchain, existing service/browser prerequisites and allowed source boundary against `specs/016-external-football-provider-contract/quickstart.md`, `.tool-versions`, `mix.exs` and `docs/AGENT_VERIFICATION.md`; preserve existing catalog/statistics/profile/coverage configuration.
- [X] T002 Scaffold the pure test bootstrap in `test/provider_contract_offline.exs` and controlled-time test harness in `test/support/providers/fixture_runtime.ex`; create the planned provider/fixture directories, select suites without Mix startup, and propagate ExUnit failure/nonempty-selection status rather than treating missing tests as success.

## Phase 2: Foundational Prerequisites

**Purpose**: Establish the typed port, input rules, safe error construction and a real bounded execution mechanism. Blocks every story.

- [X] T003 Add failing request tests in `test/football_market/providers/request_test.exs` for F-R01–F-R04: both fixed key formats, all five leagues, same/consecutive year seasons, inclusive independent bounds/offsets, unknown/missing/mixed keys, booleans/fractions, catalog-bound rejection and invalid/default/custom timeout; assert zero work on invalid inputs and no atom creation.
- [X] T004 Implement Request/Scope/result/fact/error value shapes in `lib/football_market/providers/types.ex`, lossless ADR-0011 instant rules in `lib/football_market/providers/instant.ex` and fixed-allowlist normalization in `lib/football_market/providers/request.ex`, passing T003 without invoking persistence or converting arbitrary strings to atoms.
- [X] T005 Add failing base error-envelope tests in `test/football_market/providers/error_safety_test.exs` for all eight F-E01 categories, retryability, nil/positive/invalid rate-limit delays, known fields and hostile unknown-key/exception diagnostics; ensure complete outcomes contain no partial success or reflected input.
- [X] T006 Implement template-only safe error construction and typed failure validation in `lib/football_market/providers/error.ex`, including category precedence inputs and safe operation/scope/field handling; do not inspect/log raw exception terms or manufacture retry delay.
- [X] T007 Add failing base timing/process tests in `test/football_market/providers/deadline_test.exs` for F-D01/F-D02/F-D05: exact controlled readiness, normalization cost, real blocked worker cancellation, caller exit, early crash and no late reply reaching a following request.
- [X] T008 Implement absolute elapsed-time execution and monitored worker/coordinator cleanup in `lib/football_market/providers/runtime.ex` and `lib/football_market/providers/runner.ex`, using `test/support/providers/fixture_runtime.ex` only for mechanics; keep deadline policy in Runner, catch raw worker exceptions before default crash logging, apply one terminal outcome and never join blocked work after timeout.
- [X] T009 Define `provider_label/0` and `read/3` in `lib/football_market/providers/adapter.ex`, facade/configuration resolution and pre-work rejection in `lib/football_market/providers.ex`, and the result-dispatch skeleton in `lib/football_market/providers/validator.ex`; missing configured capability returns unsupported-capability and position vocabulary is immutable/injected, with no production fixture default.

**Checkpoint**: Foundational tests run through the pure bootstrap; invalid requests never reach the adapter. Complete these before T010.

## Phase 3: US1 — Obtain Comparable Catalog Facts (P1)

**Goal**: Two differently shaped synthetic catalogs satisfy one consumer contract without persistence.

**Independent test**: `elixir test/provider_contract_offline.exs catalog`; compare both sources across all five leagues/two seasons using explicit correspondences; empty/missing/unsupported and malformed catalogs have distinct exact outcomes.

### Tests first

- [X] T010 [US1] Add failing catalog assertions in `test/football_market/providers/catalog_contract_test.exs` for F-C01–F-C05 and US1.1–4: unordered values/relationships, same-name distinct players, configured positions, safe bindings, trimmed/unique business fields and every identical/conflicting duplicate/dangling/cross-season case; reject whole candidate rather than dropping a record.

### Implementation

- [X] T011 [P] [US1] Declare independent catalog source examples, expected values/correspondences and stable case IDs in `test/fixtures/providers/source_a.exs`, `test/fixtures/providers/source_b.exs`, `test/fixtures/providers/expected.exs` and `test/fixtures/providers/cases.exs`, covering all 20 league/season/source combinations plus F-C02–F-C05; depends on T010.
- [X] T012 [US1] Implement catalog-only synthetic translations in `test/support/providers/fixture_source_a.ex` and `test/support/providers/fixture_source_b.ex`, plus the catalog assertion entry point in `test/support/provider_contract_case.ex` and correspondence comparison in `test/support/providers/fact_oracle.ex`; use different identifiers/field names/order and compare provenance separately; depends on T011.
- [X] T013 [P] [US1] Implement catalog field/relationship/business uniqueness validation in `lib/football_market/providers/catalog.ex`, safe qualified binding completeness/uniqueness in `lib/football_market/providers/provenance.ex` and result-envelope validation in `lib/football_market/providers/validator.ex`; retain lists until duplicate checks and preserve opaque safe source IDs; depends on T010.
- [X] T014 [US1] Wire catalog success/typed errors through `lib/football_market/providers.ex` and `lib/football_market/providers/validator.ex`, stamp controlled retrieval provenance separately from facts, then run the catalog selector and confirm no Ecto/service requirement; depends on T012/T013.

**Checkpoint**: US1 is an independently demonstrable catalog increment, not TASK-016 completion.

## Phase 4: US2 — Obtain Dated Performance Inputs (P1)

**Goal**: Completed dated facts retain unknown metrics and event-time affiliation.

**Independent test**: `elixir test/provider_contract_offline.exs performances`; exact bounds, retained reference closure, all nine counts and historical affiliation match independent expected facts.

### Tests first

- [X] T015 [US2] Add failing US2.1–5/F-P01–F-P10 assertions in `test/football_market/providers/performance_contract_test.exs`: scope/status/kickoff eligibility, inclusive one-microsecond boundaries, unknown-vs-zero and every count type, zero/121+ minutes, no manufactured rows, unsupported capability, transfer/current-directory closure and invalid retained/dangling/duplicate facts.

### Implementation

- [X] T016 [P] [US2] Extend `test/fixtures/providers/source_a.exs`, `test/fixtures/providers/source_b.exs`, `test/fixtures/providers/expected.exs`, `test/fixtures/providers/cases.exs` and both `test/support/providers/fixture_source_a.ex`/`test/support/providers/fixture_source_b.ex` with F-P01–F-P10 independent examples, match scope discriminators and both sources' equivalent performances; depends on T015.
- [X] T017 [P] [US2] Implement eligibility and retained transitive closure in `lib/football_market/providers/performances.ex`: exclude only proven irrelevant records, reject undecidable discriminators, include each retained player's current team/position, validate participating historical teams/positions and at-most-one player-match performance; depends on T015.
- [X] T018 [US2] Complete performance dispatch, field allowlists, canonical nine-key integer/nil counts and output/provenance closure in `lib/football_market/providers/validator.ex`, `lib/football_market/providers/performances.ex` and `lib/football_market/providers.ex`, then run the performances selector; depends on T016/T017.

## Phase 5: US3 — Handle Failure Within a Bounded Wait (P1)

**Goal**: All errors/portions are bounded and safe; existing catalog state and reads remain independent.

**Independent test**: Deadline and safety pure selectors plus `mix test test/football_market/providers/catalog_isolation_test.exs`; real blocked work terminates, exact virtual boundaries hold and every failure leaves local state unchanged.

### Tests first (parallel after US2)

- [X] T019 [P] [US3] Extend `test/football_market/providers/deadline_test.exs` for F-D03/F-D04 and full normalization/error readiness boundaries: complete portions, later-portion failure, cumulative delay, no per-page budget/retry/fallback, one outcome and no late data; assert default 5000 ms/custom 7 ms behavior without real multisecond waits.
- [X] T020 [P] [US3] Extend `test/football_market/providers/error_safety_test.exs` for F-E02/F-E03 hostile URLs/userinfo/token queries, header/authorization text, source refs/IDs, labels/fixture IDs and raw exception text; inspect every caller-visible value and reject unsafe provenance instead of rewriting identifiers.
- [X] T021 [P] [US3] Add failing F-I01 assertions in `test/football_market/providers/catalog_isolation_test.exs` using existing DataCase/Catalog fixtures: snapshot all five catalog tables and selected reads before/after all eight errors, assert zero provider calls on reads, unchanged state and no automatic retries/fallback; use exactly the integration profile tag and restore any test-only configuration.

### Implementation

- [X] T022 [US3] Complete multiphase readiness/cancellation and safe final-outcome handling in `lib/football_market/providers/runner.ex`, `lib/football_market/providers/runtime.ex`, `lib/football_market/providers/error.ex` and `lib/football_market/providers/provenance.ex`, passing T019–T021; no production Catalog/Statistics changes are authorized.
- [X] T023 [US3] Complete both fixture adapters, controlled event/portion scripts and independent expected errors in `test/support/providers/fixture_source_a.ex`, `test/support/providers/fixture_source_b.ex`, `test/support/providers/fixture_runtime.ex` and `test/fixtures/providers/cases.exs`, `test/fixtures/providers/source_a.exs`, `test/fixtures/providers/source_b.exs`, `test/fixtures/providers/expected.exs`, covering F-E01–F-E03/F-D01–F-D05; run deadline/safety/isolation entry points and demonstrate bounded real cleanup.

## Phase 6: US4 — Verify Replacement Sources Offline (P2)

**Goal**: Reusable shared acceptance proves all scenarios offline and detects incorrect equivalence.

**Independent test**: `elixir test/provider_contract_offline.exs fixtures`; every stable variant runs twice through both sources, with explicit identical expected outcomes and complete scenario/FR/SC links. No credentials/network/services.

### Tests first

- [X] T024 [US4] Add failing F-O01–F-O03 tests in `test/football_market/providers/fixture_matrix_test.exs` and `test/football_market/providers/equivalence_test.exs` for nonempty exhaustive inventory, two-source repetition, all five leagues/two seasons/17 scenarios, traceable expected outcomes and bijection negative cases (merged/missing same-name player, swapped teams and performance edges).

### Implementation

- [X] T025 [US4] Finish source B's distinct shape/order/portion representation and corresponding synthetic examples in `test/support/providers/fixture_source_b.ex` and `test/fixtures/providers/source_b.exs`; every shared case must execute against both A/B without consumer vendor branches, real network or source-derived expected values.
- [X] T026 [US4] Complete reusable `ProviderContractCase.assert_contract!/2` in `test/support/provider_contract_case.ex` and per-kind bijective value/relationship/provenance checks in `test/support/providers/fact_oracle.ex`; adapters can reuse it later, while correspondence remains test-only and never establishes local identity.
- [X] T027 [US4] Reconcile exhaustive stable variants/source examples/independent expected bases/overrides and requirement/scenario metadata in `test/fixtures/providers/cases.exs`, `test/fixtures/providers/source_a.exs`, `test/fixtures/providers/source_b.exs` and `test/fixtures/providers/expected.exs`; use test-only structural edits in `test/support/providers/fixture_data.ex`, preserve all 217 expanded cases against literal independent baseline SHA-256 fingerprints (deterministic Erlang term serialization; no Git/history test prerequisite) in `test/football_market/providers/fixture_preservation_test.exs`, assert no orphan/missing/duplicate IDs and cover every row of `specs/016-external-football-provider-contract/contracts/fixtures.md`.
- [X] T028 [US4] Finish dependency-ordered pure module/support loading and exact suite selection in `test/provider_contract_offline.exs`, register every pure ExUnit module with only the unit profile tag, and run fixtures/fixture-preservation/all selectors with fixed wall/elapsed clocks and a failing Git shim for the dedicated preservation check, loading `test/support/providers/fixture_data.ex` before adapters; demonstrate zero application/service startup and nonzero exit for unknown/empty selector or failed assertion.

## Phase 7: Polish, Scope and Developer Verification

**Purpose**: All implementation and developer evidence must finish before independent QA. These tasks are not gates.

- [X] T029 Add scoped dependency/shape and changed-production-path assertions in `test/football_market/providers/scope_test.exs` for FR-014: no Providers-to-Repo/Ecto/web/Statistics context/transport coupling, no writes/retries/scoring/public route/new infrastructure, no production files outside planned provider paths except the five exact data/bootstrap ignore filters in `mix.exs` (assert remaining Mix AST unchanged); verify supported league parity with Catalog and preserve all product invariants; tag integration.
- [X] T030 Reconcile actual public values/callbacks/fixture links/run commands against `specs/016-external-football-provider-contract/contracts/provider.md`, `data-model.md`, `specs/016-external-football-provider-contract/contracts/fixtures.md`, `quickstart.md`, `verification.json` and `docs/adr/0013-provider-contract-boundary.md`; finish documentation before final receipts and retain exact FR/SC and gate mappings without weakening checks or expanding scope.
- [X] T031 Stage completed new implementation/design inputs locally for the existing snapshot-based coverage job using the explicit paths in `specs/016-external-football-provider-contract/quickstart.md`; preserve its feature `.gitignore` rule for local check receipts, `scripts/coverage_report.sh` and `config/cp1_coverage_inventory.exs`, and do not commit/push/publish or add unrelated work.
- [X] T032 Execute manifest checks toolchain and service-preflight through `scripts/agentflow_check.py`, retaining canonical receipts `specs/016-external-football-provider-contract/handoffs/check-toolchain.json` and `specs/016-external-football-provider-contract/handoffs/check-service-preflight.json`; fail visibly when required local services/configuration are unavailable.
- [X] T033 Execute manifest format and compile checks through `scripts/agentflow_check.py`, requiring warning-free production/test-support compilation and formatted code; retain `specs/016-external-football-provider-contract/handoffs/check-format.json` and `specs/016-external-football-provider-contract/handoffs/check-compile.json` only after success.
- [X] T034 Execute request, catalog, performances, deadline, safety, fixtures, fixture-preservation and offline-all checks through `scripts/agentflow_check.py` against final source, requiring all acceptance/negative/repetition assertions and zero skipped/empty coverage; retain `specs/016-external-football-provider-contract/handoffs/check-request.json`, `specs/016-external-football-provider-contract/handoffs/check-catalog.json`, `specs/016-external-football-provider-contract/handoffs/check-performances.json`, `specs/016-external-football-provider-contract/handoffs/check-deadline.json`, `specs/016-external-football-provider-contract/handoffs/check-safety.json` and `specs/016-external-football-provider-contract/handoffs/check-fixtures.json` and `specs/016-external-football-provider-contract/handoffs/check-fixture-preservation.json` and `specs/016-external-football-provider-contract/handoffs/check-offline-all.json`.
- [X] T035 Execute catalog-isolation and scope checks through `scripts/agentflow_check.py`, asserting exact state/read independence and permitted boundaries; retain `specs/016-external-football-provider-contract/handoffs/check-catalog-isolation.json` and `specs/016-external-football-provider-contract/handoffs/check-scope.json`.
- [X] T036 Execute full regression including existing performance checks through `scripts/agentflow_check.py regression`, preserving existing statistics integrity/catalog race assertions and checkpoint behavior; update only the active TASK-016 planned-path recognition (including the exact new fixture helper/preservation test paths) in `test/football_market/statistics/scope_test.exs` and exact data/bootstrap filters in `mix.exs` when the regression exposes obsolete global-scope/discovery assumptions; retain `specs/016-external-football-provider-contract/handoffs/check-regression.json` and remediate any failure within authorized scope before claiming success.
- [X] T037 Execute unit-profile, integration-profile and coverage checks through `scripts/agentflow_check.py`, requiring complete non-skipped existing profile membership and unchanged CP1 inventory/provenance policy; retain `specs/016-external-football-provider-contract/handoffs/check-unit-profile.json`, `specs/016-external-football-provider-contract/handoffs/check-integration-profile.json` and `specs/016-external-football-provider-contract/handoffs/check-coverage.json`.
- [X] T038 Reconcile every completed task with its named files/check receipts, complete all T001–T037, create `specs/016-external-football-provider-contract/handoffs/develop.md` under 400 words with deltas/command outcomes/exact QA guidance, stage that handoff and final `specs/016-external-football-provider-contract/tasks.md` locally so QA can rerun unchanged coverage, and run `python3 scripts/workflow_artifact_probe.py develop --readiness`; rerun all stale manifest checks after any source/canonical change, leaving only independent gates unchecked.

## Phase 8: Independent Verification (Downstream)

- [ ] T039 [gate:qa] Independent QA reruns `specs/016-external-football-provider-contract/verification.json` commands, independently challenges every spec scenario and oracle/budget/safety/isolation mapping, and writes `specs/016-external-football-provider-contract/qa-report.md` plus `specs/016-external-football-provider-contract/handoffs/qa.md`; require final `Verdict: PASS`, otherwise return blockers without implementation edits.
- [ ] T040 [gate:review] Final review inspects source/diff, fresh `specs/016-external-football-provider-contract/qa-report.md` evidence, invariant/checkpoint/boundary coverage and targeted uncovered risks, then writes `specs/016-external-football-provider-contract/review-report.md` plus `specs/016-external-football-provider-contract/handoffs/review.md` with exactly one Backlog impact entry (including TASK-017/TASK-022 when applicable); require final `Verdict: PASS` and retain human merge authority.

## Dependencies and Execution Order

```text
T001 -> T002 -> T003 -> T004 -> T005 -> T006 -> T007 -> T008 -> T009
  -> US1 (T010 -> {T011 -> T012, T013} -> T014)
  -> US2 (T015 -> {T016, T017} -> T018)
  -> US3 ({T019, T020, T021} -> T022 -> T023)
  -> US4 (T024 -> T025 -> T026 -> T027 -> T028)
  -> T029 -> T030 -> T031 -> T032..T037 -> T038 -> T039 -> T040
```

US2 reuses the US1 directory/binding validator; US3 integrates both operation paths; US4 completes the reusable matrix/oracle rather than delaying US1's two-source catalog check. Each story has its own executable acceptance selector even though shared components impose sequential delivery. T032–T037 execute after source/design stabilization; service-preflight precedes DB tests. Do not parallelize database suites/profiles/coverage or canonical mutations/receipts. No task may silently replace a failed prerequisite with a skip.

### Parallel examples

- US1: after T010, declare fixture data T011 while implementing pure catalog/binding validation T013; T012 follows T011, then integrate T014 after both branches.
- US2: after T015, extend synthetic source data/translations T016 while implementing the pure performance validator T017; T018 joins both.
- US3: T019/T020/T021 edit three independent test files after US2; T022 follows all failing tests. These are the three parallel test-writing opportunities explicitly marked `[P]`.
- US4: execute T024–T028 serially; shared source/expectation/oracle files would conflict. There is no independent parallel write opportunity within this story.

## Implementation Strategy

First demonstrate the US1 catalog increment after foundations. It is the MVP demonstration, not an allowed stopping point for this task. Add dated performance facts, bounded safe failures/local isolation, then full offline replacement evidence. Preserve checkpoints through final regression/profiles/coverage. Completion for implementation means T001–T038 and current manifest receipts; delivery still needs separate independent QA and final review PASS. No live-provider feasibility or complete CP2 claim follows from synthetic acceptance.

Task totals: 40; US1 5, US2 4, US3 5, US4 5; shared/setup/foundation/developer/gate tasks 21. Every task uses a checkbox, unique sequential ID, story labels in story phases, and concrete artifact paths. Only T039/T040 are mapped in verification.json.task_stages.
