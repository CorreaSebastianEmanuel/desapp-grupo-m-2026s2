# TASK-066 finding, hunk and regression ledger

Base: `4b257566e18fc2b7ddc55d0c5a730b27481b6d2b`. Selected environment:
`POSTGRES_PORT=55432 REDIS_PORT=6379 MIX_TEST_PARTITION=task066`, Node 24.21.0,
Docker mappings inspected, locked Node dependencies prepared, Chromium launch
verified. Assets prepared with `MIX_ENV=test mix assets.setup` and `mix assets.build`.
No shared database reset. TASK-065 remains todo, explicitly depending on TASK-066.

Archive base `57b26cccf72de49e9a5cc99acf3d4fd1773ac3d3` was verified as an ancestor;
SHA256 `af9164af764551ad12f7bfbac2c16d33a62ff666a53541fd2fce938d8c9012c8` matched.
Current contexts passed `git apply --check`; application and support batches were
applied separately after current regressions. No historical check credit.

## Inventory and source reconciliation

The complete fresh pre-refactor inventory (192 findings) and source hashes/revision/diff
identity are retained in `tmp/task066/pre-refactor-findings.log` and
`tmp/task066/pre-refactor-metadata.json`; maintained paths are in
`tmp/task066/maintained-inputs.txt`. The provisional earlier measurement omitted hidden
root inputs; the corrected authoritative inventory preceded all application edits.
The tooling contract caught the hidden wildcard omission. Both maintained hidden
root files are explicit. Final `inventory` writes the exact effective input list,
source hashes, analyzer version and check identities to
`tmp/task066/effective-measurement.json`; all 413 maintained paths reconcile with all
413 effective inputs. All parse statuses are valid and default-priority findings are zero.
`verification.json` owns every executable command and FR/SC coverage mapping.

Check names below have the `Credo.Check.` prefix. F/R/W are the original flycheck
categories. Every indexed finding is causally removed in its original file; no
source exclusion, rule override, suppression, baseline or raised threshold exists.

