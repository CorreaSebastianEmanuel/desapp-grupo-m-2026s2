# Development handoff — TASK-019 CI repair

PR #38 failed because the provider dependency assertion read ignored `.specify/feature.json`. It now requires exact Oban approval from the committed synchronization plan and always exercises version, duplicate and unrelated-dependency mutations. Production code is unchanged.

Targeted evidence: `mix test test/football_market/providers/scope_test.exs:140 --warnings-as-errors` passed with missing metadata and a stale TASK-013 pointer (one passed each); outputs `/tmp/task019-scope-{missing,stale}.log`. The catalog query-plan test passed with unchanged 99,999-row fixture/index assertions after adding only a 60-second seed-query timeout (22 seconds; `/tmp/task019-query-plan.log`). Plan records this bounded test correction; three existing synchronization scope allowlists add only that exact test path. Unknown-feature rejection remains.

Environment: pinned Elixir 1.20.3 is `/tmp/football-market-elixir-1.20.3-otp-29/bin`; prepend PATH. Use `POSTGRES_PORT=55432 MIX_TEST_PARTITION=task019_20261015 ERL_FLAGS='+S 4:4'`. Owned container `football-market-task019-postgres` runs pinned PostgreSQL 17.6 with max_connections=250. Existing host port5432 runs PostgreSQL18.6 and caused constraint-code/connection failures; its databases remain intact. Locked npm dependencies and Playwright Chromium are installed.

Prior failed checks were diagnosed before corrections: missing browser executable, host-version/pool failures, bulk-fixture timeout, then exact scope allowance rejection (152/153 unit passed). Relevant source/plan inputs changed before each new verification scope; no unchanged third failure was retried.

All ten final manifest checks passed through `scripts/agentflow_check.py`, with unchanged source/design fingerprints. Integration: 121.733 seconds; runtime HTTP: 7.008 seconds. Current `handoffs/check-*.json` receipts replace earlier evidence. Independent QA must rerun all checks without reuse, challenge missing/stale metadata and fixture cardinality, and preserve the earlier B1 runtime-rejection regressions. Final review follows fresh QA. Neither gate is claimed complete for this repair.
