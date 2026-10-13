# Tasks: Balanced Valuation Strategy

**Input**: specs/059-balanced-valuation-strategy/plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md and verification.json.

**Tests**: Required by FR-011 / AGENTS. Add meaningful assertions before corresponding behavior; demonstrate missing behavior with a red test, keeping inherited already-supported scenarios green. Do not manufacture failures or mark checks complete without execution. Every new test module has exactly one :unit or :integration tag. One implementation owner; parallel labels describe independent file work, not permission to launch agents.

**Format**: Sequential IDs; [P] means independent files after stated prerequisites, [USn] maps spec stories. Paths are repository-relative. Only final QA/review tasks carry gate labels. No code publication is authorized by this file.

## Phase 1: Setup

Purpose: Confirm the bound feature and existing local runtime; no project initialization/dependency changes.

- [X] T001 Confirm TASK-022 dependency, current feedback and the exact eleven-path implementation boundary in `specs/059-balanced-valuation-strategy/plan.md`; use existing `test/support/valuation_case.ex` fixtures and retain operator-calibration ownership in `docs/adr/0021-balanced-strategy-explicit-rules-and-exact-contributions.md`.
- [X] T002 Run toolchain and fresh services preflight from `specs/059-balanced-valuation-strategy/verification.json` via `scripts/agentflow_check.py`; per current Feedback 1, toolchain is checked now and full services receipt is deferred to T024 after the documented external recovery; keep T002 unchecked until T024 succeeds; use guarded test database and existing PostgreSQL/Redis/Node-browser setup from `README.md` and `scripts/test_profile.sh`.

## Phase 2: Foundational

Purpose: Wire exact boundary evidence before introducing production code. Foundation is ready when assertions/allowances are in place and expected missing-scorer failures are understood; no claim that acceptance is green yet.

- [X] T003 Write the exact planned-file/purity and active-allowance assertions in `test/football_market/valuation/balanced/scope_test.exs`; preserve unrelated/unplanned-path rejection and existing historical TASK-022 tests; confirm assertions detect an absent/unplanned scorer.
- [X] T004 Extend only top-level production inventory in `test/football_market/valuation/scope_test.exs` by balanced.ex, keeping historical allowance assertions tied to the original TASK-022 inventory, and add exact active-feature eleven-path branches to `test/football_market/statistics/scope_test.exs` and `test/football_market/providers/scope_test.exs`; preserve legacy branches, AST checks and unknown-feature empty allowances per plan.md.

## Phase 3: US1 — General Weekly Score (P1, MVP)

Goal: A production balanced/1 definition computes the explicit overall weighted formula. Independent criteria: all nine single-metric cases give 1.000000; mixed-role saturation gives 2.000000; main fixture gives 1.500000; complete zeros and penalties render correctly.

### Tests first

- [X] T005 [P] [US1] Add public evaluate/score tests for all US1 scenarios in `test/football_market/valuation/balanced/formula_test.exs`: nine metrics, mixed historical roles, overall saturation, equal totals with varied/zero minutes and affiliation, known zeros, explicit penalties, score above one, retained input explanation and no implied preset/sign; observe missing production behavior before T007.
- [X] T006 [P] [US1] Add schema/identity/derived-requirement assertions in `test/football_market/valuation/balanced/config_test.exs`: arbitrary nonempty subsets, signed integer/fractional/zero exact weights, all-zero config, Request-order overall keys, equivalent Decimal normalization and rejection of missing/empty weights, unsupported metrics/options/role maps and invalid numeric types; observe missing behavior before T007.

### Implementation

- [X] T007 [US1] Create `lib/football_market/valuation/balanced.ex` implementing existing Scorer callbacks, balanced/1 identity, explicit flat weights and overall requirement derivation, safe missing-feature failure and exact weighted callback using `lib/football_market/valuation/decimal_math.ex`; no defaults/registry/position policies/raw data or writes; satisfy T005–T006.
- [X] T008 [US1] Run balanced-config and balanced-formula checks via `scripts/agentflow_check.py` from `specs/059-balanced-valuation-strategy/verification.json`; assert prepare+score equals evaluate and document any real failure before continuing.

Checkpoint: US1 is independently testable; formula fixtures remain explicit test configuration, not production calibration.

## Phase 4: US2 — Explicit Rules and Incomplete Data (P1)

Goal: Config membership defines data requirements and invalid/incomplete inputs fail safely. Independent criteria: omitted unknown metrics succeed; configured unknown metrics fail even at zero weight/minutes; all-zero complete inputs succeed; invalid config fails before empty history; empty history/unknown player/invalid rules stay distinct.

### Tests first

