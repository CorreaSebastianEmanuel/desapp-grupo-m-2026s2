# Tasks: Initial Player Token Issuance

**Input**: Design documents from `specs/062-initial-player-token-issuance/`.
**Prerequisites**: spec.md, plan.md, research.md, data-model.md, contracts/initialization.md, traceability.md, verification.json and current TASK-028 feedback if present.
**Tests**: Required by FR-013, constitution and explicit test-first stage instruction. Each test task is written and run to demonstrate an expected behavioral failure before the corresponding implementation; do not substitute a broken harness/compile error for a behavioral red test. Use narrow development probes while coding; final manifest checks run once after all source/design edits. Every ExUnit module has exactly one profile tag and no skipped scenarios.
**Organization**: Story phases are independently testable with controlled fixtures. All three stories and cross-cutting checks must finish before QA/publication; US1 is only an internal demo MVP.
**Format**: `- [ ] Tnnn [P?] [USn?] Description with path`. Paths are repository-relative. [P] indicates independent file work after phase prerequisites; one implementation owner still executes the work.

## Phase 1: Setup

- [X] T001 Create `test/support/market_case.ex` with exact plan inventory, existing catalog/user fixtures, test-only Decimal balance sentinels, guarded unique market test namespace, migration-prefix clients, distinct-backend barriers, isolated legacy snapshot fixtures and fresh-BEAM evidence reader; reuse established patterns without changing existing helpers or deleting immutable shared rows.

## Phase 2: Foundational

Blocking prerequisite: pure input/error contract before story services.

- [X] T002 Write and demonstrate failing unit cases in `test/football_market/market/input_test.exs` for singleton designation, UUIDs, assertion-only map, canonical integer quantity/exact price, float/unknown-option rejection and deterministic typed errors; include invalid_input/transaction_in_progress in the contract expectations and cover absent/duplicate/ambiguous designation and do not intern arbitrary atoms.
- [X] T003 Implement the pure validators and safe error types in `lib/football_market/market/input.ex` and `lib/football_market/market/error.ex` to satisfy T002; represent canonical 100 and Decimal 1 without clock, Repo, providers, valuation or role checks.

## Phase 3: US1 — Establish Initial Inventory (P1, MVP)

Goal: Complete first issuance and original-evidence retrieval for eligible existing players.
Independent test: Initialize separate fresh player IDs; assert 100 tokens each, sole original owner, exact quote/value, unchanged sentinels/accounts, durable linked rule/date evidence and reload in a fresh application.

### Tests first

- [X] T004 [P] [US1] Write failing integration/contract cases in `test/football_market/market/issuance_test.exs` for US1 scenarios 1–4: first-issued outcome/projection, independent players and season-specific identities, display-name refresh without remint, exact 1/100 credits, every other owner zero, unchanged accounts/balance sentinels and no purchase/sale effects; assert nested initialization rejects before writes and top-level success is committed; run without provider/statistics/active strategy.
- [X] T005 [P] [US1] Write failing persistence cases in `test/football_market/market/storage_test.exs` for required facts, FKs, unique player issuance/initial quote, canonical quantity/value, first-commit recipient ownership (including wrong-owner direct inserts), same-player quote linkage and ordinary UPDATE/DELETE/TRUNCATE rejection for quotes/issuance/recipient/protected lock; assert retained originals after failures without disabling production guards. Include current feedback regression: migrate with an explicit target prefix while the connection search_path points at a populated source schema; assert target singleton and unchanged source rows.
- [X] T006 [P] [US1] Write failing committed reload cases in `test/football_market/market/durability_test.exs` using `test/support/market_case.ex`: stop/reconnect owned Repo, fresh BEAM reads exact original IDs/dates/rule/value and fixed recipient; no duplicate allocation, no inherited process state or provider/configuration prerequisite.

### Implementation

- [X] T007 [US1] Create `priv/repo/migrations/20261014000000_create_initial_player_issuance.exs` for seeded lock, immutable first-recipient singleton, shared market_quotes, market_holdings and market_issuances; add named uniqueness/canonical/FK/linkage/first-commit-original-owner/append-only protections from data-model.md, qualifying all function/table references by migration prefix; insert no user, player or quote presets. Qualify the seeded lock INSERT with the explicit Ecto migration prefix independently of connection search_path.
- [X] T008 [US1] Create `lib/football_market/market/initialization_lock.ex`, `lib/football_market/market/initial_recipient.ex`, `lib/football_market/market/holding.ex`, `lib/football_market/market/quote.ex` and `lib/football_market/market/issuance.ex` with required typed fields, restrictive associations and named changeset constraint mapping; retain only original evidence and derive exact inventory value.
- [X] T009 [US1] Implement first-issuance persistence in `lib/football_market/market/store.ex`: top-level READ COMMITTED transaction with nested-initialization rejection, initialization-then-player locks, existing user validation, empty-history prerequisite, recipient fixation, one DB UTC sample, quote/holding/issuance insertion and durable coherent evidence retrieval; no floating arithmetic or account/financial ledger mutation.
- [X] T010 [US1] Create trusted façade in `lib/football_market/market.ex` and fail-closed empty designation default in `config/config.exs`; implement only initialize_player/1, assertion-map initialize_player/2 and get_initial_issuance/1 per contracts/initialization.md; capture designation once and return explicit issued/not_initialized/missing-player outcomes; make T004–T006 pass without routes/Mix tasks/jobs/ingestion hooks.

