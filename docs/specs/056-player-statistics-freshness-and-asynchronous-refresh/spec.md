# Player statistics freshness and asynchronous refresh — TASK-056

**Feature Branch**: `056-player-statistics-freshness-and-asynchronous-refresh`
**Record type**: Retrospective specification of an already merged manual delivery.

Backfilled 2026-10-26. This is the implemented behavioral contract, not evidence
that earlier SDD stages ran. The declaration is the canonical Agentflow ownership
key. Original PR #53 used the shorter branch `056-player-statistics-freshness`;
see [provenance](reconciliation.md). The separate directory
`specs/056-football-scraping-adapter` remains owned by TASK-055 and is untouched.

## Outcome and acceptance

- **FR-001**: Existing authenticated `GET /api/players/:player_id` preserves its
  `data` catalog object and adds sibling `statistics_status`. List/search reads
  never enqueue work; detail checks PostgreSQL even after a cached search.
- **FR-002**: Status identifies player, season, provider, league code/year span
  and `league_season` coverage. The existing importer refreshes a complete
  provider/league-season; players within that scope share the same refresh work.
- **FR-003**: TTL defaults to 86,400 configurable seconds and starts at the last
  complete, validated, atomically accepted check for that exact provider/season.
  Accepted changed, no-change, replay and complete-empty checks renew it. Reads,
  queue admission, failure and incomplete checks do not. Expiry is exclusive.
- **FR-004**: Never-checked or stale detail may admit one existing durable Oban
  import. Queued/executing/retry-wait work is reused without adding a trigger for
  every poll. Admission lock contention returns `busy` without waiting for source
  execution. Database admission and job insertion are atomic.
- **FR-005**: Exact league/year scope selects trusted source/mapping/policy
  options from server configuration. HTTP parameters cannot override them.
  No source is enabled by default. Config/enqueue failures remain visible while
  available local catalog data is returned.
- **FR-006**: Existing bounded retries remain authoritative. After exhausted
  transient failures, new automatic admission respects a configurable 3,600-second
  cooldown or a longer provider hint. Permanent, validation, conflict and
  unconfirmed-publication failures remain blocked for unchanged trusted inputs;
  an existing trusted manual retry or corrected configuration can recover them.
- **FR-007**: Import status and valuation status are independent. Valuation
  follows the latest changed import affecting the exact player/season, including
  legacy intents without snapshots, and aggregates its weekly calculation
  requests. Later no-change checks do not hide pending or failed calculation work.
- **FR-008**: Current configured adapter coverage is fixture-only and explicitly
  reports `source_mode: fixture`; absent configuration reports `unconfigured`.
  `fresh` describes accepted-check age, not verified live-source accuracy. This
  feature does not activate live scraping or relax completeness/access gates.
- **FR-009**: Authentication and valid player lookup precede admission. Missing
  credentials return 401; malformed/unknown players return 404; catalog storage
  failure returns 503. Public status excludes raw payloads, secret configuration
  and unallowlisted diagnostics. Historical facts and immutable quotes remain
  protected.
- **FR-010**: OpenAPI and configuration documentation describe freshness,
  refresh, valuation and error states. Existing synchronization recovery,
  receipts and uniqueness constraints are reused; no second ledger, broker,
  scheduler, trading rule, ranking or UI feature is added.

## Verification

Maintained freshness/HTTP/concurrency tests and the full integration profile
cover these requirements. `verification.json` declares reproducible checks;
it is not a historical receipt. Fresh independent reconciliation reports are
recorded separately in `qa-report.md` and `review-report.md`.
