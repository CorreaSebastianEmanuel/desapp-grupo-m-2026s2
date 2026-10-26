# Implemented boundary — TASK-056

Retrospective architecture record, backfilled 2026-10-26. This reconciliation
adds canonical ownership/documentation, not application behavior.

PlayerController obtains preloaded local Catalog detail before asking the
Freshness context for status. Settings resolves trusted exact-scope options
through Synchronization.Input. Refresh takes the existing scope advisory lock
without waiting, uses a short transaction lock timeout and admits work through
Synchronization.Store only when required. Accepted-check truth remains the
existing statistics_import_scopes pointer maintained by atomic import publication.

ValuationStatus reads the latest changed player/season intent and aggregates
quote calculation requests. Snapshot membership and legacy changed-performance
membership are both supported. Import and valuation are deliberately separate
states. No provider execution happens in the detail request.

## Implemented files

- `lib/football_market/statistics/freshness/context.ex`, `settings.ex`,
  `refresh.ex`, and `valuation_status.ex` — orchestration/status, trusted settings,
  admission/cooldown decisions and calculation aggregation.
- `lib/football_market/synchronization/store.ex` — shared nonblocking admission
  lock using the existing scope key, with existing durable admission paths.
- `config/synchronization.exs` — TTL, cooldown and exact-scope source options;
  source map defaults empty.
- `lib/football_market/catalog.ex`,
  `lib/football_market_web/controllers/player_controller.ex`, and
  `lib/football_market_web/controllers/player_json.ex` — validated local detail,
  error mapping and additive JSON status.
- `priv/repo/migrations/20261026000000_index_statistics_freshness_reads.exs` —
  lookup indexes only; no weakening of facts/history/uniqueness constraints.
- `priv/static/openapi.json` and `README.md` — response and configuration docs.
- `test/football_market/statistics/freshness/`,
  `test/football_market_web/controllers/player_freshness_test.exs`, and
  `test/support/freshness_case.ex` — deterministic TTL/failure, committed
  concurrency, source isolation and HTTP regressions.

The importer, outbox/receipts, retry budgets, worker restart recovery and accepted
check publication retain their original owners. Fixture attribution is explicit;
this task does not implement live retrieval, portfolio data, orders or trading.
