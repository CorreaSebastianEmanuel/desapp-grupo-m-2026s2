# ADR-0028: Atomic statistics acceptance with retained position evidence

**Status**: Accepted for TASK-021 design under approved product feedback
**Date**: 2026-10-16

## Context

TASK-021 FR-010/011 requires an entered substitute to retain unknown position after tied or insufficient history, while TASK-016 validation and TASK-020 storage require a known position. The critic also identifies order dependence within atomic season batches and unobservable completeness witnesses. Inspection finds catalog-specific durable runtime and no durable valuation request API. Stack, source access and immutable facts remain ADR-0010/0013/0018/0019/0025-owned.

## Decision

Extend the sole provider result with safe explicit completeness evidence and optional performance participation evidence. Only proven substitute entrants without a trusted event-time position can pass with nil; other missing positions still fail. Expose existing source-owned terminal/detail/assessment witnesses without inventing live coverage or enabling access. Explicit complete-empty requires its own witness.

Add guarded performance position-evidence states. Legacy facts retain their known position using a DDL legacy_direct default; no fact UPDATE or disabled immutable trigger. Null positions require substitute_entered plus tie/insufficient_history reason and validated immutable basis. Keep restrictive season/team FKs, uniqueness and exact count semantics.

Freeze already committed known same-player/same-season performance history before inserting any proposed batch facts. Count prior matches strictly before subject kickoff; exclude equal/later kickoff and every new row in this batch. Count accepted derived known positions as known history. Retain basis IDs, frequencies and policy version. This resolves order dependence while following spec's already-accepted-history constraint; the critic's proposed union with unaccepted batch rows would expand that constraint and is not adopted. Source-identical replay reuses retained derivation, never today's enlarged history. Late facts cannot rewrite accepted unknowns.

Use one existing Synchronization runtime with operation-qualified admission, dispatch, receipts and recovery; preserve catalog defaults and table compatibility. Same-season statistics publication and direct writes share a transaction advisory lock. All accepted facts, first provenance, check/pointer, fenced receipt and unique calculation intent commit together. Retain safe failed attempts separately without successful-check advancement. Replays may add check observations but never replace original lineage.

Dispatch calculation intent after commit through an idempotent Valuation request-acceptance boundary with stable intent identity. Persist request and dispatch status separately. This task does not evaluate, select strategies or create quotes; unavailable downstream completion stays visible as requested/pending. Worker crash or callback failure cannot lose the durable request or relabel import success.

## Consequences and alternatives

A first season batch can retain unknown entrants even when it contains earlier starters; this is deliberate already-accepted history, independent of list order. Later imports can use larger accepted history only for new facts. Database evidence guards and real committed concurrency/restart tests are required. Source payload equality and first provenance are separate from newer observation timestamps.

Rejected: sentinel positions, globally relaxed position validation, incremental batch-order derivation, replay rederivation, inferred empty completeness, raw response retention, second provider/scheduler, synchronous valuation, and unfenced post-commit callbacks. Each fabricates data, loses work, breaks immutability or expands scope. No TASK-020 workflow reopening, provider replacement or new service is authorized. Detailed structures/interfaces and verification: specs/065-statistics-ingestion-pipeline/{plan.md,data-model.md,contracts/ingestion.md,verification.json}.
