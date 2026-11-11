# TASK-091 · Richer performance data and consistent strategy selection

## Outcome

Import verified match metrics, expose their recorded coverage, and let administrators provision, inspect, edit and separately activate immutable versions of the two supported valuation families.

## Acceptance

- [ ] Authorized player-profile imports fetch linked match documents through the existing assessed transport, deadline and shared budget. Validate player/match, league/season, kickoff, teams and historical position. Accept only assessed per-player match counters; never substitute team totals, season aggregates, passes or xG.
- [ ] Preserve nine integer counters and informational minutes. Verified zero remains zero; absent values remain unknown. Reads expose known/unknown counts and complete, partial or unavailable recorded coverage. Missing required valuation inputs remain insufficient data.
- [ ] Enrich existing performances additively with append-only, check-linked cumulative metric snapshots. Preserve original rows and provenance, reject changes to known values or identity/position, retain known values when later sources omit them, and make repeated enrichment idempotent. Replay authenticates the exact original or retained enriched snapshot. Old quotes and admitted calculation inputs remain unchanged; enriched inputs request a later nightly calculation.
- [ ] Explicit administrator setup provisions one versioned balanced preset and one position-aware preset idempotently, without activation, duplicate copies, identity merging or price recalculation. The administrator editor saves changed weights/references as a new immutable custom version. Existing configuration/selection concurrency and authorization apply to every command.
- [ ] Administration shows exactly two formula families, saved-version counts, stable identities, preset/custom origin, equivalent-rule versions, effective weights/references/role mapping, active identity and empty/unconfigured states. Saving and activation are separate actions; activation takes effect at the next nightly close.
- [ ] Shared Statistics read, player-detail API and player card expose all recorded counters and per-metric coverage with Spanish labels, explicit unknown values and a local-recorded-only disclaimer; existing fields remain compatible.
- [ ] Focused tests cover translation/identity failures, zero/missing values, immutable enrichment/replay, preset setup/editor/authorization/concurrent selection and a real browser selection journey. Register source/test inventories. The harness runs required local checks after development; no full regression runs in this stage.
- [ ] Repair Feedback 1: unavailable originals retain immutable unreproducible calculations with no price/quote/ranking, stable evidence-bound identities and safe replay. Preserve the historical 33-path configuration inventory while checking the exact current namespace including editor/presets; permit only the reviewed deterministic SHA-256 call in valuation purity checks, with negative controls. Player-card assertions cover every known/unknown metric and retain financial/provenance checks. Run the four reported modules, enrichment/preset/browser regressions and the specifically requested integration profile; leave authoritative selected checks to ThinFlow.

## Scope

Existing scraper/provider boundary, immutable statistics evidence and read projections, valuation replay/input identities, configuration domain/provisioning and administration editor, player detail API/card, focused integration/browser tests and affected inventories.

Feedback 1 repair also owns the ranking selection, valuation/configuration scope and portfolio LiveView regression tests. Current integration evidence is retained at `.agentflow/runs/7f342332/thinflow/task-091-integration-repair.json` for the evaluator; earlier evaluation does not cover this repair.

The user authorized one additional verification round after the full-profile timeout and evaluator B1. Preserve that failed result. Native follow-up output, progress/wait diagnostics, receipt and material input identities live under `.agentflow/runs/7f342332/thinflow/integration-round2/`; obtain complete integration without weakening timeout or selection, refresh selected checks and use a fresh independent verification before resuming the existing publication gate.

Operational prerequisite: narrowly support feedback rewinds of the installed Spec Kit v2 execution checkpoint so the registered repair actually reaches the same builder. Preserve captured workflow/model settings, prior outputs and backups, existing retry/feedback limits and normal final-stage publication retries. Include `agentflow` and its focused feedback regression tests in the task's exact scope.

## Non-goals

New formula families, decimal xG or general passes, automatic activation, immediate recalculation, historical count/quote updates, database resets, history deletion or configuration deduplication; unrelated refactors and workflow-policy changes.

