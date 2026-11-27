# Feature Specification: Conditional Buy Orders

**Feature Branch**: `059-conditional-buy-order-domain-and-api`

**Created**: 2026-10-27

**Status**: Draft

**Input**: TASK-059 — Price-triggered all-or-nothing buy orders with explicit lifecycle, expiry, cancellation, ownership and atomic idempotent execution.

## User Scenarios & Testing

An authenticated market user can leave an instruction to buy a whole-number quantity of one player's tokens when that player's current valid quote is at or below a maximum unit price. The order expires at a user-selected future time. The order does not reserve credits or tokens: a qualifying price is necessary but is not a guarantee of purchase. Existing purchase rules determine the actual quote, available balance, and inventory at execution.

An ordinary order read reports the persisted lifecycle status and a derived `expiry_reached` indicator that is false before the explicit expiry and true at or after it. Reads never mutate orders or enqueue work. A pending order is ineligible for execution at or after expiry even if an evaluator has not yet persisted its transition to `expired`.

### User Story 1 - Place and Track a Conditional Buy Order (Priority: P1)

As an authenticated market user, I can create a buy order with a player, quantity, maximum unit price, and explicit expiry, and see its current status, so that I can request a future purchase without continuously watching prices.

**Why this priority**: Creating an order and understanding whether it remains active or completed is the core value of the feature.

**Independent Test**: Create a valid order whose maximum is below the current quote, then read it and the user's order list; verify they report its persisted pending status, correct expiry indicator, requested terms, and no balance or holding changes. Repeat reads across its expiry without an evaluation and verify the reads do not change persisted state or enqueue work.

**Acceptance Scenarios**:

1. **Given** an authenticated user, an initialized player, a valid quantity and maximum price, and a future expiry, **When** the user creates an order, **Then** the system retains a pending order owned by that user with the exact requested terms and creation time.
2. **Given** a user has orders and another user has orders, **When** either user lists or reads orders, **Then** they can see only their own orders and cannot infer another user's order details.
3. **Given** a valid order whose maximum price is below the current quote or for which no valid current quote exists, **When** it is evaluated, **Then** it remains pending without changing credits or holdings.
4. **Given** a user submits an invalid player, quantity, maximum price, or expiry, **When** they create an order, **Then** the request is rejected with a safe validation outcome and no order or financial change is retained.
5. **Given** an order is pending, **When** its owner reads it or lists orders immediately before expiry, **Then** the persisted status is pending and the derived expiry indicator is false.
6. **Given** an order is pending and no evaluator has transitioned it, **When** its owner reads it or lists orders exactly at or after expiry, **Then** the persisted status remains pending, the derived expiry indicator is true, and the order is ineligible for execution; the read does not persist expiry, mutate the order, or enqueue work.
7. **Given** an evaluator has durably transitioned a due order to expired, **When** its owner reads or lists it, **Then** the persisted status is expired and terminal, the derived expiry indicator reflects the explicit expiry and current time, and the read causes no further state change or work enqueue.

### User Story 2 - Execute a Qualifying Order Once (Priority: P1)

As an order owner, I want a pending order to buy the full requested quantity when the current price meets my limit and the purchase can be completed, so that the order fulfills my instruction without partial trades or duplicate charges.

**Why this priority**: Triggered purchases must preserve the same market and financial integrity as direct purchases.

**Independent Test**: Create a pending order, make a confirmed current quote meet its limit, and evaluate the order repeatedly and concurrently; verify one complete purchase, one terminal executed order, and no duplicate effects.

**Acceptance Scenarios**:

