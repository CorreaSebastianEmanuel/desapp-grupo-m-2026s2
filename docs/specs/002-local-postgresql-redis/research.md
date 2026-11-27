# Research: Local PostgreSQL and Redis Environment

## Decisions

### Orchestration
- **Decision**: One Docker Compose v2 file with official images pinned by digest, scoped volumes, health checks, and loopback ports.
- **Rationale**: Smallest cross-platform declarative lifecycle with inspectable configuration and persistence.
- **Alternatives considered**: Host packages are machine-specific; Testcontainers does not provide long-lived dev services; Kubernetes is disproportionate.

### Redis client
- **Decision**: Add Redix behind a narrow application-owned infrastructure module, with no cache operations.
- **Rationale**: Proves application configuration using an established client while preserving later cache design.
- **Alternatives considered**: `redis-cli` bypasses the app; hand-written RESP is needless protocol ownership; cache abstraction is TASK-041.

### Isolation
- **Decision**: Reject test startup/mutation unless the resolved DB is `football_market_test` plus optional partition and differs from dev.
- **Rationale**: Environment overrides make separate defaults fail-open.
- **Alternatives considered**: Separate PostgreSQL instances add needless weight; domain fixtures are out of scope.

### Migration evidence
- **Decision**: Create a tiny infrastructure-only singleton probe relation.
- **Rationale**: Proves DDL, persistence, rollback shape, and repeatable migration without anticipating domain entities.
- **Alternatives considered**: No-op/schema_migrations-only evidence is weak; product tables violate FR-016.

### Verification
- **Decision**: One Mix command independently probes both dependencies via application config/clients, sanitizes output, and succeeds only when both do.
- **Rationale**: A first failure cannot hide the other status.
- **Alternatives considered**: Boot-only checks short-circuit; container health bypasses app wiring; HTTP health is TASK-038.

### Timing
- **Decision**: Automate functional evidence but keep the ten-minute clean-checkout result as a precisely bounded manual trial.
- **Rationale**: Image pulls and runner variance make a CI timing gate flaky.
- **Alternatives considered**: An author-machine observation without protocol is not falsifiable.

### ADR status
- **Decision**: No ADR for TASK-002.
- **Rationale**: The design implements, rather than deviates from, the architecture baseline. Any later deviation requires an ADR.
- **Alternatives considered**: ADRs for routine compliant choices dilute deviation records.

