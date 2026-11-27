# Tasks: Valuation Strategy Configuration and Versioning

**Input**: design documents in `specs/061-valuation-strategy-versioning/`.
**Prerequisites**: spec.md, plan.md, research.md, data-model.md, contracts/, verification.json; completed TASK-023/024.
**Tests**: mandatory under FR-016/repository rules. Write assertions before corresponding source behavior; record expected red, implement the diagnosed behavior before retrying, preserve attempt history. No unchanged failure retries or fabricated source changes.
**Organization**: four P1 stories then owner checks/downstream gates. `[P]` means separate file authoring after prerequisites; one implementation owner. Paths are repository-relative within plan.md's exact 33-file code inventory.

## Phase 1: Setup

- [X] T001 Reconcile the 33-path boundary and 24 scenarios in `specs/061-valuation-strategy-versioning/plan.md` and `specs/061-valuation-strategy-versioning/contracts/acceptance-map.md`; preserve approved summation, explicit helpers and TASK-026 retention/calibration boundary.
- [X] T002 Execute initial toolchain/services IDs from `specs/061-valuation-strategy-versioning/verification.json` via `scripts/agentflow_check.py`; retain actual guarded PostgreSQL/Redis readiness evidence and current operator targets, without reset/weakened sandbox checks.

## Phase 2: Foundation

- [X] T003 Build deterministic helpers in `test/support/valuation_configuration_case.ex`: complete rules/local facts, canonical numeric assertions, message barriers; guarded unique test-schema migration/dynamic-Repo ownership with matching search paths, distinct backends and fresh child BEAM application probes. Parent retains only trusted test-generated original envelopes in ignored temporary inputs; assert child status/results, restore each process Repo and stop clients without fixture deletion/disabled guards.

**Foundation checkpoint**: no production test options. New ExUnit modules each carry exactly one existing unit/integration tag; audited discovery needs no profile/CI edits.

## Phase 3: US1 — Save and Inspect Complete Rules (P1, MVP)

**Goal**: explicit immutable exact rules without activation.
**Independent test**: save both formulas, retrieve every field, restart fresh application instances and compare canonical evidence without providers.

### Tests first

- [X] T004 [P] [US1] Add pure validation assertions in `test/football_market/valuation/configurations/rules_test.exs`: two identities, all position groups, zero/all-zero requirements, metric/reference union and strict nonempty proper mapping; reject unknown/extra/malformed/duplicate/improper structures, caller requirements/modules and invalid numeric values before writes.
- [X] T005 [P] [US1] Add typed-codec unit assertions in `test/football_market/valuation/configurations/codec_test.exs`: integer/Decimal distinction, equivalent Decimals/negative zero, signed fractions/huge coefficients/extreme exponents under varied contexts; reject nonfinite/malformed values, bad schema and unsafe atom/module/string coercion.
- [X] T006 [P] [US1] Add integration storage/read/list tests in `test/football_market/valuation/configurations/storage_test.exs` and initial restart round-trips in `test/football_market/valuation/configurations/durability_test.exs`: full groups/unused mapping, existing positions, distinct UUID saves, no activation, tied-time identity ordering, unknown/empty/outage distinctions and zero partial writes.
- [X] T007 [P] [US1] Add Repo/SQL guard assertions in `test/football_market/valuation/configurations/immutability_test.exs`: unused/inactive version identity/formula/rules/time update/delete/truncate/no-op rejection, protected anchor/history, restrictive references/reused UUIDs, disconnected/duplicate history insert and unsupported write-isolation rejection with full rollback snapshots; assert named guard errors after successful fixture insertion, never missing-table failures. Cover shared migration behavior before T010 and US4.2.

### Implementation

Execute the preceding new assertions once to establish the intended missing-behavior failure before implementing this story; after a diagnosed red, make the real source correction before retrying.