| Original finding | Check / category | Causal change and regression |
|---|---|---|
| `lib/football_market/accounts.ex:130:5` | Readability.WithSingleClause / R | equivalent case/if preserving error branch; `causal-application + integration` |
| `lib/football_market/accounts.ex:193:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/accounts/browser_sessions.ex:29:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/accounts/browser_sessions.ex:67:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/accounts/browser_sessions.ex:92:5` | Refactor.CondStatements / F | equivalent if/else preserving branch order; `causal-application + integration` |
| `lib/football_market/accounts/user.ex:43:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/catalog/development_seed.ex:114:40` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-seed` |
| `lib/football_market/catalog/development_seed.ex:141:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-seed` |
| `lib/football_market/catalog/development_seed.ex:161:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-seed` |
| `lib/football_market/catalog/development_seed.ex:192:55` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-seed` |
| `lib/football_market/catalog/development_seed.ex:95:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-seed` |
| `lib/football_market/catalog/ingestion.ex:51:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/observation.ex:20:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/publisher.ex:120:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/publisher.ex:172:15` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/publisher.ex:33:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/reconciler.ex:111:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/reconciler.ex:11:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/reconciler.ex:233:32` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/catalog/ingestion/reconciler.ex:76:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/catalog/query.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/infrastructure/verification.ex:20:5` | Refactor.MapJoin / F | use map_join with identical mapper/separator; `causal-remaining + integration` |
| `lib/football_market/market/consistency.ex:30:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/market/consistency.ex:46:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/market/consistency.ex:56:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/market/consistency.ex:5:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/market/store.ex:18:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/market/store.ex:42:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/providers/instant.ex:3:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/performances.ex:19:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/runner.ex:38:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/assessment.ex:50:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/assessment.ex:80:14` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/providers/scraping/fixture_transport.ex:56:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/source.ex:115:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/source.ex:5:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/translator.ex:129:21` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/statistics.ex:126:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/statistics.ex:147:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/statistics/count.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/statistics/error.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/canonical.ex:76:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/positions.ex:30:28` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:24:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:255:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:294:13` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:342:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:401:13` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:492:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:554:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:628:8` | Refactor.FunctionArity / F | group related fact arguments in one tuple; `causal-remaining + integration` |
| `lib/football_market/statistics/ingestion/publisher.ex:98:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/statistics/input.ex:132:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/statistics/input.ex:143:15` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/statistics/input.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-application + integration` |
| `lib/football_market/statistics/input.ex:51:5` | Refactor.CondStatements / F | equivalent if/else preserving branch order; `causal-application + integration` |
| `lib/football_market/statistics/input.ex:66:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/statistics/query.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/synchronization/dispatcher.ex:47:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/dispatcher.ex:68:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/execution_guard.ex:22:5` | Readability.WithSingleClause / R | equivalent case/if preserving error branch; `causal-remaining + integration` |
| `lib/football_market/synchronization/input.ex:138:30` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/input.ex:161:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/input.ex:178:37` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/policy.ex:33:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/policy.ex:4:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/recovery.ex:25:15` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/recovery.ex:51:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/scheduler.ex:120:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/scheduler.ex:158:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/scheduler.ex:222:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/scheduler.ex:28:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/scheduler.ex:49:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:120:5` | Readability.WithSingleClause / R | equivalent case/if preserving error branch; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:159:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:217:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:233:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:27:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:296:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/balanced.ex:33:29` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/valuation/calculation_requests.ex:31:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/valuation/calculation_requests.ex:80:5` | Readability.WithSingleClause / R | equivalent case/if preserving error branch; `causal-remaining + integration` |
| `lib/football_market/valuation/configurations/store.ex:113:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/configurations/store.ex:25:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/evidence.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/managed.ex:61:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/managed_types.ex:6:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/position_aware.ex:47:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/valuation/position_groups.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/replay.ex:125:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/valuation/replay.ex:44:13` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/request.ex:130:9` | Readability.WithSingleClause / R | equivalent case/if preserving error branch; `causal-remaining + integration` |
| `lib/football_market/valuation/request.ex:131:58` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/request.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/request.ex:31:5` | Refactor.CondStatements / F | equivalent if/else preserving branch order; `causal-remaining + integration` |
| `lib/football_market/valuation/scoring.ex:15:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/valuation/scoring.ex:88:23` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/statistics_reader.ex:36:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/types.ex:20:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/types.ex:24:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/types.ex:28:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/types.ex:37:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/types.ex:41:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/valuation/week.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market/workers/catalog_sync.ex:35:15` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/workers/catalog_sync.ex:48:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/workers/catalog_sync.ex:69:14` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market_web/components/workspace_components.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market_web/controllers/player_controller.ex:73:13` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market_web/controllers/session_controller.ex:25:15` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market_web/live/browser_auth.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/football_market_web/live/browser_auth.ex:40:61` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market_web/live/browser_auth.ex:6:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market_web/plugs/browser_auth.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/mix/tasks/catalog.seed.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-seed` |
| `lib/mix/tasks/infrastructure.database.ex:34:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/mix/tasks/infrastructure.database.ex:40:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/mix/tasks/infrastructure.database.ex:46:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/mix/tasks/infrastructure.database.ex:55:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `lib/mix/tasks/infrastructure.verify.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/ci/credo_remediation_contract_test.exs:96:5` | Refactor.FilterFilter / F | one filter with ordered predicates; `causal-safeguards + unit` |
| `test/ci/e2e_runtime_contract_test.exs:58:44` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-safeguards + unit` |
| `test/ci/profile_integration_sentinel_test.exs:7:14` | Refactor.MatchInCondition / F | case on closed environment tuple; `causal-safeguards + unit` |
| `test/ci/profile_unit_sentinel_test.exs:7:14` | Refactor.MatchInCondition / F | case on closed environment tuple; `causal-safeguards + unit` |
| `test/football_market/accounts/authentication_test.exs:100:7` | Refactor.MapJoin / F | use map_join with identical mapper/separator; `causal-application + integration` |
| `test/football_market/catalog/ingestion/concurrency_test.exs:101:37` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `test/football_market/catalog/ingestion/concurrency_test.exs:119:37` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/catalog/ingestion/concurrency_test.exs:191:40` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/catalog/ingestion/concurrency_test.exs:217:47` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/catalog/ingestion/concurrency_test.exs:265:49` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/catalog/ingestion/concurrency_test.exs:83:48` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/market/concurrency_test.exs:16:23` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `test/football_market/providers/scope_test.exs:278:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/football_market/statistics/concurrency_test.exs:134:23` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/statistics/concurrency_test.exs:134:46` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/statistics/concurrency_test.exs:38:39` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/football_market/statistics/input_test.exs:85:33` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-application + integration` |
| `test/football_market/statistics/scope_test.exs:307:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `test/football_market/valuation/balanced/arithmetic_test.exs:109:23` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-application + integration` |
| `test/football_market/valuation/balanced/arithmetic_test.exs:109:30` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-application + integration` |
| `test/football_market/valuation/balanced/scope_test.exs:183:14` | Warning.ExpensiveEmptyEnumCheck / W | retain nonempty query-list assertion; `causal-application + integration` |
| `test/football_market/valuation/position_aware/arithmetic_test.exs:86:18` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-application + integration` |
| `test/football_market/valuation/position_aware/arithmetic_test.exs:86:25` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-application + integration` |
| `test/football_market/valuation/position_aware/scope_test.exs:180:14` | Warning.ExpensiveEmptyEnumCheck / W | retain nonempty query-list assertion; `causal-application + integration` |
| `test/support/accounts_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-application + integration` |
| `test/support/browser_session_case.ex:114:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/browser_session_case.ex:120:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/browser_session_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/catalog_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/catalog_concurrency_case.ex:35:37` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `test/support/data_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/e2e/fixtures.ex:119:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `e2e` |
| `test/support/e2e/fixtures.ex:31:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `e2e` |
| `test/support/e2e/fixtures.ex:75:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `e2e` |
| `test/support/e2e/fixtures.ex:93:5` | Warning.UnusedEnumOperation / W | retain and assert reduced replay identity; `e2e` |
| `test/support/infrastructure_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/ingestion_fixtures.ex:165:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/ingestion_fixtures.ex:200:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/ingestion_fixtures.ex:209:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/ingestion_fixtures.ex:217:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/openapi_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/position_aware_case.ex:168:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/position_aware_case.ex:90:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `test/support/providers/fact_oracle.ex:22:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `test/support/providers/fact_oracle.ex:43:13` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/support/providers/fixture_runtime.ex:31:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-application + integration` |
| `test/support/providers/fixture_source_a.ex:91:75` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/support/providers/fixture_source_b.ex:88:75` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/support/providers/scraping_fixture_data.ex:111:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `test/support/providers/scraping_fixture_data.ex:142:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/support/providers/scraping_fixture_data.ex:218:25` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/support/providers/scraping_fixture_data.ex:32:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `test/support/providers/scraping_fixture_data.ex:38:19` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `test/support/statistics_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/statistics_case.ex:34:90` | Readability.LargeNumbers / R | numeric separators; same integer value; `causal-remaining + integration` |
| `test/support/synchronization/case.ex:24:20` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `test/support/test_profile_audit.ex:71:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-safeguards + unit` |
| `test/support/test_profile_audit.ex:78:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-safeguards + unit` |
| `test/support/valuation_case.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:100:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:105:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:110:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:115:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:1:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:49:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:53:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:70:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:75:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:80:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:85:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:90:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |
| `test/support/valuation_scorers.ex:95:11` | Readability.ModuleDoc / R | declare private-module documentation explicitly; `causal-remaining + integration` |

## Newly exposed finding locations

Moved and newly exposed helper findings were remeasured after each causal batch; none remains. Original full measurements remain in the referenced check outputs.

| Location | Check / category | Causal change and regression |
|---|---|---|
| `lib/football_market/market/consistency.ex:53:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/market/store.ex:23:26` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/providers/scraping/assessment.ex:50:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/source.ex:120:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-application + integration` |
| `lib/football_market/providers/scraping/source.ex:64:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/statistics.ex:119:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:161:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:219:7` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:235:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:298:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/calculation_requests.ex:31:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/valuation/scoring.ex:102:23` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `test/football_market/providers/scope_test.exs:291:11` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-application + integration` |
| `lib/football_market/catalog/ingestion.ex:76:8` | Refactor.CyclomaticComplexity / F | split ordered predicates/body into private helpers; `causal-remaining + integration` |
| `lib/football_market/synchronization/store.ex:179:9` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |
| `lib/football_market/valuation/scoring.ex:100:23` | Refactor.Nesting / F | extract callback/helper inside original execution boundary; `causal-remaining + integration` |

