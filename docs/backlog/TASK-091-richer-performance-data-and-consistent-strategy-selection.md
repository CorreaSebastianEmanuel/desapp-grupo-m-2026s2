---
id: TASK-091
title: Richer performance data and consistent strategy selection
type: task
checkpoint: CP3
priority: high
workflow: thinflow-v1
status: done
depends_on: TASK-025, TASK-055, TASK-077, TASK-086, TASK-090
active_run: none
---

## Outcome

Latest product direction (2026-11-12): Administration shares the workspace sidebar and design and offers only two fixed, automatically available formulas, General and Por posición. Strategy creation, names and editing are explicitly deferred by the user. Historical configurations/selection remain immutable; the compact spec and latest feedback decision supersede earlier editor proposals below.

Enrich authorized player scraping with verified per-match metrics already supported by the valuation domain, expose metric availability in player detail, and make the two supported strategies and their immutable configuration versions understandable and consistently provisioned across local installations. Provide two versioned predefined configurations alongside an administrator editor that saves custom weights and references as new immutable versions. Diagnose configuration counts without deleting history or silently changing active rules. The user approved the initial numerical calibration below after reviewing the weights, weekly references and meaning of excluded metrics, and explicitly requested implementation.

## Investigation

- `Valuation.Request.metrics/0` and `Statistics.Input.metrics/0` already support goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards. Balanced and position-aware scoring already accept explicit weights and normalization references for these metrics.
- `Scraping.PlayerProfile.profile_match_details/4` currently constructs performances from profile match-history rows; it does not fetch the available match-detail links. `Assessment.local_development/0` verifies only goals, assists and cards. Other metrics remain unknown even when a match document could supply them.
- Live inspection on 2026-11-10 of https://www.fotmob.com/players/194165 (Harry Kane) and https://www.fotmob.com/matches/bayern-munchen-vs-mainz-05/37vb95 returned bounded public HTML with matching match identity 5881220 and player 194165. That player's match statistics included shots on target, tackles, interceptions and accurate passes; season statistics included further shooting, passing and defensive groups. This is one observed capability, not proof of complete coverage for all players, roles, leagues or matches. Missing fields and semantic evidence still need validation.
- `Statistics.recorded_summary/1` and the player card currently expose only minutes, goals and assists, irrespective of the other stored fields. Assists are not general pass counts.
- `AdministrationLive` lists every saved configuration version. `Configurations.Store.create/1` intentionally creates distinct immutable identities even for equal rules; the registry supports exactly two formula families. Multiple entries for one family are not proof of extra formulas or a duplicate-record defect. Different databases may contain different versions. This checkout's development database had zero saved configurations and zero performances during inspection; the user's other installation was not inspected.
- `Statistics.Ingestion.Records.retain_existing_performance!/4` rejects any changed count, including unknown-to-known enrichment, as `immutable_conflict`. A richer parser alone would therefore break reimports of previously retained performances. Historical evidence and replay must remain authoritative.

## Acceptance

1. Import verified available per-player, per-match metrics through the existing authorized transport and provider boundary. Validate match/player identity, league/season, kickoff and historical position; preserve source meaning, deadlines, request budgets, completeness and rate limits. Do not infer player values from team totals or season aggregates.
2. Distinguish verified zero, unknown, unavailable and partial coverage throughout ingestion, valuation and presentation. An absent required metric must not become zero or a fabricated score. The initial metric scope is the existing nine counters plus informational minutes; decimal xG, general passes and a new scoring algorithm are outside this task unless explicitly added by a product decision.
3. Define and test a compatible additive enrichment path for already imported matches. Preserve original retained facts and evidence, known values, old calculation replay and immutable quotes; repeat import/enrichment must be idempotent. Do not remove immutable guards, update historical counts in place or reset the user's database.
4. Provide one predefined balanced configuration and one predefined position-aware configuration with an administrator-only editor for their explicit weights and normalization references. Editing a preset or a saved configuration creates a new immutable custom version; the original remains available. All effective weights, references, role requirements and configuration identities must be inspectable and versioned. No silently invented production calibration, activation or immediate price recalculation. Preset provisioning must be explicit and idempotent: repeated setup must not create indistinguishable copies, change an existing active selection or merge historical configuration identities. Saving and activation remain separate administrator actions.
5. Present the two strategy families separately from their configuration versions. Explain empty/unconfigured states, identify the active version, and distinguish equivalent or different saved rules without deleting or merging historical identities. Preserve administrator authorization, concurrent activation checks and nightly-close behavior.
6. Return available recorded metrics and coverage through the shared domain read, player-detail API and player card, with readable Spanish labels and explicit unknown states. Preserve existing API fields and avoid implying complete-season or live coverage.
7. Add focused regression tests for translation, missing/zero values, immutable enrichment and replay, configuration provisioning/version display, authorization and actual browser selection. Register affected source/test inventories and run ThinFlow-selected checks plus the affected integration/browser cases before independent evaluation.

## Product decisions

The user selected the administrator editor and requested that both predefined configurations coexist with it. Preserve the original two formula families and version history. Show predefined and custom configurations clearly; a custom configuration is a version of a formula, not another formula family. This settles the configuration approach; do not ask the user to choose presets versus editor again.

After reviewing the complete weight table, the weekly references and examples of normalization and excluded metrics, the user said "bueno, bien, empecemos con la task". This approves the proposed initial editable presets and authorizes starting TASK-091 through ThinFlow. A dash excludes the metric from that strategy/group; missing required source data remains insufficient data. Do not request these settled choices again.

## Approved initial preset calibration

These are explicit initial educational settings, not empirically calibrated fair-market valuations. They retain the existing weekly UTC cumulative-count formulas, per-metric normalization cap of one, historical position grouping, exact arithmetic and rounding. References are shared across the role groups. A dash excludes the metric from that preset/group; it is not a configured zero weight and does not create a missing-data requirement.

| Metric | Weekly reference | Balanced | Goalkeeper | Defender | Midfielder | Forward |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Goals | 2 | 4 | 4 | 4 | 4 | 5 |
| Assists | 2 | 3 | 3 | 3 | 4 | 3 |
| Shots on target | 6 | — | — | 1 | 1.5 | 2 |
| Tackles | 8 | — | — | 3 | 2 | — |
| Interceptions | 6 | — | — | 3 | 2 | — |
| Saves | 10 | — | 4 | — | — | — |
| Goals conceded while on field | 4 | — | -2 | — | — | — |
| Yellow cards | 2 | -0.5 | -0.5 | -0.5 | -0.5 | -0.5 |
| Red cards | 1 | -2 | -2 | -2 | -2 | -2 |

For example, two goals reach the goals feature cap for the week; further goals do not increase that metric's contribution under the retained formula. Balanced remains a universally interpretable attacking/discipline baseline using the four profile counters. Position-aware adds the verified role-relevant match counters rather than requiring goalkeeper-only statistics from outfield players. Required values must actually be present: missing counters remain insufficient data, never invented zeros. A nonpositive result retains the existing no-positive-performance-quote behavior; do not introduce an unapproved base price or floor.

The administrator can subsequently adjust these approved initial values through new versions. Neither shipping presets nor saving an edit activates a configuration or immediately recalculates quotes. Refine the compact spec before building. Investigation and task definition do not constitute an implemented feature or a passing evaluation.