- [X] T008 [US1] Implement reviewed code-only dispatch in `lib/football_market/valuation/configurations/registry.ex` and rule derivation in `lib/football_market/valuation/configurations/rules.ex`; extract reusable rule-only references/mapping validation in `lib/football_market/valuation/request.ex`, preserving existing behavior without fake subject/week/defaults.
- [X] T009 [US1] Implement exact typed schema encoding/decoding in `lib/football_market/valuation/configurations/codec.ex` per data-model.md: full canonical integer/Decimal/group/mapping retention, whitelist decode and visible storage corruption without numeric ceilings/football fallback.
- [X] T010 [US1] Add complete schema/guards in `priv/repo/migrations/20261013000000_create_valuation_configurations.exs` and Ecto schemas in `lib/football_market/valuation/configurations/version.ex`, `lib/football_market/valuation/configurations/selection_lock.ex`, `lib/football_market/valuation/configurations/selection_change.ex`: seeded protected singleton only, restrictive FKs, UPDATE/DELETE/TRUNCATE protection, volatile READ COMMITTED-only predecessor insertion/order after lock and stable indexes. Run guarded migration; no preset/published-migration edit.
- [X] T011 [US1] Implement create/get/list/active/history in `lib/football_market/valuation/configurations.ex` and `lib/football_market/valuation/configurations/store.ex`: validate before writes, transactional key-share position checks, UUID save, full codec recovery, consistent version/selection snapshots and not-found/no-active versus visible storage failure; no provider/unrelated writes.
- [X] T012 [US1] Run rules-codec, versions and current durability IDs from `specs/061-valuation-strategy-versioning/verification.json` through `scripts/agentflow_check.py`; require exact fresh-runtime canonical readback and guards before recording story completion.

**Checkpoint**: independently inspectable internal storage MVP, no production calibration/selection. All stories still required for TASK-025.

## Phase 4: US2 — Select New Calculation Rules (P1)

**Goal**: single immediate selection, durable append-only history and expected-identity conflicts.
**Independent test**: activate/switch/restore A/B/C, stale/no-op requests and competing committed transactions.

### Tests first

- [X] T013 [P] [US2] Add lifecycle assertions in `test/football_market/valuation/configurations/activation_test.exs`: explicit nil expectation, switch/restore across formulas, unknown/malformed/unsupported target, stale-before-no-op, matching no-op without change/version, predecessor/target/time history and save without selection effects.
- [X] T014 [P] [US2] Add committed race assertions in `test/football_market/valuation/configurations/concurrency_test.exs`: private initially empty namespace, competing first activations/different targets, distinct backend IDs/barriers, complete old/new reads, post-lock order and tied times; delayed expected A succeeds after A→B→A without revision semantics.
- [X] T015 [US2] Extend `test/football_market/valuation/configurations/durability_test.exs` with activate/switch/restore then fresh BEAM reload of exact identity/history, including time ties/provider outage, with no cached selection.

### Implementation

Execute the preceding new assertions once to establish the intended missing-behavior failure before implementing this story; after a diagnosed red, make the real source correction before retrying.

- [X] T016 [US2] Implement activation transaction in `lib/football_market/valuation/configurations/store.ex`: validate IDs, lock singleton, compare expectation before no-op, require existing supported target, append one complete change/commit; map named conflicts safely and propagate unexpected failures.
- [X] T017 [US2] Expose explicit `activate(target, expected)` in `lib/football_market/valuation/configurations.ex` with change-or-nil response; no optional expectation/revision/scheduling/version edits.
- [X] T018 [US2] Run selection/current durability IDs from `specs/061-valuation-strategy-versioning/verification.json` via `scripts/agentflow_check.py`; require real commits/independent connections and no partial/duplicate changes.

**Checkpoint**: selection/history survive restart, inactive originals remain inspectable and the ABA limit is tested.

## Phase 5: US3 — Bind One Immutable Version per Calculation (P1)

**Goal**: fix saved rules before facts; return UUID with inherited score/evidence.
**Independent test**: balanced 1.000000/2.000000, approved concentrated/split position scores 2.000000/4.000000 and in-flight A fixation despite B activation.

### Tests first

- [X] T019 [P] [US3] Add managed integration assertions in `test/football_market/valuation/configurations/managed_test.exs`: active/explicit inactive use, UUID/formula/full evidence, exact fixture scores and trace/message barrier after resolution before facts; activate B separately, assert original A completes and next call uses B.
- [X] T020 [P] [US3] Add no-score assertions in `test/football_market/valuation/configurations/outcomes_test.exs`: every rule/module override, no active, malformed/unknown UUID, unavailable formula/storage, unknown player, empty week, unmapped position/unknown required metric including zero weights; validation before facts and distinct inherited errors/no writes.
- [X] T021 [P] [US3] Add scope assertions in `test/football_market/valuation/configurations/scope_test.exs`: actual SQL/provider/external/event/job traces for reads/save/activate/evaluate; reads/evaluation zero mutations, save only version, activate only change, visible real read failure and no catalog/fact/quote/financial side effects.

