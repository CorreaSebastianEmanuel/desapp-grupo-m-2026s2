# Tasks: Idempotent Catalog Ingestion

**Input**: `specs/057-idempotent-catalog-ingestion/` design artifacts.
**Prerequisites**: spec.md, plan.md, research.md, data-model.md, contracts/ingestion.md, verification.json; current TASK-005/TASK-055 feedback.
**Tests**: Required by FR-017 and repository rules. Author tests first, execute and record meaningful assertion failures before associated implementation; do not count missing file/compile errors alone as behavioral red evidence. All tasks stay unchecked in architecture.
**Organization**: One implementation owner; story-organized increments. Paths are repository-relative. `[P]` identifies independent files in the same ready phase, not permission to delegate.

## Phase 1: Setup

- [X] T001 Confirm toolchain/services and existing browser prerequisites with scripts/check_toolchain.sh, scripts/local_services.sh and scripts/test_profile.sh; record blockers in specs/057-idempotent-catalog-ingestion/handoffs/develop.md without enabling live source or changing provider defaults.
- [X] T002 Create independently authored five-league/two-season fixture expectations and barrier/failpoint helpers in test/support/ingestion_fixtures.ex; reuse existing provider/scraper fixture ports, keep expected rows/statuses independent of canonicalizer/reconciler, and include existing historical/account baselines.

## Phase 2: Foundational prerequisites

- [X] T003 Write failing database schema/uniqueness tests in test/football_market/catalog/ingestion/publication_test.exs for typed target FK/kind/scope constraints, per-provider target uniqueness, observation membership, rollback and the full exact/case/whitespace matrix; include valid final bound-team key swaps and invalid retained-team collisions before migrations.
- [X] T004 Create priv/repo/migrations/20261008000000_create_catalog_ingestion_tables.exs with scope/revision pointers, typed binding targets, append-only observation/membership structure and required restrictive/composite FKs per data-model.md; include target composite keys needed by bindings.
- [X] T005 Create priv/repo/migrations/20261008000100_make_team_business_keys_deferrable.exs with stored normalized columns and same-named initially-immediate constraints per ADR-0019; preserve other indexes/FKs and reversible migration definitions, verify existing Catalog constraint tests without running destructive rollback against shared services.
- [X] T006 Implement Ecto schemas/changesets in lib/football_market/catalog/ingestion/scope.ex, source_binding.ex, observation.ex and observation_binding.ex; validate count/evidence shape and keep observation/binding identities immutable through internal APIs; update lib/football_market/catalog/team.ex only if constraint handling requires it.

Foundation checkpoint: constraints/tests compile, configured positions are unchanged, new storage cannot accept cross-scope or dangling targets. Algorithm test failures remain until the associated story implementation.

## Phase 3: US1 — Publish One Complete Local Catalog (P1; MVP)

**Goal**: Fetch complete catalogs through the merged port and atomically publish coherent local records/evidence.
**Independent test**: Complete fixture import matches independent relationships/bindings/counts; invalid response or injected persistence failure publishes nothing; reads are local.

- [X] T007 [P] [US1] Write failing contract/basic reconciliation tests in test/football_market/catalog/ingestion/reconciliation_test.exs covering request/canonical vocabulary, both-key team adoption, missing league/season creation, invalid scope/position and duplicate/relationship whole-result rejection.
- [X] T008 [P] [US1] Extend test/football_market/catalog/ingestion/publication_test.exs with accepted initial/update counts, no-op timestamps, complete visibility and failures after each write class; independently seed prior catalog/evidence and assert no orphan hierarchy on first failure.
- [X] T009 [P] [US1] Write failing local search/filter/detail and unrelated-state tests in test/football_market/catalog/ingestion/isolation_test.exs before/during/after ingestion and source outage; assert zero provider calls from reads and unchanged historical/account data.
- [X] T010 [US1] Implement basic whole-candidate identity resolution/validation in lib/football_market/catalog/ingestion/reconciler.ex for bound entities, canonical league/season, unique two-key team adoption, configured positions and opaque provider-neutral new player identities; preserve omissions and final candidate business uniqueness independent of row order.
- [X] T011 [US1] Implement atomic publication in lib/football_market/catalog/ingestion/publisher.ex: transaction-only writes, scope advisory lock, conflict-safe shared canonical insert/re-read, deterministic row locking/revalidation, selective team-constraint deferral with forced immediate validation, typed bindings/membership, incoming-only counts and revision/evidence commit; expose failpoints only through test helpers, not public behavior.
- [X] T012 [US1] Implement lib/football_market/catalog/ingestion.ex internal request/import entry and lib/football_market/catalog/ingestion/outcome.ex basic success/failure structs per contracts/ingestion.md; capture revision before exactly one Providers.catalog/2 call, load existing positions, preserve selected offline source, never fetch inside transaction or publish late work.
- [X] T013 [US1] Run US1 focused failing-then-passing evidence for reconciliation/publication/isolation tests in test/football_market/catalog/ingestion/ and record command outcomes in specs/057-idempotent-catalog-ingestion/handoffs/develop.md; inspect publisher's write-set for financial/statistics/history exclusions.

