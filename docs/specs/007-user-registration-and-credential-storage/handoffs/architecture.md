# Architecture Handoff: TASK-007

## Decisions

- Implement a new internal `FootballMarket.Accounts` context; do not attach registration rules to web or catalog modules.
- Use a `users` row plus one-to-one `password_credentials` row, inserted in one `Ecto.Multi` transaction. Return a public user projection only.
- Normalize email as trim + lowercase. Name the PostgreSQL functional unique index on `lower(btrim(email))` and map its conflict to an `:email` changeset error.
- Use Argon2id through `argon2_elixir` 4.1.3. Production/test parameters and the non-disclosure boundary are fixed in ADR-0003.
- `verify_password/2` is an internal boolean-only capability for the future authentication feature. No controller, route, LiveView, OpenAPI operation, login, token, or API-key feature belongs here.

## Risks

- Argon2 requires a native build dependency and intentionally consumes memory. Validate locked dependency compilation and keep weak settings confined to `test`.
- A pre-insert duplicate check is only helpful feedback; the named database index must remain the final authority, including under concurrency.
- Passwords can leak through debugging if placed in changesets/log metadata. Keep them transient and test public result/error/serialization shapes.

## Implementation guidance

- Follow the existing Ecto UUID/timestamp/schema conventions and SQL Sandbox patterns.
- Validate every input before hashing; do not trim a password. Preserve the original user/credential records after duplicate or failed writes.
- Add focused unit and database integration tests before the full suite, including a forced transactional failure and a database-conflict/race path.
