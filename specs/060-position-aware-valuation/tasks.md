# Tasks: Position-aware Valuation Strategy

**Input**: specs/060-position-aware-valuation/{spec,plan,research,data-model,quickstart}.md, contracts/, verification.json; approved TASK-024 Feedback 1.
**Prerequisites**: Completed TASK-022; existing engine and exact helper. TASK-023 is not a prerequisite. Reuse settled context and ADR-0020/0021/0022.
**Tests**: Mandatory under FR-012 and repository rules. Write assertions before related source corrections; inherited conformance can already pass. Observe genuine red failures for the missing scorer, then correct the corresponding source. No artificial red, skipped tests or third identical failing attempt.
**Organization**: Five story increments; one implementation owner. Common engine entities/interfaces are reused; there are no endpoint/model/migration tasks to invent.

## Format and path conventions

Every item uses `- [ ] Tnnn [P?] [USn?] description with exact repository-relative paths`. [P] permits independent file edits only after stated prerequisites; it does not authorize parallel shared service/global-trace tests or extra agents. All code/test changes remain the exact 13 paths in plan.md. Only T028/T029 are downstream verification gates; every other task must finish before QA.

## Phase 1: Setup

- [X] T001 Validate pinned tools and actual service readiness via scripts/check_toolchain.sh and guarded MIX_ENV=test mix test.prepare plus mix infrastructure.verify; confirm Node24/Playwright Chromium prerequisites in scripts/test_profile.sh, and record safe setup evidence references in specs/060-position-aware-valuation/handoffs/develop.md without running complete profiles yet.
- [X] T002 Create deterministic explicit four-group definitions/requests and historical fixture helpers in test/support/position_aware_case.ex using test/support/valuation_case.ex and existing Catalog/Statistics APIs; keep raw records and expected scores distinct, without presets or production arithmetic as an oracle.

## Phase 2: Foundational boundaries

Goal: protect the complete active inventory before adding production behavior. T003's missing-module assertion may remain expected red until T007; completion here means the test and bounded allowances are authored, not that the final feature passed.

- [X] T003 Add test-first exact 13-file active inventory, unchanged 058/059 allowances, unknown-feature/unplanned-path negatives and pure scorer AST assertions in test/football_market/valuation/position_aware/scope_test.exs; observe genuine missing-scorer failure and retain bounded evidence for the actual correction in T007.
- [X] T004 Add only position_aware.ex to the production inventory in test/football_market/valuation/scope_test.exs and the exact active-060 plan paths to test/football_market/statistics/scope_test.exs and test/football_market/providers/scope_test.exs; preserve every earlier inventory and cross-layer exclusion, with no broad wildcard allowance.

## Phase 3: US1 — Historical position rules (P1, MVP)

Goal: explicit position-specific scoring for single-position histories with the common workflow. Independent test: all four role scores and all 36 group/metric pairs match independently calculable expectations, with historical grouping and minutes independence.

### Tests first

- [X] T005 [P] [US1] Write unit tests in test/football_market/valuation/position_aware/config_test.exs for identity/version, complete nonempty four-group maps, all supported metrics, finite signed/fractional/zero weights, canonical derived requirements and direct malformed config rejection; cover duplicate/list/improper collections and invalid Decimal fields before production validation.
- [X] T006 [P] [US1] Write database-backed integration tests in test/football_market/valuation/position_aware/formula_test.exs for US1.1–US1.5 through prepare/evaluate/authenticated score/replay, center-back/fullback mapping, affiliation/minutes invariance and complete descriptor rules; add baseline 1/6 rounded-feature and two-group tiny-product assertions before implementing the shared exact summation path.

### Implementation and checkpoint

- [X] T007 [US1] Implement FootballMarket.Valuation.Scorer callbacks in lib/football_market/valuation/position_aware.ex: exact map shape and finite leaves before traversal, all-four-group ordered requirements including zero weights, present-group required-feature validation and one flattened DecimalMath.weighted call returning an unrounded Decimal; reuse existing final rounding/evidence/authentication and reject invalid direct feature views safely.
- [X] T008 [US1] Run the config/formula files in test/football_market/valuation/position_aware/config_test.exs and test/football_market/valuation/position_aware/formula_test.exs with warnings-as-errors after T007; record observed red-to-green outcome and confirm all US1 independent expected scores in specs/060-position-aware-valuation/handoffs/develop.md.

## Phase 4: US2 — Mixed historical positions (P1)

Goal: retain every historical role, independent cap and non-diluting sum. Independent test: mixed 2.500000, concentrated 2.000000 versus split 4.000000, and mapped fresh 2.000000 versus original replay 3.000000.

- [X] T009 [P] [US2] Add integration assertions for all US2.1–US2.5 in test/football_market/valuation/position_aware/mixed_test.exs, including independent saturation, absent measured groups with retained rules, known-zero midpoint group at zero minutes and historical remap original replay; assert every row belongs exactly once.
- [X] T010 [US2] Run test/football_market/valuation/position_aware/mixed_test.exs, complete any test-exposed populated-group iteration gap in lib/football_market/valuation/position_aware.ex only after its assertion is present, and record independently matching mixed/cap/non-dilution scores; if T007 already conforms, retain it without gratuitous source edits.

