# Focused design findings

## Committed success (critic finding 1)

Decision: join `market_quotes.calculation_id` to `quote_calculations.id` with status `successful`, exact player/configuration linkage and positive performance sequence/price. Reuse confirmation invariants, not transient request/delivery state.

Rationale: `lib/football_market/quotes/calculation.ex` declares immutable status. `priv/repo/migrations/20261018000000_create_quote_calculations.exs` enforces successful linkage and one quote-keyed event; `20261018001100_require_successful_quote_confirmation.exs` additionally requires each successful calculation to commit exactly one matching quote/event. Incomplete transactions are invisible. Failed/no_quote outcomes cannot have eligible performance quotes. Existing `Quotes.Store.confirm!/6` appends the performance quote and event atomically. Pending delivery does not invalidate it.

Alternatives considered: positive price alone cannot prove performance confirmation; request success is a mutable execution projection; acknowledged evaluation would incorrectly exclude committed quotes. Preserve ADR-0029.

## Snapshot linearization (critic finding 2)

Decision: reuse Configurations.active/0 and quote selection in one owned read-only REPEATABLE READ transaction. Snapshot begins at its first data SELECT. Reject an incompatible enclosing transaction.

Rationale: ADR-0023 explicitly permits repeatable read for read-only snapshots, while activation writes require READ COMMITTED. Current Configurations.Store.active/0 uses the serialization anchor and latest committed selection. A normal multi-statement READ COMMITTED read would allow quote history to change between queries. Independent committed-connection tests must demonstrate activation/quote commits before and after snapshot acquisition.

Alternatives considered: two ordinary reads are inconsistent; locking selection would unnecessarily block activation; duplicating active-selection SQL in a single giant statement avoids a transaction but duplicates configuration decoding/integrity logic. New durable boundary: ADR-0033.

## Interface and existing tooling

Decision: add protected GET /api/ranking; reuse `AuthenticateAPI` and checked-in OpenAPI, exact decimal strings and UUIDs. Reuse unit/integration profiles; execute socket assertions separately once.

Rationale: current router exposes protected catalog reads and the feature is API/domain only. UI belongs to TASK-047. Existing `test/football_market_web/workspace_http_runtime_test.exs` demonstrates a real listener test, and existing quote/valuation runtime helpers support isolated committed stores without disabling guards. The dedicated feature runtime script lives under scripts/ outside ExUnit discovery, avoiding duplicate execution or changes to profile classification.

Alternatives considered: adding LiveView expands scope; ranking under a dynamic player-detail segment risks route capture; adding a new runner or dependency is unnecessary. No settled technology research or internet lookup was required.

## Feedback 3 concrete local findings

Decision: repair query levels and ranking-owned fixture/runtime inputs; extend only the three inherited guard files allowed in current feedback. No technology question is reopened.

Rationale: `Ranking.Reader.active_quotes/1` already selects a map; `confirmed_quotes/1` adds another select and treats projected aliases as fields without a subquery. `QuotesCase.rules/1` requires a top-level position; quote fixtures wrap it in `base`. `ValuationConfigurationCase.client/1` accepts only `valuation_test_[a-f0-9]+`. Runtime currently calls nonexistent `Quotes.save_mapping`, passes a list to boolean `assert!`, and switches the HTTP Repo without switching the caller before snapshots. Catalog-only route/status/browser guards and feature-labelled Oban expectations conflict with the merged baseline. These are concrete integration failures confirmed by Feedback 3 and local source inspection, not evidence for a redesign.

Alternatives considered: preserve shared helper contracts and repair callers; select once per query level instead of masking programmer errors with storage fallback; assert an exact expanded operation set instead of accepting arbitrary operations; assert the merged worker configuration instead of adding another task-specific branch. ADR-0033 records the bounded repair. No external research is needed.
