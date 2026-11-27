# Tasks: Conditional Order Evaluation Workers

**Input**: `specs/071-conditional-order-evaluation-workers/` — spec.md, plan.md, verification.json and all four applicable supporting artifacts.
**Owner**: TASK-060. Tests are mandatory under repository rules and this test-first request. Every new behavioral test must fail for the intended missing behavior before implementation, then pass. Keep one implementation owner; do not implement other backlog tasks.

**Feedback 1 resume**: Preserve T001–T022 completion and delivered application behavior. Reopen only T023/T024 for canonical packaging and regenerated developer verification; T025/T026 require fresh independent sessions. Previous PASS reports/receipts remain historical and cannot satisfy this run. Existing task order requires tests before behavior; the development handoff discloses incomplete historical red-test provenance, which this architecture session does not invent or repair by assertion.

## Phase 1: Setup

- [X] T001 Prepare isolated committed-connection/Oban fixtures in test/support/order_evaluation/case.ex and test/support/order_evaluation/runtime_probe.ex, reusing existing owned-schema safeguards and deterministic clocks/barriers; validate service/toolchain prerequisites per specs/071-conditional-order-evaluation-workers/quickstart.md without starting full profiles.

## Phase 2: Foundational prerequisites

Blocks all stories. Do not replace the financial evaluator or introduce new purchase rules.

