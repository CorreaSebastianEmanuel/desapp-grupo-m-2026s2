# Trusted statistics ingestion interfaces

These are Elixir domain/provider interfaces, not HTTP APIs. No routes or permissions change. Existing public reads remain local-only.

## Provider result extension (TASK-016 boundary)

Providers.performances retains its request, deadline, scope, error and provenance contract. Extend Result with optional completeness, validated when present; ingestion requires full league-season evidence. Completeness is a versioned closed map: normalized scope, full_scope=true, terminal witness, expected eligible match qualified identities, detail coverage by identity, assessment revision/reference, and explicit empty attestation when empty. Source-owned assessed witnesses must support every assertion. Never expose body/URL/transport diagnostics or accept unknown evidence as complete. Catalog behavior stays compatible. Legacy direct-position DTOs remain valid for existing consumers; missing completeness prevents ingestion publication.

Performance adds optional participation evidence: direct known event-time position continues to work; nil position_ref requires trusted substitute_entered evidence. Reject absent position for every other role, unrecognized nonnil positions, profile usualPosition as match evidence, missing required identity/minutes/team/kickoff. Translator only emits entrant role when source evidence is verified; synthetic cases are marked in fixture inventory. Unknown optional count keys normalize to nil only when omitted/explicit unknown, explicit zero stays zero; malformed present values fail.

## Request and inspect

`Synchronization.request_statistics(scope, source_ref: safe_ref, fixture_ref: optional_safe_ref, mappings: trusted_entries, policy: optional_policy)` returns {:ok, retained_run} or {:error, safe_error}. Scope is a supported league_code/start_year/end_year, with no partial date interval. Source is required and resolves through the existing closed registry; fixture content/configuration identity is pinned. Only existing catalog bindings or exact trusted mapping instructions resolve entities; a mapping cannot retarget an accepted binding. No new_players option here. Equivalent active full inputs coalesce; differing inputs produce scope_busy with safe run ID. Trusted context only, no user endpoint, runtime module name or credentials in input/job args.

`Synchronization.get_run/1` and operation-filtered `list_runs/2` expose safe request/scope, attempts/waits/terminal reason, import outcome/check reference and calculation intent state; preserve legacy catalog defaults. Internal `Statistics.Ingestion.get_check/1` and `get_fact_provenance/1` support independent acceptance inspection. Do not add freshness predicates or provider calls to history reads.

Worker `StatisticsImport` uses existing one-shot execution/claim/recovery protocol with operation=statistics; only a valid current receipt fence can publish. `Statistics.Ingestion.import_scope(scope, execution_options)` is a trusted worker boundary, not a separate jobless public ingress. It fetches through Providers, validates completeness, and publishes with the fenced delivery context. Source assessment is rechecked before publication.

## Outcome taxonomy

Accepted outcomes: accepted_changes, accepted_unchanged, replay, accepted_empty. Failure categories distinguish invalid/incomplete, immutable_conflict, unsupported_capability/access_refused, retryable temporary source or persistence/execution failure, interrupted and exhausted. Source error categories/retry hints remain TASK-016-defined; runtime retry ownership remains TASK-019-defined. Safe field codes/templates only. Unknown source exception text is never echoed. Failure cannot move successful-check state.

All accepted outcomes include scope, check and run IDs and explicit non-live fixture attribution when applicable; only changes include calculation intent ID. Calculation state is a separate field/reference, never inferred from import success.

## Position and replay

Policy v1 uses only committed prior known performance positions in same player/season, strict earlier kickoff, one vote per match, fixed before proposed inserts. Equal kickoff and all proposed rows are excluded. Store basis IDs/frequencies; unique mode gives derived_history, tie/no known prior history gives unknown_history with reason. Existing accepted source material authenticates replay; reuse its effective position and basis even after history growth. Changed source material rejects the whole scope. Direct supplied event-time positions remain direct, including for entrants when trusted.

## Downstream request

Publisher atomically persists calculation intent with changed performance membership. Post-commit dispatcher/worker calls `Valuation.CalculationRequests.accept(intent_id, accepted_check_id, changed_performance_ids)` idempotently. Return {:ok, request} for new or identical existing request; safe conflict on differing material, safe temporary error on persistence failure. Acknowledge delivery separately; retry without duplicating receiving requests. Requested means requested, not evaluated or quoted. Read pending/failed state independently of successful import. No scoring inputs, strategy selection, current quote or quote writes are part of this interface.
