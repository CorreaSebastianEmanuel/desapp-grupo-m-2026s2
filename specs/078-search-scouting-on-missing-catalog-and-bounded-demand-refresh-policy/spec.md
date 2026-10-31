# Search scouting on missing catalog and bounded demand refresh policy

## Outcome

An eligible local catalog search miss schedules one durable, asynchronous scouting run for the normalized player name. The run uses an explicitly bounded provider strategy, imports only catalog facts through existing idempotent ingestion, and publishes its terminal status and imported result. Existing stale-statistics detail refresh remains unchanged: accepted facts are visible immediately, with quote calculation deferred to the nightly close.

## Acceptance

- [ ] Given a valid catalog miss, when scouting is admitted, then the search returns immediately, shares work with an equivalent active normalized name, and queues no more than five full-catalog requests for the configured season.
- Given an invalid query, an active or negatively cached name, or an exhausted hourly admission budget, when search runs, then it makes no new provider request and returns the applicable scout status and next eligible attempt.
- Given a successful provider response, when catalog ingestion completes, then a later local search can find the player and no statistics, quotes, balances, tokens, orders, or transactions have changed.
- Given no explicitly configured compatible season and provider source, when a valid catalog miss is searched, then local search returns immediately with an unavailable scouting status and creates no provider work.
- Search validation rejects empty, malformed, overlong, or non-player-like arbitrary queries without creating provider work.
- Equivalent normalized names reuse an active run; a completed miss is negatively cached for the configured TTL. Per-window admission and a strict provider-request budget bound scouting work; exhausted work reports its next eligible attempt.
- A catalog miss returns immediately with a scheduled/current scout status. Provider errors do not fail local search reads; status exposes the last run state and next attempt time.
- A successful scout uses catalog ingestion, makes the player visible on a later local search, and broadcasts completion after persistence.
- Scouting does not create or alter statistics, quotes, balances, tokens, orders, or transactions.
- Focused unit and E2E profile coverage proves deduplication, rejection, negative caching, provider failure isolation, non-blocking response, result publication, and financial/quote isolation. Search workflow docs and ADR-0016 describe the accepted policy and its tradeoffs.
- The existing demand-triggered statistics refresh and nightly-only quote calculation behavior remain covered and unchanged.

## Scope

- Add bounded scouting for eligible catalog misses, with normalized-name deduplication/status, negative-cache and rate/budget enforcement, asynchronous provider work, catalog-only persistence, and post-commit PubSub notification.
- Preserve TASK-056 stale-statistics refresh behavior.
- Update `docs/PLAYER_SEARCH_WORKFLOW.md`, add the decision/tradeoff to ADR-0016, and add targeted unit/E2E tests.

## Non-goals

- Changing statistics freshness, quote admission/calculation, trading, or financial data.
- Unbounded name scraping, provider access-policy bypass, Redis dependency, or a new service/queue infrastructure.
- Changing unrelated catalog/search behavior or existing provider operations beyond the selected scouting strategy.

## Risk

Medium: search-triggered provider requests and catalog publication introduce external-load and catalog-integrity risk. Fail closed on invalid input or unavailable provider; enforce durable deduplication and request limits; preserve local reads and the existing ingestion validation/publication boundary. Provider live access remains subject to TASK-055's documented access gate.

## Decisions

- Settled: accepted statistics facts remain visible immediately; quote calculation remains nightly-only (TASK-079). Scouting is catalog-only and never waits on provider work.
- Settled: equal normalized names share a run; successful imports use existing idempotent catalog ingestion; provider failure leaves local search available.
- Settled by product decision: scouting may issue at most one existing full-catalog request per supported league for the current configured season (maximum five requests), then match the normalized name locally. This reuses the existing provider contract and access/coverage evidence.
- Settled defaults: at most 10 newly admitted names per rolling hour and a 24-hour negative cache. The request budget remains at most five provider calls per run. A budget-exhausted run becomes eligible after the next configured nightly window.