- [X] T002 Add failing scheduler persistence/argument/scope tests in test/football_market/market/order_evaluation/scope_test.exs for valid singleton state/member constraints, rollback, bounded safe worker inputs, no financial authority in job args, no domain dependence on Redis and no GET/list scheduling; preserve prior lifecycle contract tests.
- [X] T003 Add priv/repo/migrations/*_add_conditional_order_evaluation_passes.exs and schemas lib/football_market/market/order_evaluation_pass.ex and lib/football_market/market/order_evaluation_member.ex per data-model.md, including singleton seed, generation/ordinal uniqueness, order references and pending snapshot indexes; satisfy persistence assertions from T002 before stories.

## Phase 3: US1 — Evaluate Orders Against Confirmed Quotes (P1, MVP)

Goal: committed producer work leads to an ordered all-or-nothing decision at the current authoritative quote.
Independent test: commit creation/quote, perform the new worker, and assert exact pending/executed/rejected outcome and atomic financial evidence. Covers US1.1–6, FR-001–004/009/011/012 and SC-001/003/005.

- [X] T004 [P] [US1] Write failing delivery/worker tests in test/football_market/market/order_evaluation/delivery_test.exs and test/football_market/workers/conditional_order_evaluation_test.exs: create and quote enqueue rollback injection, existing event identity/confirm return shape, stale-fence acknowledgement, atomic claim+wake+receipt, repeated acceptance and safe malformed job arguments; extend test/football_market/quotes/followup_test.exs for retained quote atomicity.
- [X] T005 [P] [US1] Write failing worker-authority tests in test/football_market/market/order_evaluation/eligibility_test.exs: event price cannot authorize, both committed quote lock orders, equality/above-limit, absent/invalid/nonpositive quotes, current funds/inventory, both rejection reasons, due expiry and lock wait across expiry; retain exact token/credit/append-only evidence assertions in existing conditional_orders tests.
- [X] T006 [P] [US1] Write failing ordering tests in test/football_market/market/order_evaluation/ordering_test.exs: committed snapshot members ordered by creation then UUID, tied timestamps, two worker instances blocked at singleton, scarce inventory/shared-balance winner, >100 members, and concurrent/backdated arrivals deferred to a later pass. Use separate committed connections and explicit barriers, not shared Sandbox connections.
- [X] T007 [US1] Extract private evaluate_in_transaction! in lib/football_market/market/conditional_order_store.ex without changing public transaction ownership, resource lock order, expiry clock, quote validator, idempotency namespace or terminal outcomes; run T005 and existing quote/cancellation race controls.
- [X] T008 [US1] Implement snapshot capture and one-member transactional steps in lib/football_market/market/order_evaluation_store.ex: lock singleton first, materialize ordered UUID membership, evaluate exactly one member via T007, commit outcome and cursor together, never skip transient failure, and clean only completed scheduler members; satisfy T006 ordering tests.
- [X] T009 [US1] Implement domain delivery/acceptance in lib/football_market/market/order_evaluation.ex and atomic producer integration in lib/football_market/market/conditional_order_store.ex and lib/football_market/quotes/store.ex; preserve return shapes and use existing claim/acknowledge fencing with stable receipt plus Oban wake in one outer transaction, avoiding cursor locks under producer player locks.
- [X] T010 [US1] Implement thin lib/football_market/workers/conditional_order_evaluation.ex with safe ID-only arguments, at most 100 steps and transactionally durable continuation before success, rescan coalescing outside producer locks and max_attempts 3 with 5/30-second backoff; delegate decisions to Market and satisfy T004–T006.
- [X] T011 [US1] Run delivery and eligibility focused checks plus US1 ordering cases declared in specs/071-conditional-order-evaluation-workers/verification.json; record actual scenario outcomes in handoffs/develop.md without marking downstream verification complete.

## Phase 4: US2 — Recover Missed Work Safely (P1)

Goal: restart, retry and overlapping recovery cannot strand or duplicate purchases.
Independent test: discard original deliveries, restart isolated execution, sweep, and repeat concurrently; every eligible/due order is revisited and every order has at most one purchase. Covers US2.1–5, FR-005–009 and SC-002/004/005.

- [X] T012 [P] [US2] Write failing recovery tests in test/football_market/market/order_evaluation/recovery_test.exs for startup, minute scheduling, expired quote leases, acknowledged event with lost job, lost continuation, restart of isolated worker/application execution, >100 mixed pending/due members and newly committed orders during a pass; expiry recovery needs no quote and reads remain pure.
- [X] T013 [P] [US2] Write failing retry/contention tests in test/football_market/market/order_evaluation/retry_test.exs and test/football_market/market/order_evaluation/contention_test.exs: rollback before/during financial writes, crash after committed purchase before acknowledgement, three-attempt exhaustion then successful sweep, overlapping recovery/quote jobs, shared-user cross-player spending and cancelled/expired races, asserting one purchase/transfer/two ledger entries and supply exactly 100.
- [X] T014 [US2] Implement bounded event pagination, pass resumption and all-pending sweep in lib/football_market/market/order_evaluation.ex and lib/football_market/market/order_evaluation_store.ex; persist page continuations, use existing event fences, recover even acknowledged-event/discarded-job cases and preserve cursor/order on transient error; satisfy T012/T013.
- [X] T015 [US2] Add lib/football_market/workers/conditional_order_recovery.ex and configure the queue concurrency 1 plus minute Cron in config/synchronization.exs, preserving existing queues/plugins and configured isolated Oban seam; enqueue startup recovery through lib/football_market/application.ex without making Redis a domain scheduling dependency.
- [X] T016 [US2] Complete worker retry classification and safe exhaustion behavior in lib/football_market/workers/conditional_order_evaluation.ex and lib/football_market/workers/conditional_order_recovery.ex; prove no technical rejection, no cursor skipping and restart repair through T012/T013, retaining existing order cancellation/quote locking tests.
- [X] T017 [US2] Run recovery and contention focused manifest checks and record real restart, overlapping-instance and financial invariant evidence references in handoffs/develop.md; do not rely on enqueue-only assertions as execution proof.

## Phase 5: US3 — Observe Committed Evaluation Outcomes (P2)

Goal: connected clients can receive safe post-commit hints and reconnect recovers authoritative stored results.
Independent test: subscribe with commit/rollback barriers, execute/reject/expire, lose a hint, then owned-read the same terminal evidence. Covers US3.1–2, FR-010/013 and SC-006.

- [X] T018 [P] [US3] Write failing tests in test/football_market/market/order_evaluation/notifications_test.exs for no pre-commit/rollback/no-op signal, owner-scoped executed/rejected/expired/cancelled hints, no duplicate terminal transition hints, failed/lost PubSub and identical reconnect state; verify no unsafe payload or exception-derived user reason.
- [X] T019 [P] [US3] Add assertion-based real HTTP journey test/runtime/order_evaluation_http.exs using owned-schema fixtures and actual new workers: repeat service/listener preflight, create 201/Location, owned reads/cancel 200 JSON, auth/header/foreign-ID/invalid-term errors, qualifying and nonqualifying quote, rejection/expiry, duplicate/recovery financial counts and lost-hint reconnect; retain all existing TASK-059 pure-read and exact financial HTTP assertions.
- [X] T020 [US3] Implement lib/football_market/market/order_notifications.ex and post-commit integration in lib/football_market/market/order_evaluation.ex and lib/football_market/market/conditional_order_store.ex; derive owner from persistence, emit hints only for actual transitions including public evaluate/cancel, catch notification failure without retrying a committed purchase and leave UI subscription/rendering to TASK-061.
- [X] T021 [US3] Run notifications focused check and real runtime HTTP check from specs/071-conditional-order-evaluation-workers/verification.json; inspect body/header and post-commit/lost-message assertions and record evidence references in handoffs/develop.md.

## Phase 6: Cross-cutting verification and independent gates

- [X] T022 Reconcile all new source/test/helper paths in config/test_profiles.json, config/credo_inventory.json and applicable existing source-role inventories; run scope check and preserve coverage infrastructure, existing HTTP/OpenAPI shapes and browser E2E profile rather than adding a duplicate full-profile command.
- [X] T023 Finish canonical edits in specs/071-conditional-order-evaluation-workers/quickstart.md and handoffs/develop.md; verify the byte-preserved archive in tmp/task060-feedback-1/qa-evidence/ against handoffs/check-qa-supplement.json, update retained report links, and ensure qa-evidence/ is absent per ADR-0038. Finish all canonical/feedback/lesson edits before checks; execute every verification.json check using scripts/agentflow_stage_checks.py --stage develop --reuse, then complete the reconciliation/readiness step T024. All T001–T024 work and test checks must pass before QA; no historical CP1 coverage extra gate, no stale receipts, no repeated unchanged passing profiles and no bypass of two-failure budgets.
- [X] T024 Reconcile delivered files/assertions against every scenario in specs/071-conditional-order-evaluation-workers/spec.md and tasks.md, mark implementation/developer tasks complete only on actual evidence, and ensure qa-report.md/review-report.md remain independent downstream artifacts; if canonical repairs are needed, rerun checks under the documented receipt rules before QA. Once reconciliation and all developer checks pass, mark T001–T024 complete, capture source/input fingerprints under tmp/task060-feedback-1/pre-qa-fingerprints.json with quickstart.md commands, and run scripts/workflow_artifact_probe.py develop --readiness; only T025/T026 may remain unchecked.
- [ ] T025 [gate:qa] Independent QA of spec/plan/tasks and every manifest check, executed fresh without reuse, including real HTTP, restart, committed connection races and all product invariants; write fresh specs/071-conditional-order-evaluation-workers/qa-report.md and handoffs/qa.md with supplemental results only in handoffs/check-qa-supplement.json. After output finalization run the quickstart.md fingerprint assertions, recording equality in handoffs/check-qa-packaging.json; never recreate qa-evidence/. End qa-report.md exactly Verdict: PASS only when all checks and fingerprint assertions pass.
- [ ] T026 [gate:review] Final review of implementation, fresh independent QA and acceptance mappings, running targeted checks for uncovered risks; verify handoffs/check-qa-packaging.json and retained bundle provenance, then write fresh specs/071-conditional-order-evaluation-workers/review-report.md ending exactly Verdict: PASS only when justified. Do not merge or publish from this architecture session.

## Dependencies and execution order

T001 -> T002 -> T003 -> US1 (T004–T011) -> US2 (T012–T017) -> US3 (T018–T021) -> T022–T024 -> independent QA T025 -> final review T026. Within US1, T004/T005/T006 precede T007–T010; T008 needs T007; T009 needs the step/domain seams; T010 needs all prior implementation. US2 extends the working US1 engine and US3 observes both stories. No parallel story implementation is assumed. No developer implementation or applicable check task is a downstream gate.

## Parallel examples

US1: T004 delivery/adapter tests, T005 eligibility tests and T006 ordering tests can be authored in separate files after T003. US2: T012 recovery tests and T013 retry/contention tests can be authored separately after US1. US3: T018 notification tests and T019 runtime journey can be authored separately after US2. Shared-database tests and all final manifest checks run serially; parallel authoring does not authorize parallel profile execution or extra agents.

## Implementation strategy

MVP is US1 plus foundation: durable triggers and current-quote atomic decisions. Validate its focused scenarios before adding recovery, then add outcome hints. TASK-060 acceptance still requires all three stories and both independent PASS gates. Do not deploy or stop at the MVP. Preserve TASK-059's no-read-side-effects decision and TASK-061's UI ownership throughout.