### Implementation

Execute the preceding new assertions once to establish the intended missing-behavior failure before implementing this story; after a diagnosed red, make the real source correction before retrying.

- [X] T022 [US3] Define ManagedResult/ManagedDescriptor in `lib/football_market/valuation/managed_types.ex`, fixed-version evaluation in `lib/football_market/valuation/managed.ex` and `evaluate_managed/2` plus managed production guidance in `lib/football_market/valuation.ex`; reconstruct existing Definition/Request from one saved version, preserve common DTOs/formulas and release selection transaction before facts.
- [X] T023 [US3] Run managed ID from `specs/061-valuation-strategy-versioning/verification.json` via `scripts/agentflow_check.py`; assert fixture/outcome/in-flight coherence and zero-write snapshots before proceeding; T021 comprehensive effect tracing is executed by the architecture check at T030/T035.

**Checkpoint**: inactive explicit use never activates; no result store/price conversion is added.

## Phase 6: US4 — Recover Original Rules and Reproduce Scores (P1)

**Goal**: original saved identity/full rules and authoritative original membership determine replay.
**Independent test**: retain A, switch B, accept late facts and restart; original replay stays 1.000000 and mismatches fail.

### Tests first

- [X] T024 [P] [US4] Add replay assertions in `test/football_market/valuation/configurations/replay_test.exs`: UUID/formula/full config/reference/requirements/mapping agreement including absent/unused entries, switching/late facts/current affiliations, missing originals/unsupported formulas, tampered raw/derived/score evidence and malformed envelope/nested lists; zero substitution/activation.
- [X] T025 [P] [US4] Add canonical assertions in `test/football_market/valuation/configurations/canonical_test.exs`: at least 20 deterministic multi-metric/group/mapping permutations, same rules/scores/common evidence apart from UUID/time, integer/Decimal tags, equal-score different-rules mismatch and stable timestamp tie order; keep vectors in memory.
- [X] T026 [US4] Extend `test/football_market/valuation/configurations/durability_test.exs` with externally held original envelope replay in fresh BEAM applications after committed switching/late facts for both formulas; extend `test/football_market/valuation/configurations/scope_test.exs` with replay no-provider/no-write assertions, preserving earlier cases without production descriptor storage.

### Implementation

Execute the preceding new assertions once to establish the intended missing-behavior failure before implementing this story; after a diagnosed red, make the real source correction before retrying.

- [X] T027 [US4] Implement original-envelope lookup/full canonical rule comparison in `lib/football_market/valuation/managed.ex` and `replay_managed/1` in `lib/football_market/valuation.ex`; delegate inherited authoritative fact/derived/score replay, preserve missing/unsupported/mismatch/storage distinctions and never consult activation/mutate evidence.
- [X] T028 [US4] Run replay/completed durability IDs from `specs/061-valuation-strategy-versioning/verification.json` via `scripts/agentflow_check.py`; require original membership after restart/late facts, tamper failures and ≥20 canonical permutations, plus US4.2 protection already tested in T007/T012.

**Checkpoint**: TASK-026 still owns production descriptor retention/quote integrity.

## Phase 7: Polish, Owner Checks and Independent Gates

