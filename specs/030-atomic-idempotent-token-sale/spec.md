# Outcome specification: Atomic idempotent token sale

**Feature Branch**: `030-atomic-idempotent-token-sale`

**Task**: `TASK-030`

## Outcome

Sell owned tokens at the current quote while preserving holdings, balance, supply, and ledger.

## Acceptance

- [ ] A seller holding tokens sells a positive whole-number quantity to the
      designated initial recipient (market stand) at exactly the one
      authoritative current quote; the market stand is debited
      quantity × unit quote, the seller is credited the same exact amount,
      tokens move seller → market stand, holdings and the 100-token supply
      are conserved, and one immutable sale record with its paired debit/credit
      ledger entries and token transfer is retained.
- [ ] Repeating a completed sale with the same seller, request key, and
      details returns the original evidence with no further effects; reuse of
      the key with different details returns `key_conflict`; concurrent
      identical deliveries produce exactly one sale.
- [ ] Rejections (missing market credits, insufficient seller inventory,
      self-sale, uninitialized or missing player, unavailable quote,
      inconsistent supply, invalid request, unauthenticated) leave balances,
      holdings, supply, and history exactly unchanged and do not consume the
      request key.
- [ ] Delivered tests cover successful transfer and exact arithmetic,
      sequential and concurrent replay, lost-acknowledgement retry, key
      conflict and seller-scoped keys, quote-decision-point ordering with
      quote confirmation, rollback-free refusals, recovery after rejection,
      and the HTTP contract (`POST /api/sales` with `api_protected`
      authentication and an updated published OpenAPI 3 document).

## Scope

- Implement only the outcome and directly required tests or documentation.

## Non-goals

- Unrelated product behavior and opportunistic refactors.

## Risk

- Declared: pending; deterministic path classification is authoritative.

## Decisions

- Human decision (2026-10-27, ezequielgonzalez, recorded in the backlog
  task): a sale mirrors the TASK-029 purchase contract — the designated
  initial recipient (market stand) buys the seller's tokens at the one
  authoritative current quote, pays the seller from its own credited balance,
  all-or-nothing, rejected unchanged when the market lacks the exact credits
  the sale requires. No user-to-user resale listings, no fees, and no
  synthetic crediting. Consequences: sale lives beside purchases as
  `market_sales` with mirror locks/ordering/refusal kinds; the shared
  credit-entry and token-transfer evidence tables are widened with nullable
  `sale_id` ownership so financial history stays in one place; application
  provisioned seller balances remain an input (sale proceeds satisfy
  seller-side bookkeeping); the designated stand is the only buyer.
