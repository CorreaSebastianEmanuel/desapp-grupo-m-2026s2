# Implementation Plan: Atomic Idempotent Token Sale

**Task**: TASK-030
**Spec**: [spec.md](spec.md)
**Date**: 2026-10-26

## Summary

Extend the existing Market domain with a direct authenticated sale that mirrors the completed purchase boundary while reversing asset movement. PostgreSQL remains authoritative: one transaction locks the player, both user identities, both balances, and current holdings; selects the current quote; validates funds/tokens; updates projections; and inserts complete immutable sale evidence.

## Architecture boundary

- `FootballMarket.Market` delegates to a new `Sales` domain facade.
- `SaleInput` performs pure canonical validation.
- `SaleStore` owns PostgreSQL locking, exact calculation, atomic mutation, idempotency, and evidence lookup.
- New Ecto schemas represent sale operations, sale ledger entries, and sale token transfers.
- `SaleController` and `SaleJSON` only adapt HTTP input/output; no business or persistence rules enter the web layer.
- Reuse existing users, issuances, holdings, quotes, balances, market consistency validation, authentication, and player/user lock order.

## Persistence design

Add three append-only structures rather than weakening the already verified purchase tables:

- `market_sales`: seller, fixed recipient, player, quote snapshot, request key, quantity, exact money, and completion time; unique `(seller_id, request_key)`.
- `market_sale_credit_entries`: exactly one recipient debit and one seller credit equal to the sale total.
- `market_sale_token_transfers`: exactly one transfer from seller to fixed recipient equal to the sale quantity.

Deferred constraint triggers reject incomplete or contradictory evidence. Existing `market_immutable()` protects update/delete/truncate. Holdings and balances remain mutable projections protected by their existing nonnegative and supply constraints.

## Coordination and failure model

1. Refuse nested transaction use.
2. Acquire seller/request-key advisory lock and resolve completed replay/conflict first.
3. Lock player, validate issuance/counterparty, then lock both users and balances in stable UUID order.
4. Read holdings and current quote while holding the player lock; validate full seller quantity and recipient funds.
5. Apply exact balance/holding changes and insert complete sale evidence in one transaction.
6. Map storage/connection/constraint failures to `temporarily_unavailable`; failed transactions retain no key or partial effects.

This ordering is compatible with purchase and quote writers and is recorded in ADR-0036.

## HTTP contract

`POST /api/sales` accepts exactly `player_id`, `quantity`, and `request_key` through `:api_protected`. Success and matching replay return 200 with immutable sale data and decimal strings. Safe errors mirror purchase mapping, adding `insufficient_tokens`, `insufficient_market_funds`, and `self_sale` as 409 outcomes.

## Verification plan

- Unit: strict input boundary and exact-money schema validation.
- Integration: transfer/evidence, refusal snapshots, retry/conflict, duplicate races, competing funds/tokens, quote ordering, purchase/sale serialization, rollback fault injection, deferred integrity, immutability, and migration upgrade.
- Web/OpenAPI: authenticated API-key/JWT identity, exact response, authority override rejection, error mapping, protected-route metadata, and schema publication.
- Repository gates: format, compile with warnings-as-errors, unit profile, integration profile, Credo inventory/check, OpenAPI validation, and relevant runtime checks available locally.

No workflow execution, commit, push, PR, backlog completion, or independent PASS is part of this manual implementation session.
