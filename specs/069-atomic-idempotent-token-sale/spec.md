# Feature Specification: Atomic Idempotent Token Sale

**Feature**: `069-atomic-idempotent-token-sale`
**Created**: 2026-10-26
**Status**: Draft
**Input**: TASK-030 — Sell owned tokens at the current quote while preserving holdings, balance, supply, and ledger.

## User scenarios and testing

The seller is the authenticated market user. A sale transfers only that user's existing tokens back to the immutable initial recipient from TASK-028. The initial recipient pays with credits already present in its balance. A sale never mints tokens or credits and never accepts caller-supplied identity or price authority.

### User Story 1 — Sell owned tokens at the current quote (P1)

As an authenticated holder, I can sell a positive whole-number quantity of my player tokens at the current quote so that I receive the exact proceeds and the initial recipient recovers the tokens.

Acceptance scenarios:

1. Given an initialized player, a positive current quote, sufficient seller holdings, and sufficient initial-recipient credits, a sale transfers the requested tokens from seller to recipient, credits the seller, and debits the recipient by `quantity × unit quote`.
2. A completed sale retains seller, recipient, player, quote identity and version evidence, quantity, unit price, total, request key, completion time, one token transfer, and a balanced debit/credit ledger pair.
3. The player supply remains exactly 100 and unrelated players, holdings, balances, purchases, and quotes remain unchanged.
4. If quote confirmation races with a sale, the sale uses exactly the quote that is current after it acquires the shared player lock; the retained evidence matches that quote.

### User Story 2 — Retry safely (P1)

As a client retrying after a timeout, I can repeat a sale request without selling or receiving payment twice.

Acceptance scenarios:

1. Repeating the same seller-scoped request key with the same player and quantity returns the original immutable sale without new effects.
2. Concurrent identical requests produce one sale, one transfer, and one ledger pair; both successful callers observe the same operation.
3. Reusing a completed key with another player or quantity returns `key_conflict` and preserves the original sale.
4. Failed attempts do not consume the request key and may succeed later after holdings, counterparty funds, or pricing become available.

### User Story 3 — Reject unsafe or impossible sales (P1)

As a seller, I receive a safe, distinguishable refusal when a sale cannot complete, with no partial state.

Acceptance scenarios:

1. Reject malformed input, unauthenticated calls, missing players, uninitialized players, absent/nonpositive quotes, and attempts by the initial recipient to sell to itself.
2. Reject a seller that owns fewer tokens than requested as `insufficient_tokens`.
3. Reject a sale when the initial recipient lacks the exact purchase funds as `insufficient_market_funds`.
4. Any business rejection, write failure, deferred-integrity failure, or nested transaction leaves balances, holdings, sale history, transfer evidence, and ledger evidence unchanged.

## Functional requirements

- **FR-001**: Accept only an authenticated actor plus exactly `player_id`, positive integer `quantity` (maximum 2,147,483,647), and a nonblank Unicode request key of at most 128 characters without NUL bytes.
- **FR-002**: The authenticated account is always the seller; caller-supplied seller, recipient, price, quote, or total authority is rejected.
- **FR-003**: Sell only tokens currently owned by the seller and transfer them only to the player's immutable initial recipient. No minting, burning, listing, arbitrary counterparty, or partial fill is allowed.
- **FR-004**: Select the current valid positive quote at the serialized decision point and retain its immutable identity, effective time, rule/version, and nullable configuration/mapping/performance evidence.
- **FR-005**: Calculate the total exactly as integer quantity multiplied by exact cent-valued `Decimal`/PostgreSQL `NUMERIC`; floats are prohibited.
- **FR-006**: Debit only credits already held by the initial recipient and credit the seller by the same total. The sale creates no credits, funding operation, fee, or negative balance.
- **FR-007**: Atomically commit the two balance changes, two holding changes, sale record, one token transfer, and balanced ledger pair; otherwise commit none.
- **FR-008**: Preserve 100 tokens per initialized player, nonnegative holdings and balances, append-only financial history, and existing purchase evidence.
- **FR-009**: Scope idempotency to `(seller_id, request_key)`. Matching completed retries return the original result; conflicting completed retries return `key_conflict`; failed attempts remain retryable.
- **FR-010**: Serialize concurrent sales, purchases, and quote confirmations through the existing player/user lock order so they cannot double-sell tokens, overspend the recipient, or retain mismatched pricing.
- **FR-011**: Expose `POST /api/sales` through the existing protected API pipeline and return exact money as strings. No public history/list route is added.
- **FR-012**: Automated tests cover successful exact transfer, validation, all business refusals, rollback, immutable storage, sequential and concurrent idempotency, competing sales, purchase/sale interaction, and quote ordering.

## Success criteria

- **SC-001**: Every successful sale transfers exactly the requested owned quantity and exactly `quantity × retained quote` credits in the opposite direction.
- **SC-002**: Every tested duplicate key creates at most one sale, one transfer, and one ledger pair.
- **SC-003**: Every tested rejection or injected failure leaves the complete market snapshot unchanged.
- **SC-004**: All concurrency tests preserve nonnegative balances/holdings, total supply 100, and quote/evidence agreement.
- **SC-005**: HTTP clients can distinguish success, invalid input/authentication, missing player, unavailable market state, insufficient tokens, insufficient market funds, and key conflict without storage details.

## Scope boundary and assumptions

- TASK-029 purchase behavior and persistence remain unchanged.
- The initial recipient is the only sale counterparty because it is the durable market inventory owner already established by TASK-028. It must spend existing credits; adding funding or a credit issuer is out of scope.
- TASK-031 owns unified public transaction-history access. This task retains internal immutable sale evidence but adds no list/history endpoint.
- Conditional orders, partial fills, user-to-user listings, fees, notifications, portfolio calculations, and UI are out of scope.
