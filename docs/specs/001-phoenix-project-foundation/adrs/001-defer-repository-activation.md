# ADR-001: Defer Repository Activation to TASK-002

**Status**: Accepted for TASK-001; superseded when TASK-002 activates persistence  
**Date**: 2026-09-08

## Context

The architecture baseline requires Ecto/PostgreSQL, while TASK-001 requires clean local startup and explicitly defers PostgreSQL/Redis environment provisioning to TASK-002. A normally supervised Ecto repository may retry a missing database or make runtime health ambiguous even when a static route responds.

## Decision

TASK-001 retains the `FootballMarket.Repo` module, Ecto SQL/Postgrex dependencies, and conventional configuration, but does not include Repo in the application supervision tree. The default page and tests must not call the Repo. TASK-002 owns adding Repo supervision, validated database configuration, creation/migration commands, and local PostgreSQL/Redis prerequisites.

## Consequences

- TASK-001 starts and serves its smoke contract with PostgreSQL and Redis unavailable.
- The project identity and persistence namespace are stable for TASK-002.
- No TASK-001 check may be interpreted as validating database connectivity.
- TASK-002 must explicitly supersede this ADR when it activates Repo and update startup documentation accordingly.

## Alternatives rejected

- Requiring PostgreSQL now expands TASK-001 into TASK-002.
- Generating without Ecto causes immediate structural churn and weakens alignment with the mandated baseline.
- Supervising Repo while accepting connection failures makes a reachable page an unreliable health signal.
