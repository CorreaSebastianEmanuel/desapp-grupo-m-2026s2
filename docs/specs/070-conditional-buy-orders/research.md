# Feature-specific research

## Shared purchase transaction

- Decision: extract transaction-local purchase preparation/write primitives, retaining public PurchaseStore.execute transaction ownership. See ADR-0036.
- Rationale: local `purchase_store.ex` explicitly returns transaction_in_progress for caller transactions and uses Repo.rollback for insufficiency. Wrapping the public call cannot atomically complete an order or commit a rejection. Eligibility must return before writes; transient failure must abort the outer transaction.
- Alternatives considered: separate commits can orphan a purchase; nested public call is refused; copying financial logic would diverge from direct purchase rules.

## Purchase identity

- Decision: conditional_order_id uniquely identifies conditional evidence; direct lookup and buyer/key uniqueness apply only to direct rows.
- Rationale: `purchase_input.ex` accepts arbitrary UTF-8 request keys up to 128 characters. No derived textual key is reserved; a user could otherwise preoccupy an order's key through direct purchase. Historical direct rows stay null-origin and retain current replay behavior.
- Alternatives considered: reserve a client prefix (breaks existing keys), trust UUID unpredictability (not an integrity constraint), reuse matching direct purchase (could falsely execute an order without a new trade).

## Quote and clock authority

- Decision: reuse existing player lock shared by quote confirmation and purchase; sample clock_timestamp after lock acquisition, then use one Quotes.latest result.
- Rationale: `quotes/store.ex` locks the player and exposes wall-clock access; `quotes/reader.ex` defines authoritative sequence ordering. Transaction-start now() can predate lock waits. Separate-connection barriers are established in purchases/quote_order_test.exs.
- Alternatives considered: event price, pre-lock read, old cheaper quote, transaction-start expiry timestamp all violate accepted boundaries.

No external research needed. Technology, services and profile decisions remain docs/ARCHITECTURE.md, ADR-0017, ADR-0028 and ADR-0032; this feature does not reopen them.
