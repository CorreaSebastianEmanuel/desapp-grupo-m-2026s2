# Active-strategy ranking performance validation

## Outcome

Produce repeatable evidence showing the cost of the active-strategy ranking read before and after the TASK-041 Redis cache, and use that evidence to decide whether a ranking-specific SQL or index change is warranted. Keep the result limited to ranking; this task sets no application-wide SLA.

## Acceptance

- [x] A reproducible local benchmark compares the pre-TASK-041 read behavior with the current post-TASK-041 implementation using the same seeded PostgreSQL dataset and request workload. The harness identifies that the baseline path reproduces the historical uncached ranking read.
- [x] The workload seeds 100 issued players and 400 successful performance quotes (4 per player), then performs 1,000 ranking reads from 10 concurrent clients. The post-change run records both the initial cold read and warmed repeated reads.
- [x] The report records revision, PostgreSQL version, dataset size, monotonic concurrent-workload elapsed time, cumulative request latency, p50/p95 read latency, ranking-related PostgreSQL statement counts, and the complete `EXPLAIN (ANALYZE, BUFFERS)` plans for the ranking and revision-count queries. A focused regression test proves elapsed workload time is distinct from summed request latency. Results are observational and are not asserted as fixed latency thresholds.
- [x] The report states whether the repeated-read optimization is demonstrated and whether query-plan evidence supports a ranking-specific SQL or index change; any proposed change must be tied to captured `EXPLAIN (ANALYZE, BUFFERS)` evidence.
- [x] The benchmark can be rerun from documented commands without modifying application data outside its isolated test database.

## Scope

- Add a focused ranking benchmark harness and results report with its environment, full query plans, and reproduction steps.
- Make a ranking-specific query or index change only if the measured plan demonstrates a clear opportunity; add focused coverage for any such behavior-affecting change.

## Non-goals

- Application-wide SLA targets, unrelated database tuning, changes to ranking behavior, and tuning based on unrepresentative production claims.

## Risk

- High. The task adds benchmark tooling and retained performance evidence; the benchmark resets an isolated test database, and any query or index change must be ranking-specific and evidence-backed.

## Decisions

- Use 100 players with 4 successful eligible performance quotes each, 1,000 reads, and 10 concurrent clients so before/after runs are comparable without production data.
- Reproduce the uncached pre-TASK-041 read in the benchmark harness and compare it with the current cached implementation on the same checked-out revision, database, and seeded data. Report observations rather than imposing an unstated latency target.