1. **Given** a pending, unexpired order and a valid current quote at or below its maximum, with enough user credits and available inventory for the full quantity, **When** the order is evaluated, **Then** it executes entirely at that current quote and retains the corresponding purchase and financial changes atomically.
2. **Given** the current quote is above the order's maximum, **When** the order is evaluated, **Then** it remains pending and no purchase occurs.
3. **Given** a qualifying order has insufficient user credits or insufficient available inventory for the full quantity, **When** the order is evaluated, **Then** it becomes rejected with a user-visible reason and no partial purchase or financial change occurs.
4. **Given** an order has executed, **When** its evaluation is repeated, including concurrently or after a retry, **Then** the existing outcome is returned or observed and no second purchase, debit, credit, token transfer, or operation is created.
5. **Given** an order has executed, **When** the user reads it later, **Then** its record identifies the actual unit quote, total cost, and completion time used for the purchase.
6. **Given** a quote confirmation races an order evaluation, **When** both are serialized to a purchase decision, **Then** the limit check and purchase use one authoritative quote decision: if the quote confirmation commits first, an older event price cannot authorize execution; if evaluation commits its purchase decision first, that decision uses the quote current at that serialized point.
7. **Given** a quote commits for a player with pending orders but its evaluation delivery is interrupted or missed, **When** durable recovery runs, **Then** the evaluation is replayable and the affected pending orders, including those due for expiry, are revisited; this recovery has no specified timing guarantee and is owned by TASK-060.

### User Story 3 - Cancel or Let an Order Expire (Priority: P1)

As an order owner, I can cancel an order that is still pending and see when an order has expired, so that an old instruction cannot buy after I no longer want it active.

**Why this priority**: Explicit control of the order's active lifetime prevents unintended purchases and is part of the promised lifecycle.

**Independent Test**: Cancel a pending order and separately evaluate an order at or after its expiry; verify both become terminal without financial effects and cannot later execute.

**Acceptance Scenarios**:

1. **Given** the authenticated owner has a pending order before its expiry, **When** they cancel it, **Then** it becomes cancelled and cannot execute.
2. **Given** an order reaches its explicit expiry instant while pending, **When** it is evaluated, **Then** it becomes expired and cannot execute; an ordinary read at that instant reports persisted status `pending` with the derived expiry indicator true until the evaluator records the transition.
3. **Given** cancellation and a qualifying execution race, **When** both attempt to change the same pending order, **Then** exactly one transition wins atomically: if cancellation wins there is no purchase; if execution wins the purchase occurs once and cancellation reports the terminal state.
4. **Given** an order is executed, cancelled, expired, or rejected, **When** its owner tries to cancel it or it is evaluated again, **Then** its terminal outcome is preserved and no new financial effects occur.
5. **Given** a non-owner attempts to read or cancel an order, **When** the request is handled, **Then** no order details are disclosed and the order remains unchanged.

### Edge Cases

