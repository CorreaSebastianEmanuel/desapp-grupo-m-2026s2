# Develop handoff — TASK-021 (feedback 6 re-entry, 2026-10-17)

## Changes (feedback 6: CI baseline pollution)

Committed-row statistics tests now run inside a per-test owner schema instead of the shared test DB. `FootballMarket.StatisticsIngestion.Case.with_statistics_store/1` mirrors the sanctioned `Synchronization.Case` owned-store pattern: isolated schema with the full migration chain, isolated Oban (`statistics_import`), app-env Oban override, and `DROP SCHEMA CASCADE` teardown. The three committing tests (`statistics/ingestion/recovery_test.exs`, `statistics/ingestion/concurrency_test.exs`, `synchronization/statistics_test.exs` tests 2–3) were rewired; spawned probes/races opt in via `Repo.put_dynamic_repo(store_repo)`. Baseline env is captured before the store and restored in `on_exit`, so no TestOban name leaks to other tests.

Supporting deltas: `lib/football_market/synchronization/dispatcher.ex` gained an additive optional `:repo` (default unchanged) so the tick can serve an owned store; `IngestionFixtureAdapter` barrier `pg_backend_pid` now uses `Repo.query!` (dynamic-aware) so backends identify the isolated pool (catalog flows unchanged); `mix.exs` `test_ignore_filters` and the `Providers.ScopeTest` expected inventory add the three statistics fixture files, making the warnings-as-errors CI baseline runnable; migration requires are memoized per VM to avoid module-redefinition warnings.

Decision: append-only/immutable triggers make post-hoc cleanup of committed statistics rows impossible, so isolated owner schemas are the only feedback-compliant option. QA-01/02/03 remediation was not reverted; zero library-behavior change without the option.

Residue from earlier crashed sessions was cleared with `MIX_ENV=test mix ecto.drop` + `mix test.prepare` (environment reset only), then `mix infrastructure.verify` passed.

## Command outcomes (this session, stage develop)

Via `python3 scripts/agentflow_check.py CHECK_ID --reuse`, all PASS: preflight 1.9s, format 1.1s, compile 0.8s, unit 32.7s, integration 376.3s (manifest elapsed ~6.9 min; one integration attempt at 1.3s failed before the Node-24 PATH prerequisite was set — environment, not source). Full CI-equivalent `MIX_ENV=test mix test --warnings-as-errors`: 606 passed, 4 excluded, ~5.3 min; Postgres "injected precommit failure" logs are expected test-fault injections. After the full suite the shared DB is clean: 0 synchronization_runs, statistics checks, leagues, observations, oban_jobs. Receipts under `.agentflow/runs/checks/a51aee7448d14823adfa2fce949af473/065-statistics-ingestion-pipeline/develop/`.

## QA guidance

Run every manifest check independently (`--stage qa`, no `--reuse`) with `MIX_OS_CONCURRENCY_LOCK=0` and Node 24 on PATH (`~/.nvm/versions/node/v24.21.0/bin`). Re-run the full `mix test --warnings-as-errors` as the CI-equality check. Challenge the isolated-store semantics (distinct committed backends, recovery/finalization, coalescing) and the frozen-history/outbox cases. Keep T031/T032 open until fresh PASS verdicts. No commit, push, PR or merge.
