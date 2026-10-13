# Tasks: Valuation Engine Contract and Normalization

**Input**: specs/058-valuation-contract-normalization/{spec,plan,research,data-model}.md and contracts/.
**Prerequisites**: TASK-020 accepted Statistics facts, Feedback 1, ADR-0020, verification.json.
**Tests**: Required by FR-015 and repository rules. Each test task precedes corresponding behavior implementation; execute red first (including undefined-interface failure), then green. Do not mark a check task complete without execution. Each ExUnit module has exactly one profile tag; no skips or ignored tests. Paths below are exact repository-relative implementation boundaries.
**Organization**: US1/US2 P1 then US3/US4 P2. All four stories are required for TASK-022; US1 is an internal MVP validation checkpoint, not completion or publication authorization.

## Phase 1: Setup

- [X] T001 Create deterministic Sandbox-backed fixture helpers in `test/support/valuation_case.ex` using existing Statistics/Catalog fixture interfaces; support fixed weekly facts, nine metrics, all groups, five leagues/two seasons, transfers and late arrivals without provider calls or database resets.

## Phase 2: Foundational

- [X] T002 Add failing internal DTO/request/error contract assertions in `test/football_market/valuation/contract_test.exs` covering malformed/unknown keys, explicit required values, valid UUIDs, mapping pair shape/duplicate keys/unsupported groups, empty/unsupported requirements, minutes rejection, numeric types and safe deterministic no-score errors per contracts/valuation-context.md.
- [X] T003 Define immutable Request/Fact/ScopeInputs/Prepared/Definition/FeatureView/ScoreResult/Descriptor/Error structures in `lib/football_market/valuation/types.ex` and `lib/football_market/valuation/error.ex`; validate shapes/finite integer or Decimal numeric leaves in `lib/football_market/valuation/request.ex` without defaults or arbitrary atom creation; make T002 green.

**Checkpoint**: Contract foundations ready; no database writes or new schema/dependencies.

## Phase 3: US1 — Prepare Comparable Weekly Local Inputs (P1)

**Goal**: Exact local weekly selection, summed counts, decimal normalization and retained evidence.
**Independent test**: Hand-calculated membership/count/reference results through preparation-unit/history-integration checks, including transfers and equivalent offsets.

### Tests first

- [X] T004 [P] [US1] Add failing weekly instant tests in `test/football_market/valuation/week_test.exs` for US1.1/1.6, UTC Monday bounds, offsets/microseconds, year crossing, malformed/equal/reversed/nonweekly intervals and forbidden precision.
- [X] T005 [P] [US1] Add failing arithmetic tests in `test/football_market/valuation/normalization_test.exs` for US1.2/1.3, every counting metric, positive exact decimal references, invalid references, zero/large counts, saturation, 1/6, 1/128, near-half ratios beyond ambient precision, signed rounding/zero and caller Decimal-context independence.
- [X] T006 [P] [US1] Add failing PostgreSQL selection/evidence tests in `test/football_market/valuation/history_test.exs` for US1.1/1.2/1.4/1.5: exclusive closing boundary, exact player/season isolation, same-instant distinct matches and byte-ordered ties, baseline explicit historical mapping/partition with missing selected mapping rejected, current transfers, retained original facts/minutes, order-independent preparation descriptors and local-only reads; tag integration.

### Implementation

- [X] T007 [US1] Implement exact UTC consecutive-week validation in `lib/football_market/valuation/week.ex` and complete weekly/reference/requirement validation in `lib/football_market/valuation/request.ex`, reusing Statistics instant precision without changing its inclusive read contract.
- [X] T008 [US1] Implement read-only subject/season verification, bounded Statistics history resolution, exclusive end filtering, duplicate rejection and immutable DTO projection in `lib/football_market/valuation/statistics_reader.ex`; no direct valuation persistence queries or current-affiliation classification.
- [X] T009 [US1] Implement exact coefficient/exponent numeric validation, rational cap/quotient-remainder half-away rounding and fixed six-place formatting in `lib/football_market/valuation/decimal_math.ex`; preserve arbitrary accepted integer sizes and no negative zero.
- [X] T010 [US1] Implement historical mapping baseline in `lib/football_market/valuation/position_groups.ex`, canonical overall/populated-group aggregation in `lib/football_market/valuation/preparation.ex` and preparation-only canonical descriptor generation in `lib/football_market/valuation/evidence.ex`; sum all applicable rows, retain raw minutes/nil metrics and make unordered preparation evidence identical before scoring exists.
- [X] T011 [US1] Expose validated read-only prepare/1 in `lib/football_market/valuation.ex`, connect request/reader/preparation workers and make T004–T006 green; ensure complete-input preparation works independently of any scorer or production config.