- Expiry is exclusive: an order is eligible only while the current time is strictly before its expiry; at or after expiry it is expired and cannot execute.
- Reads and lists are side-effect-free. They return persisted lifecycle status and a derived expiry indicator computed from the order's explicit expiry and current time; they do not persist expiry, mutate an order, or enqueue evaluation work. At or after expiry, a pending order may therefore be read as pending with the indicator true until evaluation durably transitions it to expired. Terminal persisted statuses remain terminal.
- The qualifying price check and purchase use the same authoritative current quote decision. A quote included in an old event or job cannot authorize a purchase if a newer quote confirmation commits before the serialized purchase decision. Quote confirmation racing evaluation is resolved by the serialization order, and must not combine eligibility from one quote with execution at another.
- A quote that is absent, invalid, or nonpositive cannot trigger execution; the order remains pending until it expires or a valid quote is available.
- Credits and inventory are not reserved at order creation. Other trades may use either before this order executes.
- Requested quantity must be a positive integer no greater than the player's fixed total supply of 100. The requested amount may exceed currently available inventory; if the price later qualifies but the full amount is unavailable, the order is rejected rather than partially filled.
- Maximum price must be a positive exact monetary amount using the market's supported quote precision. No floating-point amount or client-supplied execution price is accepted.
- A temporary system failure during evaluation leaves the order eligible for a safe retry; it does not become rejected or create partial effects.
- When a user has several eligible pending orders competing for the same credits or player inventory, each purchase remains individually all-or-nothing and the combined outcomes cannot overspend the user or exceed the fixed token supply.
- An order created when its price condition is already met is evaluated promptly under the same rules; it is not guaranteed to execute if funds or inventory are insufficient.
- A read at a given instant may observe a pending order whose expiry has passed if the evaluator has not yet committed the lifecycle transition; the derived expiry indicator communicates the time condition without pretending the transition has already been persisted.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow an authenticated market user to create a buy order only for their own account, naming an initialized player, a positive integer quantity from 1 through 100, a positive maximum unit price in the market's exact supported quote precision, and an explicit expiry later than the order's creation time.
- **FR-002**: The system MUST retain each order's owner, player, requested quantity, maximum unit price, creation time, expiry time, lifecycle status, and any terminal outcome details needed to explain the result.
- **FR-003**: The system MUST support the lifecycle states `pending`, `executed`, `cancelled`, `expired`, and `rejected`. Only pending orders may transition to a terminal state, and a terminal order's status and outcome MUST remain unchanged.
- **FR-004**: The system MUST make an order eligible for evaluation when it is created and after a new valid quote is confirmed for its player. Pending orders MUST be revisited so an order is not left pending indefinitely solely because an evaluation event was missed. Durable scheduling, quote-confirmation handoff, missed-work recovery, and expiry recovery are TASK-060 responsibilities.
- **FR-022**: Ordinary order reads and lists MUST return the persisted lifecycle status and a derived `expiry_reached` indicator that is false before the explicit expiry and true at or after it. Such queries MUST NOT persist expiry, mutate an order, or enqueue evaluation work. At or after expiry, a pending order MUST be ineligible for execution even before its persisted status transitions to expired; terminal persisted states MUST remain terminal.
- **FR-005**: The system MUST execute an order only if it is pending, the current time is earlier than expiry, and the current authoritative valid positive quote is less than or equal to its maximum unit price. An old event price MUST NOT authorize execution. The limit check and purchase MUST use a single serialized authoritative quote decision when quote confirmation races evaluation.
- **FR-006**: When an order qualifies and the entire purchase is possible, the system MUST use the existing market purchase rules and the then-current authoritative quote, balance, and available inventory. The buyer MUST be the order owner, and token sourcing MUST follow the existing purchase rules.
- **FR-007**: Order execution MUST be all-or-nothing. If the current quote qualifies but the owner lacks sufficient credits or the full requested inventory is unavailable, the system MUST set the order to `rejected` with a distinguishable reason and MUST NOT partially debit, credit, transfer tokens, or create a purchase operation.
- **FR-008**: The executed order state, purchase, buyer and seller credit movements, token transfer, and immutable operation record MUST commit atomically. A failed or interrupted transaction MUST leave none of these effects partially committed.
- **FR-009**: Each order MUST identify at most one purchase. Repeated or concurrent evaluations, including delivery after an ambiguous acknowledgement, MUST return or observe the same outcome and MUST NOT cause a second purchase or financial effect.
- **FR-010**: The system MUST NOT reserve or earmark credits or inventory for pending orders. Order creation MUST NOT change balances, holdings, or purchase history.
- **FR-011**: An owner MUST be able to cancel a pending order before expiry. Cancellation and execution MUST be serialized so exactly one transition can win; after either wins, the other operation MUST preserve and report the terminal outcome without further effects.
- **FR-012**: A pending order MUST become `expired` at or after its explicit expiry and MUST NOT execute at or after that time. Expiry, cancellation, rejection, and execution MUST be terminal outcomes.
- **FR-013**: The system MUST allow an authenticated owner to list and read their orders and MUST prevent users from reading, listing, or cancelling another user's orders. Unauthenticated access MUST be rejected without changing order state.
- **FR-014**: Order reads MUST expose the requested terms, current lifecycle state, creation and expiry times, and, for terminal orders, the completion time and relevant execution or rejection details. An executed order MUST expose its actual quote and total cost.
- **FR-015**: Invalid or missing order terms, unknown or uninitialized players, attempts to set another owner, and attempts to change immutable order terms after creation MUST be rejected without order or financial side effects.
- **FR-016**: The system MUST preserve the existing market invariants: total player token supply remains 100, balances never become negative, monetary arithmetic is exact and never floating point, financial transactions and audit records remain append-only, and quotes are not overwritten.
- **FR-017**: This feature MUST be limited to conditional buy orders. It MUST NOT add partial fills, sell orders, reservations, user funding, external brokers, a real-time execution guarantee, or an external notification service.
- **FR-018**: Automated behavioral tests MUST cover order validation and ownership, pending behavior, qualifying execution at the current quote, no-quote and above-limit cases, insufficient-funds and inventory rejection, expiry, cancellation, cancellation/execution races, repeated and concurrent evaluation, transactional rollback, multiple-order contention, and preservation of market invariants.
- **FR-019**: Automated behavioral tests MUST verify side-effect-free order read/list behavior immediately before expiry, exactly at expiry, after expiry but before lifecycle evaluation, and after the persisted transition to expired, including status, derived expiry indicator, and absence of read-triggered mutation or work enqueue.
- **FR-020**: Automated behavioral tests MUST cover both serialization orders for a quote-confirmation/evaluation race and prove that an older event quote cannot authorize a purchase after a newer quote has committed.
- **FR-021**: TASK-060's integration tests MUST prove that evaluation work associated with a committed quote is durable or replayable across an interrupted or missed delivery, and that recovery revisits pending orders and due expiries. These tests MUST NOT depend on order reads or lists to trigger recovery, and MUST NOT imply a timing service-level guarantee.

