# ADR-0036: Conditional order atomic lifecycle and purchase composition

**Status**: Accepted for TASK-059 design, 2026-10-27; human feedback TASK-059 is authoritative.

## Context

ADR-0017 proposed a default expiry, reproducible dispatch order and durable workers. The accepted TASK-059 spec requires explicit expiry, promises no winner priority, and assigns scheduling/recovery to TASK-060. Feedback requires pure read projections. ADR-0032 and the current PurchaseStore forbid caller-owned transactions, so calling Market.purchase inside an order transaction cannot satisfy atomicity. Direct purchase keys are arbitrary client strings; deriving an order key alone could alias an existing direct purchase.

## Decision

Preserve public direct-purchase transaction ownership and response behavior. Extract a private-to-Market transaction participant shared by direct and conditional coordinators. It acquires the existing player/accounts/balance locks, selects the authoritative quote once, checks eligibility before any writes, and performs the existing balanced financial writes. It never opens or commits its own transaction. Its conditional path accepts a locked persisted order, never caller-provided execution price/owner. No web or worker calls this primitive directly.

A conditional evaluator owns READ COMMITTED transaction, locks one order FOR UPDATE, returns terminal evidence unchanged, then takes its purchase identity lock and player FOR UPDATE, sorted user and balance locks following ADR-0032. After all potentially blocking locks, sample PostgreSQL clock_timestamp(): expiry wins before quote, funds or inventory decisions. Read Quotes.latest exactly once under the player lock; use that same quote for limit and purchase. No quote/nonpositive/invalid quote or above-limit means pending only if unexpired. No fallback to an older cheap quote. Quote confirmation already holds the player lock through commit. Completion time records the serialized decision; eligibility before expiry does not promise commit before expiry. Terminal cancellation locks the order and uses the current database clock too; a due pending cancellation records expired rather than cancelled.

Business insufficiency returns a tagged result before financial writes so the coordinator can persist rejected in the same transaction. Infrastructure/inconsistent-state errors roll back everything, retaining pending for retry. Executed order and financial evidence commit together; terminal writes are immutable. Cancellation and evaluation both lock the order first; direct purchases never acquire order locks. No path locks a second player after acquiring accounts.

Add nullable conditional_order_id to purchases, with unique nonnull order identity and a deferred reciprocal reference to the order's purchase_id. Preserve arbitrary direct request keys using a partial buyer/request_key unique index for purchases whose conditional_order_id is null and the same filter in direct lookup. Conditional idempotency uses the order UUID and separate lookup, not the direct-key namespace. Preserve the existing advisory lock for direct purchases; order-scoped identities may serialize harmless hash collisions. Extend database evidence guards to require matching order owner/player/quantity/actual quote, and executed status plus reciprocal purchase reference at commit. No standalone conditional purchase may commit. Existing financial append-only guards remain.

Creation persists pending only; the retained row is replayable eligibility input. TASK-060 owns transactionally durable quote/create scheduling and sweeps; TASK-059 supplies transaction-composable creation and side-effect-free candidate reads, with no worker or timing SLA. Public creation still returns only after commit. TASK-060 must integrate the in-transaction creation participant and quote confirmation rather than use a lossy post-commit notification.

## Consequences and alternatives

Pure GET/list computes expiry_reached from one database clock sample per response without locks that mutate state, updates or enqueue. Expiry becomes persisted only through a command/evaluator. This supersedes ADR-0017's suggested default duration and dispatch ordering; there is no default expiry or global winner policy. Durable delivery remains a TASK-060 acceptance obligation, not a completed TASK-059 capability.

Reject separate purchase/order commits, nested public purchase calls, event-price authorization, direct-key aliasing and Oban uniqueness as financial deduplication. Committed separate-connection barriers prove both quote orders, cancellation races and shared-account contention. A lock wait crossing expiry must also prove expiry precedence. No infrastructure addition or public direct-purchase contract change is authorized.