## Risk

High: provider evidence, immutable fact enrichment, reproducible financial inputs and administrator configuration. Deterministic diff classification remains authoritative.

## Decisions

- The user approved the administrator editor alongside both predefined configurations and the initial educational calibration in the active backlog task. Do not reopen these choices.
- Retain UTC weekly cumulative counts, per-metric cap one, historical role grouping, exact decimal arithmetic and existing rounding. Nonpositive results still publish no positive quote.
- Weekly references: goals 2, assists 2, shots_on_target 6, tackles 8, interceptions 6, saves 10, goals_conceded 4, yellow_cards 2, red_cards 1.
- Balanced weights: goals 4, assists 3, yellow_cards -0.5, red_cards -2.
- Position-aware weights: goalkeeper goals 4, assists 3, saves 4, goals_conceded -2; defender goals 4, assists 3, shots_on_target 1, tackles 3, interceptions 3; midfielder goals 4, assists 4, shots_on_target 1.5, tackles 2, interceptions 2; forward goals 5, assists 3, shots_on_target 2. Every role includes yellow_cards -0.5 and red_cards -2. Other metrics are excluded, not zero-weight requirements.
- Provision presets against the installed standard role codes (GK, DEF, MID, FWD), fail visibly on missing mappings; never guess unknown role codes. Preset identity includes calibration version and immutable role mapping. Equal custom rules retain their separate identities.
- An unavailable recorded metric means no known values in the retained matches, not a claim that the provider can never supply it. Partial coverage never becomes a fabricated total. Unknown-to-known additions preserve the original evidence and each accepted cumulative snapshot.
- Unavailable-original calculation failures include the same deterministic fact digest used for non-original metric snapshots, binding the supplied failure evidence without authenticating it. Original-fact validation still rejects unavailable rows; original and retained enriched replay remain authoritative. The purity exception is restricted to `StatisticsReader`'s exact `:crypto.hash(:sha256, digest)` call.
- Sobelow exception re-triage: the three existing low-confidence findings in `quotes/membership.ex` (lines 194 and 220) and `statistics/ingestion/observations.ex` (line 41) remain bounded. Both SQL strings are fixed, with caller values bound through PostgreSQL parameters; the added enrichment subquery contains no interpolated SQL. The fixture read still uses one fixed repository path and validates its inventory digest. Refresh only those reviewed source hashes and the relocated query line, preserving exact file/rule/line/confidence matching and rejection after any later source mutation. The native scan reported no other new findings.
- Dialyzer re-triage in both dev/test application profiles: retain the existing exact `Ecto.Multi.new/0` → `run/3` opaque-MapSet exception at `statistics.ex:72` and defensive evidence-score nil comparison at `quotes/engine.ex:305`. Those expressions are unchanged; enrichment added later statistics reads and two preceding identity lines in the engine. Refresh their exact native-observed message/source identities and relocated line only; preserve profile, phase, kind, dependency-lock binding and strict rejection of all other findings.
- Feedback recovery compatibility: explicit rewinds invalidate the supported native v2 execution tree after backing it up and retaining results before the requested stage. The installed engine then reconstructs only the remaining captured steps. Recover an earlier erroneous completed replay only when its non-final pointer matches the latest classified ThinFlow feedback; do not reopen ordinary completed publications or guess unknown schemas. This uses the same run, builder settings and one existing repair entry. Five portable regression cases and a real installed-engine shell-only probe verified prefix retention, actual builder/gate re-execution and refusal/idempotence controls; fresh independent evaluation must also review this repair.
- Match-document role codes supply historical grouping (0 goalkeeper, 1 defender, 2 midfielder, 3 forward); profile lineup identity must agree when present. Unmapped historical positions fail closed instead of inheriting today's catalog role. Detail-link responses that identify a different match, including a newer match returned for a reused fixture URL, fail closed and do not establish complete coverage.
