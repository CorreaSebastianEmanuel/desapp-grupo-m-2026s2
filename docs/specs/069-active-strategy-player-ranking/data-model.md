# Ranking data model

No tables, columns, constraints or mutable projections are added.

## Existing persisted facts

- `valuation_configuration_versions`: immutable UUID `id`, `strategy_id`, `formula_version`; ID is the exact saved version identity (ADR-0023).
- `valuation_selection_changes`: latest committed `change_order` selects `new_version_id`; read through existing Configurations.active/0 and serialization anchor.
- `market_issuances`: player identity limits ranking to issued players; existing initial quote and 100-unit supply remain untouched (ADR-0024).
- `market_quotes`: UUID `id`, player UUID, exact numeric `unit_price`, UTC microsecond `effective_at`, `configuration_version_id`, `rule_id`, `rule_version`, `calculation_id`, positive per-player `performance_sequence`.
- `quote_calculations`: immutable successful outcome; quote/player/configuration/price/time linked under deferred confirmation constraints (ADR-0029). No result is inferred from a request lease or evaluation delivery state.

## New transient structures

`Ranking.Result`: configuration_version_id UUID, strategy_id string, formula_version string, ordered entries list.

`Ranking.Entry`: position positive integer, player_id canonical UUID, quote_id UUID, unit_price Decimal, effective_at DateTime UTC. JSON encodes Decimal as a fixed two-place string without conversion through float, timestamp as RFC3339 UTC preserving microseconds.

Select maximum (effective_at, performance_sequence) within each issued player's successful quotes matching exact active version and strategy/formula. Across selected rows order (price DESC, UUID ASC), then enumerate. Prices/times come from the selected quote, not a fresh valuation. Empty entries is a valid active result. Missing active selection and storage failure are separate errors, never fabricated structures.

## State and invariants

Ranking has no lifecycle and persists no state. Reads cannot activate, append, enqueue or trade. An immutable snapshot may retain the prior configuration when activation commits after snapshot acquisition. All returned entries reference the reported configuration. Snapshot tests must include newly committed history to prove the quote and selection views share that boundary. Token supply, append-only history/audit, exact prices and provider-independent local reads remain unchanged.
