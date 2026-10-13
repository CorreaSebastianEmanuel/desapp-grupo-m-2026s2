# Data model — Position-aware strategy

No persistence entity, schema or migration is added. The [common DTO contract](../058-valuation-contract-normalization/contracts/valuation-context.md) and lib/football_market/valuation/types.ex own field layouts; the following are feature-specific constraints.

| Existing object | Position-aware values / relationships | Validation |
|---|---|---|
| Definition | module=FootballMarket.Valuation.PositionAware, strategy_id="position_aware", version="1", config=%{weights: group_maps} | Exactly explicit reviewed module/identity/version/config; no registry/default |
| Effective config | weights maps goalkeeper/defender/midfielder/forward to nonempty metric-weight maps | Exact four group keys, supported nine metrics, finite signed integer/Decimal leaves; zero valid; no overall or option keys |
| Request | exact player/season/week, full position mapping, all four derived requirement lists and shared reference map | Common UUID/UTC-week/mapping validation; zero weights still required; references exactly union, positive and finite |
| Fact → ScopeInputs | Each original performance belongs to exactly one historical group; several positions can map to defender | Common immutable local row identity, half-open membership, complete configured counts; never current affiliation |
| FeatureView | features contains configured rounded Decimals for populated historical groups only | Six-place common capped features; absent scopes have no entry, known-zero has an entry |
| ScoreResult → Descriptor | Common fixed-six score plus original Prepared and complete reproduction descriptor | All four rule sets retained, exact sum rounded once; original facts/rules verified on score/replay |

All nine metric names follow Request.metrics/0: goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards. Any nonempty subset is valid for every group, without implicit penalty sign. Stable historical-position UUIDs map through the explicit request; center-back/fullback map to defender without mutable-label heuristics.

Measured group absence and rule presence are separate. No ScopeInputs row is created for absent groups, but their weights/requirements/references remain reproducible configuration. Unconfigured nil metrics and valid minutes are retained raw evidence; they are not score inputs. No overall features contribute.

## Logical transitions (no stored state changes)

Explicit valid definition/request → common historical preparation → populated-group rounded FeatureView → one exact unrounded weighted sum → common rounded ScoreResult/Descriptor. Invalid configuration fails before empty-history classification. Required unknown values stop preparation with ordered group/metric/performance details and no partial score.

Retained result + explicit original definition → authoritative original fact comparison → reprepare original membership → compare canonical derived values/rules → recompute and compare score. Late arrivals or fresh rules create a separate calculation. Missing originals, changed supplied rules and inconsistent evidence return the existing distinguishable no-score errors. No calculation writes, quote transitions, events or financial entities exist here.