### Scope and ownership

- TASK-059 owns conditional order domain behavior and authenticated order access contracts, including lifecycle, validation, ownership, read projections, cancellation, and atomic idempotent purchase semantics.
- TASK-060 owns durable evaluation scheduling, quote-confirmation work handoff, missed-work recovery, and expiry recovery. Durable scheduling must not depend on reads/lists; quote confirmation and evaluation handoff must avoid a committed quote with lost evaluation work, and recovery must revisit pending orders and expiries.
- TASK-061 owns the user interface. This specification defines the user-visible order/read behavior but does not assign UI implementation to TASK-059.

### Key Entities

- **Conditional Buy Order**: A user's immutable purchase instruction containing its player, whole-token quantity, maximum unit price, creation time, explicit expiry, lifecycle state, and outcome.
- **Order Outcome**: The terminal result of an order: execution with actual price and total, cancellation, expiry, or rejection with a reason.
- **Current Player Quote**: The latest valid positive quote available at the authoritative purchase decision point; it determines both eligibility and actual purchase price.
- **Purchase Operation**: The existing immutable market record of a completed token purchase, including participants, quantity, quote, total, and completion time.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In every successful order, the user receives the full requested quantity and pays the exact total at the current quote that met the limit; no order produces a partial purchase.
- **SC-002**: Across repeated and concurrent evaluations of any one order, no more than one purchase, token transfer, or corresponding debit/credit pair is completed.
- **SC-003**: In every order that remains pending, is cancelled, expires, is rejected, or fails before commit, no partial purchase or financial effect is visible.
- **SC-004**: In every cancellation/execution race, the order has exactly one terminal outcome and its financial effects match that outcome.
- **SC-005**: Every order owner can retrieve all their own order terms and status, while no other user can retrieve its details or change it.
- **SC-006**: In all tested orders and competing trades, user balances remain nonnegative and each initialized player's total token supply remains exactly 100.
- **SC-007**: At every expiry boundary, order reads accurately distinguish persisted lifecycle status from the time-derived expiry indicator and never cause a lifecycle transition or evaluation enqueue.
- **SC-008**: In every quote-confirmation/evaluation race, execution uses one authoritative quote decision and no stale event price can produce a purchase after a newer quote has committed.

## Assumptions

- The existing authenticated identity and purchase operation are authoritative; orders do not accept a caller-selected owner, execution quote, seller, or total cost.
- The market's existing quote precision, validity, designated token source, and balance rules apply unchanged to conditional purchases.
- Users with multiple orders are not promised a global execution priority; every order is evaluated against the state available when its own serialized purchase decision is made.
- Expiry timestamps use UTC and must be explicitly supplied by the user; the feature does not silently choose a default duration.
- Transient infrastructure failures are retryable delivery failures, not business rejections. Business rejection applies only after a qualifying price is observed and the whole purchase cannot be completed for funds or inventory reasons.
