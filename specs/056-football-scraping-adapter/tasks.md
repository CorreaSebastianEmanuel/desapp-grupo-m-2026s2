# Tasks: Football Scraping Adapter

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/, source-assessment.md, fixture-matrix.md and authoritative TASK-021 feedback.
**Tests**: Mandatory test-first under constitution/user request. Write and run each new behavior's assertions to demonstrate failure before implementation; then make them pass. Existing passing regressions are not a red-test requirement. Keep checks running through scripts/agentflow_check.py for canonical receipts after final source edits.
**Paths**: Repository-relative. No source contact, actual live activation, web endpoint or publication. One implementation owner; parallel markers describe independent work, not authorization to spawn agents.

## Phase 1: Setup

- [X] T001 Review merged provider types/Runner and current feedback, establish offline toolchain/dependency prerequisites from `specs/056-football-scraping-adapter/quickstart.md`, and record any implementation delta there without reopening settled technology.
- [X] T002 Create literal synthetic inventory/cases/documents/expected scaffold in `test/fixtures/scraping/inventory.exs`, `test/fixtures/scraping/cases.exs`, `test/fixtures/scraping/documents.exs`, `test/fixtures/scraping/expected.exs` and load-only helper `test/support/providers/scraping_fixture_data.ex`; classify observed shapes versus hypothetical roster/witness/semantics, retain explicit scenario IDs and safe byte fingerprints, never generate expected facts from production code.

## Phase 2: Foundational

Goal: runnable source-shaped harness through existing Providers with one deadline. Complete T001–T005 before stories.

- [X] T003 Write failing harness/safety assertions in `test/football_market/providers/scraping/safety_test.exs` for malformed source JSON/HTML, unknown selectors, zero-test refusal, attempted network/credential use and persistence/web/financial dependencies in new adapter modules; tag offline suites :unit and future isolation :integration for existing profile discovery.
- [X] T004 Create `test/scraping_adapter_offline.exs` to load existing provider contract modules/support plus Jason ebin without starting Phoenix/Ecto/services, support assessment/catalog/performances/safety/deadline/matrix/equivalence/repeat selectors, and minimally register suites; add bootstrap/data exclusions in `mix.exs` only where needed. Require actual assertions and nonzero tests, not unconditional success; later story tasks extend selectors.
- [X] T005 Define synchronous internal port in `lib/football_market/providers/scraping/transport.ex`, fixed-key source decoding/observation validation skeleton in `lib/football_market/providers/scraping/source.ex`, and existing Adapter entrypoint in `lib/football_market/providers/scraping.ex`; preserve Request/Runner/Validator and whole-result publication, without implementing story behavior before its failing tests.

## Phase 3: US1 — Know Whether a Source Can Be Used (P1, MVP)

Goal: honest assessment and refusal before retrieval. Independent test: assessment selector proves scoped simulated access, default actual denial and no misleading promotion; all US1.1–US1.4 expectations in fixture-matrix.md.

- [X] T006 [US1] Add access-default/scoped/invalidation/assessment-inventory cases and independently authored expectations to `test/fixtures/scraping/cases.exs`, `test/fixtures/scraping/expected.exs`, `test/fixtures/scraping/inventory.exs`, covering missing/expired/withdrawn evidence, incomplete conditions, exact operation/season, invalid-input precedence and switch-only denial.
- [X] T007 [US1] Write failing gate/admission tests in `test/football_market/providers/scraping/assessment_test.exs` through Providers for all US1 scenarios, revisions/expiry between portions and before publication, unapproved redirect destinations and simultaneous simulated callers sharing limits; assert zero fetch on rejection and no actual-assessment promotion after fixture success.
- [X] T008 [US1] Implement assessment indexing/validation/current-revision reader in `lib/football_market/providers/scraping/assessment.ex` and actual deny-only `lib/football_market/providers/scraping/disabled_transport.ex`; actual unresolved limits/permission/witnesses remain blockers, no network client or config bypass.
- [X] T009 [US1] Implement explicit `lib/football_market/providers/scraping/fixture_transport.ex` with read-only safe documents, controlled elapsed time, current-assessment checks and atomic test-state admission across simulated callers, then integrate assessment-before-fetch/recheck-before-publication in `lib/football_market/providers/scraping.ex` and `lib/football_market/providers/scraping/source.ex`; no redirects/retries/detached work. Caller cannot select a hypothetical fixture as live data.
- [X] T010 [US1] Execute assessment check and reconcile `specs/056-football-scraping-adapter/source-assessment.md` with actual blockers, five league/two-season operation rows, nine metric states and exact scope/evidence; only mark complete on passing `python3 scripts/agentflow_check.py assessment`.

