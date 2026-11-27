# Data Model: Phoenix Project Foundation

## Decision

TASK-001 introduces no domain entities, database tables, migrations, persisted records, or state transitions.

`FootballMarket.Repo` may exist as inert framework plumbing so TASK-002 can activate PostgreSQL without renaming or regenerating the application. It is not supervised, queried, or required by the default route or baseline tests in this feature.

## Validation implications

- The migration directory is empty except for conventional placeholders, if generated.
- Tests require neither a database sandbox nor fixture data.
- Review must find no player, user, API key, quote, token, transaction, portfolio, provider, job, cache, or audit model.
- Any persistent entity or database-backed acceptance path is a scope violation for TASK-001.
