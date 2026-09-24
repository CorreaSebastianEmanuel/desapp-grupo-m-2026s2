# Contract: Development Catalog Seed

This is an explicit local command and internal service contract. It is not an HTTP API, startup hook, deployment step, or provider integration.

## Command

```sh
mix catalog.seed
```

- Supported only when the checked-in seed capability is enabled (`dev` and isolated `test`); every other/unknown environment is denied before application/Repo startup or transaction work.
- Must not be invoked by `mix setup`, Ecto setup aliases, application/release startup, migrations, CI deployment, or production operations.
- Requires migrated PostgreSQL. It requires neither Redis, HTTP, external providers, nor network access.
- Exits `0` only after the complete transaction commits.
- Success output identifies fixed target totals and created/reused totals. A no-op second run reports 44 reused and 0 created.
- All forbidden, conflict, validation, relationship, concurrency, or persistence outcomes exit nonzero through `Mix.Error`.

## Service

`FootballMarket.Catalog.DevelopmentSeed.run/0` returns:

```text
{:ok, %{created: non_neg_integer, reused: non_neg_integer, totals: map}}
{:error, %{category: atom, entity: atom, identity: string, optional(:cause) => atom}}
```

The exact internal struct is reversible, but these semantics are stable:

- environment denial happens before database access;
- all lookups and inserts are inside one transaction;
- success means the full manifest is present;
- error means that invocation committed no change;
- no success path updates, reassigns, or deletes a record.

## Identity and conflict behavior

Text identity uses TASK-005's normalized database lookups. Normalized-equivalent matches retain their existing UUID, literal stored spelling, timestamps, attributes, and relationships. Dual code/name identities must resolve to one row. Player display name is exact; all required relationship IDs must match the resolved manifest ancestors. A conflict includes entity type and the manifest identity but does not reveal the existing row's arbitrary contents.

## Safe signaling

The public categories are `disabled`, `validation`, `conflict`, and `persistence`. The allowed category/cause pairs are:

- `disabled` for the seed capability, without a cause;
- `validation/invalid_manifest`;
- `conflict/alternate_identity`, `conflict/misplaced_relationship`, `conflict/attribute_mismatch`, and `conflict/relationship_mismatch`;
- `persistence/database`, `persistence/write_failed`, `persistence/concurrent_write`, and `persistence/database_unavailable`.

Entities and identities are restricted to the fixed manifest and the `development-seed` boundary identity. Any unknown or malformed internal failure is exposed only as `category=persistence entity=seed identity=development-seed cause=write_failed`. Raw exceptions, stack traces, database URLs/configuration, credentials, UUIDs, timestamps, provider payloads, arbitrary stored values, and fixed changeset details are excluded from command output.

## Concurrency

Only one active invocation is supported. Database uniqueness/foreign-key constraints must prevent duplicates if commands or unrelated writers race, and any losing seed transaction must roll back fully. Concurrent invocations are not guaranteed to both succeed. Retrying after the competing transaction completes is supported and must converge.
