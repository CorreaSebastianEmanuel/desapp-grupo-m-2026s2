# Feature-specific seam decisions

## Atomic producer seams
Decision: compose the existing create_in_transaction! with Oban insert; retain quote_evaluation_requests and add its event-ID wake in Quotes.Store.confirm!.
Rationale: current create command owns commit, while quote confirmation already stores durable follow-up. No lossy post-commit scheduling.
Alternatives considered: PubSub-only delivery loses work; a second quote outbox duplicates TASK-026.
Evidence: lib/football_market/market/conditional_order_store.ex; lib/football_market/quotes/store.ex; ADR-0029/0036.

## Reproducible competing decisions
Decision: a PostgreSQL singleton cursor plus captured ordered member UUIDs; one member/evaluation per transaction, queue concurrency one.
Rationale: accounts and issuance recipient can conflict across players. A durable snapshot defines observable order despite overlapping workers, late commits and backdated creation timestamps. No winner promise outside that pass.
Alternatives considered: player-only locks do not order shared balances; queue setting alone is not a multi-instance correctness lock; holding player/account locks across a whole batch violates ADR-0032. A moving keyset can skip late rows or insert new contenders into a pass.
Evidence: ADR-0032/0036; ConditionalOrderStore.pending_candidates currently orders only by UUID and cannot serve this new pass contract unchanged.

## Quote authority and leased acceptance
Decision: reuse PurchaseTransaction.current_quote!, Quotes.latest and the existing claim/acknowledge APIs; acceptance and Oban wake commit in one outer transaction.
Rationale: current quote selection uses authoritative performance sequence; validity already checks exact positive values, and infrastructure errors are transient. Quote lease fencing samples database clock after locks.
Alternatives considered: event-price authorization, a new active-strategy filter, and backwards cheap-quote search would change existing rules. Separate enqueue and acknowledge transactions create an ambiguous consumption gap.
Evidence: lib/football_market/market/purchase_transaction.ex:current_quote!; lib/football_market/quotes/reader.ex; lib/football_market/quotes/recovery.ex.

## Notification strength
Decision: best-effort post-commit PubSub hints, no durable notification ledger.
Rationale: FR-010 permits lost notification and requires authoritative reconnect reads; storing another delivery ledger adds no accepted guarantee.
Alternatives considered: guaranteed delivery exceeds scope; broadcasting inside a transaction exposes uncommitted outcomes.
Settled stack choices remain docs/ARCHITECTURE.md and ADR-0017; no external research required.