Checkpoint: Fresh eligible-player issuance works and original evidence survives reload. Do not publish a partial feature.

## Phase 4: US2 — Repeat or Resume Safely (P1)

Goal: Preserve one issuance and current financial state under retries, interruptions and concurrency.
Independent test: Committed distinct connections compete, transfer and insert quotes; retry returns original issuance without changes, pre-commit failures rollback, lost response after commit does not remint.

### Tests first

- [X] T011 [P] [US2] Write failing cases in `test/football_market/market/retry_test.exs` for US2 scenarios 1/4/5: repeat invocations with no token mutation, fixture transfers 80/20 and 0/100, exact unchanged balances/all quotes/current fixture quote, retained initial evidence and original recipient even with zero current holdings.
- [X] T012 [P] [US2] Write failing committed race cases in `test/football_market/market/concurrency_test.exs` for US2 scenario 2 and critic races: same-player duplicates, conflicting recipients, different-player first recipients, retry versus atomic transfer and first issuance versus ordinary quote insert in both lock orders; assert distinct pg_backend_pid, barrier/blocking evidence, final issuance identities/supply and complete snapshots, never shared-sandbox pseudo-concurrency or timing-only sleeps.
- [X] T013 [P] [US2] Write failing cases in `test/football_market/market/rollback_test.exs` for US2 scenario 3: induce DB failure after recipient/quote/holding/issuance writes but before commit in isolated test namespace, verify zero new effects and valid retry; separately discard committed acknowledgement and reload/retry retained evidence. No production fault callback or compensating deletes. Extend `test/football_market/market/storage_test.exs` with deferred supply conservation and negative/fractional/inflating mutation failures.

### Implementation

- [X] T014 [US2] Extend `lib/football_market/market/store.ex` with already_completed projection only after prerequisite/state validation, no-op preserved original facts, transactional rollback and safe storage-failure translation; assert nested calls fail before writes and every top-level success follows commit; handle duplicate identities without a caller invocation key and distinguish committed acknowledgement loss from an incomplete attempt; make T011/T013 pass.
- [X] T015 [US2] Complete coordinated SQL guards/deferred conservation in `priv/repo/migrations/20261014000000_create_initial_player_issuance.exs` and store lock protocol in `lib/football_market/market/store.ex`: holding/quote mutations lock affected player, supported isolation only, final initialized aggregate=100 and linked original quote/market recipient consistency, immutable player/owner holding keys and protected TRUNCATE; make T012 and added T013 storage cases pass. Do not implement trading or performance writers.

Checkpoint: Every US2 scenario passes, including adjacent financial writes and both interruption boundaries.

## Phase 5: US3 — Reject Unsafe Initialization (P2)

Goal: Clear rejection before first/duplicate success; no repair of contradictory history.
Independent test: Every missing/invalid/conflicting prerequisite and legacy-inconsistent state yields a safe failure, preserving all snapshots; market-wide recipient cannot change for a new player.

### Tests first

- [X] T016 [P] [US3] Write failing cases in `test/football_market/market/rejection_test.exs` for all seven US3 scenarios: missing player; absent/ambiguous/nonexistent user; requested wrong recipient/quantity/price; orphan quote/holding; bad completed facts/total; same-player and new-player recipient changes; invalid designation/inconsistency overriding already_completed. Assert unchanged records/accounts/sentinels; exercise DB-blocked corruptions separately from test-owned legacy snapshots.
- [X] T017 [P] [US3] Write failing pure adversarial snapshot cases in `test/football_market/market/consistency_test.exs`: whole nonnegative holdings, 120/-20 offsets, valid owner/player IDs, canonical original quantity/value, original quote's matching player/value/rule/version/date, required facts/completion, fixed market recipient agreement; permit 0/100 redistribution and later fixture quotes while retaining original evidence.

### Implementation

- [X] T018 [US3] Implement pure snapshot validation in `lib/football_market/market/consistency.ex` and refine `lib/football_market/market/error.ex` for safe inconsistency/conflict reasons; never accept mere aggregate/presence checks or propose top-up/history repair; satisfy T017.
- [X] T019 [US3] Integrate full post-lock prerequisite/recipient/snapshot validation in `lib/football_market/market/store.ex` and `lib/football_market/market.ex` before both success outcomes, using existing input contract; compare all existing market issuance recipients, preserve failure state, translate missing/invalid/assertion/conflict errors and make T016 plus all retry regressions pass.

Checkpoint: All three stories and every acceptance/edge case in traceability.md pass. No manual financial repair is part of initialization.

## Phase 6: Polish, cross-cutting checks and independent gates

