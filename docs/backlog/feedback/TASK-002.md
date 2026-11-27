# Feedback — TASK-002

## Feedback 1

- Time: 2026-09-13T21:29:10+00:00
- Author: ezequielgonzalez
- Restart from: develop

Fix redis_disposability_test.sh so its assertion matches the documented Redis authority boundary, and replace the static occupied-port check with real runtime bind-conflict coverage for both PostgreSQL 5432 and Redis 6379. Rerun all TASK-002 scripts, mix test, and the real HTTP oracle.

## Feedback 2

- Time: 2026-09-13T21:39:17+00:00
- Author: ezequielgonzalez
- Restart from: develop

Handle malformed POSTGRES_PORT and REDIS_PORT without crashing during config evaluation. mix infrastructure.verify must exit nonzero, categorize the affected dependency as invalid configuration, still probe and report the other dependency, and never expose credentials. Add black-box integration coverage for both malformed-port cases, then rerun the full Docker-backed suite and real HTTP oracle.

## Feedback 3

- Time: 2026-09-14T00:43:11+00:00
- Author: ezequielgonzalez
- Restart from: develop

Make the documented three-cycle restart workflow reliable after adjacent lifecycle/integration runs. Prevent overlapping or stale cleanup/restart activity from leaving the scoped PostgreSQL and Redis containers stopped, and ensure readiness guarantees a subsequent database setup/verification can connect. Add regression coverage for consecutive lifecycle plus three-cycle runs. QA also requires a human-authorized scoped reset/recreate trial before PASS.

Human authorization (2026-09-13): the user explicitly permits the destructive reset/recreate acceptance trial, limited strictly to Docker volumes `football_market_local_postgres_data` and `football_market_local_redis_data`. Delete no other volumes or data. Prove the prior sentinel disappears and the fresh migration probe is restored.

Authorized reset evidence (2026-09-13): the primary workflow operator ran `./scripts/local_services.sh reset --confirm`. Docker removed exactly `football_market_local_postgres_data` and `football_market_local_redis_data` together with the repository-scoped containers/network. After `start`, `ready`, and `mix infrastructure.database.setup`, the migration recreated `infrastructure_probe`; its marker was `ready`, and the count for the prior `qa-reset-sentinel` was `0`.

Final-review remediation (2026-09-13): lifecycle locking now records the owner PID, removes a lock whose owner is dead, and preserves bounded waiting for a live owner. `consecutive_lifecycle_acceptance_test.sh` now simulates a dead owner and actually overlaps `stop` with `start`, then proves readiness, database setup, application-owned verification, and all three restart cycles. The targeted suite passed together with formatting, warnings-as-errors compilation, 14 ExUnit tests, and `git diff --check`.
