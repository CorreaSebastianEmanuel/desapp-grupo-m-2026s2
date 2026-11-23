# Independent evaluation — TASK-042

Reviewed the compact spec, backlog outcome, REVIEW.md, repository baseline and constitution, complete candidate diff, implementation, test support, and ThinFlow candidate receipt. No TASK-042 feedback file exists. This evaluator did not implement the candidate, change implementation, inspect workflow logs, or delegate evaluation.

## Acceptance / evidence

| Acceptance | Assessment and evidence |
| --- | --- |
| Quote identity changes after outer commit; rollback preserves ranking | PASS. `ranking.ex:46–69` reads configuration and eligible quote count in one read-only repeatable-read snapshot. The test at `ranking_cache_test.exs:145` holds a real outer writer transaction open and verifies old ranking before commit, unchanged identity after rollback, and fresh quote after commit. |
| Activation, reactivation, failed and rolled-back selection | PASS. Committed selection order participates in the key; activation uses the existing serialized selection history. Test at line 175 verifies rollback, commit, reactivation with a new key, and already-active rejection. |
| Configuration scope; unchanged order, eligibility and shape | PASS. Test at line 214 confirms inactive configuration publication preserves the active cache. Diff inspection confirms eligibility predicates, latest-per-player ordering, price/player ordering, row fields and positions are preserved. Revision counting reuses the same eligibility query. |
| Late fills and 30-second expiry without renewal | PASS. Test at line 239 blocks an old fill, publishes and caches a newer quote, then releases the old fill and verifies newer reads stay fresh. Controlled clock assertions cover a hit at 29 seconds and a refill at 30. Production Redis adapter still uses `SET ... EX 30`; hits perform only GET. |
| Redis failures, publication/activation independence and recovery | PASS. Test at line 273 exercises unavailable reads/writes, raised exceptions and exits, committed publication and activation during outage, and recovery without old ranking reuse. Cache rescue/catch paths return a miss or absorb write failure. Writers contain no Redis dependency. |
| PostgreSQL financial authority and focused regressions | PASS. Test at line 304 proves a deliberately corrupted, accepted cache price does not affect purchase quote or price. `market/trading.ex:188` still obtains the quote through `Quotes.latest/1`; financial implementation is unchanged. All six new cases are registered in the integration inventory. |

## Risk, architecture and deterministic evidence

The selected **high** tier is correct for the application, test-support and maintained-inventory changes. All seven candidate paths are mapped; no policy or check definitions were weakened. Scope remains ranking/cache reads and their regression support. PostgreSQL supplies authoritative identity and financial prices; Redis remains a disposable adapter. No web authorization, provider, settlement or persistence-write boundary changed.

Validated the receipt with `thinflow.readiness(..., require_evaluation=False)`: task, branch, current selection, policy digest, material digest `99da2abe3dabe88fb80d928c348830c16ae38a63ca95ce33383d06f2e90fb0fe`, complete check membership, successful exits, confined evidence paths and evidence hashes match. Read the named deterministic check evidence: CI contracts passed 36 tests; harness checks passed 388 tests; format and warnings-as-errors compilation exited zero with legitimately empty output; unit profile reports 451 expected/discovered/executed/passed cases and complete status. Harness negative-fixture diagnostics occur within a successful unittest run, not failed candidate checks. Revalidated receipt freshness after the targeted run.

The required local selection executes the unit profile, while the changed behavioral suite is tagged integration. To close that concrete coverage gap, ran a focused ExUnit invocation with `MIX_OS_CONCURRENCY_LOCK=0 MIX_ENV=test mix test test/football_market/ranking_cache_test.exs test/football_market/ranking_test.exs`: **11 passed**, exit 0, seed 527379. The second supplied path does not exist and contributed no tests; the result covers the existing cache suite only. Its DataCase uses committed PostgreSQL transactions rather than shared sandbox visibility. Also ran `git diff --check`, exit 0. No full suite was rerun.

## Blocking findings

None. The candidate is ready for hosted CI and human merge.

## Advisory findings

None requiring changes in this task.

## Residual risks

- Every hit now retains a PostgreSQL snapshot during Redis GET and counts configuration-scoped eligible quote history. This documented tradeoff is unbenchmarked here; workload/SLA validation remains outside scope.
- Failure and TTL tests use a deterministic Redis substitute; this QA pass did not exercise a real Redis outage or wall-clock expiry. The production adapter's existing expiry command is unchanged.
- Revision correctness relies on existing append-only selection, quote, calculation and issuance constraints, verified in migrations. Administrative database restoration/reset is outside the supported mutation path.
- Full integration, hosted quality/security checks and exact-head `ThinFlow required` remain CI responsibilities. Human merge is still required; this evaluation does not claim task completion.

Verdict: PASS
