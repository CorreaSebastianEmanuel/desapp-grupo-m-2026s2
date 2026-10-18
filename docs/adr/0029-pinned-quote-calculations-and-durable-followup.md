# ADR-0029: Pinned quote calculation membership and atomic follow-up

**Status**: Accepted for TASK-026 design within approved spec and feedback
**Date**: 2026-10-17

## Context

TASK-026 FR-008/010 and the product critic require each changed accepted weekly membership to remain recoverable. Current TASK-021 intents retain changed IDs only, managed evaluation selects current weekly facts, and the shared TASK-028 quote store lacks performance evidence linkage. FR-006 feedback approves exact explicit versioned scale conversion without a floor. No formula, provider or public API decision is reopened.

## Decision

Extend existing import acceptance under its season lock with immutable full player/season/UTC-week snapshot children linked to intent/check. Preserve existing accept/3 receiving identity and separate delivery status. Late facts create another snapshot, not a rewrite. Legacy intents may use only provable original membership; otherwise expose unreproducible and require a distinct explicit fresh request.

Bind saved strategy and mapping once before valuation fact reads and persist across retries; imported membership itself is captured at acceptance without choosing a strategy. Introduce a narrow managed pinned-membership entrypoint using original verification and existing Preparation/Scoring. Retain schema-versioned typed exact evidence, including no-score inputs. No alternative formula or executable term storage.

Canonical calculation identity includes subject/week, ordered original membership, configuration UUID/version and mapping UUID/version. DB uniqueness plus material equality resolves digest conflicts; request IDs are distinct from logical calculation identity. Scale is explicit positive finite decimal with two-place nearest/ties-away conversion. There is no production default or floor.

Extend shared market_quotes. Confirm evidence/result, performance quote and exactly one quote-keyed evaluation event atomically under existing player locking, then calculation locking. Sequence orders same-time performance quotes. Immutable guards and deferred linkage constraints cover ordinary direct DML. Separate fenced execution projections/append-only attempts support three bounded attempts and interruption recovery without mutating import acceptance or original evidence.

Use at-least-once delivery of stable quote-evaluation:<quote_uuid>. TASK-060 owns transactional effective-work deduplication and acknowledges after consumption; unconsumed events remain pending. No conditional-order evaluator is implemented here. Valid absent/insufficient/nonpositive results are no_quote; malformed inputs, unsupported strategies and unrecoverable originals have distinct terminal categories; only temporary infrastructure failures retry. See the internal contract for exact mapping.

## Consequences and alternatives

This deliberately extends TASK-021 publication and TASK-025 managed interfaces only to preserve their existing guarantees across delayed calculation. Current-membership worker selection collapses accepted histories; changed-only membership misvalues partial weeks; a parallel quote store fragments issuance history; in-memory notification loses confirmed work; Oban uniqueness alone cannot guarantee immutable logical identity. A production calibration preset would invent an unapproved rule.

Implementation must prove original replay after restart/late facts, strategy fixation, exact conversion, direct-write guards, committed races, fenced exhaustion and atomic follow-up. Canonical design: specs/026-quote-recalculation-and-immutable-history/{plan.md,data-model.md,contracts/calculation.md,verification.json}. Settled architecture and trust rules remain ADR-0020–0024/0028.
