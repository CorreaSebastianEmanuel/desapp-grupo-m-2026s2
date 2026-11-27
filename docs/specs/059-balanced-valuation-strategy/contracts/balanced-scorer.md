# Balanced scorer contract v1

Internal Elixir interface only; no HTTP route. Reuse [valuation-context.md](../../058-valuation-contract-normalization/contracts/valuation-context.md) for trusted binding, shared validation, outcomes, typed evidence and authoritative replay. This adds only production formula/config.

## Definition and callbacks

Explicit existing `%Definition{module: FootballMarket.Valuation.Balanced, strategy_id: "balanced", version: "1", config: %{weights: weights}}` is supplied to evaluate/2, score/2 or original scored replay/2. prepare/1 is unchanged. identity/0 returns `{"balanced", "1"}`. validate_config/1 accepts the schema below or returns `{:error, safe_reason}`; Scoring translates to ordinary validation error. requirements/1 derives ordered overall requirements; score/2 consumes FeatureView/canonical config and returns `{:ok, finite_unrounded_Decimal}` or an ordinary missing-contribution error. The implemented module is `lib/football_market/valuation/balanced.ex`; it delegates exact contributions to DecimalMath.weighted/1. No default/registry.

## Configuration

Exactly `%{weights: %{metric_atom => weight}}`, plain nonempty maps. Supported atoms/order are Request.metrics/0: goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards. Reject other keys/options/string keys. Leaves are finite signed integers or valid Decimal values; fractions/zero unrestricted, no sum/sign rules. Reject lists/improper tails, nested role maps, structs as containers, strings/floats/booleans/nil, missing or malformed Decimal fields, NaN/infinities. Never intern strings or provide defaults.

Every configured key, including zero, is required in overall scope. Request requirements and positive exact reference keys match exactly. Removing an entry removes its requirement; assigning zero does not. Empty weights fail; complete nonempty all-zero config succeeds with 0.000000. Validation precedes empty history selection.

## Formula and evidence

Common preparation supplies `F_m = round6(min(T_m/R_m, 1))` from all selected weekly accepted facts. Balanced returns exact `sum(W_m * F_m)`. Common engine rounds once, nearest/ties away from zero, rendering six places without scientific notation/negative zero. No product rounding, weight-sum division, bias, clamp, group aggregation, minute bonus or quote conversion.

Example totals 3 goals/1 assist/2 conceded, references 4/2/4, weights 2/1/-1 → 1.500000. One goal/reference 6/weight 3 → feature 0.166667, score 0.500001. Fixtures are not production calibration.

Existing Descriptor binds original facts/membership/request/features, strategy identity/version/full canonical config/requirements and score. Replay requires original definition/authoritative facts, never fresh configuration/membership/affiliation. Equivalent Decimals canonicalize; inherited integer/Decimal type tags remain distinct. No additional store/module serialization.

## Failure and side effects

Malformed config/rules yield common validation without score; zero-weight missing data fails with overall metric/performance details; missing omitted metrics do not block. Unknown player, empty recorded history and insufficient data remain distinct. Missing configured callback feature yields ordinary strategy failure, never partial score. Unsupported versions, unavailable originals and inconsistent evidence preserve common kinds; current config substitution fails replay.

Reviewed callbacks use feature/config only: no Catalog/Statistics/Repo/provider/time/randomness/web/job/cache/event/financial access. Workflow performs authoritative local reads only. Callback exception containment is not routine config validation; no broad infrastructure rescue. Durable retention/authentication/config lifecycle remain downstream.

Operator calibration and effective configuration retention remain TASK-025/026 integration obligations. The formula fixtures demonstrate semantics and must not become market presets.
