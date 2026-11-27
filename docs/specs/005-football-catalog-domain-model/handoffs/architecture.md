# Architecture Handoff

## Decisions not repeated in the plan

- The approved human decision is authoritative: an in-season transfer updates the existing player's current team. ADR-0002 binds future ingestion/statistics work to retain event-level team context rather than infer historical affiliation from the mutable catalog snapshot.
- Keep database constraint names stable and explicit; the context must translate them into field/relationship errors rather than expose raw PostgreSQL exceptions.
- Treat PostgreSQL `lower(btrim(...))` under the configured database collation as the sole identity-comparison oracle. Do not add a competing Elixir normalization algorithm.

## Risks

- Player identity uniqueness depends on the composite team/season foreign key. Migration order and tests must prove PostgreSQL rejects a mismatched `(team_id, season_id)`, while the context never accepts `season_id` independently from callers.
- PostgreSQL expression indexes may not be chosen for tiny fixtures. Query-plan tests need representative cardinality and must distinguish an index-capable design from a forced planner choice.
- Stable UUID ordering is deterministic but not semantic ranking. Later catalog APIs must choose their own user-facing sort without changing this persistence contract.

## Implementation guidance

- Build the migration parent-first and use restrictive foreign keys; map delete constraints with `no_assoc_constraint` or equivalent context errors.
- Centralize the five league pairs in the domain context and test every mismatched pair, not only unsupported codes.
- Prefer direct context integration tests over web tests because this task exposes no route. Use SQL Sandbox concurrency tests with separate checked-out connections where required.
- Do not generalize `Ecto.Multi` into a bulk importer. Add a transaction only for a concrete command that actually spans writes.
