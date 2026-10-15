# Independent QA — TASK-019

2026-10-15; feature resolved from `.specify/feature.json`. Reviewed spec, plan, tasks, architecture/development handoffs, current TASK-019 feedback, manifest and implementation diff. No implementation edits, Agentflow invocation, delegated work, developer receipt reuse, historical reports or workflow logs.

Evidence directory **E**: `qa-evidence/independent-20261015-b1/`. Exact manifest commands, exit codes and timings: `E/results.json`; manifest snapshot and implementation hashes retained alongside it. All ten checks independently passed; successful check time 280.685 seconds. Unit/integration receipts audit 51/97 files respectively, not test totals. Initial Chromium sandbox denial took 0.500 seconds; permitted local execution passed on the next attempt. No retry limit exceeded.

| Check | Fresh evidence | Result |
|---|---|---|
| Toolchain, browser, services, service clients | `E/{toolchain,browser_preflight,services,service_clients}.log`; pinned Elixir/OTP, Node 24/Chromium, PostgreSQL/Redis | PASS |
| Format, compile, whitespace | `mix format --check-formatted`; `MIX_ENV=test mix compile --warnings-as-errors`; `git diff --check`; corresponding E logs | PASS |
| Unit | `MIX_ENV=test mix test.unit`; `audit_count=51 status=complete` | PASS |
| Integration | `MIX_ENV=test mix test.integration`; `audit_count=97 status=complete` | PASS |
| Runtime | `MIX_ENV=test mix run -e 'FootballMarket.Synchronization.RuntimeProbe.run!()'`; `TASK019_RUNTIME_PASS`, actual listener, disposable BEAM, isolated Redis | PASS |
| Independent adversarial acceptance | `MIX_ENV=test mix run E/adversarial.exs`; `E/adversarial.log`, `Result: 5 passed` | PASS |

Acceptance matrix: named maintained tests are under `test/football_market/synchronization/`, independently rerun through the profiles above. **A** denotes the independently authored `E/adversarial.exs` execution. **R** denotes the fresh runtime probe.

| Acceptance criterion | Evidence and observed assertion | Result |
|---|---|---|
| US1.1 | request/concurrency/inspection; terminated requester retains run/job; worker confirms acceptance/counts | PASS |
| US1.2 | inspection; changed, unchanged, complete-empty and replay; attribution/reference retained, replay applies zero bindings | PASS |
| US1.3 | input/request; A B1: six malformed/unavailable/incomplete runtimes rejected for initial/manual/schedule, zero work; explicit/default valid controls accepted | PASS |
| US1.4 | request; unavailable store returns safe error without ID/run/catalog mutation | PASS |
| US1.5 | integrity, R, A HTTP; queued/failed work preserves local list/detail, zero read-triggered provider calls | PASS |
| US2.1 | scheduler; due UTC association; A invalid/drifted persisted source rolls back, restoration admits exactly once | PASS |
| US2.2 | scheduler/recovery/R; disabled/unconfigured/removed schedules create no implicit imports | PASS |
| US2.3 | scheduler; five missed instants retain latest candidate only, compressed supersession, no pre-enable backfill | PASS |
| US2.4 | scheduler/R; concurrent due dispatch, terminal/coalesced occurrence and application restart retain deduplication | PASS |
| US2.5 | scheduler/recovery; disable stops admission, accepted work survives, re-enable changes generation | PASS |
| US3.1 | concurrency; A: ten distinct backends including actual due scheduler plus initial/manual yield one run, ten triggers, one occurrence | PASS |
| US3.2 | input/request/concurrency; fixture/source/instruction conflicts preserve active input; reordered instructions equivalent | PASS |
| US3.3 | retry; A provider guidance 120001 ms persists 121-second wait, early delivery makes no call/attempt, next attempt succeeds | PASS |
| US3.4 | retry/policy/recovery; attempts 1–3, 60/300-second waits, no fourth, new deliberate run permitted | PASS |
| US3.5 | retry/policy/integrity and retained ingestion regressions; closed terminal categories, stale/conflict/invalid/access outcomes, no fallback | PASS |
| US3.6 | recovery/R; queued/retry/interrupted work survives runtime termination; budget/deadline retained, interruption visible | PASS |
| US3.7 | recovery, ingestion delivery_receipt tests, R; publication rollback/fence revocation and third-attempt lost completion, confirmed receipt without fourth retrieval | PASS |
| US3.8 | R; absent, cleared and reconnected isolated Redis preserves durable execution/history | PASS |

HTTP evidence: A records ten real loopback requests across queued/failed phases. Both GET endpoints return 200 with `application/json; charset=utf-8` and persisted player ID/name. Unauthenticated requests return 401, `WWW-Authenticate: Bearer realm="api"`, `error.code=unauthenticated`; missing detail returns 404, `player_not_found`. R additionally exercises reads after application restart with unavailable Redis. Ephemeral credentials are omitted from evidence.

Requirement coverage: FR-001–003/008–009 and SC-001/006 map to US1 plus inspection; FR-004–005/012 and SC-002 to concurrency/migrations/recovery; FR-006–007 and SC-003 to US2; FR-010–011 and SC-004 to retry/policy/recovery; FR-013 and SC-005 to receipts/R; FR-014–016 and SC-007 to integrity/scope, retained provider/ingestion regressions and R. Nonempty financial/quote/statistics snapshots remain identical; supply stays 100. No pruning or downstream implementation introduced.

B1 is independently closed. Implementation hashes remained unchanged during verification. Blockers: none. Final review remains a separate gate.

Verdict: PASS
