# Implementation Plan: Football Catalog Domain Model

**Branch**: `005-football-catalog-domain-model` | **Date**: 2026-09-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-football-catalog-domain-model/spec.md`

## Summary

Add a `FootballMarket.Catalog` domain context backed by Ecto/PostgreSQL records for leagues, seasons, teams, positions, and season-specific players. Database foreign keys, checks, and normalized unique indexes preserve the hierarchy under concurrency; context functions trim input, translate constraint failures into field/relationship errors, expose explicit business lookups, and allow the approved current-affiliation player reassignment. Repair the local artifact gate so its declared timestamped migration glob is resolved safely and cannot strand the run. No HTTP surface, seed taxonomy, provider mapping, transfer history, or speculative bulk-ingestion command is introduced.

## Technical Context

**Language/Version**: Elixir 1.20.3

**Primary Dependencies**: Phoenix 1.8.13, Ecto SQL 3.13, Postgrex; no new runtime dependency

**Storage**: PostgreSQL through `FootballMarket.Repo`

**Testing**: ExUnit, Ecto SQL Sandbox, migration/integration tests against the TASK-002 PostgreSQL service

**Target Platform**: Linux-compatible Phoenix server and local macOS/Linux development

**Project Type**: Modular-monolith web application; this feature is domain and persistence only

**Performance Goals**: Index-supported direct and AND-composed catalog lookups at the representative 100,000-player scale; record `EXPLAIN` evidence, while deferring reproducible latency/SLA measurement to TASK-043

**Constraints**: Exactly five application-owned league pairs (`PL` / Premier League, `BL1` / Bundesliga, `PD` / La Liga, `SA` / Serie A, `FL1` / Ligue 1); normalized uniqueness must be race-safe; restrictive parent deletion; atomic context commands; no external identifiers or web contract

**Scale/Scope**: Five leagues, multiple seasons and teams, open position catalog, representative 100,000 players; five schemas, one context, one migration, persistence/context tests; one narrowly scoped delivery-tool fix with regression tests

## Constitution Check

*GATE: Passed before Phase 0 and re-checked after Phase 1.*

- **Specification before implementation — PASS**: the plan traces to FR-001–FR-019. The approved human decision resolves in-season transfers as current-affiliation reassignment; all other critic findings are resolved in [research.md](research.md).
- **Domain integrity — PASS**: foreign keys, restrictive deletion, transaction boundaries, checks, and race-safe unique indexes protect catalog integrity. No financial or token rule is touched.
- **Modular simplicity — PASS**: one `FootballMarket.Catalog` context uses the existing Repo/PostgreSQL baseline. Web, worker, cache, and provider layers remain unchanged.
- **Evidence-based quality — PASS**: [quickstart.md](quickstart.md) defines migration, focused tests, full tests, and query-plan evidence. Every behavioral rule has an automated-test obligation.
- **Independent verification — PASS**: the independent product challenge was synthesized and the required human decision is recorded as approved. [ADR-0002](../../docs/adr/0002-current-affiliation-player-snapshot.md) preserves the durable consequence for later work.
- **Safety and delivery — PASS**: planning adds no secrets, destructive operation, push, merge, or production mutation.

Post-design re-check: **PASS**. The data model and persistence contract retain all boundaries above. The ADR is not an architecture-baseline deviation; it records an approved durable domain choice that future statistics and ingestion designs must respect. No constitution violation requires an exception.

## Design Decisions

### Domain and persistence boundary

`FootballMarket.Catalog` is the only application-facing boundary. Ecto schemas and query modules live beneath that context; callers do not compose Repo queries. Changesets provide early errors, while PostgreSQL constraints remain authoritative during races. Context functions map named constraint violations to stable field or relationship errors.

### Normalization and supported leagues

Display values are stored after surrounding whitespace is trimmed. Business comparisons use PostgreSQL `lower(btrim(value))`, and expression unique indexes enforce the declared scopes atomically. This deliberately uses the database cluster's Unicode/collation behavior as the single comparison oracle instead of maintaining a second application-only case-folding algorithm.

The five name/code pairs are an application-owned allowlist: `PL`, `BL1`, `PD`, `SA`, and `FL1` paired with the names in Technical Context. A league changeset rejects unsupported or mismatched pairs; a database check limits normalized codes to that set. Pair tests prevent a recognized name from being combined with another supported code.

### Explicit lookups

Stable identity means each UUID primary key. Business identities are: league code or name; season `(league_id, start_year, end_year)`; team code or name within `season_id`; position code or name; and player catalog identity within the season derived through its team. Player filters accept zero or more of `league_id`, `season_id`, `team_id`, and `position_id`, compose with AND, reject unknown filter keys, and return ascending player UUID order. Empty filters mean all players. Unknown valid identities produce empty collections or `{:error, :not_found}` for singular fetches. Pagination and HTTP semantics remain later-task scope.

### Transactions and transfer behavior

Single-record context commands rely on one Repo operation. No speculative multi-record command is added. If implementation needs one concrete command to write multiple records, it must use `Ecto.Multi` and return no partial change on failure. Updating a player's team is permitted only when the destination team belongs to the same league season; the UUID and catalog identity remain stable. A move across seasons is rejected and requires a distinct season player record. Historical roster stints remain out of scope.

### Index strategy and performance evidence

Unique indexes cover every normalized business identity. Players carry a database-constrained `season_id`: composite foreign key `(team_id, season_id) -> teams(id, season_id)` makes it impossible to contradict the team while enabling a race-safe unique index on `(season_id, lower(btrim(catalog_identity)))`. Team season ownership is immutable after creation. Foreign-key indexes cover `seasons.league_id`, `teams.season_id`, and player `team_id`/`position_id`. A composite player index `(team_id, position_id, id)` supports team/position combinations; joins use indexed parent keys for league and season filters. Tests populate representative data and inspect `EXPLAIN` for index-capable plans. SC-007's latency percentile is not claimed here because hardware, concurrency, and sample protocol belong to TASK-043.

## Rejected Alternatives

- **Roster stints/effective dates**: rejected because they add a new temporal core entity beyond FR-019 and the approved snapshot decision.
- **Rejecting or cross-season mutating transfers**: rejected because one makes the current catalog stale and the other violates the season-snapshot identity boundary.
- **Application-only duplicate checks**: rejected because concurrent inserts can pass them.
- **`citext` or a new normalization dependency**: rejected because PostgreSQL expression indexes satisfy the required comparison without another extension or algorithm.
- **Bulk catalog API**: rejected because no current use case defines one; atomicity applies only to concrete multi-write commands.
- **HTTP/pagination contract and local stopwatch benchmark**: rejected as later-task scope and non-reproducible evidence respectively.

## Project Structure

### Documentation (this feature)

```text
specs/005-football-catalog-domain-model/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── catalog-context.md
└── handoffs/
    └── architecture.md

docs/adr/
└── 0002-current-affiliation-player-snapshot.md
```

### Source Code (repository root)

```text
lib/football_market/
├── catalog.ex
└── catalog/
    ├── league.ex
    ├── season.ex
    ├── team.ex
    ├── position.ex
    ├── player.ex
    └── query.ex

priv/repo/migrations/
└── *_create_catalog_tables.exs

test/football_market/catalog/
├── catalog_test.exs
├── constraints_test.exs
└── query_test.exs

test/support/
└── data_case.ex

scripts/
└── workflow_artifact_probe.py

test/scripts/
└── workflow_artifact_probe_test.py
```

**Structure Decision**: Extend the existing root Phoenix application with one domain context and persistence-owned schemas/query code. No catalog code enters `football_market_web`, infrastructure adapters, workers, or Redis. The probe change is an explicitly authorized delivery-tool exception required to recognize the migration glob; it is isolated from runtime application code.

## Complexity Tracking

No constitution violations require justification.
