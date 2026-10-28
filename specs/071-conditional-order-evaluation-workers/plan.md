# Implementation Plan: Conditional Order Evaluation Workers

**Branch**: `060-conditional-order-evaluation-workers` | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)
**Backlog owner**: TASK-060; the generated directory number is not a backlog identity.

## Summary

Extend the existing modular application with PostgreSQL-backed Oban delivery, ordered evaluation passes, periodic recovery and post-commit PubSub hints. Reuse TASK-059's financial evaluator and TASK-026's quote evaluation outbox. No new endpoint, UI, credit provisioning, provider integration or financial product is introduced. Human feedback TASK-059 fixes pure reads and expiry precedence. Current backlog/feedback/TASK-060.md feedback 1 governs verification output placement; preserve all approved application behavior and ADR-0036/0037.

## Technical Context

- Language/runtime: pinned Elixir 1.20.3 / OTP 29.0.6 (`.tool-versions`). Phoenix 1.8, Ecto/PostgreSQL, Oban 2.24 and Phoenix.PubSub already exist; no dependencies added.
- Storage: existing orders, immutable purchases/ledger, quotes and quote_evaluation_requests; new singleton evaluation-pass cursor. Redis is neither scheduling authority nor required by domain recovery.
- Testing: ExUnit unit/integration profiles, real committed PostgreSQL connections, current browser E2E profile and real Bandit HTTP assertions. Deterministic local fixtures; no provider calls.
- Platform/scope: local Linux modular web application, CP2 asynchronous orders. Queue concurrency 1, at most 100 evaluation steps per job, 3 immediate attempts; minute cron and startup wake recover work. No latency or throughput SLA. PostgreSQL singleton serialization protects across application instances, independently of Oban queue settings.
- Concrete unknowns resolved locally: current creation participant, quote outbox lease protocol, quote validator, and lock order; see research.md. No unsettled technology research or external documentation is needed.

## Constitution Check

Pre-design: PASS. Spec and approved feedback determine behavior; ADR-0032/0036 preserve exact money, supply 100, immutable financial facts, quote history and atomicity. Workers delegate to Market and Quotes; no web business logic or new infrastructure. Tests precede each behavioral change; independent QA/review remain downstream.

Post-design: PASS. The new transaction participant is private to Market and preserves public commit ownership. Each evaluation transaction touches only one player after locking its order; quote/create producers never lock the pass cursor. No cycle through player -> cursor is introduced. Reproducible pass order and notification strength are clarified in spec.md and ADR-0037. No constitution exception.

## Architecture and implementation boundary

### Transactional producers

Refactor ConditionalOrderStore.create to own the same READ COMMITTED transaction around its existing create_in_transaction! participant plus an Oban ConditionalOrderEvaluation wake insertion. Return the same committed projection only after both persist. Failure inserting work rolls back creation. GET/list remain side-effect-free.

Quotes.Store.confirm! already inserts one immutable-identity quote_evaluation_requests row with the confirmed quote under the player lock. Retain that atomicity and return shape. Insert an event-ID-only evaluation wake in that same transaction for prompt processing. No calculation, valuation formula, quote sequencing or historical selection changes. The retained event is recoverable even if an Oban delivery is lost.

### Effective work acceptance

OrderEvaluation accepts a quote event through the existing Quotes.Recovery claim/fence protocol. In one outer Repo transaction, claim the event, insert an Oban global-pass wake carrying only stable event identity, then acknowledge using a deterministic receipt `conditional-evaluation:<event_uuid>`. Nested existing Repo.transaction calls must participate in that same outer transaction; prove rollback and lease expiry with tests. Acknowledgement means durable work acceptance, never financial completion. Replays with the same receipt are harmless; stale fences and conflicting receipts remain rejected. No new quote event ledger.

### Ordered passes and financial decisions

Use a single durable cursor row. A step transaction locks that row FOR UPDATE before any order/resource lock. When idle, capture all currently visible pending order UUIDs in a pass-members table using one INSERT SELECT statement snapshot, assigning ordinals in ascending `(created_at, id)` order. New or backdated commits cannot enter that captured membership. Each step selects the next member after its durable cursor without SKIP LOCKED and advances by ordinal, never by a fresh moving query. Store the maximum captured tuple for diagnostics only; membership is the authority.

