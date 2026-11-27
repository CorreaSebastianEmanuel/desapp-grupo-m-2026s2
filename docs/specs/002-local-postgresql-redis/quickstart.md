# Quickstart Validation

Exact commands must remain aligned with the implemented lifecycle script and README.

## Prerequisites

macOS/Linux x86_64 or arm64, TASK-001 toolchain, Docker Engine 27+ or current Docker Desktop with Compose v2, Git/POSIX shell, and free loopback ports 5432, 6379, 4000.

```bash
./scripts/check_toolchain.sh
docker version
docker compose version
docker compose config
```

Resolved Compose output must satisfy [the contract](contracts/local-environment.md).

## Happy path

```bash
./scripts/local_services.sh start
./scripts/local_services.sh inspect
./scripts/local_services.sh ready
mix ecto.setup
mix ecto.migrate
mix infrastructure.verify
mix test
```

All exit 0; both services are independently reported; the [probe](data-model.md) exists; repeated migration reports current. Start `mix phx.server` and run `./scripts/verify_foundation.sh` to prove TASK-001 compatibility.

## Persistence, isolation, and failures

Create the acceptance script's non-domain dev sentinel, then run stop/start/readiness/prepare/migrate/verify three times; the sentinel must survive. Run tests and confirm it remains. Unsafe test DB overrides (dev identity and non-test name) must fail before mutation.

Test PostgreSQL unavailable, Redis unavailable, invalid PostgreSQL config/auth, and invalid Redis config/auth. For every `mix infrastructure.verify` run, both status lines appear, the affected dependency fails, secrets are absent, and exit is nonzero. Occupied ports must also produce visible startup failure.

## Timing and reset

Run [the full protocol](plan.md#acceptance-evidence-protocol) from absent project/volumes. Time the first configure/start action through successful app connectivity and foundation HTTP oracle; require at most ten minutes.

```bash
./scripts/local_services.sh reset
```

Reset must name destroyed scoped volumes. Restart/prepare: the old sentinel is absent and migration probe is recreated. Do not commit transcripts.
# Implemented Local Infrastructure Commands

The canonical workflow is `cp .env.example .env`, `./scripts/local_services.sh start`, `inspect`, `ready`, `mix infrastructure.database.setup`, `mix infrastructure.database.migrate`, `mix infrastructure.verify`, `stop`, `restart`, and the separately destructive `reset --confirm`. Readiness is bounded to 30 seconds and reports PostgreSQL and Redis independently. `README.md` documents prerequisites, safety constraints, failure categories, and test isolation.