## Phase 4: US2 — Repeat and Reconcile Without Duplicate Identities (P1)

**Goal**: Prove exact replay, qualified identities, explicit replacement and domain concurrency.
**Independent test**: Ten replays retain original reference; reorder/ref changes preserve identities; ambiguous mapping fails; overlapping revision 0/n publications converge or lose safely.

- [X] T014 [P] [US2] Write failing canonical equality tests in test/football_market/catalog/ingestion/canonical_test.exs with independent expected encoding: order/reference bijections, UTC instant normalization, provider/kind/scope/source case distinctions, fixture/live attribution and digest collision equality guard.
- [X] T015 [P] [US2] Write failing identity/update tests in test/football_market/catalog/ingestion/identity_test.exs for same-name qualified players, unbound name collision, source replacement mapping/new declarations, conflicting/duplicate/extra instructions, cross-season targets, transfer/name/position identity stability and all row-order permutations; include bound-team name/code exchanges and real final collisions.
- [X] T016 [P] [US2] Write failing ten-replay/later-unchanged/lost-reply tests in test/football_market/catalog/ingestion/replay_test.exs; assert exact acceptance/binding counts, original evidence with zero applied counts, replay after intervening updates and unchanged timestamps despite re-referencing.
- [X] T017 [P] [US2] Write failing independent-connection/barrier tests in test/football_market/catalog/ingestion/concurrency_test.exs: equivalent/different first imports at 0, overlap at n, same facts with different retrieval/fixture attribution, distinct seasons sharing a missing league, observer old-or-complete-new reads and unrelated scope integrity; use committed scoped fixtures with safe cleanup.
- [X] T018 [US2] Implement versioned resolved-fact canonicalization/equality in lib/football_market/catalog/ingestion/canonical.ex; hash fixed ordered safe arrays and retain full equality material, with retrieval/fixture attribution separate from football-row equality.
- [X] T019 [US2] Complete lib/football_market/catalog/ingestion/reconciler.ex trusted scoped correspondence/new-player validation and order-independent bound-first matching; reject ambiguous legacy/replacement sources without guessing and preserve same-season IDs while keeping other seasons distinct.
- [X] T020 [US2] Complete lib/football_market/catalog/ingestion/publisher.ex exact-replay-before-revision checks and original-reference convergence; capture absent revision=0 in lib/football_market/catalog/ingestion.ex, return concurrent-change for differing overlap without automatic retry, and record later unchanged observation without entity updates.
- [X] T021 [US2] Run focused canonical/identity/replay/concurrency checks in test/football_market/catalog/ingestion/ and record evidence in specs/057-idempotent-catalog-ingestion/handoffs/develop.md, including repeated controlled race outcomes and ten-redelivery assertions.

## Phase 5: US3 — Preserve Accepted State and Explain Outcomes (P1)

**Goal**: Preserve accepted state and expose safe lineage/count/recovery outcomes without false freshness/readiness.
**Independent test**: Older/equal/empty/omitted/conflicting/provider/persistence cases produce exact safe statuses and preserve prior state.