- [X] T020 Write failing boundary tests in `test/football_market/market/scope_test.exs` for exact plan inventory, pure rules/domain→store separation, only intended table writes, no user/credential/balance modification, provider/valuation/job/event calls or HTTP declarations, exact inherited active-feature allowances and unknown/unplanned feature rejection; audit new test profile membership.
- [X] T021 Extend only the exact active `specs/062-initial-player-token-issuance` inventory allowance in `test/football_market/statistics/scope_test.exs` and `test/football_market/providers/scope_test.exs`; preserve every historical allowance/module-purity/security check, allow no blanket directory patterns, and make T020 and inherited regressions pass.
- [X] T022 Reconcile `specs/062-initial-player-token-issuance/verification.json`, `specs/062-initial-player-token-issuance/traceability.md` and `specs/062-initial-player-token-issuance/quickstart.md` with implemented tests/constraints and current feedback; confirm every FR/SC and numbered acceptance/edge case maps to executable assertions, all named inventory files exist, initialization-before-valuation CP2 demo ordering is documented, no new endpoint/runtime obligation or duplicate coverage profile execution is hidden; finish all source/design edits here.
- [X] T023 Execute every check in `specs/062-initial-player-token-issuance/verification.json` in manifest order through scripts/agentflow_check.py with explicit development reuse policy; require toolchain/format/warnings-as-errors compile/test-DB prepare/live service preflight and exactly one final audited unit/integration profile each per current input set. Confirm profile membership/no skips, inspect bounded failures and stop after two unchanged failed executions. Retain passing receipts under `specs/062-initial-player-token-issuance/handoffs/`; no historical CP1 coverage report extra gate.
- [X] T024 Create `specs/062-initial-player-token-issuance/handoffs/develop.md` under 400 words with deltas, receipt references, elapsed check time, residual risks and precise independent QA guidance; reconcile completed task files and final receipts, mark T001–T024 only when satisfied, and run develop --readiness via scripts/workflow_artifact_probe.py before QA. Do not commit/push/publish.
- [ ] T025 [gate:qa] Independent QA reruns every manifest check without developer receipt reuse, challenges every acceptance/edge case and real committed race/restart evidence, and writes `specs/062-initial-player-token-issuance/qa-report.md` under 900 words and `specs/062-initial-player-token-issuance/handoffs/qa.md` under 250 words; finish Verdict: PASS only on complete acceptance.
- [ ] T026 [gate:review] Final review inspects implementation/diff, current feedback and fresh QA evidence for architecture/security/invariants/CP2 integration ordering; run targeted checks only for discrepancies/uncovered risks and write `specs/062-initial-player-token-issuance/review-report.md` under 600 words with exactly one Backlog impact entry and `specs/062-initial-player-token-issuance/handoffs/review.md` under 250 words; finish Verdict: PASS only when ready for human review/merge.

## Dependencies and execution order

Setup T001 → foundational T002→T003 → US1 (T004/T005/T006 → T007→T008→T009→T010) → US2 (T011/T012/T013 → T014→T015) → US3 (T016/T017 → T018→T019) → T020→T021→T022→T023→T024 → independent QA T025 → final review T026.

US2 and US3 depend on US1 persistence, and integration validation touches the same Store, so implement story phases sequentially. Their independent test criteria use prepared fixtures; independence does not imply separate production storage or parallel Store edits. US3's corruption tests can be drafted after foundation, but completion waits on US2's coordinated snapshot behavior. Every applicable implementation/test/check task precedes QA; task_stages maps only T025/T026. Do not mark a failed/absent task completed to satisfy readiness.

## Parallel examples per story

- US1: T004 issuance tests, T005 storage tests and T006 durability tests can be drafted together after T001–T003; distinct files, common completed helper. T007 waits for their red assertions.
- US2: T011 retry, T012 race and T013 rollback tests can be drafted together after US1. T013's storage-test extension is distinct from the other two tasks. Store/migration changes T014/T015 stay sequential.
- US3: T016 rejection integration and T017 pure consistency cases can be drafted together after US2; T018 waits for tests and T019 waits for T018. No shared helper edits in these parallel groups.

[P] describes opportunities, not a request to launch more sessions or implementation owners. Any discovered shared-helper edit removes the parallel opportunity until that prerequisite is complete.

## Implementation strategy

Build US1 as a local demonstration of one fresh player's original inventory; validate narrow story probes without publishing it. Add US2 race/rollback preservation, then US3 defensive rejection. Keep existing product rules and interfaces; later holdings/quotes are test fixtures only. Finalize boundaries/documentation, then run all manifest checks and readiness once for final unchanged inputs. Independent QA reruns separately; final review relies on fresh QA and resolves targeted risks. No historical CP1 coverage report, new public initializer, funds, trades, chart or conditional order implementation is authorized here.

## Notes

26 tasks: US1=7, US2=5, US3=4, shared/final=10. All tasks remain unchecked at architecture stage. The owner must create every file explicitly named in a completed task. All 16 acceptance scenarios and the edge cases are mapped in traceability.md; repeated cases may share asserted fixtures but may not be omitted. No external research agents or separate planning session were used.
