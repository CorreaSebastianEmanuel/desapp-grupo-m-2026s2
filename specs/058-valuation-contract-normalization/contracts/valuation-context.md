# Valuation context contract v1

Internal Elixir interface, no HTTP route. Trusted local consumers invoke FootballMarket.Valuation; no user permissions, provider calls, external payloads or writes. Behavioral truth: [spec.md](../spec.md). Trust decision: ADR-0020.

## Entrypoints

| Call | Success | Failure |
|---|---|---|
| prepare(request) | {:ok, Prepared} | {:error, Error} |
| score(prepared, definition) | {:ok, ScoreResult} | ordinary no-score error |
| evaluate(request, definition) | prepare then score, same result | ordinary no-score error |
| replay(descriptor, definition) | original Prepared or ScoreResult according to descriptor | unavailable/inconsistent-replay or validation error |

Preparation-only replay receives nil definition; scoring replay requires an explicit original definition. Requests use a documented atom-key map or Request struct. Reject unknown keys, malformed/conflicting structures, and arbitrary string-to-atom conversion. UUIDs follow existing validation. week_start/end accept DateTimes or ISO-8601 explicit-offset strings at ADR-0011 precision. Normalize to UTC; require consecutive Monday midnights. Validate required request config even on an empty week.

Requirements are a map from overall/goalkeeper/defender/midfielder/forward to nonempty lists of counting metrics. Reject empty declarations/sets, duplicate metrics, unsupported scopes/metrics and minutes. References are a map with exactly the required metric union, each value a positive finite integer or Decimal; reject extras/missing entries. One metric reference is shared across scopes. Mapping is a list of {stable_position_uuid, group} pairs so duplicates/conflicts remain visible before map construction; reject duplicate keys or unsupported groups. All selected positions need a mapping; unused valid entries are allowed. Caller explicitly maps central defenders/fullbacks to defender; no mutable-label heuristics.

Scope order is overall, goalkeeper, defender, midfielder, forward. Metric order is goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards. Public numeric configuration accepts finite integers/Decimal structs only, rejecting strings, booleans, floats, NaN/infinity and malformed Decimal fields. No production defaults.

## Selection and preparation

Validate exact Catalog player/season. Read Statistics inclusive history with explicit bounds, filter kickoff < end, verify isolation, then snapshot original match/performance facts. No classification by current affiliation. Distinct matches at the same instant remain distinct. Reject duplicate performance IDs or player/match pairs. Canonical row order is UTC kickoff, stable stored match_identity bytes, performance UUID bytes; not database locale/case-fold order.

Every row maps to exactly one historical group, even for overall-only requests. Overall and all populated groups retain membership, row count and integer total_minutes. Complete required totals/features exist only in applicable declared scopes. Unrequired metrics remain raw, including nil. Overall exists for nonempty selection even when not required; populated unrequired groups remain visible without fabricated totals/features. Empty groups have no entry.

Unknown required metrics in any applicable present scope return insufficient-data with all ordered scope/metric/performance details and no partial success. No row exclusion/imputation. Absent required groups are not unknown rows: leave them absent. If no declared required scope is populated, return insufficient-data/no_applicable_required_scope. Mixed applicable and absent scopes can prepare if applicable metrics are complete.

Sum all selected integer counts for each scope/metric. Normalize min(total/reference, 1). Decode exact coefficient/exponent to an integer ratio, cap by cross multiplication. For an uncapped numerator N/denominator D, divide N*1,000,000 by D into quotient q/remainder r; use q+1 if 2*r >= D, else q. Construct positive Decimal at exponent -6 and expose fixed text. No intermediate ratio/per-row rounding, ambient Decimal precision or float arithmetic. Large counts have no new ceiling; zero-minute and extra-time histories follow the same rules.

## Trusted scorer behavior

FootballMarket.Valuation.Scorer callbacks:

- identity() -> {nonempty_strategy_id, nonempty_version}.
- validate_config(explicit_config) -> {:ok, canonical_config} or {:error, safe_details}.
- requirements(canonical_config) -> {:ok, requirements} or {:error, safe_details}.
- score(feature_view, canonical_config) -> {:ok, finite_Decimal} or {:error, safe_reason}.

Definition contains explicitly supplied module, strategy ID/version and full config. Check behavior availability and exact identity, all numeric leaves, module config/schema and derived requirements. No registry/default lookup, runtime module-name deserialization or public arbitrary closures. Test-support modules provide illustrative general/group-aware scorers and failure/malformed-return fixtures; production modules are downstream.

Before scoring, authenticate/reprepare caller-held Prepared facts/rules via authoritative reads and compare every derived value. Require module-derived requirements to equal preparation requirements. Module validation binds each illustrative weight to its declared scope/metric; a config weighting an undeclared metric or disagreeing requirement fails before callback invocation. Configuration admits only explicit keys; no implicit injected values.

FeatureView exposes only declared rounded normalized features as finite Decimals at exponent -6, indexed by overall/populated group. Raw counts/minutes, memberships, identities, affiliation and time are excluded. An absent required feature remains absent. Illustrative require-all policy returns strategy_failure/missing_contribution; an explicitly configured populated-only policy can succeed. These policies are test inputs, not production defaults.

Reviewed modules use only feature/config inputs and exact decimal contributions; no time/randomness/provider/persistence/current affiliation/cache/jobs. Determinism is a trusted conformance obligation, not a sandbox guarantee. Exact illustrative weighted sums operate on integer coefficients/exponents, not ambient precision. Engine rejects nondecimal outputs (including integer/string/float), NaN/infinity, malformed return shapes and expected callback failures. Callback exceptions are caught only at that boundary as a safe strategy_failure/callback_exception without exception payloads. Do not broadly rescue persistence outages into football outcomes.

