# Implementation Plan: Local PostgreSQL and Redis Environment

**Branch**: `002-local-postgresql-redis` | **Date**: 2026-09-13 | **Spec**: [spec.md](spec.md)

## Summary

Add a repository-scoped Docker Compose environment for PostgreSQL and Redis, pinned to immutable official-image digests and published only on IPv4 loopback. Extend Phoenix with environment-overridable PostgreSQL/Redis configuration, a minimal infrastructure-only Ecto migration, and one Mix verification task that checks both dependencies independently through application-owned clients and fails unless both succeed. Document and automate bounded lifecycle, isolation, failure, persistence, and reset checks without domain schema, cache behavior, public health routes, or production infrastructure.

## Technical Context

**Language/Version**: Elixir 1.20.3, Erlang/OTP 29.0.3; POSIX shell for acceptance tooling  
**Primary Dependencies**: Phoenix 1.8.13, Ecto SQL 3.13, Postgrex, Redix, Docker Compose v2  
**Storage**: PostgreSQL is authoritative; Redis is disposable read-optimization infrastructure only  
**Testing**: ExUnit, Ecto SQL Sandbox, Mix tasks, shell acceptance tests, real service connections  
**Target Platform**: Acceptance baseline is macOS or Linux, x86_64/arm64, Docker Engine 27+ or current Docker Desktop with Compose v2. Windows/Git Bash remains documented but is outside TASK-002 acceptance evidence.  
**Project Type**: Modular Phoenix web application with repository-native developer tooling  
**Performance Goals**: Manual clean-checkout preparation within 10 minutes; readiness/connectivity bounded to 30 seconds; stop within 10 seconds  
**Constraints**: Loopback-only ports; immutable images; deterministic project/volumes; sanitized diagnostics; fail-closed test DB identity; routine lifecycle preserves state; reset is separate and destructive  
**Scale/Scope**: Two services, dev and partitionable test DBs, one infrastructure probe relation, one aggregate verification command

## Constitution Check

*GATE: Passed before research and re-checked after design.*

- **Specification before implementation — PASS**: Decisions trace to FR-001–FR-016 and the product challenge; recorded feedback says no further human check is required.
- **Domain integrity — PASS**: PostgreSQL remains authoritative; Redis has no authoritative state or business behavior; the migration is non-domain.
- **Modular simplicity — PASS**: One Phoenix application and one local Compose project; no service split or production topology.
- **Evidence-based quality — PASS**: Config/unit tests, real integration checks, migration reruns, failure injection, resolved-Compose inspection, and the manual trial protocol are executable.
- **Independent verification — PASS**: Product challenge and authoritative decision are incorporated; QA/review remain independent.
- **Safety/delivery — PASS**: No secrets or destructive routine command. Reset is explicit and repository-scoped.
- **Architecture/checkpoint — PASS**: This follows the Ecto/PostgreSQL/Redis baseline and supplies only CP1 persistence foundations.

Post-design re-check: **PASS**. Contracts retain independent results and nonzero aggregate failure; the model has no product entity. There is no architecture deviation requiring an ADR. Any implementation departure from these boundaries requires a reviewed ADR.

## Challenge Resolution and Rejected Alternatives

| Finding | Smallest compliant solution | Rejected alternative |
|---|---|---|
| Reproducibility | Exact clean baseline, commands, exit/output expectations, 30-second bounds, three persistence cycles, four failure trials, retained evidence; manual ten-minute trial | CI wall-clock gate is unreliable across image pulls/runners |
| Exposure | Bind ports to `127.0.0.1`, inspect resolved Compose config, label local credentials unsafe elsewhere | All-interface/host networking exposes weak local services |
| Isolation | Require `football_market_test` plus optional partition, forbid equality with dev, and prove a dev sentinel survives | Separate defaults alone fail open; domain seed data is out of scope |
| Connectivity | `mix infrastructure.verify` uses app config, Repo, and app-owned Redis client; always reports both and fails if either fails | Container-only checks bypass the app; HTTP health belongs to TASK-038 |
| Migration | Infrastructure-only singleton probe relation | No-op migration is weak evidence; product tables violate FR-016 |
| Reset/readiness | Fixed project/volumes, finite health checks, separate volume-naming reset | Implicit volume deletion and unbounded polling are unsafe |

## Implementation Design

### Orchestration

