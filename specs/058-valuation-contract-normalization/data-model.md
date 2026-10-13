# Internal valuation data model

Plain immutable in-memory structs/maps; no Ecto schemas or persisted results. Existing Statistics Match/Performance contracts remain authoritative.

| Entity | Fields/relationships | Validation |
|---|---|---|
| Request | player_id, season_id, week_start/end, requirements, references, position_mapping | Exact subject/season; explicit week; nonempty requirements; positive finite references |
| Week | UTC DateTimes at six-digit precision | Consecutive Monday midnights, half-open |
| Fact | performance/player/season/match IDs, stable match_identity, UTC kickoff, home/away team IDs, historical team/position IDs, minutes, metrics (nine counts), resolved group | Resolved from Statistics; counts nonnegative integer or nil; minutes nonnegative integer; unique performance IDs and player-match pairs |
| Mapping | canonical list of position-ID/group pairs | Four supported groups, each selected position mapped once; duplicate keys/conflicts rejected; unused entries allowed |
| ScopeInputs | scope map key, membership (ordered performance IDs), row_count, total_minutes, required totals/features | Overall and populated groups only; complete declared applicable features |
| Prepared | canonical request rules, Facts/groups, scope inputs, preparation descriptor | No score; retains all raw nil values |
| Definition | explicit reviewed module, strategy_id/version/config; binding derives validated config/requirements | Identity and requirements agree with preparation; no defaults/registry |
| FeatureView | rounded finite Decimals per declared metric/overall or populated group | No raw minutes, counts, identity, time, membership or affiliation |
| ScoreResult | fixed six-place signed score, Prepared, scoring descriptor | Finite Decimal callback result rounded once; no clamp/negative zero |
| Descriptor v1 | schema/rule versions, request, ordered original Facts/groups, scope derived values; optional exact strategy/version/config/requirements/score | Canonical exact membership/rules; executable module never serialized |
| Error | kind, reason, ordered safe details | No score/partial success, provider payload or persistence internals |

Counts: goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards. Minutes are evidence only. Each metric has one reference shared across scopes. Numeric input is finite integers or Decimal structs, never numeric strings/booleans/floats/NaN/infinity. Canonical numeric config preserves integer-vs-decimal type and normalizes equivalent Decimal values. Exposed features/scores use six-place strings, counts/minutes integers.

## State transitions

Request -> structural validation -> exact subject lookup -> weekly selection -> historical mapping -> completeness -> Prepared -> definition validation/binding -> ScoreResult.

Validation, not-found, empty-history and insufficient-data stop without scoring. Valid empty selection means no-recorded-performances. Nonempty selection with no applicable declared scope means insufficient-data. Unknown required metrics in any present applicable scope stop the whole preparation; no partial result. Zero minutes never invalidate complete counts. Mixed present/absent declared scopes preserve applicable features; explicit scorer policy may fail for a missing contribution.

Descriptor -> structure/original-rule validation -> original fact resolution/comparison -> exact original-membership preparation -> derived comparison -> optional original scorer -> score comparison.

Replay never transitions to fresh selection. Missing facts/rules and inconsistent evidence fail explicitly. Retaining/protecting descriptors is TASK-026; version/config storage is TASK-025. Every unsuccessful call is read-only and yields no quote, event, financial write or historical rewrite.
