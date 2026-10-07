# Checkpoints

## CP1 — 2026-09-29

GitHub repository, green Actions build, SonarCloud with fewer than 10 issues, JWT, OpenAPI 3, minimum model, unit tests, user/API-key creation, and player catalog.

## CP2 — 2026-11-03

Updated from the teaching announcement supplied by the team on 2026-10-07 (presentation/delivery remains Tuesday 2026-11-03). See [the recorded announcement](CP2_SCOPE_CHANGE.md).

- Remaining core requirement: separate unit and actual end-to-end testing profiles. Existing integration profiles must be checked rather than assumed equivalent to browser E2E.
- New requirement: frontend visualization of user data with charts.
- New requirement: plan, implement and present an additional product feature, with product rationale, technical rationale, a short demo and a code walkthrough. The team plans conditional buy orders evaluated asynchronously (ADR-0017).
- Retained market capabilities: configurable valuation strategies, dated immutable quotes, token trading, portfolio/operation history and active-strategy ranking. The announcement withdraws core checklist items, not these functional requirements.
- Persistence/HSQLDB-H2 alternatives, startup test data, Swagger documentation and coverage jobs are no longer new pending core deliverables; preserve their existing implementations and quality guarantees.
- Green build and regression/coverage checks remain engineering safeguards, not substitutes for the new product requirements.

Redis and a complete responsive frontend remain CP3; the authenticated frontend required by the CP2 charts and additional feature is delivered in CP2. Scoped TTL refresh is supporting work and must not displace required charts or the additional feature.

## CP3 — 2026-12-08

Architecture test, service audit, tag/release notes, metrics, monitoring endpoints, cached high-frequency ranking, advanced metrics, responsive frontend, and complete demonstration scenarios.

The team assumes PostgreSQL/Phoenix equivalents are accepted for checklist items originally naming HSQLDB/H2 and Spring tooling.

