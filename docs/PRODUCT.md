# Football Player Market

Build a market where football performance determines historical player quotes and authenticated users trade a fixed supply of player tokens.

## Domain

- Players belong to Premier League, Bundesliga, La Liga, Serie A, or Ligue 1.
- Statistics are imported through replaceable external-provider adapters and persisted locally.
- At least two configurable valuation strategies exist; every quote stores its strategy version and effective date.
- Every player starts with 100 tokens owned by one superuser at one credit each.
- Users buy at the current quote from available inventory and sell only owned tokens.
- Portfolio shows quantity, average purchase price, current value, profit/loss, and history.

## Invariants

1. Player token supply is always 100.
2. Money and quotes never use floating-point arithmetic.
3. Trading is atomic and idempotent.
4. Financial transactions and audit records are append-only.
5. Historical quotes are inserted, never overwritten.
6. Provider failure does not break local reads.
7. Quotes are reproducible from stored inputs, configuration, and strategy version.


## CP2 frontend and additional feature

The revised CP2 includes authenticated visualizations of user-owned portfolio data and a planned additional feature: conditional buy orders. Charts distinguish current allocation, historical portfolio value, realized profit/loss and unrealized profit/loss; missing historical quotes are visible gaps, never invented zero values.

Conditional orders request an integer quantity of player tokens at or below a user-specified maximum unit price before an explicit expiry. A worker uses the then-current authoritative quote, balance and inventory and delegates execution to the existing atomic idempotent purchase rules. Orders do not reserve funds or inventory. Proposed lifecycle, cancellation race and rejection semantics are recorded in ADR-0017 and must be specified and challenged in TASK-059 before implementation. No partial fills, external broker, real-time market guarantee or external notification service is added.
