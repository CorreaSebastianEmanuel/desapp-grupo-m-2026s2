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

