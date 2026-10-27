# ADR-0036: Atomic sale counterparty and coordination

## Status

Accepted for TASK-030 on 2026-10-26.

## Context

The product requires users to sell only owned tokens at the current quote. Existing issuance establishes one immutable initial recipient, and TASK-029 already uses that recipient as the inventory seller and credit receiver. No funding, credit issuer, order book, or arbitrary counterparty exists in the CP2 boundary.

## Decision

Direct sales reverse the TASK-029 asset flow against the same initial recipient: the authenticated user transfers owned tokens to that recipient, which pays from its existing credit balance. Missing or insufficient recipient funds reject the entire sale; no credits are created and balances never become negative.

Sales reuse the purchase lock order: completed-key advisory lock, player row, sorted user rows, sorted balance rows, then holdings/current quote. The player lock orders sale against purchases, quote confirmation, and holding writes. Sale evidence is stored in dedicated append-only tables with deferred completeness checks so the already verified purchase schema and triggers remain unchanged. TASK-031 may later unify read models across purchase and sale evidence.

## Consequences

- Supply and credit movement remain conserved and exactly auditable.
- The market can buy back only to the extent that its initial recipient has accumulated or otherwise already holds credits.
- Cross-trade locking is deterministic and uses the existing PostgreSQL authority.
- Public history, funding, listings, partial fills, and conditional sales remain outside TASK-030.