- [X] T009 [P] [US2] Expand `test/football_market/valuation/balanced/config_test.exs` with rejected plain-map/container/options/type/metric cases, improper weights and nested tails, malformed Decimal sign/coef/exp/extra/missing fields and unknown strings; require explicit ordinary validation results rather than callback_exception, using contracts/acceptance-map.md.
- [X] T010 [P] [US2] Add public evaluate/authenticated score regressions in `test/football_market/valuation/balanced/outcomes_test.exs` for US2.1–6, exact requirements/reference mismatches, configured zero-weight missing counts, all-zero completeness, unknown/empty/invalid outcomes, malformed requirements/mapping/nested config, zero minutes, weekly opening/closing boundaries/equivalent offsets, player/season isolation and mandatory historical mapping.

### Implementation

- [X] T011 [US2] Complete bounded structural validation in `lib/football_market/valuation/balanced.ex` against T009–T010 before any traversal/arithmetic; reject structs/lists/unsupported keys and invalid numeric fields, keep exact metric membership including zero and no atom conversion/defaults/broad rescue; preserve existing common error ownership.
- [X] T012 [US2] Run balanced-config and balanced-outcomes via `scripts/agentflow_check.py` using `specs/059-balanced-valuation-strategy/verification.json`; check no-score errors identify the configured missing metric, overall scope and original performance and that invalid config is not hidden by an empty week.

Checkpoint: US2 validates configuration and completeness independently using a simple one-metric production definition.

## Phase 5: US3 — Exact Decimal Contributions (P1)

Goal: Exact product/sum followed by one final common rounding, independent of Decimal context. Independent criteria: all US3 examples, signed ties, fractional residuals and wide-exponent cancellation agree with independently supplied expected strings.

### Tests first

- [X] T013 [US3] Add all US3 public evaluate/score cases and direct shared-helper regressions in `test/football_market/valuation/balanced/arithmetic_test.exs`: rounded-feature 1/6, no per-product rounding, signed ties/negative zero, large cancellation, disparate exponents and residuals below/at/above both signed ties, equivalent noncanonical Decimals, ±10000-exponent zero factors, huge accepted counts, permutations and varied precision/rounding contexts restored in cleanup; use independent expected values from contracts/acceptance-map.md.

### Implementation

- [X] T014 [US3] Refine only weighted/1/private helpers in `lib/football_market/valuation/decimal_math.ex` with exact coefficient/exponent multiplication, early zero elimination, trailing-zero canonicalization, equal-exponent cancellation and one surviving scale; return unrounded finite Decimal/canonical positive zero; preserve ratio/normalize/round behavior and introduce no numeric ceiling or new dependency.
- [X] T015 [US3] Run balanced-arithmetic via `scripts/agentflow_check.py` using `specs/059-balanced-valuation-strategy/verification.json`, including inherited `test/football_market/valuation/normalization_test.exs` and `test/football_market/valuation/scoring_test.exs` to prove shared-helper compatibility.

Checkpoint: US3 is independently tested through a small accepted history plus standalone exact-helper assertions; production helper is never the expected-value oracle.

## Phase 6: US4 — Original-rule Reproduction (P2)

Goal: Complete common evidence reproduces original successful scores without substituting new facts/config. Independent criteria: replay all successful example fixtures, changed fresh rules/late arrivals cannot alter originals, tampering/unavailable/unsupported cases fail distinctly, and at least 20 permutations yield identical canonical evidence.

### Tests and conformance

- [X] T016 [P] [US4] Add production-definition descriptor/evaluate-score equivalence/replay regressions in `test/football_market/valuation/balanced/replay_test.exs` for all US4 scenarios and every successful numeric fixture; cover late arrival, changed weights/references/mapping/current affiliation, unsupported definitions, unavailable originals, altered facts/features/score/config, duplicate membership, improper fact/membership/config tails and at least 20 deterministic multi-metric/multi-row permutations.
- [X] T017 [P] [US4] Extend `test/football_market/valuation/balanced/scope_test.exs` with provider-independent successful/failed evaluate/score/replay, unchanged original facts, calling-process SQL mutation/event assertions after fixtures and scorer AST restrictions including local send/spawn; put the read-failure probe in a separate tagged DataCase async:true module in this file, invoking public evaluate in a monitored raw process without sandbox ownership/caller propagation and asserting visible failure rather than football absence; restore handlers and never change global sandbox mode or stop services.
- [X] T018 [US4] Run balanced-replay and architecture via `scripts/agentflow_check.py` using `specs/059-balanced-valuation-strategy/verification.json`; prove existing common replay supports production Balanced without modifying `lib/football_market/valuation/replay.ex` or introducing another store/engine.

Checkpoint: US4 is a conformance increment against existing replay behavior, not a new persistence lifecycle.

## Phase 7: Polish, Developer Verification and Independent Gates

All applicable implementation and developer-check tasks must complete before independent gates. Final checks follow all source/design edits; prior valid developer receipts may be explicitly reused. Any material corrective edit requires current fingerprints for all checks again.