**Checkpoint**: US1 preparation MVP is independently testable. Validation continues through later stories; do not publish or declare TASK-022 complete.

## Phase 4: US2 — Distinguish Missing Records, Insufficient Data and Zero (P1)

**Goal**: Never invent appearances, metrics or scores.
**Independent test**: Known zeros, empty week, unknown subject, nil required/unrequired and zero-minute histories yield distinct ordinary outcomes.

- [X] T012 [P] [US2] Add failing all-nine-metric completeness assertions in `test/football_market/valuation/missing_data_test.exs` for US2.1/2.3–2.6, scoped nil handling, deterministic complete missing details, zero/extra-time minutes and no row exclusions; tag unit for pure accepted DTO tests.
- [X] T013 [P] [US2] Add failing database-backed public outcome assertions in `test/football_market/valuation/outcomes_test.exs` for US2.2/2.7: known empty vs not-found vs insufficient-data, matches without performances, invalid-request precedence and no score/quote/event/write; tag integration.
- [X] T014 [US2] Complete scoped required-metric completeness and no-applicable-scope handling in `lib/football_market/valuation/preparation.ex`, `lib/football_market/valuation/error.ex` and `lib/football_market/valuation.ex`; make T012/T013 green without imputing nils, participation penalties or partial results.

**Checkpoint**: US1+US2 prepare complete accepted evidence and expose every preparation failure distinctly.

## Phase 5: US3 — Retain Historical Position Groups (P2)

**Goal**: Explicit historical groups preserve mixed-role/transfer evidence.
**Independent test**: Position-aware local fixtures yield overall .750000, defender .500000 and midfielder .250000; current role changes do not alter evidence; absent goalkeeper is not zero.

- [X] T015 [US3] Add failing group assertions in `test/football_market/valuation/position_groups_test.exs` for all US3.1–3.7, all four groups, explicit CB/fullback defender mapping, duplicate/conflicting/unsupported mappings, unused mappings, populated-unrequired groups, mixed present/absent required scopes and independently capped group totals; tag integration.
- [X] T016 [US3] Complete stable historical mapping validation/partition and group-scope completeness in `lib/football_market/valuation/position_groups.ex` and `lib/football_market/valuation/preparation.ex`; make T015 green while preserving absent groups and applicable defender features when goalkeeper is absent, with no current-position fallback or production combination policy.

**Checkpoint**: General/position-aware preparation shares exact facts; scoring of absent contributions is exercised in US4.

## Phase 6: US4 — Replay a Decimal Score Exactly (P2)

**Goal**: Trusted explicit scoring, original-membership replay and authentic immutable fact comparison.
**Independent test**: Illustrative signed weighted scores match exact decimal oracles; late arrival/transfer/new rules do not change replay; coordinated fact/derived tampering fails.

### Tests first

- [X] T017 [P] [US4] Add failing scorer assertions in `test/football_market/valuation/scoring_test.exs` for US4.1/4.2/4.4/4.5/4.8, features-only callback, exact signed weighted sums, configuration-derived requirement mismatch and undeclared weighted metric rejected before callback, ordinary scorer errors/exceptions/invalid results, and explicit require-all versus populated-only policies on absent groups; tag integration.
- [X] T018 [P] [US4] Add failing authoritative replay/public-score assertions in `test/football_market/valuation/replay_test.exs` for US4.3/4.6/4.7: late arrival, transfers, changed version/references/weights/mapping, duplicates, unavailable originals/rules, coordinated counts/totals/features/score tampering, altered position/group/kickoff, wrong player/season/week and caller-mutated Prepared; tag integration.
- [X] T019 [P] [US4] Add failing canonicalization tests in `test/football_market/valuation/canonical_test.exs` for at least 20 distinct fact permutations, tied kickoff byte-ordering, mapping/requirements/nested config order, deterministic error details and descriptor/features/score equality; tag unit with accepted immutable DTOs and illustrative module inputs.

### Implementation