- Add `compose.yaml` with exactly PostgreSQL and Redis, official images pinned by readable tag plus immutable digest, health checks, repository-scoped named volumes, and `127.0.0.1` publishing. No host networking/admin UI.
- Add tracked local-default documentation/config that works without tracked edits and permits environment overrides. Defaults are explicitly unsuitable for shared/production use.
- Provide stable repository commands for start, stop, restart, inspect, bounded readiness, and separately named reset. Readiness reports each service and ends within 30 seconds. Reset names and removes only this project's volumes.

### Application boundaries

- Keep `FootballMarket.Repo` as PostgreSQL boundary and add it to supervision. Read environment overrides in dev/test; disable sensitive connection display.
- Add Redix and a narrow `FootballMarket.Infrastructure.Redis` connector/config boundary. No cache/domain operations.
- Centralize safe target formatting (host, port, database only) and configuration validation; never render URLs/passwords.
- Share a fail-closed guard among test boot, preparation, migration, and verification. Test DB must be exactly the fixed prefix plus optional Mix partition, and differ from dev.

### Migration and verification

- Initial ordered migration creates `infrastructure_probe` with singleton key, fixed non-secret marker, and timestamps, inserts the singleton, and removes it on rollback. No domain context reads it.
- Standard Ecto create/migrate aliases remain repeatable and expose migration identity on failure.
- The verification task must declare no automatic application start, load the compiled application configuration without starting the supervision tree, then independently start/probe temporary Repo and Redis clients. It collects both results, prints sanitized per-service and aggregate outcomes, cleans up, and exits nonzero on either failure. This is the sole verification path; normal application startup still supervises `FootballMarket.Repo` and may fail fast when PostgreSQL is unavailable.
- The test-database identity guard must execute while test configuration is evaluated and again in every repository preparation/migration/verification entry point, before Repo startup or any create/drop/migrate query. All entry points share the same pure validation rules and sanitized category-only errors.
- Add unit tests for parsing, sanitization, aggregation, and isolation guard; real integration tests for success/independent failure; migration assertions and rerun; shell checks for resolved config, health bounds, persistence, isolation, occupied ports, and reset.

## Acceptance Evidence Protocol

1. Begin with a clean checkout, no Compose project/volumes, pinned TASK-001 toolchain, Docker running, images available/pullable, and ports 5432/6379/4000 free. Record OS/architecture, Docker/Compose versions, commit, and start time.
2. Run documented configure, start, inspect, readiness, prepare/migrate, application verification, application start, and foundation HTTP oracle in order. All exit 0 and both services are named. Stop timer after connectivity and HTTP pass; require at most ten minutes. This is a manual acceptance measure.
3. Insert a non-domain dev sentinel; run three full stop/start/readiness/prepare/migrate/verify cycles. All exit 0, later migrations are current, sentinel survives.
4. Prepare/run tests and confirm dev sentinel survives. Override test DB to dev, then a non-test name; both fail before mutation and expose no credential.
5. Run four trials: PostgreSQL unavailable, Redis unavailable, invalid PostgreSQL auth/config, invalid Redis auth/config. Each verification reports both statuses, names the affected dependency, hides secrets, and exits nonzero.
6. Inspect resolved Compose config for loopback ports, digests, scoping, volumes, and finite health bounds. Exercise occupied-port failure.
7. Invoke separate reset, confirm scoped volumes disappear, then restart/prepare; old sentinel is absent and migration probe returns. Retain transcripts/test output as uncommitted QA evidence.

## Project Structure

```text
compose.yaml
.env.example
config/{config,dev,runtime,test}.exs
lib/football_market/infrastructure/{configuration,redis}.ex
lib/mix/tasks/infrastructure.verify.ex
priv/repo/migrations/*_create_infrastructure_probe.exs
scripts/local_services.sh
test/football_market/infrastructure/
test/integration/
test/scripts/
specs/002-local-postgresql-redis/{plan,research,data-model,quickstart}.md
specs/002-local-postgresql-redis/contracts/local-environment.md
specs/002-local-postgresql-redis/handoffs/architecture.md
```

**Structure Decision**: Extend the existing single Phoenix application. Infrastructure clients/config stay below Mix tooling; shell tooling owns Compose lifecycle. No web, domain, worker, or public API surface is added.

## Complexity Tracking

No constitution violations or justified complexity exceptions.
