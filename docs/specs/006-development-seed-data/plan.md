# Implementation Plan: Development Seed Data

**Branch**: `006-development-seed-data` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-development-seed-data/spec.md`

## Summary

Add one explicit `mix catalog.seed` action that reconciles a fixed, fictional 2026–2027 catalog manifest through the existing Ecto/PostgreSQL catalog model. The operation validates the manifest, resolves records by TASK-005 business identities, reuses normalized-equivalent records without rewriting them, creates only absent records, and rolls back the whole invocation on any conflict or persistence failure. The action is allowlisted for development and test only, never runs from startup/setup/deployment, requires no provider or network, and exposes stable success/failure signaling for automation.

## Technical Context

**Language/Version**: Elixir 1.20.3 on Erlang/OTP 29.0.6

**Primary Dependencies**: Phoenix 1.8.13, Ecto SQL 3.13, Postgrex; no new dependency

**Storage**: Existing PostgreSQL catalog tables through `FootballMarket.Repo`; no migration or seed-ownership column/table

**Testing**: ExUnit, Ecto SQL Sandbox, Mix task tests, and an isolated local PostgreSQL command scenario

**Target Platform**: Linux/macOS development and CI; production execution is prohibited

**Project Type**: Modular-monolith Phoenix application; this feature is a catalog-domain service plus a thin Mix task

**Performance Goals**: `mix catalog.seed` exits successfully within 10.0 seconds against an already-running, migrated, empty local PostgreSQL database with dependencies compiled

**Constraints**: Exactly 44 manifest records (5 leagues, 5 seasons, 10 teams, 4 positions, 20 players); one all-or-nothing transaction; no updates/deletes; normalized identities follow PostgreSQL `lower(btrim(...))`; no network, provider, Redis, startup, setup, release, or production path

**Scale/Scope**: One immutable manifest, one reconciler, one command adapter, focused domain/command tests, documentation, and no HTTP/UI surface

## Constitution Check

*GATE: Passed before Phase 0 and re-checked after Phase 1.*

- **Specification before implementation — PASS**: the design traces to FR-001–FR-020. The current human approval adopts both recommendations in `handoffs/product-decision.md`; [ADR-0005](../../docs/adr/0005-development-seed-safety-and-semantic-convergence.md) records their durable meaning.
- **Domain integrity — PASS**: the existing catalog business identities and database constraints remain authoritative. One transaction, conflict-before-mutation behavior, and no update/delete path preserve catalog integrity.
- **Modular simplicity — PASS**: the feature stays inside the existing Catalog/Repo boundary and adds no service, adapter, cache, worker, endpoint, schema, or dependency.
- **Evidence-based quality — PASS**: automated tests cover every required state and failure class; [quickstart.md](quickstart.md) defines the reproducible command and performance evidence.
- **Independent verification — PASS**: the product challenge was synthesized, its two material choices are approved, and rejected alternatives are explicit below and in [research.md](research.md).
- **Safety and delivery — PASS**: the seed capability is false by default, enabled only in development/test configuration, denied before database access elsewhere, and neither automatic nor destructive.

Post-design re-check: **PASS**. The data model adds no persistent entity, the command contract preserves domain/persistence separation, and the validation guide covers checkpoint-visible catalog data. ADR-0005 records a durable interpretation and safety policy, not a deviation from the modular-monolith baseline. No constitution exception is required.

## Design Decisions

### Supported boundary and environment safety

`mix catalog.seed` is the only supported entry point. `Mix.Tasks.Catalog.Seed` is a thin adapter over `FootballMarket.Catalog.DevelopmentSeed`; it is not added to `mix setup`, any Ecto alias, application startup, release boot, migration, or deployment. A checked-in application capability defaults to `false`, is enabled only by `dev.exs` and `test.exs`, and has no environment-variable override. The task fails before application/Repo startup when its environment is denied, and the service independently fails before database access when the capability is disabled, so a production or unknown environment cannot seed.

The service returns `{:ok, summary}` or a typed error. The task exits zero only on success and raises a safe `Mix.Error` otherwise. Success reports fixed target totals plus created/reused counts. Failures report a category, entity type, and manifest business identity; validation fields/allowlisted causes are retained, while raw exceptions, database configuration, connection details, stored row contents, and credentials are never rendered.

### Manifest and reconciliation

The immutable manifest in [data-model.md](data-model.md) is validated before persistence and processed in deterministic dependency order: leagues, seasons, teams, positions, players. A single `Ecto.Multi`/`Repo.transaction` boundary carries resolved ancestor records between named reconciliation steps. Every step returns a matched record or inserts through the existing catalog rules; any conflict, changeset, constraint, or persistence error aborts the multi and is mapped to the typed result. There is no update or delete operation.

TASK-005's PostgreSQL `lower(btrim(...))` behavior is the only text-identity oracle. For entities with two alternate keys, both lookups must resolve to the same row. The comparison contract is:

| Entity | Business identity lookup | Exact canonical checks | Required relationship checks |
|---|---|---|---|
| League | normalized code and normalized name, independently | none; both are identity fields | none |
| Season | resolved league ID + exact start/end years | years are identity components | resolved target league |
| Team | target season ID + normalized code and name, independently | none; both are identity fields | resolved target season; a manifest code/name under another season is a misplaced-target conflict |
| Position | normalized code and normalized name, independently | none; both are identity fields | none |
| Player | target season ID + normalized catalog identity | display name byte-for-byte | resolved target team and position |

No match creates a record. One coherent match is reused verbatim. Alternate keys resolving to different rows, only one alternate key matching a differently paired row, or any canonical/relationship mismatch is a conflict. UUIDs, timestamps, and the literal case/whitespace of normalized-equivalent identity fields are ignored and preserved. Thus convergence is semantic, not byte-for-byte rewriting.

### Atomicity, preservation, and concurrency boundary

All 44 reconciliation steps run in one database transaction. A late conflict rolls back earlier inserts; matching and unrelated records are never updated, reassigned, or deleted. Existing named unique and foreign-key constraints remain the race-safe authority.

The supported contract permits one active seed invocation. Simultaneous invocations are explicitly outside scope: a racing invocation may fail with a sanitized persistence/concurrent-write error, but constraints must prevent duplicates and its entire transaction must roll back; retry after the other run completes must converge. This resolves the critic's boundary without adding PostgreSQL advisory locks, isolation changes, waiting, or retry policy.

### Performance and checkpoint evidence

The SC-006 reference setup is the repository-pinned Elixir/Erlang toolchain with local PostgreSQL already running, dependencies fetched/compiled, and a dedicated empty development database already created and migrated. Measurement begins when `mix catalog.seed` launches and ends at process exit; service startup, dependency installation/compilation, database creation, and migration are excluded. The command must finish in at most 10.0 seconds, after which catalog lookups must prove exact target counts and league/team/position coverage. Redis, HTTP, and external-provider availability are irrelevant.

## Rejected Alternatives

- **Reject or rewrite normalized-equivalent identities**: rejection contradicts approved reuse; rewriting violates preservation and FR-011/FR-013.
- **Upsert/on-conflict reconciliation**: cannot reliably diagnose split alternate identities or relationship mismatches and risks silently overwriting local data.
- **`priv/repo/seeds.exs` as the contract**: conventional but weaker for typed result/exit tests and easily conflated with setup aliases; the dedicated Mix task is equally explicit and more testable.
- **Automatic setup/startup/deployment loading**: violates FR-017 and the approved production guard.
- **HTTP endpoint, worker, provider adapter, Redis, or generalized bulk import**: expands scope and crosses established boundaries without a requirement.
- **Advisory lock, serializable isolation, or automatic race retry**: concurrent success is not required; existing constraints plus transaction rollback provide integrity with less PostgreSQL-specific policy.
- **Seed-ownership columns/tables or a migration**: manifest membership defines ownership and the existing business keys already support reconciliation.
- **Local timing without a reference boundary**: cannot honestly prove SC-006; the quickstart fixes database/toolchain state and the measured interval.

## Project Structure

### Documentation (this feature)

```text
specs/006-development-seed-data/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── development-seed.md
└── handoffs/
    └── architecture.md

docs/adr/
└── 0005-development-seed-safety-and-semantic-convergence.md
```

### Source Code (repository root)

```text
config/
├── config.exs
├── dev.exs
└── test.exs

lib/football_market/catalog/
├── development_seed.ex
└── development_seed/
    └── manifest.ex

lib/mix/tasks/
└── catalog.seed.ex

test/football_market/catalog/
└── development_seed_test.exs

test/mix/tasks/
└── catalog.seed_test.exs

README.md
```

**Structure Decision**: Keep the manifest and reconciliation logic below the existing Catalog domain boundary, with Repo access limited to that service and a thin Mix adapter for explicit operator use. Extend configuration only with the deny-by-default seed capability. No web, worker, provider, cache, or migration directory changes are planned.

## Complexity Tracking

No constitution violations require justification.
