# Tasks: Scheduled Synchronization Jobs

**Input**: `specs/063-scheduled-synchronization-jobs/` design artifacts; TASK-019; ADR-0025.
**Tests**: Required by FR-016 and repository rules. Write each behavioral test FIRST and demonstrate an assertion failure before its implementation; missing dependency/compilation is setup failure, not sufficient RED evidence. Use a minimal compiling seam where needed. Do not mark tests complete until required assertions pass.
**Organization**: US1/US2/US3 are all P1; implement in listed order. Paths are repository-relative. All checkboxes start unchecked; only downstream QA/review have gate tags.

## Phase 1: Setup

- [X] T001 Verify pinned toolchain and service/browser prerequisites from specs/063-scheduled-synchronization-jobs/quickstart.md; retain actual command outcomes for the eventual handoffs/develop.md and do not run destructive service resets.
- [X] T002 Add and resolve open-source Oban ~> 2.24.2 in mix.exs and mix.lock; verify the locked version's transaction/migration/worker APIs compile with the pinned toolchain before relying on them.
- [X] T003 Build controlled clock, offline fixture registry, independent expected outcomes and distinct-connection/disposable-runtime harness in test/support/synchronization/case.ex, test/support/synchronization/clock.ex, test/support/synchronization/fixtures.ex and test/fixtures/synchronization/expected.exs; no live transport or secret configuration.

## Phase 2: Foundational (blocks stories)

- [X] T004 Write RED migration and authority-boundary assertions in test/football_market/synchronization/migration_test.exs and test/football_market/synchronization/scope_test.exs: active uniqueness, retained history, no finance/statistics writes, prefix-aware isolated schemas, exact production inventory and unknown-feature rejection.
- [X] T005 Add exact active-feature inventory allowances and negative regressions in test/football_market/providers/scope_test.exs, test/football_market/statistics/scope_test.exs and test/football_market/market/scope_test.exs; preserve legacy inventories and issuance's approved config/config.exs hash unchanged.
- [X] T006 Create prefixed Oban migration priv/repo/migrations/20261015000000_add_oban.exs and ledger migration priv/repo/migrations/20261015000100_create_synchronization_ledgers.exs with partial active-scope uniqueness, run/attempt/trigger/schedule/occurrence constraints and restrictive history references per data-model.md; make T004 migration assertions pass.
- [X] T007 Implement durable schemas in lib/football_market/synchronization/run.ex, lib/football_market/synchronization/attempt.ex, lib/football_market/synchronization/trigger.ex, lib/football_market/synchronization/schedule.ex and lib/football_market/synchronization/occurrence.ex; prepared deliveries have no fake numbered attempt and terminal history has no automatic pruning.
- [X] T008 Write RED default/configuration validation cases in test/football_market/synchronization/policy_test.exs, then implement validated disabled-by-default synchronization and manual Oban test configuration in config/synchronization.exs, config/runtime.exs and config/test.exs with production clock in lib/football_market/synchronization/clock.ex; do not modify config/config.exs or auto-start imports.

## Phase 3: US1 — Request and inspect (P1, MVP)

**Goal**: Durable explicit asynchronous fixture requests and safe inspection.
**Independent test**: terminate requester after commit, execute pending fixture work and inspect safe acceptance plus usable local catalog (US1.1–5).

- [X] T009 [P] [US1] Write RED input/canonical identity tests in test/football_market/synchronization/input_test.exs: normalized scopes, missing sources, invalid policy, full comparison after digest, instruction-order equivalence and non-secret fixture identity.
- [X] T010 [P] [US1] Write RED admission/inspection tests in test/football_market/synchronization/request_test.exs and test/football_market/synchronization/inspection_test.exs for US1.1–4, changed/unchanged/empty/replay counts, durable triggers, pagination/validation, store unavailable, requester termination and safe redaction.
- [X] T011 [US1] Write RED optional receipt/fence and legacy-caller tests in test/football_market/catalog/ingestion/delivery_receipt_test.exs, including revoked/scope-mismatched contexts, rollback and atomic replay acceptance; then create priv/repo/migrations/20261015000200_create_catalog_delivery_receipts.exs and lib/football_market/catalog/ingestion/delivery_receipt.ex.
- [X] T012 [US1] Extend only lib/football_market/catalog/ingestion.ex and lib/football_market/catalog/ingestion/publisher.ex to validate optional delivery_context and atomically confirm safe Outcome under receipt row lock for publication/replay; preserve revision, stale/conflict, provider and canonical-delivery behavior; pass T011 and retained ingestion regressions.
- [X] T013 [US1] Implement closed source registry resolution and versioned non-secret canonical inputs in lib/football_market/synchronization/input.ex; reject unapproved refs/modules and invalid trusted instructions before any executable work; pass T009.
- [X] T014 [US1] Implement scope-locked transaction admission, full equality/coalescing, conflict, durable trigger associations, prepared receipt and transactional Oban insertion in lib/football_market/synchronization/store.ex; expose request_catalog/get_run/list_runs through lib/football_market/synchronization.ex with safe typed errors and bounded inspection; pass T010 without retrieval in admission.
- [X] T015 [US1] Write RED normal execution/guard teardown assertions in test/football_market/synchronization/concurrency_test.exs, then implement lib/football_market/synchronization/execution_guard.ex with dedicated connection scope/global-slot locks, monitored cleanup and finite timeout; never leave locks in a pool.
- [X] T016 [US1] Implement one-shot lib/football_market/workers/catalog_sync.ex and supervised runtime wiring in lib/football_market/application.ex; claim numbered attempt once, resolve pinned inputs/access and delegate ingestion outside admission/publication bookkeeping transactions; record only confirmed safe success or safe terminal failure; no exception/secret payload in Oban arguments/errors.
- [X] T017 [US1] Complete test/football_market/synchronization/integrity_test.exs and test/support/synchronization/runtime_probe.ex RED-first for US1.5, actual loopback list/detail status/header/body/auth/error assertions and PostgreSQL/listener readiness; make probe and US1 targeted tests pass while asserting zero provider calls from reads and unchanged financial/statistical/quote rows.

