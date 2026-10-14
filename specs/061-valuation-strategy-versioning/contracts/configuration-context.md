# Internal configuration and managed valuation contract v1

Trusted maintainers/internal consumers only; no HTTP routes, roles, administration screen or provider access. Behavioral source: [spec.md](../spec.md). Inherited scoring/replay: [common contract](../../058-valuation-contract-normalization/contracts/valuation-context.md), ADR-0020/21/22. Persistence details: [data-model.md](../data-model.md).

## Management surface

`FootballMarket.Valuation.Configurations`:

| Call | Success | Ordinary failure |
|---|---|---|
| create(rules) | `{:ok, Version}` | validation / unsupported_strategy |
| get(uuid) | `{:ok, %{version: Version, active_version_id: uuid_or_nil}}` | validation / not_found |
| list() | `{:ok, %{versions: ordered_versions, active_version_id: uuid_or_nil}}` | visible storage failure, never fabricated empty list |
| active() | `{:ok, Version}` | no_active_configuration |
| activate(target_uuid, expected_current_uuid_or_nil) | `{:ok, %{active_version_id: target_uuid, change: SelectionChange_or_nil}}` | validation / not_found / unsupported_strategy / conflict |
| history() | `{:ok, ascending_changes}` | visible storage failure |

Use the existing Valuation.Error safe kind/reason/details for ordinary outcomes. `get` is a consistent version/selection snapshot; `list` is a consistent ordered list/selection snapshot. `active` returns the complete stored version without silently substituting another formula; managed use still checks support. Nil is an explicit expected absence, never an optional default argument. No update/delete API. Storage exceptions stay visible; do not broadly rescue them into business outcomes.

Creation accepts exactly an atom-key plain map with `strategy_id`, `formula_version`, `config`, `references`, `position_mapping`. Config follows the existing formula schema: balanced `%{weights: metric_map}`; position-aware `%{weights: %{goalkeeper: metric_map, defender: metric_map, midfielder: metric_map, forward: metric_map}}`. Every metric map is nonempty and finite exact signed integer/Decimal values are mandatory; all-zero is valid. Requirements derive from every configured metric, including zero weights. References exactly cover the union with positive finite integers/Decimals. Mapping is a nonempty proper pair list of existing position UUIDs/supporting historical group atoms; reject duplicate/conflicting identities before map construction. All four groups/unused valid mappings persist. Unknown fields, caller requirements, module names, pair collections in map slots, improper tails, structs in map slots, floats, booleans, numeric text, nonfinite/malformed Decimals fail before insert. No injected production values/default activation.

Formula registry is code-only: balanced/1 → Balanced, position_aware/1 → PositionAware. No executable module is selected from persisted data. Unknown pairs fail unsupported on creation/use; read-only lookup/listing remains possible when support later disappears.

Activation serializes and checks expected identity in a short READ COMMITTED database transaction. The insertion guard rejects other write isolation levels; read-only consistent inspection may use a single statement or REPEATABLE READ. Stale expectations fail without insertion, including stale attempts to select the already active target. Matching no-op returns `change: nil`. Initial activation and restoration append durable changes; no version mutation. Selection takes effect when committed. Ordered history retains previous/new identities and effective time, with order stable when times tie. The database insert guard supplies order after locking and samples the transaction timestamp; confirmation is commit visibility rather than a commit-clock guarantee. Readers never see partial history or an inconsistent pointer. Value expectation A can match after A→B→A; no caller revision token. No scheduled/per-player/date selection or automatic recalculation.

## Managed calculation surface

`FootballMarket.Valuation`:

| Call | Success | Failures |
|---|---|---|
| evaluate_managed(subject_week, :active) | `{:ok, ManagedResult}` | no_active_configuration, validation, unsupported_strategy, inherited football/scorer failures |
| evaluate_managed(subject_week, {:version, uuid}) | `{:ok, ManagedResult}` | malformed/unknown identity, unsupported_strategy, inherited failures |
| replay_managed(ManagedDescriptor) | `{:ok, ManagedResult}` | unavailable_replay, unsupported_strategy, inconsistent_replay, validation |

Subject/week map has exactly `player_id`, `season_id`, `week_start`, `week_end`; inherited explicit UTC-week rules apply. Rules/requirements/references/mapping/module/strategy overrides are invalid. Resolve one full immutable version before facts; reconstruct the inherited Definition/Request using that version alone. No selection lock spans fact reads; activation during evaluation cannot change the fixed rules. Explicit inactive evaluation never activates it.

Successful score/prepared and common Descriptor remain the inherited evidence. Managed result separately exposes UUID, strategy_id/formula_version and one strategy-independent envelope containing UUID and common Descriptor. No permanent descriptor write. Both formulas share this format. The saved rules must equal descriptor strategy.config, strategy.requirements and request references/requirements/mapping canonically. Existing descriptor strategy.config is already typed canonical tuple data and is compared directly; normalized mapping pairs are compared directly to retain unused UUID/group entries. Integer/Decimal distinctions and unused/absent settings participate in comparison.

Replay loads envelope UUID without consulting activation. Missing original configuration → unavailable_replay/original_rules_unavailable; unavailable formula → unsupported_strategy; mismatched UUID/formula/full rules or altered inherited evidence → inconsistent_replay. Validate envelope shape/UUID/schema before traversal and reject nested malformed evidence ordinarily. Once bound, inherited Replay verifies authoritative original membership/facts/derived values/score; late arrivals never enter replay. Corrupt persisted rules/connection outages remain visible storage failures, never fallback scores.

No active configuration → distinct no_active_configuration; valid inactive explicit calls still work. Preserve not_found player, no_recorded_performances, insufficient_data and scorer errors. Configuration validation precedes empty football history. Providers can be unavailable. Reads/evaluation/replay write no version/history/fact/quote/financial record or event/job; saves/activation only write their own records. Existing prepare/score/evaluate/replay remain compatible formula/conformance helpers; downstream market consumers must use managed calls.

TASK-026 must retain/protect the entire version/evidence binding; whole-result substitution by another legitimate result is outside this internal evidence trust boundary. No price conversion/calibration, quote jobs/history, rankings, trading or wider CP2 feature is delivered here.