## Phase 5: US3 — Exactly configured statistics (P1)

Goal: distinguish known zero, absence, unknowns and invalid configuration. Independent test: precise no-score kinds/details for each US3 case, with zero-weight requirements and no defaults.

- [X] T011 [P] [US3] Extend test/football_market/valuation/position_aware/config_test.exs with the full FR-003 direct callback and engine-definition malformed matrix: missing/extra/overall groups, unsupported metrics/options, struct/map/list tails, duplicate pair collections, text/boolean/float/nonfinite and missing/extra/malformed Decimal fields; ordinary validation must not be callback_exception.
- [X] T012 [P] [US3] Add integration tests for US3.1–US3.7 in test/football_market/valuation/position_aware/outcomes_test.exs: group-specific nil versus known values, zero-weight entries, removal without affecting other roles, all-zero/empty/not-found distinctions, invalid-config precedence, exact requirement/reference union including absent groups, duplicate required metrics and missing/duplicate/conflicting mappings.
- [X] T013 [US3] Conform safe config/feature validation in lib/football_market/valuation/position_aware.ex to the failing assertions from T011/T012, if any, preserving existing Request/Scoring validation/error taxonomy and no common-engine edits; reject malformed containers before enumeration and never convert duplicate supplied collections into maps.
- [X] T014 [US3] Run test/football_market/valuation/position_aware/config_test.exs and test/football_market/valuation/position_aware/outcomes_test.exs; assert ordered group/metric/performance details and absence of partial score for every negative case, recording results in specs/060-position-aware-valuation/handoffs/develop.md.

## Phase 6: US4 — Exact reproduction (P2)

Goal: exact signed arithmetic and original-rule authoritative replay. Independent test: US4.1–US4.9 expected values, at least 20 input permutations, complete canonical evidence and explicit unavailable/inconsistent/unsupported outcomes.

- [X] T015 [US4] Extend test/support/position_aware_case.ex with a deterministic independent integer-rational feature/final-rounding generator and permutation builders; calculate expectations without DecimalMath/scorer functions, keep vectors in memory or ignored tmp, and expose reproducible case counts/checksum summaries rather than committed expanded datasets.
- [X] T016 [P] [US4] Add integration arithmetic assertions in test/football_market/valuation/position_aware/arithmetic_test.exs for US4.1–US4.3/US4.8–US4.9: rounded 1/6 and 1/128, signed within/cross-group ties, unsigned rounded zero, no product/subtotal rounding, huge within/across-group cancellation and fractional exponent residuals under varied ambient Decimal contexts using the independent T015 oracle.
- [X] T017 [P] [US4] Add integration tests for US4.4–US4.7 in test/football_market/valuation/position_aware/replay_test.exs: complete descriptor and absent-group rule binding, late arrival versus original selection, changed weights/references/mappings/absent-group rules, altered raw+derived Prepared facts rejected before callback, duplicate/missing originals and unsupported definitions, plus at least 20 multi-performance/group/metric/mapping permutations with identical canonical evidence.
- [X] T018 [US4] Run test/football_market/valuation/position_aware/arithmetic_test.exs and test/football_market/valuation/position_aware/replay_test.exs; correct any scorer-only test-exposed gap in lib/football_market/valuation/position_aware.ex after the failing assertion, keeping one exact global sum and the inherited authoritative replay boundary, and retain oracle source/count/checksum evidence references in specs/060-position-aware-valuation/handoffs/develop.md.

## Phase 7: US5 — Explicit historical week (P2)

Goal: strategy choice never changes common selected local facts or ordinary failures. Independent test: UTC half-open bounds, equivalent offsets, year crossing, subject/season isolation and count0/2/huge cases.

- [X] T019 [P] [US5] Add database-backed integration tests for US5.1–US5.4 in test/football_market/valuation/position_aware/selection_test.exs, exercising stored kickoff boundaries versus arrival/completion, equivalent offsets, year crossing, same-instant distinct matches, exact subject/season isolation, every invalid week class, not-found and accepted large-count saturation through production evaluation/scoring/replay.
- [X] T020 [P] [US5] Extend test/football_market/valuation/position_aware/scope_test.exs with actual SQL read/no-write capture, disabled-provider and event-call assertions across success and representative failure paths, unchanged original rows and an isolated dynamic-repo ownership failure that remains an infrastructure exception; clean up trace/env handlers without stopping shared services.
- [X] T021 [US5] Run test/football_market/valuation/position_aware/selection_test.exs and test/football_market/valuation/position_aware/scope_test.exs serially where global tracing is used; verify membership/error/effect assertions and record results in specs/060-position-aware-valuation/handoffs/develop.md, preserving Statistics semantics unchanged.

## Phase 8: Polish, developer checks and downstream verification

