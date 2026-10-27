# Feature Specification: Atomic Idempotent Token Purchase

**Feature Branch**: `029-atomic-idempotent-token-purchase`

**Created**: 2026-10-23

**Status**: Draft

**Input**: TASK-029 — Buy available tokens at the current quote with locking, balance changes, ledger, and idempotency. Human feedback establishes that buyers may spend only credits already provisioned to their accounts; funding and credit grants are outside this task.

## User Scenarios & Testing *(mandatory)*

The buyer is an authenticated market user. The designated initial recipient from TASK-028 is the source of available tokens and receives purchase proceeds. Authentication establishes the buyer's identity; a request cannot buy for another account. Purchases use the latest valid quote retained under TASK-026 and preserve its history.

### User Story 1 - Buy Available Player Tokens (Priority: P1)

As an authenticated user, I can purchase a whole-number quantity of available player tokens at the current quote, so that my holding increases and the seller receives the corresponding credits.

**Why this priority**: Buying is a core market action and transfers the fixed initial supply into user portfolios.

**Independent Test**: Given an issued player, a current positive quote, enough available inventory, and enough buyer credits, purchase a quantity and verify the resulting buyer and seller balances, holdings, exact purchase total, and durable operation record.

**Acceptance Scenarios**:

1. **Given** a player with an available current quote, enough tokens in the designated recipient's holding, and a buyer with sufficient credits, **When** the buyer requests a positive whole-number quantity, **Then** the quantity transfers from that recipient to the buyer, the buyer is charged quantity multiplied by the current unit quote, and the recipient is credited the same amount.
2. **Given** a successful purchase, **When** the buyer or market operator reads the retained operation, **Then** it identifies the buyer, source recipient, player, quantity, exact unit quote, exact total, request key, and completion time.
3. **Given** multiple players are initialized to the same designated recipient, **When** a purchase is completed for one player, **Then** only that player's holdings and balances change, and each player's supply remains exactly 100 across all owners.
4. **Given** the buyer has sufficient funds and inventory is available, **When** the latest quote changes while the purchase competes to complete, **Then** the purchase uses one authoritative current quote: it completes entirely at that quote or fails without effects; it never charges a stale quote while recording a different one.

### User Story 2 - Retry a Purchase Without Duplicating It (Priority: P1)

As a buyer or a retrying client, I can safely repeat a purchase request after a timeout or concurrent delivery, so that one intended purchase is charged and recorded at most once.

**Why this priority**: A repeated charge or token transfer would violate market integrity and undermine user trust.

**Independent Test**: Submit the same request key sequentially and concurrently, including a retry after the first completion acknowledgement is lost; verify that all successful responses identify one operation and that balances, holdings, and ledger change once.

**Acceptance Scenarios**:

1. **Given** a purchase completed for a buyer and request key, **When** the same buyer retries the same key and same purchase details, **Then** the existing purchase result is returned and no additional balance, holding, or ledger changes occur.
2. **Given** two identical requests for the same buyer and key arrive concurrently, **When** both are processed, **Then** they resolve to the same completed purchase or one waits and reads that result, with only one transfer and one purchase record.
3. **Given** a request key has completed a purchase, **When** that buyer reuses the key with different player or quantity details, **Then** the request is rejected as a key conflict and the original purchase remains unchanged.
4. **Given** a purchase committed but its response was not received, **When** the buyer retries with the same key and details, **Then** the completed operation is returned without a second charge or transfer.

### User Story 3 - Reject a Purchase That Cannot Complete (Priority: P1)

As a buyer, I receive a clear failure when the requested purchase is invalid or cannot be covered by current funds, inventory, or quote, so that no partial financial change is left behind.

**Why this priority**: A failed trade must not overdraw an account, oversell the fixed supply, or leave balances and holdings out of sync.

**Independent Test**: Attempt purchases with insufficient funds, insufficient available inventory, absent quote, invalid quantity, and missing player; verify the failure reason and unchanged balances, holdings, and purchase history.

**Acceptance Scenarios**:

