# ADR-0004: Keep Development Seeds Production-Prohibited and Semantically Convergent

**Status**: Accepted

**Date**: 2026-09-23

**Scope**: TASK-006 development seed data

## Context

TASK-006 requires repeatable seeding, normalized identity reuse, unchanged matching records, and the same observable target from empty, complete, or partial catalogs. A normalized-equivalent stored identity can differ literally from the manifest, so byte-identical convergence would require either rejecting a valid match or rewriting developer data. The specification also prohibited automatic production loading without deciding whether manual production invocation was acceptable. The product challenge raised both as material data-integrity decisions, and the required human check approved the recommended behavior.

## Decision

Seed convergence is semantic. Business identity follows TASK-005's normalized PostgreSQL comparison; normalized-equivalent existing identity strings and their UUIDs/timestamps are reused without rewriting. Non-identity canonical attributes and required relationships must match exactly or the whole run fails.

The supported seed action is production-prohibited. A deny-by-default application capability is enabled only in checked-in development/test configuration, with no environment-variable override. The command and seed service reject disabled or unknown environments before database access. Seeding is explicit and is never attached to startup, setup, migrations, releases, or deployment.

## Consequences

- A successful partial or repeated run converges to the same business dataset while preserving harmless literal case/whitespace variants.
- Demonstration data cannot be deliberately or accidentally loaded through the supported action in production.
- Tests and tooling must compare normalized identities plus exact canonical attributes/relationships, not raw manifest equality.
- Changing the stable manifest later is seed-version evolution and needs separately specified migration/reconciliation behavior.

## Rejected alternatives

- **Reject normalized variants**: contradicts the approved normalized-reuse outcome.
- **Rewrite variants to manifest spelling**: changes matching developer data and violates identity preservation.
- **Allow deliberate production invocation**: permits coherent fictional data to contaminate an authoritative catalog.
- **Rely only on documentation or task wiring**: does not fail closed when the service is called directly.
