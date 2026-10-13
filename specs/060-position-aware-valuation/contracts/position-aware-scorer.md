# Position-aware scorer contract v1

Internal Elixir interface; no HTTP route. Extends the [existing valuation contract](../../058-valuation-contract-normalization/contracts/valuation-context.md), without changing its DTOs, entrypoints or trust boundary. Behavioral truth: [spec.md](../spec.md); durable decision: [ADR-0022](../../../docs/adr/0022-position-aware-populated-group-sum.md).

## Explicit definition

```elixir
%FootballMarket.Valuation.Definition{
  module: FootballMarket.Valuation.PositionAware,
  strategy_id: "position_aware",
  version: "1",
  config: %{weights: %{
    goalkeeper: %{saves: 2, goals_conceded: -1},
    defender: %{tackles: 2},
    midfielder: %{assists: 1},
    forward: %{goals: 4}
  }}
}
```

This is an illustrative fixture, not a market preset. The caller separately supplies an exact player/season, consecutive UTC Monday midnights, historical UUID/group mapping and references for exactly saves/goals_conceded/tackles/assists/goals. Explicit preparation requirements must equal these configured metric sets for all four groups, even when absent. No default weights or references are supplied.

Configuration accepts only plain atom-keyed maps: exactly weights, exactly four group keys, nonempty supported metric maps, finite signed integers/Decimal structs. Integers and fractional/zero/negative Decimals are valid; strings, booleans, floats, NaN/infinity, malformed Decimal fields, structs as containers, missing/extra keys, overall scope and lists are invalid. Pair collections, including duplicate group/metric entries and improper tails, fail ordinarily before conversion. Do not construct a map from supplied pairs. Common required-metric lists and historical mapping pair lists reject duplicates/conflicts before canonicalization. Unsupported string keys never create atoms.

## Scorer callbacks

| Callback | Result | Constraint |
|---|---|---|
| identity/0 | {"position_aware", "1"} | Formula identity, not durable configuration lifecycle |
| validate_config/1 | {:ok, complete_config} or {:error, safe_reason} | No preset, implicit policy, coercion or exception for malformed input |
| requirements/1 | {:ok, four_group_requirements} or {:error, safe_reason} | Lists follow Request.metrics order, include zero weights, omit overall |
| score/2 | {:ok, unrounded_finite_Decimal} or {:error, safe_reason} | Only populated rounded FeatureView + complete validated config; no effects |

Common Scoring binds the definition and enforces exact requirement agreement before callback. Request validates references against exactly their union. Direct callback calls also reject malformed config/feature shapes and missing declared metrics in present groups; absent groups are skipped, never invented zeros. A view with no applicable populated group is invalid; ordinary preparation already distinguishes empty/no-applicable data.

## Formula and numeric boundary

For each populated group g, sum required weekly counts under the common selection/completeness rules. Common preparation produces F_gm=round6(min(T_gm/R_m,1)). PositionAware consumes these rounded features and computes the exact sum of W_gm*F_gm across all populated groups and configured metrics. Return one unrounded Decimal from DecimalMath.weighted; the common engine alone applies round6 to the final sum. Rounding is nearest/ties away from zero, six fixed decimal places, no scientific notation/negative zero. Do not round contributions or group subtotals. No clamp, average, denominator, exposure factor, dominant position or implicit penalty sign.

Four goals at reference 2 and weight 2 score 2.000000 concentrated, versus 4.000000 split 2+2 across two groups. One goal in defender at weight 1 and forward at weight 4 scores 2.500000. Adding a populated midfielder with known zero goals at weight 9 keeps 2.500000 and changes measured evidence. Two group features 0.500000 at weight 0.000001 produce exact contributions 0.0000005 each and final 0.000001, not 0.000002.

## Facade, evidence and replay

Use common prepare/1, score/2, evaluate/2 and replay/2. Prepared requirements must equal all four derived sets. score authenticates authoritative original facts before callback; evaluate reads accepted local facts; replay authenticates retained original membership/fields and recomputes under the exact original definition/configuration. No local facts are replaced with current affiliation or caller-manufactured snapshots.

Success is common ScoreResult with six-place score, Prepared and Descriptor. It binds original facts/membership, resolved groups, full position mapping/week, all four group's effective weights/requirements, shared references, populated normalized features, normalization/rounding identifiers and strategy ID/version. Existing Evidence.canonical owns order independence; equivalent Decimal values normalize, integer/Decimal type tags remain distinct. Absent group config is present in effective evidence but absent from measured scopes.

Late facts only affect fresh selection. Changed weights/references/mappings, including an absent group's rule change, cannot substitute during original replay. Unsupported identity/version, missing originals and tampered facts/grouping/features/score retain common distinct failures. Descriptor origin protection and durable rule recovery remain TASK-026/025; this interface does not authenticate wholesale substitution with a different legitimate descriptor.

## Outcomes and conformance

Common Error kinds and safe details are unchanged: validation, not_found, no_recorded_performances, insufficient_data, unsupported_strategy, strategy_failure, unavailable_replay and inconsistent_replay. Missing required values identify group/metric/performance; zero-weight entries still require known values and references. Unknown unconfigured counts do not block. Valid empty history is no_recorded_performances; invalid rules fail first. Persistence failures remain visible.

All paths are deterministic and read-only. Scorer only references valuation modules and receives no raw minutes, affiliation, membership or time. No provider, persistence, event/job/cache, permission, quote/history, trading or UI change. Tests assert authoritative scoring/replay, zero writes/provider/events and infrastructure-error visibility; see [acceptance map](acceptance-map.md).