## Phase 4: US2 — Obtain Complete Catalog Facts (P1)

Goal: complete synthetic catalog translation with truthful provenance. Independent test: ten scoped examples, valid empty, absent/unsupported scope, same-name distinct players and all integrity failures via catalog selector. Depends on US1 admission/source harness.

- [X] T011 [US2] Author catalog-scopes/empty/integrity source documents and independent outcomes in `test/fixtures/scraping/documents.exs`, `test/fixtures/scraping/cases.exs`, `test/fixtures/scraping/expected.exs`, `test/fixtures/scraping/inventory.exs`; include five leagues × two seasons, hypothetical complete-roster witnesses, wrong-season response, duplicate bindings/records, unresolved roles, missing/nonterminal/repeated portions and complete empty versus missing scope.
- [X] T012 [US2] Write failing request-to-result catalog assertions in `test/football_market/providers/scraping/catalog_test.exs` checking exact football facts/current affiliations, requested scope at every portion, list duplicate rejection, completeness witnesses, fixture/provenance qualification and no schedule-only catalog success.
- [X] T013 [US2] Implement catalog discovery/required-roster accumulation in `lib/football_market/providers/scraping/source.ex` and fixed hypothetical roster decoding/canonical mapping/candidate construction in `lib/football_market/providers/scraping/translator.ex`; preserve lists and exact scope, use existing Validator for final closure and duplicates, fail whole request if a witness/roster is absent. No real FotMob roster schema/coverage claim.
- [X] T014 [US2] Execute catalog check, verify independently testable scope and error outcomes, and keep `specs/056-football-scraping-adapter/contracts/source-mapping.md` aligned with any source-path delta; only mark complete on passing `python3 scripts/agentflow_check.py catalog`.

## Phase 5: US3 — Obtain Honest Dated Player Performances (P1)

Goal: complete eligible match facts, truthful required/optional fields and historical positions. Independent test: performances selector checks US3.1–US3.6 and completed-empty appearances. Depends on US1; T013's shared source/translator files must be settled before edits here.

- [X] T015 [US3] Author performance-eligibility/metrics-tristate/historical-affiliation/required-facts/unsupported-performance/attribution-events examples in `test/fixtures/scraping/documents.exs`, `test/fixtures/scraping/cases.exs`, `test/fixtures/scraping/expected.exs`, `test/fixtures/scraping/inventory.exs`; cover ten scopes, inclusive/time-zone bounds, statuses, explicit empty appearances, all nine zero/unknown/invalid metrics, transfers, own goal/keeper change, missing positionId with present usualPosition and direct verified versus unverified event semantics.
- [X] T016 [US3] Write failing whole-operation assertions in `test/football_market/providers/scraping/performances_test.exs` for literal expected facts/errors, eligibility precedence, current versus event affiliation/position, missing minutes/unmapped position, 0/>120 minutes, duplicate player-match pairs, wrong match/league/season, incomplete discovery/details and explicit empty-versus-missing playerStats.
- [X] T017 [US3] Implement observed schedule/match/playerStats decoding and performance accumulation in `lib/football_market/providers/scraping/source.ex` and `lib/football_market/providers/scraping/translator.ex`; fixed metric dictionary, explicit position map, per-metric evidence, required-fact rejection and existing Validator. No usualPosition fallback, event counter reconstruction or team-total substitution; known unavailable capability fails before fetch.
- [X] T018 [US3] Execute performances check and reconcile precise verified/hypothetical mappings in `specs/056-football-scraping-adapter/contracts/source-mapping.md`; only mark complete on passing `python3 scripts/agentflow_check.py performances` and leave actual source-assessment coverage blocked.

## Phase 6: US4 — Verify Replacement and Failures Offline (P2)

Goal: independent equivalence, safe failures, one bounded read and unchanged local state. Independent test: two identical offline corpus runs plus runtime cancellation/state isolation. Depends on US2/US3.

