---
id: TASK-078
title: Search scouting on missing catalog and bounded demand refresh policy
type: task
checkpoint: CP2
priority: medium
workflow: thinflow-v1
status: review
depends_on: TASK-011, TASK-018, TASK-055, TASK-056, TASK-079
active_run: 139dd9b4
---

## Outcome

Encode the CP2 product decision "demand + bounded scouting" for ingestion:

1. Keep the already-implemented demand refresh (TASK-056): opening a player detail whose statistics are stale (TTL expired or never checked) enqueues a deduplicated verification run; confirmed statistics update the stored facts immediately, whatever the hour. Daily quote recalculation is NOT part of this task: per the closing-price decision (TASK-079), stored statistics only record pending calculation work that the nightly batch admits. Do NOT retire this behavior (an earlier draft of this task proposed scheduler-only ingestion and is superseded by this decision).
2. Add the one missing behavior: searching a player who is not in the catalog triggers a bounded catalog scouting run chained to find the requested player. Resolution path (provider likely has no name search in its tier): normalize the name → try the provider name search when available, otherwise guess candidate team(s) from the name and pull those squad rosters → match the player. Requirements:
   - Deduplicate by normalized search name (same normalized name = one scouting run; reuse any active run).
   - Bounded budget per run: strict validation gate (format limits, no arbitrary queries), a small maximum of provider requests per scouting walk (fallback of guessing candidate teams first, squads second), per-window rate limit, and a negative cache TTL so a fruitless walk is not retried by further searches of the same name. A budget-exhausted walk may retry in the next nightly window instead of hammering in real time.
   - Non-blocking contract: the search responds immediately with "catalog miss, scouting scheduled" plus a scout status; when the run completes it persists results and broadcasts through PubSub so a repeat search would find the player. Searches never wait or block on the provider.
   - Catalog-only scouting: a successful run persists the player via the existing idempotent catalog ingestion (TASK-018) and must not create quotes, balance or trading side effects.
   - Provider failure keeps local reads unaffected (product invariant 6); surface scout status with last run state and next attempt at, never blocking the search response.
3. Documentation: update docs/PLAYER_SEARCH_WORKFLOW.md (its rule "a search without matches must not scrape an arbitrary name" is replaced by this bounded policy) and add an addendum to ADR-0016 recording the decision, the accepted tradeoff (a searcher may obtain fresher catalog coverage than idle users) and the rejection rationale of unbounded scraping.
4. Tests: unit + E2E profiles covering deduplication, policy rejection, negative cache, provider failure isolation, and the guarantee that scouting never mutates financial state or quotes.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md), [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md) and [ADR-0016](../docs/adr/0016-local-search-and-background-refresh.md). Keep the compact ThinFlow spec as the behavioral contract; separate plan and task artifacts are not required.