Refactor the existing evaluate body into evaluate_in_transaction!(id), private to Market. A step invokes it for one member and updates the durable cursor in the SAME transaction; no transaction spans multiple players. Terminal or removed candidates are safe no-ops. Business rejection/expiry advance the cursor; infrastructure failure rolls back both cursor and financial work. Do not advance past a transiently failing member within a pass. The public evaluator retains transaction ownership and result shape for existing callers; workers use only the ordered domain entrypoint.

At most 100 individual step transactions run in a job. Before acknowledging a job with remaining members, persist a continuation job; a missing continuation is repaired by startup/cron inspecting the durable cursor. Once a pass completes, release its membership rows and return idle transactionally. Coalesce wakes arriving during a pass with a durable rescan_requested flag; setting it must not occur under a quote/player producer lock. A wake consumer sets it in its own transaction. Completion starts another snapshot if set; periodic recovery also starts a fresh pass regardless. New orders committed during a pass therefore receive a later pass, never disappear behind its cursor. No strict priority against direct purchases, cancellation, expiry or future arrivals is promised.

Reuse the order-first -> identity -> player -> sorted users/balances lock order inside the step. After blocking locks sample clock_timestamp; expiry wins, then PurchaseTransaction.current_quote! calls Quotes.latest exactly once. Existing validator rejects absent/nonfinite/nonpositive quotes; transient read failure rolls back. Limit comparison and financial writes use that identical quote. Existing unique conditional-order purchase linkage, reciprocal constraints and append-only guards remain the financial duplicate backstop.

### Recovery and retry

Add ConditionalOrderRecovery on the existing Oban Cron every minute plus an application-startup wake, using the configured Oban instance seam. Recovery enumerates unacknowledged/expired-lease quote events with bounded stable keyset pages, accepts them durably and resumes/starts a global pending-order pass. Sweep includes due expiry even without a valid quote or quote event. Persist continuations rather than relying on process memory; repeated sweeps and concurrent workers share the cursor lock. Never mutate lifecycle in a query.

Both new workers use max_attempts: 3 and backoff 5 then 30 seconds; only safe transient infrastructure failures retry. Exhaustion discards that job, retains pending orders/event or pass cursor and allows a later sweep to resume. Configuration absence and restore semantics follow existing test fixture conventions. Scheduler queue/cron settings extend config/synchronization.exs without changing existing queues or recovery owners.

### Notifications and safe outcomes

After each successfully committed state transition, call OrderNotifications to broadcast `{:conditional_order_changed, order_id}` on `conditional_orders:<owner_uuid>`. Resolve owner from the persisted order. No balances, credentials, exception text or purchase payload in hints. Pending no-op and rollback do not broadcast; terminal replay does not rebroadcast a transition. PubSub failure cannot roll back or retry a completed purchase. A crash between commit and broadcast may lose a hint. Reconnect reads existing owned projections; TASK-061 owns subscription/rendering. Cancellation's existing terminal transition uses the same post-commit helper; response behavior stays unchanged.

## Project Structure

Existing files changed: `lib/football_market/market/conditional_order_store.ex`, `lib/football_market/quotes/store.ex`, `config/synchronization.exs`, `lib/football_market/application.ex`.
New domain/persistence: `lib/football_market/market/order_evaluation.ex`, `order_evaluation_store.ex`, `order_evaluation_pass.ex`, `order_evaluation_member.ex`, `order_notifications.ex` under the same market directory. New worker adapters: `lib/football_market/workers/conditional_order_evaluation.ex`, `conditional_order_recovery.ex`. Migration: `priv/repo/migrations/*_add_conditional_order_evaluation_passes.exs`.
Tests: `test/football_market/market/order_evaluation/` for delivery, ordering, recovery, retry, scope and notifications; `test/football_market/workers/conditional_order_evaluation_test.exs`; `test/runtime/order_evaluation_http.exs`; shared committed-connection fixtures in `test/support/order_evaluation/`. Register files/helpers in `config/test_profiles.json` via scripts/test_inventory.py and source roles in `config/credo_inventory.json`, plus applicable existing inventory classifications. Do not rewrite coverage infrastructure.

## Verification and checkpoint coverage

verification.json is the executable owner; implementation runs every check before QA, then QA runs fresh. Focused scenario checks run before one unit, one integration and one E2E profile execution. CI parity uses the current wrapper contract check, which runs zero native profiles. No historical CP1 coverage report or duplicate full-profile command. Preserve hosted CI and existing coverage safeguards.

