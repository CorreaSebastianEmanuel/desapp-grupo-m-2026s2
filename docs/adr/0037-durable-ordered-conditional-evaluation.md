# ADR-0037: Durable ordered conditional evaluation passes

**Status**: Accepted for TASK-060 architecture, 2026-10-27.

## Context

TASK-060's critic found that concurrency could reverse competing order decisions, notification strength was ambiguous and quote validity could be duplicated. ADR-0036 preserves TASK-059 pure reads, one-player transaction lock order and public purchase commit ownership. Shared balances/issuance recipients can make different players conflict. Queue concurrency alone cannot serialize multiple application nodes.

## Decision

Capture pending UUIDs in creation-time/UUID order into durable members of a single active PostgreSQL evaluation pass. A singleton row lock protects each step. Evaluate one member and advance its ordinal in the same transaction using a private Market evaluator participant; retain public evaluator ownership and all financial guards. Do not hold accounts while acquiring another player. Quote/create producers append jobs/events but never acquire the pass lock under player locks. Workers serialize each pass; new commits join later passes. This strengthens dispatch reproducibility for captured contenders while preserving the explicit absence of strict global priority against direct trades, cancellation and future arrivals.

Retain TASK-026 quote events. Event claim, durable wake insertion and fenced acknowledgement compose inside one outer transaction. Quote confirmation and creation insert their wake in their own commits. Minute/startup recovery resumes cursor and pending orders regardless of event acknowledgement or exhausted jobs. Three immediate job attempts (5/30 seconds) do not change financial business outcomes.

Reuse Quotes.latest and PurchaseTransaction.current_quote! exactly; event quote is trigger identity only. Best-effort owner-scoped PubSub is attempted after commit; persisted owned reads are the sole delivery-independent state guarantee. No notification outbox or guaranteed message delivery.

## Consequences and alternatives

Adds only scheduler projection tables plus private domain seams; no new service, public API, reservation or financial product. Completed scheduler membership may be reclaimed; financial/order/quote evidence remains retained. One active pass trades throughput for simple deterministic CP2 behavior, without a latency SLA. Recovery and members are not Redis-dependent. A transient failure blocks the current step until retry/recovery succeeds; no silent skip changes the winner.

Reject per-player ordering (shared account contention), only Oban uniqueness (not a financial guard), moving snapshots (late commits can disappear), multi-player batch transactions (lock inversion), event-price authorization and transactional PubSub. Existing stack and monetary decisions remain ADR-0017/0029/0032/0036. Canonical details: specs/071-conditional-order-evaluation-workers/{spec.md,plan.md,data-model.md,contracts/evaluation.md}.