## Archived hunk decisions

All hunks in these application files were reviewed for unchanged evaluation/error order and transaction/lock/exception placement; accepted with the canonical truthiness correction below:

`lib/football_market/accounts.ex`, `lib/football_market/accounts/browser_sessions.ex`, `lib/football_market/accounts/user.ex`, `lib/football_market/catalog/query.ex`, `lib/football_market/infrastructure/verification.ex`, `lib/football_market/market/consistency.ex`, `lib/football_market/providers/performances.ex`, `lib/football_market/providers/runner.ex`, `lib/football_market/providers/scraping/source.ex`, `lib/football_market/providers/scraping/translator.ex`, `lib/football_market/statistics.ex`, `lib/football_market/statistics/count.ex`, `lib/football_market/statistics/error.ex`, `lib/football_market/statistics/ingestion/canonical.ex`, `lib/football_market/statistics/input.ex`, `lib/football_market/statistics/query.ex`, `lib/football_market/synchronization/dispatcher.ex`, `lib/football_market/synchronization/execution_guard.ex`, `lib/football_market/synchronization/policy.ex`, `lib/football_market/synchronization/store.ex`, `lib/football_market/valuation/balanced.ex`, `lib/football_market/valuation/calculation_requests.ex`, `lib/football_market/valuation/evidence.ex`, `lib/football_market/valuation/managed.ex`, `lib/football_market/valuation/managed_types.ex`, `lib/football_market/valuation/position_aware.ex`, `lib/football_market/valuation/position_groups.ex`, `lib/football_market/valuation/replay.ex`, `lib/football_market/valuation/request.ex`, `lib/football_market/valuation/scoring.ex`, `lib/football_market/valuation/statistics_reader.ex`, `lib/football_market/valuation/types.ex`, `lib/football_market/valuation/week.ex`, `lib/football_market_web/components/workspace_components.ex`, `lib/football_market_web/controllers/session_controller.ex`, `lib/football_market_web/live/browser_auth.ex`, `lib/football_market_web/plugs/browser_auth.ex`, `lib/mix/tasks/catalog.seed.ex`, `lib/mix/tasks/infrastructure.database.ex`, `lib/mix/tasks/infrastructure.verify.ex`.