- [X] T029 Extend exact inventory/role-separated AST assertions in `test/football_market/valuation/configurations/scope_test.exs` before legacy allowance changes: 33 paths, preserved pure engine, only persistence uses Repo/write/time, no arbitrary atom/module/executable decode; legacy allowances and negative exclusions remain.
- [X] T030 Update precise active-feature inventories in `test/football_market/valuation/scope_test.exs`, `test/football_market/statistics/scope_test.exs`, `test/football_market/providers/scope_test.exs` to admit only planned lifecycle paths without loosening old engine/formula purity/unrelated-path rejection; run architecture/inherited scope assertions.
- [X] T039 Correct schema scope only in `test/football_market/catalog/constraints_test.exs`, `test/football_market/accounts/persistence_test.exs`, `test/football_market/catalog/player_catalog_index_test.exs`, `test/football_market/catalog/ingestion/publication_test.exs`; retained private fixtures must not duplicate default-schema metadata assertions. Run legacy-metadata and the unchanged full integration-profile through the helper.
- [X] T031 Reconcile implemented interfaces and every FR/SC/scenario in `specs/061-valuation-strategy-versioning/contracts/configuration-context.md`, `specs/061-valuation-strategy-versioning/contracts/acceptance-map.md`, `specs/061-valuation-strategy-versioning/quickstart.md`, `specs/061-valuation-strategy-versioning/verification.json`; finish source/design edits before final receipts, preserving scope/calibration/CP2 boundaries.
- [X] T032 Run final toolchain/format/compile/fresh services IDs via `scripts/agentflow_check.py` with `specs/061-valuation-strategy-versioning/verification.json`; migrated PostgreSQL/Redis must pass. Initial evidence is stale after implementation; preserve failures and correct actual causes before retry.
- [X] T033 Run complete audited unit-profile once against final inputs via `scripts/agentflow_check.py` with `specs/061-valuation-strategy-versioning/verification.json`; retain current successful receipt, no historical CP1 coverage run.
- [X] T034 Run complete audited integration-profile once against final inputs via `scripts/agentflow_check.py` with `specs/061-valuation-strategy-versioning/verification.json`, including actual Chromium and all durable/race assertions; unavailable service/browser fails, never skip.
- [X] T035 Run remaining final rules-codec/versions/selection/managed/replay/durability/architecture/legacy-metadata IDs via `scripts/agentflow_check.py` with `specs/061-valuation-strategy-versioning/verification.json`; explicit reuse only for intact current developer receipts, never services, with no later edits or duplicate unchanged full-profile runs.
- [X] T036 Create sole developer handoff `specs/061-valuation-strategy-versioning/handoffs/develop.md` under 400 words with deltas/check evidence/elapsed time/risks/QA guidance; reconcile named artifacts and complete T001–T035 only on real work/checks, then run `scripts/workflow_artifact_probe.py develop --readiness` before QA.
- [ ] T037 [gate:qa] Independent QA reruns every check without reuse, challenges all 24 scenarios/invariants and writes `specs/061-valuation-strategy-versioning/qa-report.md` under 900 words and `specs/061-valuation-strategy-versioning/handoffs/qa.md` under 250 words; terminal `Verdict: PASS` only on independent acceptance evidence.
- [ ] T038 [gate:review] Final review inspects code/diff/architecture/fresh QA, runs targeted uncovered-risk checks and writes `specs/061-valuation-strategy-versioning/review-report.md` under 600 words with exactly one Backlog impact entry and `specs/061-valuation-strategy-versioning/handoffs/review.md` under 250 words; terminal `Verdict: PASS` only when ready for human merge.

## Dependencies and Execution Order

```text
T001–T003 → US1 (T004–T012) → US2 (T013–T018) → US3 (T019–T023) → US4 (T024–T028)
All stories → T029–T031 + T039 schema regressions → T032–T035 → T036 → T037 QA → T038 review
```

US4 explicit-version replay builds on US1/US3; its acceptance includes US2 switching, so use the shown delivery order. Independent testing means each increment has deterministic fixtures, not removal of lifecycle dependencies. T007 defines all shared migration guard assertions before T010. T006/T015/T026 extend one durability file sequentially; T021/T026/T029 extend scope sequentially. T008–T011 and T016–T017 have source dependencies and remain sequential. Parallel test authoring still precedes corresponding implementation/red runs.

All T001–T036 and T039 must complete before QA. Only T037/T038 map in task_stages; no implementation/test deferral. QA/review use fresh downstream sessions. No commit/push/publication/merge is part of these tasks.

## Parallel Examples per Story

- **US1**: after T003, author T004 rules, T005 codec, T006 storage/durability and T007 guards in separate files before T008–T011.
- **US2**: after US1, author T013 lifecycle and T014 races independently; T015 follows prior durability changes. Activation source tasks are sequential.
- **US3**: after US2, author T019 binding, T020 outcomes and T021 effects independently before T022.
- **US4**: after US3, author T024 replay and T025 canonical independently; T026 extends shared files before T027.

These are opportunities for the single owner's separate-file work, not requests to spawn agents or concurrently mutate global fixture/tracing state. Global trace/committed tests and profiles execute serially.

## Implementation Strategy

MVP is US1 intentional durable rules/readback without selection. Validate internally, then complete US2 selection, US3 binding and US4 replay. All four P1 stories/owner checks are required; do not stop at MVP. Existing profiles discover tests automatically. No CI/coverage expansion, production numerical preset, public administration, quote/job/ranking implementation. TASK-026 must retain/protect complete version/evidence binding and obtain approved calibration before a market demo; passing fixtures do not establish full CP2 delivery.
