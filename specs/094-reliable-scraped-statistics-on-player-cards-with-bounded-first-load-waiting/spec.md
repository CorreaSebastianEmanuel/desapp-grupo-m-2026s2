## Outcome

Opening a player card reveals verified scraped statistics from the configured authorized provider. Stored accepted data renders immediately, including stale data. With no accepted statistics, the card visibly waits for durable background work for at most 20 seconds, reveals accepted data as soon as detected, and continues updating after a bounded fallback. Provider IO remains in workers; navigation and local/API reads remain responsive.

## Acceptance

- [ ] Existing accepted statistics render immediately and survive provider failure.
- [ ] First open without accepted statistics admits or reuses durable work and displays “Preparando estadísticas verificadas…” while pending. Repeated and concurrent opens reuse the same scoped import.
- [ ] Accepted statistics replace the loading shell automatically without another click or reload. Initial waiting lasts at most 20 seconds, never a mandatory fixed delay. At the deadline show “La preparación sigue en segundo plano. Las estadísticas aparecerán cuando estén verificadas.” while valid work continues; later acceptance still updates the card automatically.
- [ ] Distinguish pending work, verified no participation (“Sin participaciones verificadas en este período”), unsupported coverage (“La fuente no ofrece cobertura verificable para este período”), configuration/access denial, temporary acquisition failure and rejected inconsistent evidence. Failure leaves navigation usable and preserves accepted local data; never represent missing values as zero.
- [ ] Deterministic provider regressions reproduce Anselmino’s requested PL 2026/2027 with a recent match dated 2026-11-08 but older statSeasons, and Haaland’s profile lineupPositionId 105 versus match positionId 115 and usualPosition 3. Supported evidence can succeed under the settled precedence rule; negative player/team identity, league, season, kickoff, participation and historical-position controls still reject inconsistent or insufficient evidence.
- [ ] Complete authorized player-season evidence with no participation remains distinguishable from unsupported or incomplete coverage. A recent match alone cannot establish complete season coverage.
- [ ] Corrected supported versioned inputs/configuration can admit new work after a previous terminal rejection. Preserve terminal audit evidence, deduplication, cooldowns, retry limits and immutable accepted history; unchanged rejected inputs do not retry endlessly.
- [ ] Add deterministic provider, ingestion/worker, LiveView and actual browser regressions for these behaviors, including timeout followed by success and responsive navigation on failure. Reconcile changed source/path/test inventories and affected scheduler, ingestion and configuration contracts.
- [ ] Before review readiness, record bounded, non-sensitive, revision-bound evidence of a real authorized provider → worker → accepted persisted facts → visible browser card smoke for at least one supported player with usable statistics. Fixture success does not prove live scraping. Report unavailable access specifically and leave this acceptance unfulfilled.
- [ ] The affected full integration profile, selected ThinFlow checks, independent evaluation and exact-head hosted ThinFlow required must pass before human merge. During this develop session run focused tests only; the harness selects required local checks afterward. A timeout is incomplete evidence.

Live development evidence, 2026-11-17 02:29:59 UTC: authorized FotMob live HTTP → StatisticsImport run `ba7c14a1-53f4-4ad7-8b8e-f7d197d05856` → accepted PostgreSQL facts → authenticated Chromium card. Haaland (`737066`), PL 2026/2027: 10 recorded matches, 890 minutes, 9 goals, 0 assists; the browser asserted each value against the stored summary and navigated successfully (exit 0). The initial live import accepted changes at 02:19 UTC; the final-code recheck succeeded with `accepted_unchanged`, preserving those facts. Input digest: `af1121d110cee109ee158004321e4b841967325e2332f9145af5be2ee4fbd723`. The bounded smoke used a parser-hash fixture_ref to distinguish corrected development inputs, with the configured live transport and source permission checks intact.

Evidence binding: base HEAD `51a021a5c7d7c7eee37fcda8b0092000f17ee575`, dirty TASK-094 candidate; player_profile.ex SHA256 `854daea5be22d548bf5a8231d521e45db46047bb9691de0cc6fdc13c77578569`. Runtime SHA256 `2a7542cb3702205307a92d1e8e442da04fe8bacc797dbe2645b1313d4e5c0b0a` hashes sorted path + NUL + bytes + NUL for config/synchronization.exs, lib/football_market/providers/scraping/{assessment,player_profile}.ex, lib/football_market_web/components/workspace_components.ex, lib/football_market_web/live/workspace_live.ex and tools/openapi/player_statistics_browser.mjs. No raw provider documents, credentials or account sessions are included in this evidence.

## Scope

TASK-094 only: existing scraper interpretation, first-load card presentation, persisted refresh observation, recovery through existing versioned inputs, and directly required tests/documentation. Preserve TASK-093 preload, scheduled refresh, durable recovery, rate limits and local persistence boundaries.

## Non-goals

New providers or coverage, synchronous scraping or server-side waiting in requests/LiveView callbacks, broad refactoring, fabricated statistics, current catalog position as historical evidence, strategy activation, financial-history rewrites, changed TASK-092 first-performance-quote rules or subsequent nightly-close pricing, weakened workflow/test policy, or changes to merged TASK-093 artifacts.

## Risk

Data integrity: accepting the wrong historical position or season affects immutable statistics and downstream valuations. Provider authorization, completeness and identity checks remain mandatory. Deterministic diff classification is authoritative. Review readiness still requires the affected full integration profile, selected checks, independent evaluation and exact-head CI; focused development checks and live observations do not replace them.

## Decisions

- Confirmed: initial visible waiting is capped at 20 seconds and ends earlier on detected success. Waiting is a presentation state observing persisted durable work; stored data is immediate. The Spanish labels above are conservative presentation choices.
- Evidence invariants: match and player IDs, both teams, league, completed status and kickoff must agree across profile/match evidence. An explicit contradictory match season rejects the import. Season-window checks and complete-history pagination checks remain mandatory. Missing metrics remain unknown; contradictory measured counts reject the import. Source access and HTTP allowlists remain enforced.
- Position precedence: reuse assessed match position mappings and the existing match playerStats.usualPosition fallback. Corroborate available same-match lineup entries by player/team, tactical position and normalized role. Differing unmapped profile/match tactical IDs (105/115) are not contradictory normalized roles; supported normalized profile roles must agree with the accepted match role. Reject inconsistent same-match evidence, unknown/unassessed roles and missing historical proof. Never map 105/115 broadly or use catalog position.
- Season-summary precedence: missing requested statSeasons membership can be superseded only by independently validated in-scope match evidence together with the existing complete-history proof; it cannot by itself prove an empty season. Other identity, explicit season and completeness contradictions still reject.
- Parser correction increments the local source identity to player-profile-history-v3/version 6 and the assessed revision to v6, allowing corrected jobs through normal versioned admission while preserving terminal audit evidence. Busy/cooldown work is observed as pending; rejected inputs stay terminal.