Final finite Decimal is rounded once via exact coefficient/exponent to six places, nearest with ties away from zero. No score clamp; normalize rounded zero's sign. Example 1/6 feature 0.166667 with weight 3 yields 0.500001, 1/128 yields 0.007813. Numeric references may be integers; successful scorer result must be Decimal. Output features/scores are strings with six digits after the point and no scientific notation.

## Descriptor and replay

Descriptor schema v1 captures exact subject/season/week, all original ordered Facts/resolved groups, full mapping/requirements/references, normalization identifier weekly-count-reference-cap-v1, six-place half-away rounding, scope memberships/counts/minutes/totals/features. Scoring adds exact strategy ID/version, full validated config/derived requirements and expected six-place score. Executable modules are explicitly supplied, never serialized.

Canonical evidence uses fixed keys and ordered entry lists for mapping/metric/configuration values. Preserve raw nil values. Configuration keys are stable atom/string keys with type-tagged byte ordering; nested lists retain order, nested maps canonicalize recursively. Reject PID/function/reference and other nondeterministic values. Integers and Decimals have type tags; equivalent finite Decimals normalize exact coefficient/exponent representation, while public feature/score strings remain fixed six-place. No reliance on JSON map iteration, labels or locale.

Replay validates descriptor structure/versions/rules, then resolves each original player/match pair and match through Statistics. Verify performance ID and every captured immutable field: counts/minutes, historical team/position, match identity, kickoff, subject/season and match participants. Missing original rows -> unavailable_replay. Disagreement/duplicates/wrong subject/season/out-of-week -> inconsistent_replay, never silently filter. Recompute group assignments/membership/totals/features from original mapping and compare all retained derived evidence.

Scoring replay requires explicit original trusted definition matching descriptor ID/version/config/requirements exactly. Missing original module/rules -> unavailable_replay; supplied mismatches -> inconsistent_replay. Recompute/compare score; never select current week membership, active version or current affiliation. Fresh late-arrival selection is a new calculation.

Original descriptor origin/rules are trusted internal artifacts; facts are independently verified. Coordinated count/derived-value tampering is rejected against authoritative facts. This is not authentication of wholesale replacement with a different legitimate descriptor. TASK-026 owns durable retention/integrity; TASK-025 owns config lifecycle. No public deserialization security boundary is claimed.

## Error taxonomy

Error fields: kind, reason, ordered safe details. No usable score or partial success.

| Kind | Examples |
|---|---|
| validation | invalid_week/reference/mapping/requirements, definition_requirements_mismatch; relevant field/rule |
| not_found | player_not_found |
| no_recorded_performances | empty_week; message “sin actuaciones registradas” |
| insufficient_data | missing_required_metric, no_applicable_required_scope; message “datos insuficientes”; scope/metric/performance |
| unsupported_strategy | unknown_identity_version, unavailable_module |
| strategy_failure | scorer_error, callback_exception, invalid_result, missing_contribution |
| unavailable_replay | original_fact_unavailable, original_rules_unavailable |
| inconsistent_replay | altered_fact, duplicate_fact, invalid_membership, altered_derived_values, rules_mismatch |

Expected invalid requests fail ordinarily before arithmetic. Details are ordered by fixed scope/metric/canonical row and safe field identity. Infrastructure failures remain visible failures rather than empty/insufficient-data results. No unsuccessful call yields quote/event/write/fallback. See [acceptance-map.md](acceptance-map.md).

## Implemented in-memory representation

The public facade is `lib/football_market/valuation.ex`; DTOs are in `valuation/types.ex` and Request/Error in their own modules. Fact projects Statistics `kickoff_at` to `kickoff`, `minutes_played` to `minutes`, and the nine count fields to `metrics`. ScopeInputs uses `membership`, `row_count`, `total_minutes`, `totals`, `features`; scope is its key in Prepared.scopes. Prepared retains request/facts/scopes/descriptor. Definition input contains only module/strategy_id/version/config; binding derives requirements internally. Descriptor fields are schema_version, normalization, rounding, request, facts, scopes, strategy, score. A preparation descriptor has nil strategy/score.

These internal immutable structs use keyed maps for convenient access, canonical row/mapping/metric lists, normalized Decimal references and fixed feature text. `Evidence.canonical/1` supplies the deterministic typed ordered-entry encoding of maps and nested configuration; scoring descriptors retain that encoding for strategy.config and omit executable modules. Canonical comparison validates all original/derived evidence. This is an in-memory contract, not a durable wire codec; TASK-026 must retain the complete descriptor and original definition.

`evaluate/2` validates the explicit definition before selecting facts; `score/2` authenticates retained preparation before the score callback. FeatureView includes only populated declared scopes with normalized features. Malformed or deleted struct fields return ordinary failures. Callback errors/exceptions expose safe reasons without callback payloads. Statistics' existing Count loader is isolated from caller Decimal context using PostgreSQL's full integral NUMERIC precision; arithmetic itself remains integer-rational with no new count ceiling.

List-valued requirements, mappings, nested configuration, original facts and scope memberships must be proper lists. Validate tails before Enumerable operations. Nested improper lists in retained derived evidence compare as unsupported values and fail replay/authentication; no broad rescue converts infrastructure exceptions into domain outcomes.