| Spec scenarios | Required assertions | Focused check |
|---|---|---|
| US1.1–2, SC-001 | Create/quote plus durable work commit or roll back together; enqueue failure; stable quote identity; fenced acceptance and restart | delivery |
| US1.3–6, SC-003/005 | Newer expensive/cheap quote in both committed lock orders, absent/invalid/zero quote, equality limit, exact full fill, both rejection reasons, expiry across lock wait | eligibility |
| US2.1–2, SC-004 | Lost event/job/continuation, expired lease, due-without-quote, real worker restart, pages >100 and equal timestamps, arrival during pass | recovery |
| US2.3–5, SC-002/005 | Rollback injection before/during financial work, post-commit ambiguous ack, retries exhausted then sweep, overlapping workers, scarce-resource winner by snapshot order, conserved balances/supply | contention |
| US3.1–2, SC-006 | Subscriber barrier before commit, no rollback/no-op signal, lost hint, failed PubSub, reconnect reads identical terminal result; pure reads | notifications + http |

CP2 delivery here is workers plus state hints; charts and UI/demo remain TASK-057/058/061/062. Existing independent unit, integration and actual browser E2E profiles remain mandatory. No CP3 Redis optimization/metrics expansion.

## Verification output placement (feedback 1)

ADR-0038 defines the repaired output contract. Supplemental portable QA evidence belongs in `handoffs/check-qa-supplement.json` (an already excluded output path), alongside excluded QA/review reports and handoffs. Never recreate `qa-evidence/` or write replay scripts/results into a source input directory. Keep raw execution output in the existing ignored evidence locations and temporary replay scripts in `tmp/` or `/tmp/`. No fingerprint/receipt tooling changes are authorized.

The five original supplemental files are archived byte-for-byte under `tmp/task060-feedback-1/qa-evidence/`; the bounded bundle preserves their contents, SHA-256 identities, original provenance and replay instructions. Historical reports remain historical and their links now resolve to the bundle; they cannot satisfy the resumed run. Do not manufacture receipts or change old execution claims. All source/design/feedback/lesson and packaging edits must finish before the implementation owner regenerates the 19 required developer checks. Only explicit valid development reuse is permitted; stale evidence executes again. QA then runs all 19 independently and final review assesses that fresh run.

Before QA writes outputs, capture `source_fingerprint(root)` and `input_fingerprint(feature)` using the existing functions in scripts/agentflow_verification.py. Compare them after QA finalizes its bundle/reports/handoff, assert equality and no `qa-evidence/` directory, and record the comparison under `handoffs/check-qa-packaging.json`. The quickstart provides executable assertions. A mismatch is a real re-verification obligation, never a reason to stamp provenance or weaken a gate. Preserve resolved workspace-write metadata, per-command approved browser execution and retry budgets. No extra historical CP1 report, duplicate profile run, global configuration or process-launch compatibility change is included.

## Supporting-artifact applicability

```json artifact-applicability
{"schema_version":1,"research":{"required":true,"reason":"Resolve concrete transaction and ordering seams in existing code."},"data_model":{"required":true,"reason":"Durable pass cursor and materialized members change persistence."},"contracts":{"required":true,"reason":"Worker/event acceptance and PubSub interfaces change."},"quickstart":{"required":true,"reason":"Feature-specific worker/recovery and HTTP validation setup."}}
```

## Complexity Tracking

No constitution violation. ADR-0037 records the necessary shared cursor, membership and Market transaction participant. Per-player queues cannot order cross-player shared balances; a multi-order financial transaction would violate the established one-player lock discipline. Durable membership costs storage proportional to one pending-order snapshot; delete only completed scheduler membership, never order, quote or financial evidence.

## Integration with current main

Preserve this saved Agentflow 2.3 task and its two historical gates. The default workflow on main is now ThinFlow; the legacy CI-parity check recognizes that default while still validating the installed legacy CI-baseline step, current CI wrapper and distinct unit/integration manifest profiles. Invalid or incomplete defaults and missing legacy/profile obligations remain failures. Reconcile both branches' inventories without dropping test cases, helpers or migrations. Historical reports describe the original candidate; refresh verification for the merge candidate.

Prepare the task-owned test database with `mix test.prepare` after toolchain validation and before service preflight. This adds a cold-start prerequisite to the existing ordered checks; no existing gate is removed or skipped. Dependency caches are disposable and rebuilt locally when incomplete.

Build browser assets before the integration profile because its runtime lifecycle contract opens a real sign-in page. Preserve both integration and E2E checks after that prerequisite.