- [X] T022 [P] [US3] Write failing ordering/retention tests in test/football_market/catalog/ingestion/retention_test.exs for older observation, equal instant different facts/provider/fixture, future-clock cross-provider limitation, valid empty versus unknown/unsupported/incomplete, omitted records/bindings and unchanged historical relationships.
- [X] T023 [P] [US3] Write failing safe outcome tests in test/football_market/catalog/ingestion/outcome_test.exs for all TASK-016 categories/valid retry delays, malformed sensitive input/exception leakage, persistence/concurrent recovery, no automatic retries, late completion, historical versus applied counts, fixture attribution and live access blocker.
- [X] T024 [P] [US3] Write failing complete two-run deterministic matrix in test/football_market/catalog/ingestion/matrix_test.exs for all numbered scenarios across five leagues/two seasons; compare independent expected semantic evidence, normalize only generated UUID/local acceptance instants and assert zero external calls/credentials or statistics/quote readiness claims.
- [X] T025 [US3] Complete lib/football_market/catalog/ingestion/publisher.ex retrieved-time stale/equal conflict ordering after replay/revision checks, valid empty and additive omitted-state preservation, unchanged observations and immutable historical observation membership.
- [X] T026 [US3] Complete lib/football_market/catalog/ingestion/outcome.ex and lib/football_market/catalog/ingestion.ex safe category/delay/recovery/fixture propagation and exception templates; expose no partial counts, source text or secrets and preserve existing provider timeout/publication gates.
- [X] T027 [US3] Run retention/outcome/matrix acceptance tests in test/football_market/catalog/ingestion/ and record actual outcomes in specs/057-idempotent-catalog-ingestion/handoffs/develop.md; rerun US1/US2 focused regressions only where this story changes their behavior.

## Phase 6: Polish and cross-cutting verification

- [X] T028 Confirm every new test/football_market/catalog/ingestion/*_test.exs module has exactly one unit/integration profile tag and deterministic independent assertions per test/support/test_profile_audit.ex; retain actual browser E2E discovery and existing coverage infrastructure without adding the historical CP1 report.
- [X] T029 Reconcile specs/057-idempotent-catalog-ingestion/verification.json and quickstart.md against final paths, commands and all FR/SC/scenario assertions; review final diff for Catalog-only write boundaries, no source activation, no new endpoints or permission changes, and resolve any actual design delta before final checks.
- [X] T030 Execute toolchain, service-preflight, format, compile and whitespace manifest checks through scripts/agentflow_check.py; retain current receipts referenced from specs/057-idempotent-catalog-ingestion/handoffs/develop.md, diagnose after two unchanged failures.
- [X] T031 Execute every focused acceptance and provider-contract check in specs/057-idempotent-catalog-ingestion/verification.json through scripts/agentflow_check.py after all source/design edits; assert the five-league/two-season two-run matrix, ten replays, concurrency and unchanged unrelated state before QA.
- [X] T032 Execute unit-profile and integration-profile checks once each from specs/057-idempotent-catalog-ingestion/verification.json through scripts/agentflow_check.py; no extra all-tests/coverage-report invocation, preserve actual browser regression and fresh service availability.
- [X] T033 Create concise specs/057-idempotent-catalog-ingestion/handoffs/develop.md under 400 words with deltas, check IDs/evidence references, elapsed check time, risks and exact QA guidance; reconcile every completed task with its named files and current passing receipts before development readiness.
- [ ] T034 Independent QA [gate:qa] rerun verification.json independently, challenge every scenario/rule and inspect diff; create specs/057-idempotent-catalog-ingestion/qa-report.md and handoffs/qa.md ending the report exactly Verdict: PASS only after acceptance evidence passes.
- [ ] T035 Final review [gate:review] inspect code/architecture and fresh QA evidence, run targeted risk checks, and create specs/057-idempotent-catalog-ingestion/review-report.md plus handoffs/review.md with one Backlog impact entry and terminal Verdict: PASS only if ready for human review.

## Dependencies and execution order

Setup T001–T002 -> foundation T003–T006 -> US1 T007–T013 -> US2 T014–T021 -> US3 T022–T027 -> owner polish/checks T028–T033 -> QA T034 -> review T035. US2/US3 test against seeded catalogs independently but share the publisher, so implementation is sequential. All tests precede the behavior they verify; T003 schema tests precede migrations, story tests precede story implementation. T007–T009 depend on foundation; T014–T017 depend on US1; T022–T024 depend on US2. Tasks sharing reconciler/publisher are never parallel.

Within ready test groups, examples: US1 T007/T008/T009 target separate files; US2 T014/T015/T016/T017 target separate files; US3 T022/T023/T024 target separate files. All use completed T002 helpers. `[P]` means those tasks can be composed independently by the sole owner, without additional agent sessions.

## Implementation strategy

MVP: foundation + US1 demonstrates one complete offline atomic import and local reads. Continue through US2 retry/identity/concurrency and US3 preservation/outcomes; MVP is not sufficient for TASK-018 acceptance. Do not publish intermediate increments. Full acceptance requires every T001–T033 complete with applicable check receipts; only T034/T035 may remain unchecked at developer readiness, exactly mapped to qa/review in task_stages. QA/review remain separate independent sessions owned by Agentflow, not this architecture session. No commit/push/PR/merge is part of these tasks.
