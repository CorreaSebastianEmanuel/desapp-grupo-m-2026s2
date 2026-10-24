# ADR-0032: Atomic purchase coordination and completed-only idempotency

**Status**: Accepted for TASK-029 architecture; required human decision approved by the architecture-stage instruction.
**Date**: 2026-10-23

## Context

The product critic identifies undefined self-purchases and an untestable quote-race ordering. The architecture-stage instruction confirms approval of required human decisions. Adopt the critic's recommended rejection of self-purchases; spec.md FR-012 and its edge cases now record it. The existing backlog/feedback/TASK-029.md remains authoritative: only previously provisioned credits are spendable; no funding interface or credit grants are added.

ADR-0024 already serializes quotes and holdings with the player row. ADR-0029 defines retained quote order and immutable evidence. Accounts have no credit projection. Cross-player purchases must not overspend a shared buyer, and failed requests must not consume keys.

## Decision

Introduce exact credit balance projections, immutable purchases, token-transfer evidence and paired credit ledger entries inside Market. No financial rules move into web adapters. A purchase owns a READ COMMITTED transaction; reject caller-owned transactions so returned success follows durable commit.

Take a transaction advisory lock on the buyer/key identity (stable namespace and canonical UTF-8 encoding, collisions only serialize), then inspect the completed result. Matching player/quantity returns original evidence before current funds, inventory or quote checks; conflicting material details return key_conflict. No failed-attempt row persists. Database uniqueness on buyer/key is the final duplicate backstop.

For a new purchase lock its player row FOR UPDATE, then both existing user rows FOR UPDATE in ascending UUID order, then existing balance rows in that same order. No path acquires another player or the initialization singleton afterward. Future financial writers must follow player-before-accounts ordering; account-only provisioning must never acquire a player after an account. Holdings and quote writes already take the player lock. Purchase never takes the initialization lock. Direct DML can deadlock against application lock order; PostgreSQL aborts a victim and the API reports a safe transient failure without partial success. Do not automatically retry business rejection.

After all locks, revalidate issuance/recipient/supply and choose Quotes.latest/1 within the transaction. That read is the authoritative decision point. The shared player lock excludes concurrent quote confirmation through commit. If confirmation locks first, purchase sees the new quote after waiting; if purchase locks first it commits at the old quote before confirmation. Record that exact quote UUID, version/effective facts, Decimal unit price and total. Never scan backwards for a convenient price.

Reject buyer=recipient as self_purchase. Missing buyer balance means zero existing funds, not permission to create credits. A missing seller projection may be initialized to zero in the successful transaction. New buyer holdings start at zero only in that transaction. Finite exact Decimal/NUMERIC values retain cents without floats; quantity is 1..2147483647, inventory still limits each purchase to at most the available conserved supply.

Commit the debit, credit, existing-token redistribution, immutable purchase, one transfer and exactly two ledger entries together. Database constraints protect nonnegative balances, participant/quote linkage, exact arithmetic, unique request/transfer/ledger identities and complete balanced evidence. UPDATE/DELETE/TRUNCATE of financial evidence is rejected by database guards. Rollback leaves neither financial effects nor a key reservation. Retained quote and issuance guards remain intact.

## Consequences and alternatives

All purchases serialize on the recipient account as well as relevant players; acceptable for CP2 with no invented throughput SLA. PostgreSQL remains authoritative; no Redis locks, job, reservation, external service or retry broker. Independent committed connections and explicit barriers must test both quote orders, cross-player spending and duplicate delivery; shared Sandbox connections cannot prove those races.

Application-only deduplication loses restart safety; permanent pending/failed keys violate retry semantics. Choosing a quote before locking is stale. Buyer-only balance locking omits the shared recipient and deadlock ordering. Funding endpoints and permitted self-purchase no-ops change approved product scope. Ordinary DB-owner destructive DDL is outside the existing immutability threat model.
