## Outcome

Provide an authenticated, administrator-authorized, read-only JSON API for aggregate business metrics covering quotes, conditional orders, portfolio activity, ingestion, and job outcomes. TASK-073 can consume the same domain calculation boundary without duplicating calculations.

## Acceptance

- [ ] Missing or invalid API authentication is rejected; authenticated non-administrators are forbidden. Administrator authorization uses the existing account policy.
- [ ] An authorized response covers all five business areas using a documented, fixed allowlist of aggregate fields.
- [ ] Responses contain no user-level financial data, account/player/job identifiers, credentials, provider payloads, job arguments, or raw failure details.
- [ ] Empty source data is explicitly distinguishable from unavailable source data; a failed read is never represented as a successful zero count.
- [ ] The HTTP/OpenAPI contract documents fields, units, reporting basis, authentication, authorization, and empty/unavailable behavior.
- [ ] Focused automated tests prove authorization, exact aggregates against controlled fixtures, empty data, source failure, privacy, and HTTP contract behavior.
- [ ] `GET /api/business-metrics` uses one read-only repeatable-read snapshot. Each section has `status` (`available`, `empty`, `unavailable`) and `counts`; empty sections contain explicit zeros, unavailable sections contain null counts. A required source failure invalidates the whole snapshot (HTTP 503, null `as_of`); successful snapshots return HTTP 200 and the database transaction timestamp. Responses use `Cache-Control: private, no-store`.

## Scope

- One administrator-only aggregate endpoint, a reusable domain read boundary, directly required persistence queries, contract documentation, and focused tests.
- Use existing locally persisted data or existing observability sources; preserve domain, web, persistence, and external-adapter boundaries.

## Non-goals

- Dashboard UI, mutations, new instrumentation/history storage, provider requests, per-user breakdowns, and unrelated refactors.

## Risk

- Authorization and aggregate privacy are material risks. Counts, windows, and retention semantics must be explicit so administrators do not mistake retained state for lifetime business outcomes.
- Deterministic diff classification remains authoritative.

## Decisions

- Confirmed by human feedback 1: report currently retained local records (`basis: retained_local_records`), never lifetime totals, rates, or historical ingestion attempts. Oban pruning changes retained job counts.
- Quotes count performance quotes with a calculation reference (excluding issuance) and quote calculation requests by persisted state. Conditional orders count persisted statuses, without performing expiry transitions during reads.
- Portfolio activity counts completed purchases and sales and sums their integer token quantities separately. Issuance, issuer holdings, balances, money amounts, and idempotent replays are excluded.
- Ingestion counts accepted scope records with a completed check timestamp (including accepted empty checks) and stored player match performance records. These count current rows, not import attempts or distinct players.
- Jobs count retained Oban records by state across all queues, including completed, discarded and cancelled outcomes. No queue names, arguments, errors or identifiers are returned.
- State/status maps use fixed documented keys with zeros for absent states. Every count is a nonnegative integer; no request parameters select users or alter reporting basis. The OpenAPI schema is the exact response allowlist.