## Phase 4: US2 — Controlled schedule (P1)

**Goal**: Durable UTC recurrence with latest-only catch-up and permanent occurrence associations.
**Independent test**: controlled due instants and restart show one latest occurrence per enabled scope, no implicit imports and preserved accepted work (US2.1–5).

- [X] T018 [P] [US2] Write RED deterministic scheduling tests in test/football_market/synchronization/scheduler_test.exs: all US2 cases, five missed instants, exact restart boundary, invalid/impossible cadence, no pre-enable backfill, durable terminal/coalesced dedup, blocked supersession, equivalent-then-failed occurrence and disable/re-enable generation.
- [X] T019 [US2] Implement pure UTC five-field recurrence validation/latest-due calculation and per-scope schedule configuration in lib/football_market/synchronization/scheduler.ex; reuse Oban parser and preserve enablement generation across ordinary restart; definition replacement starts a new interval without altering accepted runs.
- [X] T020 [US2] Extend lib/football_market/synchronization/store.ex for atomic schedule-generation locking, unique due association and scope admission, latest pending cursor and compressed supersession audit; incompatible work remains pending without a per-occurrence execution backlog.
- [X] T021 [US2] Implement supervised boot/15-second tick in lib/football_market/synchronization/dispatcher.ex and wire through lib/football_market/application.ex and lib/football_market/synchronization.ex; disabled/unconfigured scopes create no scheduled work, current config is validated explicitly, and store failure remains visible; pass T018.

## Phase 5: US3 — Safe recovery and duplicate prevention (P1)

**Goal**: Finite attempts, persisted waits and safe recovery without duplicate publication.
**Independent test**: ten competing callers plus killed workers/runtime, provider delays and final-attempt lost completion retain exactly bounded execution and confirmed history (US3.1–8).

- [X] T022 [P] [US3] Extend RED test/football_market/synchronization/concurrency_test.exs for ten independent-backend mixed triggers, trigger-independent equivalence, incompatible source/fixture/instructions, scope isolation, retry-wait activity and bounded global execution; verify sleeping waits release slots.
- [X] T023 [P] [US3] Extend RED test/football_market/synchronization/policy_test.exs and create test/football_market/synchronization/retry_test.exs for 3-attempt budget, 60/300-second minima, rounded provider retry guidance, custom finite policies, every non-retryable category, unknown errors, same-run numbered history and deliberate new manual work.
- [X] T024 [P] [US3] Write RED test/football_market/synchronization/recovery_test.exs for queued/waiting/executing recovery across actual worker/Oban/dispatcher and disposable BEAM termination; crash before/after publication and during completion on attempt three, failed bookkeeping, guard connection loss, receipt fencing and zero fabricated successes; reuse independently authored expected results.
- [X] T025 [P] [US3] Extend RED test/football_market/synchronization/integrity_test.exs for stable-reference fixture/instruction drift, missing config, current access revocation, no source fallback, absent/cleared/reconnected isolated Redis, redacted histories/errors/job args and exact unchanged market/quote/statistics state for all triggers/retries.
- [X] T026 [US3] Implement closed outcome classification, finite run budget and persisted UTC retry deadlines in lib/football_market/synchronization/policy.ex; interrupted begun attempts count, provider delay overrides only when longer, unknown failures terminate; pass policy tests.
- [X] T027 [US3] Extend lib/football_market/synchronization/store.ex and lib/football_market/workers/catalog_sync.ex for atomic retry history/next delivery insertion, immutable accepted input verification, current access revalidation, duplicate delivery claim prevention and no active run mutation; pass T022/T023/T025.
- [X] T028 [US3] Implement lib/football_market/synchronization/recovery.ex and integrate lib/football_market/synchronization/dispatcher.ex: acquire execution locks, finalize confirmed receipts without retrieval, revoke orphan fences, preserve known retry deadlines, record interruption and enforce exhaustion without fourth ingestion; repair unbegun delivery bookkeeping without consuming fictional attempts; pass T024.
- [X] T029 [US3] Finalize durable safe inspection in lib/football_market/synchronization/store.ex and lib/football_market/synchronization.ex with confirmed acceptance/historical versus applied counts, coalesced origins, remaining wait, exhausted/unconfirmed recovery guidance and retained prior attempts; extend test/football_market/synchronization/inspection_test.exs first for new branches.
- [X] T030 [US3] Complete adversarial test/football_market/synchronization/scope_test.exs and test/support/synchronization/runtime_probe.ex RED-first for cross-trigger/retry access/finance boundaries, actual runtime restart and absent Redis HTTP reads; pass every scenario in specs/063-scheduled-synchronization-jobs/quickstart.md without marking downstream QA/review complete.

