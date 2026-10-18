# QA Report — TASK-021 Statistics Ingestion Pipeline (independent QA, re-entry 2026-10-17)

**Scope**: independent re-audit of the remediated tree after Feedback 6 (CI baseline pollution fix). Prior QA-01/02/03 remediations (Feedback 4) re-verified in code. No developer receipt reuse; all manifest checks re-run fresh with `python3 scripts/agentflow_check.py CHECK_ID --stage qa` (no `--reuse`), Node 24 on PATH.

## 1. Manifest checks (independent execution)

| Check | Exit | Elapsed | Evidence excerpt |
|---|---|---|---|
| preflight | 0 | 2.3s | `PostgreSQL: OK (postgresql://127.0.0.1:5432/football_market_test)`, `Redis: OK`; `migrations current` |
| format | 0 | 1.4s | `mix format --check-formatted` clean |
| compile | 0 | 0.8s | `mix compile --warnings-as-errors` clean |
| unit | 0 | 33.5s | `CP1_PROFILE_RECEIPT profile=unit audit_count=58 status=complete` |
| integration | 0 | 361.5s | `CP1_PROFILE_RECEIPT profile=integration audit_count=117 status=complete`; committed-fixture stages include all three rewired statistics tests |

Evidence logs: `.agentflow/runs/checks/a51aee7448d14823adfa2fce949af473/065-statistics-ingestion-pipeline/qa/{preflight,format,compile,unit,integration}/`.

## 2. CI-equality and contamination (Feedback 6 defect)

- `MIX_ENV=test mix test --warnings-as-errors`: **606 passed, 4 excluded, exit 0**, 307.7s. No pollution failures (CatalogTest, DevelopmentSeedTest, RecoveryTest, RequestTest all green).
- Shared-DB sweep after the full suite (Postgrex, `football_market_test`): `synchronization_runs=0`, `statistics_import_checks=0`, `leagues=0`, `statistics_fact_observations=0`, `oban_jobs=0`, `player_match_performances=0`, `players=0`, `matches=0`, `statistics_match_bindings=0`, `statistics_fact_provenance=0`, `statistics_calculation_intents=0`, `statistics_fixture_artifacts=0`; leftover `statistics_ingestion_store_%` schemas = 0. **Zero committed residue.**

## 3. Diff review (11 files, matches develop handoff)

- `test/support/statistics_ingestion/case.ex`: `with_statistics_store/1` creates a per-test owner schema (full migration chain, prefix-scoped isolated Oban `TestOban`, app-env override restored in `after`, `DROP SCHEMA CASCADE` teardown). Mirrors `Synchronization.Case`.
- Committing tests rewired (`recovery_test.exs`, `concurrency_test.exs`, `synchronization/statistics_test.exs` tests 2–3); spawned probes/races opt in via `Repo.put_dynamic_repo(store_repo)`.
- `lib/football_market/synchronization/dispatcher.ex`: additive optional `:repo` only (default unchanged); catalog flow untouched.
- `test/support/ingestion_fixtures.ex`: barrier `pg_backend_pid` via dynamic-aware `Repo.query!`.
- `mix.exs` + `providers/scope_test.exs`: three statistics fixture files added to `test_ignore_filters` inventory.

## 4. Prior findings remain remediated (Feedback 4, re-verified in code)

- **QA-01 (high)**: `publisher.ex:554` `validate_match_mapping!/4` rejects retargeted/conflicting mappings (`Repo.rollback(:immutable_conflict)`); replay prevalidation resolves every match mapping (publisher.ex:50–59). Tests: `replay_test.exs:73` "a retargeted match mapping cannot bypass binding conflicts on replay or unchanged import"; `acceptance_test.exs:342` "changed participation is an immutable conflict and does not advance accepted state".
- **QA-02 (medium)**: `integrity_test.exs` now binds typed Elixir maps as `$8::jsonb` (no `Jason.encode!` strings), with a positive control insert and three invalid variants (nil participation, missing `policy_version`) asserted to raise `Postgrex.Error`.
- **QA-03 (high)**: migration `20261016000100` trigger recomputes frequencies and validates basis children against committed subjects (`statistics_position_basis_validate`, `RAISE ... ERRCODE '23514'`); `positions_test.exs:235+` asserts a late basis insert against a committed unknown raises `Postgrex.Error` and replay retains the accepted evidence.

## 5. Coverage challenge (spec.md vs executed tests; 23/23 identifiers bound)

| Spec item | Independent evidence |
|---|---|
| US1.1–1.4 (atomic accept, incomplete, unchanged, explicit empty) | `acceptance_test.exs` (multi-match exact totals; replay idempotent; "explicitly complete empty scope differs from missing completeness evidence"), `completeness_test.exs` (unproven/witness failures never advance check) |
| US2.1–2.4 (replay, conflict, races, retry/interruption) | `replay_test.exs`, `canonical_test.exs`, `concurrency_test.exs` (race asserts **2 distinct committed backend PIDs**, exactly one `accepted_changes` + one `replay`), `recovery_test.exs` (kill before/after publication, final-attempt finalization) |
| US3.1–3.6 (lineage, safe errors, nil-vs-zero, direct/derived/tie/no-history) | `provenance_test.exs` (fingerprint, non-live label), `ingestion_contract_test.exs` (unit), `metrics_test.exs` (all 9 metrics: one explicit zero among nils, persisted **and** re-read via `Statistics.get_performance`), `positions_test.exs` (unique mode with full basis, tie/insufficient unknown with reason, one-vote-per-match, shuffled-batch exclusion, direct-entrant precedence) |
| FR-013 outbox crash semantics | `calculation_test.exs`: idempotent accept, "Oban redelivers a calculation accepted before worker interruption", stale executing dispatch cannot strand intent, failed delivery separate from import, no quote writes |
| FR-015 isolation | `isolation_test.exs` (provider failure leaves facts intact; exactly 1 transport call); statically: zero `Providers` references in `statistics.ex`, `statistics/query.ex`, `valuation/statistics_reader.ex` — reads are structurally provider-free |
| FR-016 / SC-007 zero live calls | Fixture-adapter transport counter; deterministic offline fixtures; no credentials in tree |

## 6. HTTP runtime check

No web-layer changes in the feature (empty diff for `lib/football_market_web/` and `test/football_market_web/` since 44cef90); no new route, permission, or public endpoint. `runtime_required=false` is correct; no HTTP exercise applicable. Actual Oban/process/restart assertions ran inside integration as required.

## Residual notes (non-blocking)

1. `verification.json` coverage_evidence for FR-008 lists only the unit-tagged contract file; integration-side nil/zero evidence rides on SC-004 (`metrics_test.exs`). Behavior is covered in both profiles; mapping granularity only.
2. In `isolation_test.exs` the transport-counter assertion precedes the second local read; read isolation is instead proven structurally (no provider dependency in the read path). Cosmetic test-ordering note.
3. `erl_crash.dump` (6 MB) at repo root is environment residue from an earlier crashed session; untracked, not feature code.

Verdict line restored per Feedback 7 (content unchanged; no re-audit required — evidence recorded above and in `handoffs/qa.md`).

Verdict: PASS