- [X] T019 [US4] Extend `test/fixtures/scraping/cases.exs`, `test/fixtures/scraping/documents.exs`, `test/fixtures/scraping/expected.exs`, `test/fixtures/scraping/inventory.exs` with literal source-errors/shared-deadline/equivalence expectations and fixture-only correspondence/reference source inputs; cover all eight categories, secret sentinels, challenge/redirect refusal, default/custom/equality/late boundaries and huge positive timeout overrides without altering the original 217 provider cases or fingerprints.
- [X] T020 [P] [US4] Write failing safe-error/no-side-effect dependency assertions in `test/football_market/providers/scraping/safety_test.exs`, including safe retry guidance, invalid delay, source payload/exception/URL leakage and later-portion category retention; refute all forbidden module dependencies.
- [X] T021 [P] [US4] Write failing shared-deadline tests in `test/football_market/providers/scraping/deadline_test.exs` for controlled timing plus real production Runtime worker termination/no late publication, after-read assessment revocation, multiple portions, translation/validation elapsed time and both operations with 4294968000/10000000000000 overrides.
- [X] T022 [P] [US4] Write failing operation equivalence assertions in `test/football_market/providers/scraping/equivalence_test.exs` comparing both operations with existing FixtureSourceA/FactOracle through Providers; author bijections/reference inputs literally in test-only code, allow distinct qualified provenance, forbid source-specific consumer branches.
- [X] T023 [P] [US4] Write failing matrix/fingerprint/scenario coverage/repeat assertions in `test/football_market/providers/scraping/matrix_test.exs` for all 17 scenario aliases, five leagues/two seasons, nine metric states, two fixed-clock outcomes, no external calls/credentials and unchanged actual readiness assessment.
- [X] T024 [P] [US4] Write failing runtime state-isolation tests in `test/football_market/providers/scraping/isolation_test.exs` with service-readiness assertion, exact catalog/statistics snapshots and local-read equality before/after every fixture success/failure/deadline; instrument source calls and require zero calls caused by local reads; :integration tag, no weakened original isolation test.
- [X] T025 [US4] Complete safe failure/deadline/admission behavior in `lib/football_market/providers/scraping/source.ex`, `lib/football_market/providers/scraping/fixture_transport.ex`, `lib/football_market/providers/scraping.ex` after T020–T024 fail; preserve one Runner deadline and cancellation, no internal retry/fallback or detached transport task. Harden synthetic inventory loading/repeat orchestration in `test/support/providers/scraping_fixture_data.ex` and `test/scraping_adapter_offline.exs` to satisfy matrix/equivalence assertions.
- [X] T026 [US4] Execute safety/deadline/matrix/equivalence/repeat/isolation checks and existing provider-contract regression using `specs/056-football-scraping-adapter/verification.json`; require preflight before isolation and record completion only after checks pass, preserving all merged contract expectations.

## Phase 7: Polish and Cross-Cutting Concerns

Every implementation/developer-check task T001–T029 must finish before QA; only T030/T031 are deferrable gates.

- [X] T027 Run formatting, warnings-as-errors compilation, service-preflight, unit/integration profiles and workflow-controls checks from `specs/056-football-scraping-adapter/verification.json`; fix failures within plan boundary, preserve profile guarantees and the existing CI coverage infrastructure and finish code/design edits before final checks; reuse only current passing development receipts and rerun stale evidence.
- [X] T028 Reconcile completed files, all FR/SC mappings and USn.m examples in `specs/056-football-scraping-adapter/verification.json`, `specs/056-football-scraping-adapter/fixture-matrix.md` and `specs/056-football-scraping-adapter/quickstart.md`; verify product invariant/no-write boundaries and explicit CP2 blocked dependency evidence, without changing required behavior or creating a live-ready claim.
- [X] T029 Write sole developer handoff under 400 words at `specs/056-football-scraping-adapter/handoffs/develop.md` with deltas/check IDs/blockers and QA guidance; finish final source edits, rerun every manifest check to current fingerprints, mark implementation/check tasks complete, and pass `python3 scripts/workflow_artifact_probe.py develop --readiness` before independent QA.
- [ ] T030 Independent QA [gate:qa] rerun all manifest checks, challenge source-shape/completeness/assessment/equivalence oracles and current feedback, produce `specs/056-football-scraping-adapter/qa-report.md` and `specs/056-football-scraping-adapter/handoffs/qa.md` ending the report exactly `Verdict: PASS` only when all criteria hold; no implementation edits.
- [ ] T031 Final review [gate:review] inspect current independent QA, scope/invariants/CP2 blockers and evidence freshness; run targeted checks for uncovered risks and produce `specs/056-football-scraping-adapter/review-report.md` and `specs/056-football-scraping-adapter/handoffs/review.md` ending the report exactly `Verdict: PASS` only when accepted; no merge/publication or implementation edits.

## Dependencies and Execution Order

T001 → T002 → T003 → T004 → T005 → US1 (T006–T010) → US2 (T011–T014) → US3 (T015–T018) → US4 (T019–T026) → T027 → T028 → T029 → T030 → T031. US3 conceptually only needs US1, but its shared source/translator edits are sequenced after US2 to avoid conflicts. Each story's fixtures/tests precede its behavior implementation; do not mark failing tests complete as verified delivery. All four stories are required for task completion.