All hunks in these test/support files were reviewed for retained assertions, owned resources and callback/process identity; accepted with the two scraping-fixture corrections below:

`test/ci/e2e_runtime_contract_test.exs`, `test/ci/profile_integration_sentinel_test.exs`, `test/ci/profile_unit_sentinel_test.exs`, `test/football_market/accounts/authentication_test.exs`, `test/football_market/catalog/ingestion/concurrency_test.exs`, `test/football_market/market/concurrency_test.exs`, `test/football_market/statistics/concurrency_test.exs`, `test/football_market/statistics/input_test.exs`, `test/football_market/valuation/balanced/arithmetic_test.exs`, `test/football_market/valuation/balanced/scope_test.exs`, `test/football_market/valuation/position_aware/arithmetic_test.exs`, `test/football_market/valuation/position_aware/scope_test.exs`, `test/support/accounts_case.ex`, `test/support/browser_session_case.ex`, `test/support/catalog_case.ex`, `test/support/catalog_concurrency_case.ex`, `test/support/data_case.ex`, `test/support/e2e/fixtures.ex`, `test/support/infrastructure_case.ex`, `test/support/ingestion_fixtures.ex`, `test/support/openapi_case.ex`, `test/support/position_aware_case.ex`, `test/support/providers/fixture_runtime.ex`, `test/support/providers/fixture_source_a.ex`, `test/support/providers/fixture_source_b.ex`, `test/support/providers/scraping_fixture_data.ex`, `test/support/statistics_case.ex`, `test/support/synchronization/case.ex`, `test/support/test_profile_audit.ex`, `test/support/valuation_case.ex`, `test/support/valuation_scorers.ex`.

