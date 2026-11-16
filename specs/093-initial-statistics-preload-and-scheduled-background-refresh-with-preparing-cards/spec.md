## Outcome

Configured player statistics are preloaded asynchronously after application startup and refreshed by a recurring background pass. Existing accepted statistics and local catalog data remain available while imports run or providers fail. A player card with no accepted statistics shows a preparing state during active import and updates automatically when the import settles; established missing-data and failure states remain explicit.

## Acceptance

- [ ] Application startup durably enqueues a deduplicated statistics preload; a recurring durable job performs the same pass so stale work is recovered after restart and refreshed over time.
- [ ] The pass enumerates local catalog players, applies the existing per-scope TTL and trusted provider configuration, and admits work through the existing deduplicated/rate-limited synchronization boundary. It performs no provider I/O in the scheduler or page request.
- [ ] Local player and statistics reads continue to return accepted data when providers are missing, fail, or time out.
- [ ] A player card with no accepted statistics distinguishes an active queued, executing, or retry-wait import as preparing; after completion or failure, connected cards reload automatically and render the resulting statistics or the existing explicit empty/failure state.
- [ ] Existing administrator-selected valuation configuration and first-performance-quote behavior are unchanged.
- [ ] Focused tests cover startup/recurrent admission, deduplication and local-read isolation, and automatic card state updates across import completion/failure.

## Scope

- Add a durable startup and recurring worker for configured player statistics preload/refresh.
- Add preparing-state projection and connected-card refresh for active statistics imports.
- Add focused tests for the above behavior.

## Non-goals

- New provider adapters, changes to accepted-statistics rules, quote formulas, valuation configuration, or market trading.
- Manual bulk-import controls, provider calls from web requests, and unrelated UI or architecture cleanup.

## Risk

- Medium: background admission touches durable synchronization and LiveView state. Existing scope locks, TTL, retry policy, and persisted Oban jobs remain authoritative.

## Decisions

- Reuse the configured statistics freshness TTL (24 hours by default) and provider bindings; the recurring pass checks hourly, and only stale or never-checked player scopes are admitted.
- Serialize the preload pass on the existing statistics import queue and deduplicate its wake jobs. The pass itself only admits existing per-player import jobs.
- Preparing is shown only while the current player has an active queued, executing, or retry-wait import; terminal failures and absent provider configuration retain their current explicit states.