- [X] T019 Reconcile actual strategy usage and remaining calibration integration guidance in `specs/059-balanced-valuation-strategy/contracts/balanced-scorer.md` and `specs/059-balanced-valuation-strategy/quickstart.md`; keep TASK-025/026 operator ownership and no presets/HTTP expansion.
- [X] T020 Audit exact spec identifiers/scenario coverage, command paths and QA/review-only task mapping in `specs/059-balanced-valuation-strategy/verification.json` and `specs/059-balanced-valuation-strategy/contracts/acceptance-map.md`; finish design edits before T021–T028.
- [X] T021 Execute final toolchain check through `scripts/agentflow_check.py` from `specs/059-balanced-valuation-strategy/verification.json` with --reuse only for intact current development receipts.
- [X] T022 Check formatting via the format manifest check in `specs/059-balanced-valuation-strategy/verification.json`; correct actual files before restarting affected final verification.
- [X] T023 Compile with warnings as errors via the compile check in `specs/059-balanced-valuation-strategy/verification.json` under MIX_ENV=test; no warning suppression.
- [X] T024 Execute fresh guarded test preparation and PostgreSQL/Redis assertions via services in `specs/059-balanced-valuation-strategy/verification.json`; unavailable services must fail.
- [X] T025 Execute balanced-config, balanced-formula and balanced-outcomes through `scripts/agentflow_check.py` from `specs/059-balanced-valuation-strategy/verification.json`; use current receipts only, never infer success from earlier source inputs.
- [X] T026 Execute balanced-arithmetic, balanced-replay, architecture and tracked feedback-regression through `scripts/agentflow_check.py` from `specs/059-balanced-valuation-strategy/verification.json`; preserve inherited improper-list regressions without /tmp dependencies.
- [X] T027 Execute unit-profile once through `scripts/agentflow_check.py` using `scripts/test_profile.sh` from `specs/059-balanced-valuation-strategy/verification.json`; preserve profile discovery/sentinel guarantees and coverage infrastructure.
- [X] T028 Execute integration-profile once through `scripts/agentflow_check.py` using `scripts/test_profile.sh` from `specs/059-balanced-valuation-strategy/verification.json`; require existing browser preflight and actual browser checks; no additional historical CP1 coverage-report execution.
- [X] T029 Create only `specs/059-balanced-valuation-strategy/handoffs/develop.md` under 400 words with deltas, current command receipts/elapsed time, residual risks and precise QA guidance; reconcile every completed task with its named files and run `scripts/workflow_artifact_probe.py develop --readiness` after all non-gate work/checks is complete.
- [ ] T030 Independent QA [gate:qa] rerun all manifest checks without reuse, challenge every scenario and calibration boundary, and write `specs/059-balanced-valuation-strategy/qa-report.md` plus `specs/059-balanced-valuation-strategy/handoffs/qa.md`; only a terminal Verdict: PASS permits final review.
- [ ] T031 Final review [gate:review] assess alignment/invariants/exact edit scope/fresh QA evidence, run targeted uncovered-risk checks, and write `specs/059-balanced-valuation-strategy/review-report.md` plus `specs/059-balanced-valuation-strategy/handoffs/review.md`; terminal Verdict: PASS required; no merge/publication by implementation owner.

## Dependencies and Execution Order

Setup T001–T002 → foundation T003–T004 → US1 T005–T008 → US2 T009–T012 → US3 T013–T015 → US4 T016–T018 → design reconciliation T019–T020 → final developer checks T021–T028 → handoff/readiness T029 → independent QA T030 → review T031.

All US1/US2/US3 priorities are P1; US4 is P2. US2/US3 use US1's production module but isolated one-metric fixtures, so each has independent acceptance criteria. US4 needs complete rules/arithmetic; it reuses inherited replay. Tests must precede their implementation; already-supported inherited outcomes can stay green. No models/services/endpoints are created because shared in-memory types and engine are sufficient.

## Parallel Examples

After foundation, US1 T005 formula and T006 config tests can be authored independently. Within US2, T009 config and T010 outcome tests are separate files and can proceed together after US1; T011 waits for both. US3 has a shared-helper mutation and runs sequentially; no useful parallel implementation. US4 T016 replay and T017 scope evidence are independent files after US3. Only these six test-authoring tasks carry [P]. Shared balanced.ex/decimal_math.ex/scope allowlist edits are serialized. Parallel labels do not require multiple agents.

## Implementation Strategy

US1 is the minimal internal formula demonstration with explicit fixture rules. Incrementally validate US2 completeness, US3 arithmetic stress and US4 original reproduction. The task is complete only after all four stories, every developer check and both independent PASS verdicts; MVP is not authorization to skip remaining obligations. Do not activate arbitrary test rules as market calibration. Retain CP2 downstream strategy/config/quote/chart/order work and all CP3 boundaries in plan.md.
