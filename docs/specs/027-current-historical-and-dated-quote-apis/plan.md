# Implemented boundary — TASK-027

Retrospective architecture record, backfilled 2026-10-26. No product code is
introduced by this reconciliation.

The router's existing authenticated API pipeline dispatches to QuoteController.
The Quotes facade delegates local reads to Quotes.Reader, which validates player
identity and queries Market.Quote through Ecto/PostgreSQL. QuoteJSON serializes
exact decimal values and original immutable metadata. The controller validates
date shape/ambiguity before lookup and maps stable domain errors to HTTP status.
No provider, job or cache participates in these reads.

## Implemented files

- `lib/football_market/quotes/reader.ex` — identity checks, sequence ordering,
  local history and inclusive UTC-day selection.
- `lib/football_market/quotes.ex` — the local read facade functions.
- `lib/football_market_web/controllers/quote_controller.ex` and
  `lib/football_market_web/controllers/quote_json.ex` — request/error handling
  and public serialization.
- `lib/football_market_web/router.ex` and
  `lib/football_market_web/plugs/authenticate_api.ex` — existing credential policy
  applied to the three read routes.
- `priv/static/openapi.json` and `README.md` — shared API documentation.
- `test/football_market/quotes/reader_test.exs`,
  `test/football_market_web/controllers/quote_controller_test.exs`, and
  `test/football_market_web/openapi_contract_test.exs` — maintained regression
  evidence, included in the integration profile.

No migration or financial write is needed to expose the already-persisted data.
Broader changes to calculation/admission/recovery remain owned by TASK-026 and
the merged maintenance baseline, not by this read contract.