## Phase 6: Polish and developer verification

All source, design and manifest edits must finish before final checks. Only checkbox updates are allowed afterward without invalidating receipts. Runtime and service checks always execute. Do not run duplicate unfiltered/full-coverage suites.

- [X] T031 Reconcile implementation inventory, exact scope allowances, requirement/scenario map and executable command coverage in specs/063-scheduled-synchronization-jobs/plan.md, specs/063-scheduled-synchronization-jobs/quickstart.md and specs/063-scheduled-synchronization-jobs/verification.json; ensure each new test has exactly one unit/integration module tag and every requested artifact exists.
- [X] T032 Execute manifest toolchain, services and service_clients checks through scripts/agentflow_check.py after final edits; fail closed on unavailable dependencies and retain check receipts under specs/063-scheduled-synchronization-jobs/handoffs/ without secrets.
- [X] T033 Execute manifest format and compile checks through scripts/agentflow_check.py; fix real issues before final evidence and retain receipts under specs/063-scheduled-synchronization-jobs/handoffs/.
- [X] T034 Execute manifest unit and integration profiles once each through scripts/agentflow_check.py, including retained provider/scraper/ingestion/market regressions and every new assertion; retain receipts under specs/063-scheduled-synchronization-jobs/handoffs/ and no historical CP1 coverage report.
- [X] T035 Execute manifest runtime_http and whitespace checks through scripts/agentflow_check.py; require readiness plus real HTTP assertions and owned-resource cleanup in test/support/synchronization/runtime_probe.ex; retain receipts under specs/063-scheduled-synchronization-jobs/handoffs/.
- [X] T036 Write concise specs/063-scheduled-synchronization-jobs/handoffs/develop.md with actual command outcomes, RED evidence references, elapsed failure evidence if any, changed boundaries and residual risks; run scripts/workflow_artifact_probe.py develop --readiness after reconciling every completed artifact task, leaving only T037/T038 pending.
- [ ] T037 [gate:qa] Independent QA reruns verification.json without development receipt reuse, challenges all 18 scenarios and writes specs/063-scheduled-synchronization-jobs/qa-report.md plus specs/063-scheduled-synchronization-jobs/handoffs/qa.md with terminal Verdict: PASS only on independently verified success.
- [ ] T038 [gate:review] Final review inspects implementation and fresh QA evidence, runs targeted checks for uncovered risks, assesses backlog impact and writes specs/063-scheduled-synchronization-jobs/review-report.md plus specs/063-scheduled-synchronization-jobs/handoffs/review.md with terminal Verdict: PASS only if ready for human review/merge.

## Dependencies and execution order

Setup T001–T003 -> foundation T004–T008 -> US1 T009–T017 -> US2 T018–T021 -> US3 T022–T030 -> developer T031–T036 -> independent QA T037 -> final review T038. Test additions precede the corresponding implementations; shared test files are extended in later phases only after prior phase completion. No user story bypasses foundational work. US2 and US3 integrate US1's admission and receipt mechanism; their acceptance scenarios remain independently reproducible with fixtures. T036 completes its handoff and all developer tasks before readiness; T037/T038 are the only task_stages entries.

## Parallel opportunities

Within US1, T009 and T010 author separate test files after the shared harness; both precede T013/T014. Within US2, T018 can exercise multiple independently specified scope/time cases in separate processes, but schedule/store implementation remains sequential because it shares state and files. Within US3, T022–T025 author independent test files after US2; T027/T028 must follow these tests and coordinate shared Store/dispatcher edits. `[P]` indicates eligible independent work, not authorization to start additional agents or overlap the sole implementation owner.

## Implementation strategy

MVP is US1 explicit offline request/inspection with durable receipt and local reads, validated before scheduling. Then add controlled recurrence, then complete recovery/adversarial guarantees. MVP alone does not satisfy TASK-019: all US3 guards and checks are required before QA. This stage implements all stories; publication remains workflow-owned. CP2 charts, browser E2E and conditional orders retain their own tasks. No commits, pushes, PRs or merges in the implementation stage; publication remains workflow-owned after both independent PASS gates.