- [X] T020 [US4] Define reviewed module callbacks/definition binding in `lib/football_market/valuation/scorer.ex` and implement test-only general/group-aware/error/malformed illustrative modules in `test/support/valuation_scorers.ex`; module config validation derives exactly declared weighted requirements, enforces explicit policies and uses exact arithmetic with no production defaults.
- [X] T021 [US4] Extend preparation descriptors with scoring identity/version, typed canonical numeric/config encoding and original/derived evidence comparisons in `lib/football_market/valuation/evidence.ex`; integrate scoring descriptor fields with `lib/football_market/valuation/preparation.ex` without executable serialization or durable storage.
- [X] T022 [US4] Implement authenticated preparation validation, explicit definition/requirements matching, restricted feature view, guarded scorer callback errors and finite Decimal output rounding in `lib/football_market/valuation/scoring.ex`; never use raw minutes or infer a strategy/version.
- [X] T023 [US4] Implement exact original-pair fact resolution in `lib/football_market/valuation/statistics_reader.ex` and authoritative replay/recompute/comparison in `lib/football_market/valuation/replay.ex`; never trust snapshots alone or reselect current membership; fail when originals/rules unavailable.
- [X] T024 [US4] Expose score/2, evaluate/2 and replay/2 in `lib/football_market/valuation.ex`, integrate workers and make T017–T019 green, including US4.8 distinguishable failure kinds in `test/football_market/valuation/outcomes_test.exs`; no unsuccessful outcome returns a partial score or write.

**Checkpoint**: All four stories work through internal preparation/scoring/replay; test modules remain illustrative only.

## Phase 7: Polish and Cross-Cutting Verification

- [X] T025 Add failing AST/inventory/read-only and legacy guard rejection tests in `test/football_market/valuation/scope_test.exs` using exactly plan.md's inventory; assert provider/time/randomness/write boundaries, unchanged persisted facts, no quote/events, protected raw-evidence access and no unrelated path allowances; tag integration for actual read-only calls.
- [X] T026 Extend only active-feature exact planned path allowances in `test/football_market/statistics/scope_test.exs` and `test/football_market/providers/scope_test.exs`, preserving original purity/module/schema/ignore-filter assertions and unrelated-path rejection; make T025 and legacy guards green without changing production dependencies.
- [X] T027 Add required five-league/two-season/four-group fixture matrix in `test/football_market/valuation/matrix_test.exs`, asserting exact membership/totals/decimal features/scores/replay and all-nine-metric known/unknown handling per SC-001–005; tag integration; extend test-only fixtures in `test/support/valuation_case.ex` if necessary within plan boundary.
- [X] T028 Run targeted red/green regressions for the added matrix and scope cases in `test/football_market/valuation/matrix_test.exs` and `test/football_market/valuation/scope_test.exs`; repair only in-boundary discrepancies, reconciling any necessary contract change before final verification.
- [X] T029 Reconcile final interfaces, scenario/check ownership and actual paths in `specs/058-valuation-contract-normalization/contracts/valuation-context.md`, `specs/058-valuation-contract-normalization/contracts/acceptance-map.md`, `specs/058-valuation-contract-normalization/quickstart.md` and `specs/058-valuation-contract-normalization/verification.json`; finish all source/design edits before receipts and preserve authoritative spec/feedback/scope.
- [X] T030 Execute toolchain, format and compile manifest checks through `scripts/agentflow_check.py` with --reuse; record current successful receipts in `specs/058-valuation-contract-normalization/handoffs/check-toolchain.json`, `specs/058-valuation-contract-normalization/handoffs/check-format.json` and `specs/058-valuation-contract-normalization/handoffs/check-compile.json`.
- [X] T031 Execute services manifest preflight through `scripts/agentflow_check.py`, confirming guarded migrations and actual PostgreSQL/Redis readiness; record `specs/058-valuation-contract-normalization/handoffs/check-services.json`; unavailable services fail and transient service state is never reused.
- [X] T032 Execute preparation-unit and history-integration checks through `scripts/agentflow_check.py` with --reuse and record current successful receipts in `specs/058-valuation-contract-normalization/handoffs/check-preparation-unit.json` and `specs/058-valuation-contract-normalization/handoffs/check-history-integration.json`.
- [X] T033 Execute missing-data and grouping checks through `scripts/agentflow_check.py` with --reuse and record current successful receipts in `specs/058-valuation-contract-normalization/handoffs/check-missing-data.json` and `specs/058-valuation-contract-normalization/handoffs/check-grouping.json`.
- [X] T034 Execute scoring and replay checks through `scripts/agentflow_check.py` with --reuse and record current successful receipts in `specs/058-valuation-contract-normalization/handoffs/check-scoring.json` and `specs/058-valuation-contract-normalization/handoffs/check-replay.json`; execute the durable feedback-regression public-interface assertions and record `specs/058-valuation-contract-normalization/handoffs/check-feedback-regression.json`.
- [X] T035 Execute matrix and architecture checks through `scripts/agentflow_check.py` with --reuse and record current successful receipts in `specs/058-valuation-contract-normalization/handoffs/check-matrix.json` and `specs/058-valuation-contract-normalization/handoffs/check-architecture.json`.
- [X] T036 Execute complete unit-profile exactly once through `scripts/agentflow_check.py` with --reuse and record `specs/058-valuation-contract-normalization/handoffs/check-unit-profile.json`; retain all existing profile/coverage infrastructure and do not add a historical CP1 report or duplicate full-profile gate.
- [X] T037 Execute complete integration-profile, including existing actual browser E2E and performance tests, exactly once through `scripts/agentflow_check.py` with --reuse; record `specs/058-valuation-contract-normalization/handoffs/check-integration-profile.json`; service/browser prerequisites must pass without skips or omitted tests.
- [X] T038 Create only `specs/058-valuation-contract-normalization/handoffs/develop.md` under 400 words with deltas, evidence references, elapsed check time, residual risks and QA guidance; reconcile every completed task against named artifacts, then run `scripts/workflow_artifact_probe.py develop --readiness` after recording all developer task completion.
- [ ] T039 [gate:qa] Independent QA reruns every manifest check without --reuse, challenges all acceptance mappings and product invariants, writes `specs/058-valuation-contract-normalization/qa-report.md` and `specs/058-valuation-contract-normalization/handoffs/qa.md`; report ends exactly Verdict: PASS only on demonstrated success.
- [ ] T040 [gate:review] Final review examines fresh QA evidence, architecture/scope/checkpoint obligations and targeted uncovered risks, writes `specs/058-valuation-contract-normalization/review-report.md` and `specs/058-valuation-contract-normalization/handoffs/review.md`; report ends exactly Verdict: PASS only on demonstrated success; never merge or publish.

