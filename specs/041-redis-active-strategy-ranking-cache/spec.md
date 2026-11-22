# Redis active-strategy ranking cache

## Outcome

Reduce repeated PostgreSQL ranking aggregation reads by caching the active-strategy ranking in the existing Redis infrastructure. PostgreSQL remains authoritative; a cache miss or Redis failure returns the PostgreSQL result.

## Acceptance

- [ ] Ranking requests with the same active configuration version reuse a Redis entry; a cache hit avoids rerunning the ranking aggregation query.
- [ ] Cache keys identify the active strategy configuration/version, so activating another version cannot serve the previous version's ranking.
- [ ] Entries expire after a bounded 30-second TTL. After expiry, the next request refreshes from PostgreSQL.
- [ ] A miss, malformed cache entry, or Redis read/write failure returns the authoritative PostgreSQL ranking when PostgreSQL is available; Redis failure does not make ranking unavailable.
- [ ] Ranking cache hit, miss, and Redis-error events are emitted as telemetry measurements so cache use and fallback are observable.
- [ ] Focused tests cover cache reuse, version separation, expiry/refresh, and Redis failure fallback while preserving current ranking order and no-active-configuration behavior.

## Scope

- Add Redis-backed caching at the ranking domain read boundary, including a version-specific key and bounded TTL.
- Add focused tests and telemetry metrics for ranking cache outcomes.

## Non-goals

- Catalog search caching, ranking UI/API changes, cache invalidation beyond versioned keys and TTL, or changes to ranking business rules.

## Risk

- Declared: moderate. Redis is disposable; cached rankings can be at most 30 seconds stale while PostgreSQL remains authoritative on misses and failures.

## Decisions

- Use a conservative 30-second TTL to bound quote/ranking staleness without adding invalidation writes to financial transactions.
- Cache ranking entries under the active configuration identity; fetch active configuration from PostgreSQL for each read so a strategy switch selects a different cache key.