All stories and source/design changes must finish before final checks. If a common-engine defect outside the inventory is found, document evidence and amend the plan/ADR before any scope expansion; do not silently edit extra production modules.

- [X] T022 Reconcile actual assertion names and all 30 scenarios against specs/060-position-aware-valuation/contracts/acceptance-map.md, verify spec/plan/tasks/verification.json alignment and quickstart.md commands, and confirm new modules have exactly one unit/integration profile tag with no skips or default fixture exclusions.
- [X] T023 Run final toolchain, format and warnings-as-errors compile manifest IDs through scripts/agentflow_check.py after all edits; inspect bounded failures and retain genuine receipts referenced in specs/060-position-aware-valuation/handoffs/develop.md.
- [X] T024 Execute fresh services and all targeted manifest IDs position-config/position-formula/position-outcomes/position-arithmetic/position-replay/position-selection/architecture/valuation-regression via scripts/agentflow_check.py; preserve current receipts under specs/060-position-aware-valuation/handoffs/ and no weakening of checks.
- [X] T025 Execute unit-profile via scripts/agentflow_check.py once on final inputs; require the audited complete profile with no skip and record its receipt reference in specs/060-position-aware-valuation/handoffs/develop.md.
- [X] T026 Execute integration-profile via scripts/agentflow_check.py once on final inputs, including actual Chromium/browser coverage and audited complete receipt; preserve coverage/CI infrastructure and add no default historical CP1 report to specs/060-position-aware-valuation/verification.json.
- [X] T027 Finalize specs/060-position-aware-valuation/handoffs/develop.md with deltas, command receipt references, totals, oracle count/checksum and limitations; mark T001–T027 complete only with required work/evidence, then run scripts/workflow_artifact_probe.py develop --readiness before independent QA.
- [ ] T028 [gate:qa] Independent QA reruns every manifest check without developer reuse, challenges all scenario mappings and independent arithmetic/effect evidence, and writes specs/060-position-aware-valuation/qa-report.md and handoffs/qa.md ending with Verdict: PASS only on independent success.
- [ ] T029 [gate:review] Final review assesses spec/plan/tasks alignment, exact approved sum, scope/invariants/checkpoint coverage and fresh QA evidence, runs targeted checks for uncovered risks, and writes specs/060-position-aware-valuation/review-report.md and handoffs/review.md ending with Verdict: PASS only on success.

## Dependencies and execution order

```text
T001 → T002 → T003 → T004
                    → (T005 || T006) → T007 → T008 [US1]
                    → T009 → T010 [US2]
                    → (T011 || T012) → T013 → T014 [US3]
                    → T015 → (T016 || T017) → T018 [US4]
                    → (T019 || T020) → T021 [US5]
T008 + T010 + T014 + T018 + T021 → T022 → T023 → T024 → T025 → T026 → T027 → T028 → T029
```

All stories require T001–T004. US2–US5 conformance requires the US1 scorer but each has its own independent fixtures/assertions and does not require another story's output evidence. Default one-owner execution follows displayed phases/P1 before P2; arrows for each story mean entry after its earlier foundation/scorer prerequisite, not concurrent source mutations. T011 edits the config file after T005; T020 edits scope after T003; T015 edits support after T002. T007/T010/T013/T018 share one source file and execute sequentially. Per story, failing new assertions precede any correction. Existing engine conformance tests can pass immediately; no redundant engine change is planned.

## Parallel examples by story

- **US1**: After foundations, draft T005 config and T006 formula tests in their separate files; T007 waits for both.
- **US2**: T009 mixed assertions can be drafted alongside T011 invalid config assertions after T008; T010/T013 shared scorer edits remain sequential. No independent second mixed source task exists.
- **US3**: Draft T011 config and T012 outcomes concurrently; T013 waits for both.
- **US4**: Once T015 helper exists, draft T016 arithmetic and T017 replay concurrently; execute context-changing tests without leaking Decimal state.
- **US5**: Draft T019 selection and T020 scope tests concurrently; run shared tracing/service operations serially.

These are file-level opportunities for the owner, not an instruction to spawn agents or duplicate profiles.

## Implementation strategy

MVP is US1: single-position configured scoring and common authenticated replay, after foundation and its focused checks. It is an internal validation increment, not publication or full TASK-024 completion. Continue through mixed roles, completeness/validation, adversarial arithmetic/replay and selection/effect conformance before final verification.

Every final manifest command is mandatory for development. Explicit --reuse is allowed only for eligible unchanged development evidence; services are always fresh. QA never reuses developer checks. Avoid unchanged full-profile repetition; changes/stale evidence justify rerunning affected required checks. T028/T029 alone are deferred in task_stages; publication/merge is not a task in this stage.

Total: 29 tasks; US1=4, US2=2, US3=4, US4=4, US5=3; setup/foundation=4; cross-cutting/developer=6; downstream gates=2. No behavior, persistence model, endpoint, authentication, chart, quote or calibration task is added outside the strategy boundary.
