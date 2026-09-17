# Tasks Handoff

## Resolutions

- Reconciled SC-007 with the implementation boundary: TASK-005 must prove index-capable plans at 100,000-player representative cardinality; reproducible percentile latency certification remains TASK-043.
- Treated the accepted ADR, plan, and research as authoritative for the human decision: same-season transfer updates current affiliation; cross-season reassignment is rejected. The `human_check_required: true` header in `product-decision.md` is stale metadata, not an open product decision.
- Made FR-013 conditional rather than inventing a bulk API. Single writes remain atomic Repo operations; any concrete multi-write command discovered during implementation must use `Ecto.Multi` and add a rollback test.
- Kept CP1 coverage precise: this task supplies the minimum persisted model and unit/integration evidence, while HTTP catalog delivery remains TASK-011.

## Remaining risks

- Expression-index and composite-foreign-key migrations are order-sensitive; use explicit stable constraint names and verify raw database rejection as well as changeset translation.
- SQL Sandbox concurrency tests require separate checked-out connections and may expose test-isolation mistakes.
- PostgreSQL may prefer sequential scans for small fixtures. The tagged evidence test needs representative cardinality and should prove index capability without forcing a planner setting that hides a bad design.

## Sequencing guidance

Finish shared test support and migration constraints first. Implement the hierarchy (US1), then player integrity and current-affiliation updates (US2), then read composition (US3). Keep each phase red-before-green and run its focused suite before advancing. Finish with the tagged plan evidence, requirements traceability, full regression commands, and forbidden-scope audit.