1. **Given** the buyer's available balance is less than the exact purchase total, **When** a purchase is attempted, **Then** it fails for insufficient funds and creates no debit, credit, token transfer, or completed purchase record.
2. **Given** the designated recipient has fewer available tokens than requested, **When** a purchase is attempted, **Then** it fails for insufficient inventory without changing any holding, balance, or ledger record.
3. **Given** the player has no valid current quote, **When** a purchase is attempted, **Then** it fails for unavailable pricing without using an older quote or changing financial state.
4. **Given** the requested player does not exist or is not initialized, **When** a purchase is attempted, **Then** it fails without creating market state or changing balances.
5. **Given** a quantity is zero, negative, fractional, malformed, or outside the supported whole-number range, **When** a purchase is attempted, **Then** it is rejected before any financial changes.
6. **Given** a purchase attempt fails before commit, **When** its state is inspected, **Then** no partial balance changes, holding changes, or purchase record remain; the same request key may be retried after the cause is resolved.
7. **Given** a failed purchase has not completed, **When** the same key and details are retried after the buyer has enough funds or inventory becomes available, **Then** the purchase may complete once using the current quote at that later attempt.

### Edge Cases

- Concurrent purchases for the same player must serialize their effects against both inventory and quote changes; final holdings must never be negative and total supply must remain 100.
- Concurrent purchases by one buyer, including purchases for different players, must not spend the same credits twice or leave a negative balance.
- Concurrent use of one request key by different buyers is independent because request keys are scoped to the authenticated buyer.
- A request key is required, nonblank, and at most 128 characters; missing, blank, or longer keys fail without effects.
- Exact total cost is calculated without floating-point arithmetic. Since token quantity is integral and quote precision is two decimal places, totals retain exact credit precision.
- If any part of a purchase cannot be retained, no debit, credit, holding transfer, or completed purchase record is visible.
- Only tokens currently held by the designated initial recipient are available for purchase in this feature. Tokens held by other users are not silently sourced or transferred.
- Rejected requests do not consume the request key; only a completed purchase is retained as the idempotent result.
- The successful purchase and its operation record are append-only. A retry does not create a second operation or rewrite the original operation's quote or amount.
- Self-purchases by the designated initial recipient are rejected as `self_purchase` before mutation; no no-op operation or ledger pair is created.
- The buyer cannot choose the source recipient, quote, unit price, total, or buyer identity in a way that overrides authoritative market state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow an authenticated market user to request a purchase for their own account, a stable player identity, a positive whole-number quantity, and a nonblank request key of at most 128 characters scoped to that user. A caller-supplied buyer identity MUST NOT override the authenticated identity.
- **FR-002**: The system MUST source purchased tokens only from the designated initial recipient's current holding for that player. A purchase MUST transfer existing tokens and MUST NOT mint, burn, or transfer tokens from another user's holding.
- **FR-003**: The system MUST price a purchase using the current valid quote at the purchase's single authoritative decision point. If a quote change and purchase overlap, the purchase MUST use the quote ordered as current at that point, and the retained operation MUST identify that exact quote, including its effective time/version identity where available. A request MUST NOT supply or override the price.
- **FR-004**: The exact total MUST equal the requested whole-number quantity multiplied by the exact unit quote. Monetary values MUST NOT use floating-point arithmetic.
- **FR-005**: A buyer MUST have credits provisioned to their account before purchase and MUST spend only that existing balance. A completed purchase MUST debit the buyer by the exact total and credit the designated initial recipient by the same exact total. The net credit movement across these two accounts MUST be zero; this feature MUST NOT create credits or implement funding, deposits, withdrawals, credit grants, or fees.
- **FR-006**: A successful purchase MUST atomically retain the buyer debit, recipient credit, token transfer, and one immutable purchase record. Any failure before completion MUST leave all four effects absent.
- **FR-007**: The system MUST prevent simultaneous purchases from overspending a buyer, overselling the recipient's player inventory, or using a quote that is no longer current at the purchase's authoritative decision point. A buyer's balance MUST NOT become negative and total token supply MUST remain 100 per initialized player.
- **FR-008**: The system MUST require sufficient buyer balance and sufficient recipient inventory for the entire requested quantity. Purchases MUST be all-or-nothing; the system MUST NOT partially fill, queue, or automatically retry a business rejection.
- **FR-009**: A completed purchase MUST be durably identifiable by buyer, source recipient, player, quantity, exact unit quote, exact total, request key, and completion time. Purchase and financial ledger history MUST be append-only and remain retrievable after later trades or quote changes.
- **FR-010**: Repeating a completed request with the same authenticated buyer, request key, and purchase details MUST return the existing outcome without further effects. Reusing a completed key with different purchase details MUST fail with a key-conflict outcome and preserve the original operation.
- **FR-011**: A request key MUST identify at most one completed purchase for one buyer. Concurrent identical requests MUST produce at most one purchase. A failed, uncompleted attempt MUST NOT reserve the key and MAY be retried after its cause is resolved.
- **FR-012**: The system MUST reject unauthenticated requests, missing or uninitialized players, malformed request keys, nonpositive/nonintegral quantities, unavailable or nonpositive current quotes, insufficient funds, insufficient inventory, self-purchases by the designated initial recipient, and inconsistent market state with distinguishable safe outcomes and no financial or holding effects.
- **FR-013**: When multiple rejection conditions apply, the system MAY report any applicable validation failure; it MUST NOT report successful completion or mutate state. A valid completed idempotent retry MUST return the original success, while a conflicting key reuse MUST report a key conflict.
- **FR-014**: Automated behavioral tests MUST cover every acceptance scenario and edge case, including exact arithmetic, successful transfer, preserved supply, balance and inventory limits, quote-change ordering, sequential and concurrent duplicate requests, lost-acknowledgement retry, key conflict, rollback, failure retry, request-key bounds, and isolation between players and buyers. Tests MAY provision buyer credits as setup.
- **FR-015**: This feature MUST be limited to direct all-or-nothing purchases. User funding and withdrawal, arbitrary seller listings, sales by ordinary users, fees, partial fills, conditional orders, notifications, portfolio presentation, and purchase-history presentation are outside scope.