## Dependencies and Execution Order

```text
T001 -> T002 -> T003 -> US1(T004-T011)
US1 -> US2(T012-T014) -> US3(T015-T016) -> US4(T017-T024)
all stories -> T025 -> T026 -> T027 -> T028 -> T029
T029 -> T030 -> T031 -> T032-T035 -> T036 -> T037 -> T038
all T001-T038 complete/current checks -> T039 independent QA -> T040 final review
```

US2/US3 extend the same preparation worker and follow US1; US4 uses complete grouped inputs. Stories are independently validated increments with explicit dependencies, not falsely advertised as independently executable implementations. Within each phase, write/run failing tests before its behavior; models/validation then reader/domain integration. T022 can define the original-evidence authentication call before T023 supplies its replay worker; complete both before facade checks. Source/design changes after receipts require affected final checks rerun; do not change irrelevant inputs or bypass two-failure limits.

## Parallel Examples

- US1: T004 week assertions, T005 numeric oracles and T006 history assertions can be authored independently after T003, before implementation. Run database checks serially with profiles.
- US2: T012 pure nil/zero metric cases and T013 public database outcomes can be authored independently after US1.
- US3: T015's in-memory oracle tables can be prepared independently of fixture planning, but its single test file/implementation share state; no parallel checklist marker or concurrent edits.
- US4: T017 scoring, T018 authoritative replay and T019 canonical permutations occupy separate files after US3. They share only stable fixture/contract definitions.

These are file-level opportunities, not instructions to launch agents. One implementation owner; no parallel database lifecycle/full-profile executions.

## Implementation Strategy

Validate US1 first with explicit illustrative inputs. Add the missing-data guard increment, historical group increment, then scoring/replay. All are mandatory for feature completion. Preserve no-write/no-provider behavior throughout. Complete cross-cutting scope/matrix tests and reconcile design before final manifest execution. QA/review are the only mapped downstream tasks; all implementation and applicable developer test/check tasks complete before QA. No implementation/publishing occurs in the architecture session.
