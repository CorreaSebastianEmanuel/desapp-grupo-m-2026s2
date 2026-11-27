human_check_required: true

## Decision needed

How must the catalog represent a player who changes teams within the same league season?

## Why it matters

The specification allows one provider-neutral player identity per league season and exactly one team per player record, while explicitly deferring transfer history. A transfer therefore forces a choice that changes observable catalog results and affects later ingestion/statistics integrity. Existing product and checkpoint documents do not resolve it.

## Options

1. **Current-affiliation snapshot:** update the existing player’s team. Simple and within the present model, but prior affiliation is lost and previously imported team-scoped facts may become misleading unless those facts retain their own team context.
2. **Immutable stints:** represent multiple team affiliations with effective dates (or player-season plus roster stints). Preserves history, but adds a core entity and temporal rules beyond TASK-005’s stated scope.
3. **Reject in-season changes:** keep the first affiliation and require later reconciliation. Smallest implementation, but valid provider updates cannot be ingested and the local catalog becomes stale.

## Recommendation

Choose **current-affiliation snapshot** for TASK-005, explicitly defining reassignment semantics and preserving an extension point for dated roster stints in the later ingestion/statistics work. Do not add transfer-history entities now. Require later match/statistic records to carry sufficient event context so a current-team update cannot rewrite historical facts.
