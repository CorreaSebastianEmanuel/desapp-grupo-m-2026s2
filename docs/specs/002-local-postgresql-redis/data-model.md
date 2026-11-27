# Data Model: Local PostgreSQL and Redis Environment

## Infrastructure Probe

An infrastructure-only PostgreSQL relation proving migration creation, persistence, isolation, and repeatability. It is not a product entity and no domain context may depend on it.

| Field | Type | Rule |
|---|---|---|
| `id` | small integer | Primary key; singleton value 1 |
| `marker` | string | Required fixed non-secret marker |
| `inserted_at` | UTC timestamp | Required, migration-controlled |
| `updated_at` | UTC timestamp | Required, migration-controlled |

The migrated database has exactly the migration-created singleton. Reapplying current migrations creates neither duplicate relation nor row. Explicit reset removes the volume; preparation recreates both. Acceptance-only sentinels must be non-domain and self-cleaning.

## Configuration identities

| Environment | PostgreSQL rule | Redis role |
|---|---|---|
| Development | Default `football_market_dev`, overridable | Connectivity only, replaceable |
| Test | `football_market_test` plus optional Mix partition; never dev | Connectivity/integration only |

```text
database absent -> created -> migrated/current
migrated/current -> migrate again -> migrated/current
stopped -> healthy -> stopped (volumes preserved)
stopped -> explicit reset -> absent -> recreated/migrated
Redis lost/reset -> PostgreSQL unchanged
```

No player, user, token, quote, transaction, ranking, audit, or cache model is introduced.

