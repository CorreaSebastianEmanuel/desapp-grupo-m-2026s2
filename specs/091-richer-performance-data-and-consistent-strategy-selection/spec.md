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

## Scope

Existing scraper/provider boundary, immutable statistics evidence and read projections, valuation replay/input identities, configuration domain/provisioning and administration editor, player detail API/card, focused integration/browser tests and affected inventories.

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
- Sobelow exception re-triage: the three existing low-confidence findings in `quotes/membership.ex` (lines 194 and 220) and `statistics/ingestion/observations.ex` (line 41) remain bounded. Both SQL strings are fixed, with caller values bound through PostgreSQL parameters; the added enrichment subquery contains no interpolated SQL. The fixture read still uses one fixed repository path and validates its inventory digest. Refresh only those reviewed source hashes and the relocated query line, preserving exact file/rule/line/confidence matching and rejection after any later source mutation. The native scan reported no other new findings.
- Dialyzer re-triage in both dev/test application profiles: retain the existing exact `Ecto.Multi.new/0` → `run/3` opaque-MapSet exception at `statistics.ex:72` and defensive evidence-score nil comparison at `quotes/engine.ex:305`. Those expressions are unchanged; enrichment added later statistics reads and two preceding identity lines in the engine. Refresh their exact native-observed message/source identities and relocated line only; preserve profile, phase, kind, dependency-lock binding and strict rejection of all other findings.
- Match-document role codes supply historical grouping (0 goalkeeper, 1 defender, 2 midfielder, 3 forward); profile lineup identity must agree when present. Unmapped historical positions fail closed instead of inheriting today's catalog role. Detail-link responses that identify a different match, including a newer match returned for a reused fixture URL, fail closed and do not establish complete coverage.
