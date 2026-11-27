# Ranking performance results

## Reproduction

Run `mix test.prepare`, then `MIX_ENV=test mix run scripts/ranking_benchmark.exs`. The harness refuses database names outside `football_market_test*`, resets only that isolated test database before and after the run, and uses a 20-connection pool for concurrent reads. It creates 100 issued players with 400 successful eligible performance quotes (four per player), measures the first post-cache read separately, then runs 1,000 reads from 10 concurrent clients for each path.

The baseline reproduces the uncached `Ranking.read/0` behavior from the parent of commit `823855a` (TASK-041). The compared current path is the TASK-042 revision-check implementation. The captured run used revision `d1655e3` (TASK-043 benchmark candidate present in the worktree), PostgreSQL 17.6, and database `football_market_test`. This report retains the bounded primary output, including the complete plans.

## Environment and measurements

- Seed: 100 issued players, 400 successful performance quotes, 400 eligible quotes.
- Workload per path: 10 clients × 100 reads. Elapsed time is monotonic wall-clock time around the complete concurrent workload; cumulative request latency is the sum of each read's latency.
- Initial post-cache cold read: 29491 µs.
- Uncached baseline: elapsed 1294145 µs; cumulative request latency 12804890 µs; p50 11923 µs; p95 17484 µs; 2000 ranking-related SQL statements, including 1000 ranking aggregation queries.
- Current warm cache: elapsed 1347505 µs; cumulative request latency 13340481 µs; p50 12824 µs; p95 15853 µs; 3000 ranking-related SQL statements and no ranking aggregation queries.

The repeated-read cache behavior is confirmed: it avoids all 1,000 ranking aggregation queries. Current warm workload elapsed time was 4.1% higher than the uncached baseline, p50 was 7.6% higher, and p95 was 9.3% lower. The current path also issues 1,000 extra revision-check statements. This run demonstrates query avoidance, but not a consistent end-to-end latency improvement.

## Plan interpretation

The ranking aggregation query took 1.321 ms and the current revision-count query took 1.078 ms in the captured `EXPLAIN (ANALYZE, BUFFERS)` run. Both reported 1,215 shared buffer hits. The ranking plan visits each of 400 calculation rows by primary-key index after filtering the matching quote rows; PostgreSQL used a bitmap scan of `market_quotes`, sequential scan of the 100-row issuance fixture, and sort/unique for the latest quote per player. At this small synthetic dataset, these plans do not establish a ranking-specific index opportunity. This task makes no SQL or schema change. The measurements do not claim production capacity or set an application-wide SLA.

## Full captured plans

### Ranking query — `EXPLAIN (ANALYZE, BUFFERS)`

