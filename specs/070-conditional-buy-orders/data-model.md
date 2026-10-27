# Conditional order persistence

## ConditionalBuyOrder / market_conditional_buy_orders

UUID id; owner_id FK accounts user; player_id FK initialized player; quantity integer 1..100; maximum_unit_price exact NUMERIC finite positive cents; created_at and expires_at timestamptz(6), expiry strictly greater than creation; status constrained to pending/executed/cancelled/expired/rejected; completed_at nullable timestamptz(6); rejection_reason nullable insufficient_funds/insufficient_inventory; purchase_id nullable unique FK market_purchases. Requested terms never change. No updated_at write on reads.

Pending has null completion, rejection and purchase. Cancelled/expired have completion only. Rejected has completion and exactly one allowed reason, no purchase. Executed has completion and a purchase link, no rejection. Actual quote_id/unit_price/total and quote provenance are read from immutable linked Purchase, avoiding a second monetary truth. Completion is the serialized domain decision timestamp. Expired completion must be >= expires_at; cancellation, rejection and execution decisions must be < expires_at. No timing test should assume transaction commit precedes expiry.

Transitions: pending -> executed | cancelled | expired | rejected. Terminal -> same persisted outcome only, never another update. Trigger guards prohibit requested-term updates, terminal mutations and lifecycle deletion/truncation; deferred constraint triggers validate complete linkage at commit. Domain checks initialization while holding player lock; FKs enforce identity/issuance existence. Index (owner_id, created_at, id) supports owner reads; partial (player_id,id) and (expires_at,id) where pending support replay/expiry scans. No reservation relation.

## Existing Purchase extension

Add nullable conditional_order_id UUID FK orders, unique when nonnull. Direct historical rows remain null. Replace unconditional buyer/request_key uniqueness with equivalent partial uniqueness for direct rows; direct lookup includes IS NULL. Conditional evidence lookup/uniqueness uses conditional_order_id. Conditional internal request_key may contain order UUID but has no direct identity authority. Existing public input and returned direct evidence remain unchanged; serializers exclude the new internal origin field unless explicitly part of order output.

Executed order and linked purchase must reciprocally reference each other and match owner, player and quantity; purchase's price <= maximum, completion before expiry, actual total remains quantity*unit_price. Deferred integrity validation checks both sides at commit, allowing either insert order within a single transaction. Validate upgrading preexisting purchase/transfer/ledger rows without modification and preserve original append-only triggers. New insert shape must cooperate with existing purchase completeness constraints.

## Existing market facts

Issuance stays 100. Holding and credit projections may change only through existing transactional rules; purchases, transfer, paired ledger entries and quotes remain immutable. Missing buyer balance is zero existing funds; no credit provisioning interface. Decimal/NUMERIC multiplication only. Monetary validation rejects floats, NaN/Infinity, nonpositive or excess fractional precision without rounding. Uninitialized/foreign identities and unsupported term updates have no durable effects.

## Derived read projection

expiry_reached = database_clock >= expires_at for every status. One clock sample per response. It is never stored, and never substitutes for lifecycle status. Requested terms, persisted status, creation/expiry/completion and execution/rejection details are owner-scoped. Due pending rows remain pending until evaluated/cancelled as specified. No query creates job or audit mutations.
