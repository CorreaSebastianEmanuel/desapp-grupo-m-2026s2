# Cache invalidation and graceful fallback

## Outcome

Keep the ranking cache coherent with committed performance quotes and active-strategy selections. PostgreSQL remains authoritative for ranking identity and all financial decisions; Redis remains disposable.

## Acceptance

- [ ] A confirmed performance quote changes the cache identity only for its configuration after the outermost transaction commits. Concurrent readers retain the previous committed ranking until then. A rollback leaves its cache identity and ranking unchanged.
- [ ] A committed active-strategy selection, including reactivation of a previously selected version, uses a fresh cache identity. Failed or rolled-back selections do not invalidate the current ranking.
- [ ] A quote for an inactive configuration does not invalidate the active ranking. Ranking order, eligibility and response shape remain unchanged.
- [ ] A late fill from an older PostgreSQL snapshot cannot overwrite the cache identity used by newer reads. Old entries expire after the existing 30-second TTL; hits do not renew it.
- [ ] Redis read/write failures (including exceptions) return the authoritative PostgreSQL ranking and cannot prevent quote publication or strategy activation. Redis recovery cannot revive a pre-change ranking.
- [ ] Trading uses the current PostgreSQL quote even when Redis retains an older or corrupted ranking. Focused tests exercise commit/rollback ordering, scope, races, fallback and TTL.

## Scope

Ranking read/cache identity and focused regression tests, plus their maintained test inventory.

## Non-goals

Changes to financial settlement, quote publication, strategy rules, cache availability guarantees, cache TTL policy, new workers or infrastructure, full regression execution, and workflow-policy changes.

## Risk

Application read-cache change. An incorrect identity could serve stale prices in the ranking; financial execution must remain independent. Each cache read requires a PostgreSQL snapshot and a configuration-scoped quote count; cache hits still avoid ranking materialization, sorting and serialization.

## Decisions

- Use logical invalidation: keys include the committed selection order and the count of eligible immutable performance quotes for that configuration, read in the same repeatable-read snapshot as ranking data. Append-only tables make the revision monotonic within a selection; outer rollbacks never expose it. This avoids Redis deletion as a correctness dependency and isolates late fills without coupling financial writes to Redis.
- Keep the existing 30-second Redis expiry and version the key namespace. Superseded keys expire naturally, even during Redis failures; they are never selected again after a committed revision change. Reads overlapping a commit may return their consistent earlier snapshot.