Within US4, T020–T024 may run independently after T019, on separate files, before T025. They are the only [P] tasks. No parallel modifications to shared fixtures or translator/source files.

## Parallel Examples Per Story

US1: author T007 after T006; then T008 → T009. No parallel candidate because admission changes share state.
US2: T011 → T012 → T013 → T014; fixture and translator edits are sequential.
US3: T015 → T016 → T017 → T018; no shared-file parallelism with US2.
US4: after T019, independently author safety (T020), deadline (T021), equivalence (T022), matrix (T023) and isolation (T024) assertions; join before T025. One code owner executes the plan.

## Implementation Strategy

MVP is US1: honest blocked readiness and independently runnable admission examples, not a usable live feed. Then catalog, performances and independent failure/equivalence/isolation evidence. Demo only labelled offline examples. No partial set satisfies FR-013/014 or full TASK-055 acceptance. Do not implement ingestion/jobs/freshness/valuation/chart/order work to compensate for source gaps; do not commit/push/publish during implementation.

## Requirement/Scenario Traceability

US1: FR-002/003/004/015; SC-001/007; US1.1–US1.4, T006–T010.
US2: FR-001/005/006/009; SC-002; US2.1–US2.3, T011–T014.
US3: FR-006/007/008; SC-002/003; US3.1–US3.6, T015–T018.
US4: FR-001/009/010/011/012/013/014; SC-004/005/006; US4.1–US4.4, T019–T026.
Cross-cutting FR-015/SC-007 and CP1/CP2 safeguards: T027–T031. Executable mapping is verification.json; QA must challenge mapping adequacy independently.

## User-authorized verification corrections

- [X] T032 Implement explicit development-only current-receipt reuse and two-failure stopping with elapsed time/evidence in `scripts/agentflow_check.py` and shared validation in `scripts/agentflow_verification.py`; keep independent QA execution.
- [X] T033 Generalize generated-report exclusions in `scripts/coverage_report.sh` while preserving source/design snapshot detection; cover both behaviors and independent execution/retry limits in `tests/test_agentflow_delivery.py`; align the existing exclusion assertions in `test/ci/coverage_report_contract_test.exs` and its exact path in `test/football_market/statistics/scope_test.exs`.
- [X] T034 Remove cp1-coverage from this task's manifest, align the plan/guide/current feedback, and document stage-aware reuse/stop guidance in `docs/AGENT_VERIFICATION.md`, `docs/AGENT_CONTEXT_POLICY.md` and `.specify/workflows/desapp-delivery/workflow.yml`.
- [X] T035 Execute `python3 -m unittest tests.test_agentflow_delivery tests.test_agentflow tests.test_workflow_token_audit test.scripts.workflow_artifact_probe_test`; leave TASK-055 paused, with full remaining manifest/readiness and independent gates still pending.

## Final-publication correction (current human feedback)

- [X] T036 Add six assessment regressions and deadline-precedence assertions in `test/football_market/providers/scraping/assessment_test.exs`; preserve and execute `specs/056-football-scraping-adapter/handoffs/qa-evidence/publication-gate.exs` unchanged via the publication-gate manifest check.
- [X] T037 Add optional publication guard in `lib/football_market/providers/adapter.ex`, invoke it after successful final validation in `lib/football_market/providers/runner.ex`, and capture/recheck assessment revision in `lib/football_market/providers/scraping.ex` and permit only Adapter/Runner in the active-feature inventory of `test/football_market/statistics/scope_test.exs`; preserve existing adapters, safe errors and cancellation.
- [X] T038 Refresh all manifest checks, reconcile named artifacts and sole `specs/056-football-scraping-adapter/handoffs/develop.md`, and pass development readiness; independent QA/review remain pending.

## CI dependency correction (current human feedback)

- [X] T039 Add bounded exact Redis image/port/health readiness assertions in `test/ci/quality_baseline_contract_test.exs`, preserving discovery and all remaining prohibitions; execute ci-service-contract to demonstrate the missing dependency.
- [X] T040 Provision the pinned Redis service in `.github/workflows/quality-baseline.yml`, update `test/ci/fixtures/quality-baseline.sha256`, permit that exact workflow in `test/football_market/statistics/scope_test.exs`, and align `README.md`, `specs/056-football-scraping-adapter/plan.md` and `specs/056-football-scraping-adapter/quickstart.md`.
- [X] T041 Execute ci-service-contract, ci-baseline and every applicable manifest check, reconcile named artifacts and refresh sole `specs/056-football-scraping-adapter/handoffs/develop.md`; pass development readiness and leave independent QA/review pending.