```text
Sort  (cost=34.14..34.14 rows=1 width=45) (actual time=1.196..1.201 rows=100 loops=1)
  Sort Key: s0.unit_price DESC, s0.player_id
  Sort Method: quicksort  Memory: 31kB
  Buffers: shared hit=1215
  ->  Subquery Scan on s0  (cost=34.11..34.13 rows=1 width=45) (actual time=1.125..1.172 rows=100 loops=1)
        Buffers: shared hit=1215
        ->  Unique  (cost=34.11..34.12 rows=1 width=53) (actual time=1.124..1.162 rows=100 loops=1)
              Buffers: shared hit=1215
              ->  Sort  (cost=34.11..34.12 rows=1 width=53) (actual time=1.123..1.137 rows=400 loops=1)
                    Sort Key: sm0.player_id, sm0.effective_at DESC, sm0.performance_sequence DESC
                    Sort Method: quicksort  Memory: 53kB
                    Buffers: shared hit=1215
                    ->  Nested Loop  (cost=22.01..34.10 rows=1 width=53) (actual time=0.300..0.974 rows=400 loops=1)
                          Join Filter: (sm1.player_id = sq2.player_id)
                          Buffers: shared hit=1215
                          ->  Hash Join  (cost=21.74..25.78 rows=1 width=101) (actual time=0.280..0.345 rows=400 loops=1)
                                Hash Cond: (sm1.player_id = sm0.player_id)
                                Buffers: shared hit=15
                                ->  Seq Scan on market_issuances sm1  (cost=0.00..3.48 rows=148 width=16) (actual time=0.008..0.014 rows=100 loops=1)
                                      Buffers: shared hit=2
                                ->  Hash  (cost=21.73..21.73 rows=1 width=85) (actual time=0.260..0.260 rows=400 loops=1)
                                      Buckets: 1024  Batches: 1  Memory Usage: 55kB
                                      Buffers: shared hit=13
                                      ->  Bitmap Heap Scan on market_quotes sm0  (cost=4.26..21.73 rows=1 width=85) (actual time=0.036..0.152 rows=400 loops=1)
                                            Recheck Cond: (calculation_id IS NOT NULL)
                                            Filter: ((performance_sequence > 0) AND (unit_price > '0'::numeric) AND (configuration_version_id = '1dc6c109-223d-44e8-aa91-75c1f36657de'::uuid) AND (rule_id = 'balanced'::text) AND (rule_version = '1'::text))
                                            Heap Blocks: exact=9
                                            Buffers: shared hit=13
                                            ->  Bitmap Index Scan on market_quote_calculation_unique  (cost=0.00..4.25 rows=332 width=0) (actual time=0.028..0.028 rows=400 loops=1)
                                                  Buffers: shared hit=4
                          ->  Index Scan using quote_calculations_pkey on quote_calculations sq2  (cost=0.27..8.31 rows=1 width=61) (actual time=0.001..0.001 rows=1 loops=400)
                                Index Cond: (id = sm0.calculation_id)
                                Filter: ((configuration_version_id = '1dc6c109-223d-44e8-aa91-75c1f36657de'::uuid) AND (status = 'successful'::text) AND (sm0.player_id = player_id) AND (mapping_id = sm0.mapping_id) AND (unit_price = sm0.unit_price) AND (effective_at = sm0.effective_at))
                                Buffers: shared hit=1200
Planning:
  Buffers: shared hit=12
Planning Time: 1.032 ms
Execution Time: 1.321 ms
```

### Revision-count query — `EXPLAIN (ANALYZE, BUFFERS)`

```text
Aggregate  (cost=34.10..34.11 rows=1 width=8) (actual time=0.940..0.942 rows=1 loops=1)
  Buffers: shared hit=1215
  ->  Nested Loop  (cost=22.01..34.10 rows=1 width=16) (actual time=0.271..0.918 rows=400 loops=1)
        Join Filter: (m1.player_id = q2.player_id)
        Buffers: shared hit=1215
        ->  Hash Join  (cost=21.74..25.78 rows=1 width=93) (actual time=0.258..0.316 rows=400 loops=1)
              Hash Cond: (m1.player_id = m0.player_id)
              Buffers: shared hit=15
              ->  Seq Scan on market_issuances m1  (cost=0.00..3.48 rows=148 width=16) (actual time=0.008..0.014 rows=100 loops=1)
                    Buffers: shared hit=2
              ->  Hash  (cost=21.73..21.73 rows=1 width=77) (actual time=0.244..0.244 rows=400 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 52kB
                    Buffers: shared hit=13
                    ->  Bitmap Heap Scan on market_quotes m0  (cost=4.26..21.73 rows=1 width=77) (actual time=0.036..0.145 rows=400 loops=1)
                          Recheck Cond: (calculation_id IS NOT NULL)
                          Filter: ((performance_sequence > 0) AND (unit_price > '0'::numeric) AND (configuration_version_id = '1dc6c109-223d-44e8-aa91-75c1f36657de'::uuid) AND (rule_id = 'balanced'::text) AND (rule_version = '1'::text))
                          Heap Blocks: exact=9
                          Buffers: shared hit=13
                          ->  Bitmap Index Scan on market_quote_calculation_unique  (cost=0.00..4.25 rows=332 width=0) (actual time=0.026..0.026 rows=400 loops=1)
                                Buffers: shared hit=4
        ->  Index Scan using quote_calculations_pkey on quote_calculations q2  (cost=0.27..8.31 rows=1 width=61) (actual time=0.001..0.001 rows=1 loops=400)
              Index Cond: (id = m0.calculation_id)
              Filter: ((configuration_version_id = '1dc6c109-223d-44e8-aa91-75c1f36657de'::uuid) AND (status = 'successful'::text) AND (m0.player_id = player_id) AND (mapping_id = m0.mapping_id) AND (unit_price = m0.unit_price) AND (effective_at = m0.effective_at))
              Buffers: shared hit=1200
Planning:
  Buffers: shared hit=15
Planning Time: 0.729 ms
Execution Time: 1.078 ms
```