### Key Entities

- **Buyer**: The authenticated market user whose balance is charged and whose holding receives tokens.
- **Designated Initial Recipient**: The market-wide recipient established by TASK-028; supplies only tokens it currently holds for the player and receives purchase proceeds.
- **Player Quote**: The latest valid exact unit price retained for an initialized player, with its effective time and version identity.
- **Holding**: The whole-number quantity of one player's conserved token supply owned by one user.
- **Purchase Request**: A buyer-scoped request key and the player/quantity details identifying one intended purchase.
- **Purchase Operation**: Immutable evidence of a completed transfer and its exact price, total, participants, request key, and completion time.
- **Credit Balance and Ledger**: Spendable credits and append-only evidence of equal buyer debit and recipient credit for each completed purchase.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 100% of successful purchase cases, the buyer receives exactly the requested whole-token quantity, pays exactly quantity multiplied by the retained current quote, and the designated recipient receives the same credit amount.
- **SC-002**: Across 100% of tested sequential and concurrent duplicate requests, one buyer-scoped key creates no more than one completed purchase, one token transfer, and one corresponding debit/credit pair.
- **SC-003**: In 100% of rejected, interrupted, or rolled-back attempts, balances, holdings, and completed purchase history remain unchanged by the attempt.
- **SC-004**: In 100% of concurrent balance, inventory, and quote-change cases, no buyer is overdrawn, no player's total supply differs from 100, and every completed operation records the quote used to calculate its charge.
- **SC-005**: For every completed purchase, a reviewer can retrieve its buyer, source recipient, player, quantity, exact unit quote and total, request key, and completion time after subsequent market activity.
- **SC-006**: Buyers can distinguish completed purchases, insufficient funds, insufficient inventory, unavailable quotes, invalid requests, unauthenticated requests, inconsistent market state, and conflicting request-key reuse from the operation outcome.

## Assumptions

- TASK-010 supplies authenticated actor identity. The buyer is always that actor.
- TASK-026 owns current quote calculation and immutable quote history. This feature reads the current authoritative quote but does not calculate or expose quotes.
- TASK-028 owns fixed supply, the designated initial recipient, and the initial quote. Its player identity and recipient rules remain authoritative.
- Buyers can purchase only from credits already provisioned to their accounts. Funding, deposits, withdrawals, and credit grants are outside TASK-029; tests may provision balances as setup. A purchase moves credits from buyer to designated initial recipient without creating value.
- The designated initial recipient is the seller for this task because it owns initial market inventory. Ordinary users' holdings become eligible for resale only through separate behavior.
- Quote and balance values use exact credit precision with two decimal places, consistent with the market quote contract; no fee or rounding adjustment is applied to the total.
- A purchase succeeds only if the current quote is valid and positive, and both funds and full requested inventory are available at the serialized completion point.
- Durable idempotency applies to completed purchases. A failed attempt has no retained financial result and can be retried with the same key after conditions change.
- TASK-030 owns sales by ordinary users; TASK-031 owns public immutable transaction-history access; TASK-059/060 own conditional order execution. Those features reuse these purchase invariants without expanding TASK-029.
