# Defer player quote recalculation to nightly batch

## Outcome

Statistics imports and demand refreshes may complete during the day: accepted statistics are persisted and available to reads immediately, while the current market quote remains unchanged. They also persist durable pending quote-calculation requests without dispatching quote work. A scheduled nightly market-close pass admits pending work and retries recoverable pending work after crashes. Match completion does not trigger quote calculation under this product decision; match-driven recalculation remains a future option. For each configured league/season, the pass uses the configured recurrence (default `0 0 * * *`, interpreted in UTC per the existing synchronization scheduler), admits each distinct pending request for changed accepted performance facts since the prior close to the existing Oban calculation queue, plus one request for each TTL-due player using that player/season’s latest accepted fact scope. Separate pending weekly scopes remain separate requests and are each calculated; only TTL backstop requests use the latest-scope rule. Successful calculations emit immutable versioned quotes plus conditional-order evaluation events atomically. Existing evaluation delivery continues unchanged. During the day, prices remain at the prior close; player detail returns the prior quote and `statistics_status.valuation.last_quoted_at` beside statistics freshness.

## Acceptance

- [ ] Given an accepted statistics import changes facts, when daytime ingestion completes, then the new statistics are persisted and readable immediately, and inspectable quote requests remain pending without quote-calculation Oban jobs, new quotes, or evaluation events.
- [ ] Given a stale player detail triggers a demand refresh during the day, when refreshed statistics are accepted, then the detail can show those statistics alongside `statistics_status.valuation.current_quote` and `statistics_status.valuation.last_quoted_at` from the previous close.
- [ ] Given one player/season has multiple changed weekly scopes pending at close, when the configured close runs, then each distinct pending request is admitted once to the Oban calculation queue and processed independently; duplicate ticks and retries do not duplicate calculations, quotes, or evaluation events.
- [ ] Given a request becomes pending before a process stop, when a later close runs, then the request is recovered with its accepted fact snapshot and admitted for calculation.
- [ ] Given a player’s latest quote reaches the configured TTL, when the close selects backstop work, then it creates work only for that player/season’s latest accepted fact scope.
- [ ] Given calculations succeed, when their results are committed, then immutable reproducible versioned quotes and evaluation events are recorded atomically and financial state remains unchanged by deferral.
- [ ] Given daytime statistics are fresher than the quote, when the player is read, then `statistics_status.valuation.current_quote` and `statistics_status.valuation.last_quoted_at` remain visible alongside statistics freshness.
- [ ] Given a match completes during the day, when no scheduled close has occurred, then no quote-calculation job or new quote is created because of that match.
- [ ] Given a league/season has a configured close recurrence, when its scheduled UTC close occurs, then its pending and TTL-due work is admitted independently of catalog-sync occurrences.

## Scope

- Change the accepted-statistics-to-quote request pipeline so it records pending work without immediate calculation dispatch.
- Add scheduled market-close admission for configured league/season scopes, using the existing UTC recurrence parser and quote-calculation/evaluation pipeline; each scope can override the default recurrence through configuration.
- Preserve pending work across restart and expose the current quote and its last-valuation time with statistics freshness.
- Align `docs/ARCHITECTURE.md`, `docs/CP2_ARCHITECTURE.md`, `docs/PLAYER_SEARCH_WORKFLOW.md`, ADR-0016, and the CP2 architecture presentation with daytime statistics refreshes and nightly-only quote calculation.
- Update directly affected specifications and focused tests.
- Keep backlog task IDs unique and ensure TASK-079 resolves to this quote-close task consistently.
- Pin the local Node.js major/minor used by the harness to the CI Node 24 runtime.

## Non-goals

- Changing valuation formulas, strategy/version selection rules, quote precision or history semantics, statistics ingestion/freshness behavior, conditional-order rules, trading, provider access, or unrelated scheduling behavior.
- Adding match-driven recalculation; retain it only as a future roadmap option in the existing CP2 presentation material.

## Risk

Quote timing changes observable prices and conditional-order evaluation timing. Retaining the existing atomic quote/evaluation transaction and durable request recovery is required. TTL fallback eligibility affects which players and stored facts receive new quotes, so it follows the explicit rules recorded below.

## Decisions

- **Resolved by product decision:** TTL is elapsed time since the player’s latest quote (`effective_at`). If that backstop makes a player due, use only the latest accepted fact scope for that player/season; do not replay older player/season/week scopes. Configure close recurrences independently per league/season through the UTC recurrence configuration, separately from catalog-sync occurrences.
- **Resolved by product clarification:** At close, enqueue every distinct pending changed-fact request, including multiple weekly scopes for one player/season, and calculate each through the existing queue. Do not coalesce pending import requests; latest-scope selection is exclusive to the TTL backstop. Nightly close is the current calculation trigger; match completion does not trigger recalculation.