Rejected/adjusted portions: reject archived `~> 1.7.19` and flat config; use exact
pin and named stock config. Preserve `canonical_source_identity` truthiness for
false/nil. Preserve false `revoke_at` as disabled; preserve source identity selection
by original reference values rather than introducing kind-based selection. Lock
entries were resolved afresh (only Credo/bunt additions). Additional files in the
index were remediated from fresh source, independently of the archive.

## Regression and preservation review

Exact causal argv arrays are in verification.json. Tooling red: 0/4 passed before
implementation (`tooling-contract/6679473673fa4bcfbccaabb07f09d60f.log`, 0.920 s).
Initial stable tooling green: 4/4, 1.254 s. Pre-refactor causal-application passed
18.499 s; causal-persistence passed 3.000 s; causal-safeguards passed 2.402 s;
E2E/browser baseline passed 25.532 s. The remaining 69 transactional/contract files
passed before further extraction (30.474 s); seed baseline passed 76.178 s and
post-refactor 22.152 s. Current final receipts are referenced in develop.md.
A broad mixed-fixture invocation was interrupted and has no passing credit;
an inventory update invalidated one otherwise passing targeted run, which was
rerun with stable inputs. Every subsequent source batch had causal passing checks.

New characterization passes before refactoring: recipient conflict/partial fixation
short-circuits malformed history, and input field/precision error precedence.
Seven new cases are explicitly registered; all 877 old identities/assignments remain.
Six already-existing fast-lane cases were missing in the original inventory and
are now registered without changing their implementation or assignments.

Manual hunk review retains all seven invariants: supply 100 and exact Decimal
monetary values, atomic/idempotent operations, append-only transaction/audit history,
immutable quotes, local reads during provider failure, reproducible valuation.
Queries/locks/writes remain under the original transactions and rollback ordering;
provider callbacks remain under the original rescue/catch, budgets and publication
fence. Auth expiry/revocation and owner checks retain their existing errors/order.
E2E nested maps remain subset patterns, including season/league/team/position;
assertions were extracted, never projected into weaker equality checks. Native
profile audit preserves identity, duplicate/refusal order and invocation provenance;
owned cleanup and child ownership remain unchanged. Assertion-count comparison
found no decrease in any edited test/support file. The case-list refactors preserve
all original feature paths and unknown-feature refusal. New TASK-066 scope is a
finite list and its dependency exception accepts only the exact nonruntime pin;
version/runtime/environment mutations still fail.

Residual risk: regression evidence and source review do not prove semantic
equivalence. Independent QA must challenge financial/auth/native hunk behavior,
check the fresh inventory, rerun all profiles and confirm real HTTP/browser
assertions. No behavior defect fix, CI integration, coverage collector or Sonar
probe was introduced. TASK-065 stays blocked through independent gates/human merge.

Final-check corrections: warnings-as-errors found two unused trailing helper bindings, removed while retaining the returned expressions. The unit scope guard then identified the new market characterization file missing from TASK-066’s finite allowance; added that exact path and a positive contract assertion. `causal-safeguards` now explicitly runs all three cross-feature scope guards as well as native refusal cases. No source/CI directory allowance was introduced. All final receipts are regenerated after these causal corrections.


