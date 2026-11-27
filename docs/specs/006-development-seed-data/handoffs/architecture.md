# Architecture Handoff

## Implementation guidance

- TASK-005 trims on insertion but its lookups and indexes are the normalization authority. Perform all alternate-key lookups before choosing create/reuse; do not send a normalized-equivalent existing value back through a changeset, because reuse must preserve literal stored spelling and timestamps.
- The misplaced-team case needs a deliberate secondary lookup outside the intended season after the scoped lookup misses. Use it only to produce the required relationship conflict; do not broaden general team identity scope.
- Name `Ecto.Multi` steps with manifest entity/identity so late errors retain useful context, then discard the `changes_so_far` payload when mapping public errors. Never render `inspect/1` on raw exceptions or records.
- Keep the deny-by-default capability independent of operator-controlled environment variables. Task-level denial should occur before application startup; service-level denial protects direct calls.
- A concurrency test needs separate unsandboxed connections. It proves uniqueness and rollback, not that both commands succeed; avoid adding lock/retry behavior while satisfying it.

## Risks

- League creation validates exact supported pairs, so normalized variants are reusable only when found before insertion; attempting to recreate them will return a misleading changeset conflict.
- Dual identities can split across two rows only in corrupted/legacy state, but the reconciler must still report a conflict rather than select one.
- Timing evidence is valid only with the quickstart boundary. Do not turn the 10-second target into a hardware-sensitive unit-test assertion.
- Manifest values are durable contract data. Any later change is seed-version evolution and requires a new specification rather than an in-place edit.
