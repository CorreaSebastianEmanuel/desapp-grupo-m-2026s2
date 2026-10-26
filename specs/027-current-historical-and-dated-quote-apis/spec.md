# Current, historical and dated quote APIs — TASK-027

**Feature Branch**: `027-current-historical-and-dated-quote-apis`
**Record type**: Retrospective specification of an already merged manual delivery.

This record was backfilled on 2026-10-26. It describes the implemented contract;
it is not evidence that an Agentflow product/design/development run occurred.
The feature branch above is the canonical Agentflow ownership key. Original
delivery was commit `689d917` on main. See [provenance](reconciliation.md).

## Outcome and acceptance

- **FR-001**: Authenticated callers can read `GET /api/players/:player_id/quotes/current`,
  `GET /api/players/:player_id/quotes/history`, and
  `GET /api/players/:player_id/quotes/at?date=YYYY-MM-DD` with either the existing
  JWT or API-key credential. Browser cookie authority alone is insufficient.
- **FR-002**: Reads use only locally persisted immutable quotes. Initial issuance
  participates without fabricated calculation metadata. Current quote selection
  follows authoritative performance sequence, with deterministic timestamp/ID
  tie-breakers. History includes every distinct record in ascending sequence order.
- **FR-003**: A dated lookup includes the complete requested UTC day through
  23:59:59.999999 and carries the latest eligible quote forward through gaps.
  Equal prices/times do not collapse distinct quotes. Date bounds and leap days
  remain deterministic.
- **FR-004**: Single responses use `data` objects; history uses a `data` array.
  Prices are exact decimal strings with two fractional digits. Persisted UTC
  timestamps, strategy/configuration/mapping identity and nullable original
  issuance metadata are preserved in the public representation.
- **FR-005**: Missing credentials return 401; missing, duplicate, nested,
  malformed or impossible dates return 400 `invalid_date` before player lookup.
  Malformed/unknown player UUIDs return 404 `player_not_found`. Existing players
  without a quote return empty history or 404 `quote_not_found` for single reads.
  Storage failures return 503 `temporarily_unavailable`.
- **FR-006**: Routes, responses and errors are represented in the shared OpenAPI
  contract. Reads cannot enqueue jobs, invoke providers, create calculations,
  alter quote history or change financial holdings.

## Boundary

This task exposes TASK-026's existing quote history. It does not implement quote
calculation, trading, ranking, caching, portfolio analytics or a new authorization
policy. Quote confirmation correctness fixes from maintenance PR #54 remain part
of the current baseline; this record does not reassign their original ownership.

## Verification

The maintained reader/controller/OpenAPI tests and complete integration profile
exercise the above behavior. `verification.json` is a reproducible check manifest,
not a receipt or a claim of a historical workflow execution. Current independent
QA and review are recorded separately in `qa-report.md` and `review-report.md`.