CI parity fixture repair — 2026-10-19: the full integration profile reproduced
`redis-occupied` failing because Compose returned success despite a listening
loopback blocker after the preceding failed PostgreSQL startup. Observational
Docker instrumentation confirmed the Redis listener before `up` and exit 0.
The fixture now removes stopped containers before each occupied-port case, retaining
volumes, both original failure assertions, and production lifecycle behavior.
The subsequent complete-profile attempt advanced past both conflict cases but
failed the market scope guard, whose compiled allowance preceded the source edit.
The exact shell-test allowance and unknown-shell-path refusal are now included;
`causal-safeguards` passed on stable inputs (3.948 seconds). Final receipts must be
regenerated before readiness and the exact CI wrapper; prior receipts above are
historical, not acceptance evidence for this repair.

CI output repair — 2026-10-19: after fresh checks and readiness passed, the exact
CI command returned successful text but Agentflow correctly rejected its stdout
under the declared JSON contract. Keep that contract and the unchanged CI command.
Move human diagnostics and discovery sentinel to stderr; emit a single schema-1
completion JSON only after both original profiles and receipt verification pass.
The strengthened existing seven-case shell contract fails against the HEAD script
with JSONDecodeError and passes against the repair; child failure, missing/partial/
wrong-profile/stale/empty receipts remain failures with no success stdout. All four
workflow gate tests pass. No saved state, model assignment or verdict was edited.
Final receipts must be refreshed for this repair before readiness/CI/independent QA.

Port collision root cause confirmed — 2026-10-19: the stopped-container workaround
failed again at redis-occupied and is removed. In isolated owned projects, a Python
socket was bound/listening in WSL before Compose; Compose started both services
with exit 0 for PostgreSQL port 34109 and Redis port 46013. Publishing blocker
ports on the Docker daemon instead produced collision errors and exit 1 for both
services (59837 and 55407). Command: tmp/task066/probe-port-namespace.py; the local
probe summary is tmp/task066/port-namespace-results.json and bounded startup output
is tmp/task066/namespace-local-listener-{postgres,redis}.log. Earlier attribution
to partially initialized peer containers was insufficient and is superseded.
The fixture now publishes its blocker through the same daemon using the pinned
Redis image, checks running state and exact loopback publication, and retains both
original startup-failure and occupied-port diagnostic assertions. Persistence is
disabled and only its cidfile-recorded container is stopped by normal/trap cleanup.
No production service script or assertion was weakened. Stable repeated isolation
and all manifest checks must pass before resuming the unchanged JSON CI gate.

A second isolation experiment with daemon reservation alone passed once then
failed on the next execution in the same project. Keep both fixture requirements:
reserve on the daemon and remove stopped service containers before each case so
publication is allocated afresh. The product start command remains untouched.
The repeated-fixture diagnostic runs the original refusal assertions five times
in one owned project; no failure is retried into a passing aggregate.

Repeated fixture outcome: `python3 tmp/task066/verify-daemon-fixture.py` completed
five consecutive executions in one owned Compose project; all returned exit 0 and
`failure diagnostics contract: PASS`. Both occupied-port assertions executed on
each run. Owned-project cleanup exited 0. The seven JSON CI contract cases and four
workflow gate tests also passed again. This is fixture regression evidence only;
all 16 final manifest checks and the exact CI gate remain required on current inputs.

GitHub PR #48 follow-up — 2026-10-19: remote Quality baseline failed at the unit
wrapper in about 1.3 seconds, while E2E and Sonar passed. A clean local clone at
HEAD passed native inventory under Python 3.12 and passed unit 439/439 with a
prepared database. Creating a new empty football_market_testtask066ciempty database
and running the same unit profile failed at inventory-or-service-prerequisite.
The quality job lacked test.prepare, unlike the E2E job. Existing test.prepare
migrated only that new test database; the exact profile recovery is being checked.
Correction adds the existing preparation step before the unchanged CI wrapper,
strengthens the existing quality contract and permits the exact changed paths.
Feedback #1 rewinds Development; historical approvals do not authorize the update.
All required checks and fresh independent gates must pass before PR publication.
