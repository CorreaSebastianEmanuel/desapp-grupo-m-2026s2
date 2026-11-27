# Offline validation guide

Run from the repository root on branch 021-statistics-ingestion-pipeline. This guide covers the local entry points and current acceptance suite. Fixtures are synthetic and explicitly non-live.

## Prerequisites

Use the repository-pinned Elixir/Erlang toolchain and installed dependencies. Start the existing local PostgreSQL/Redis services using the repository README infrastructure instructions:
```sh
./scripts/local_services.sh start
./scripts/local_services.sh ready
```

Do not enable live retrieval, use real credentials, or point tests at development data. Integration profile also requires Node 24, tools/openapi installed dependencies and Playwright Chromium, as enforced by scripts/test_profile.sh. With Node 24 already available, prepare these prerequisites once:

```sh
npm ci --prefix tools/openapi
tools/openapi/node_modules/.bin/playwright-core install --with-deps --only-shell chromium
```

Run manifest checks from the root, in listed order:

```sh
python3 scripts/agentflow_check.py preflight --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py unit --reuse
python3 scripts/agentflow_check.py integration --reuse
```

Preflight runs guarded test DB preparation before infrastructure.verify; it fails for missing PostgreSQL/Redis or migration failure. Do not print environment variables or credentials to diagnose it. Each profile runs exactly once; no aggregate test/CP1 coverage report afterward. New cases must be included in the profile audit and assert actual execution, not skip due to unavailable runtime.

## Deterministic demo/acceptance cases

Fixtures and expected values live in `test/fixtures/statistics_ingestion/{documents,inventory,expected}.exs`. `inventory.exs` pins the SHA-256 of the fixture document and records its synthetic origin, creation date, rule coverage and non-live status. `test/support/statistics_ingestion/case.ex` uses the existing fixture adapter, catalog bindings and transport counter. Relevant assertions live in `acceptance_test.exs`, `calculation_test.exs`, `canonical_test.exs`, `completeness_test.exs`, `concurrency_test.exs`, `integrity_test.exs`, `isolation_test.exs`, `metrics_test.exs`, `positions_test.exs`, `provenance_test.exs`, `recovery_test.exs`, and `replay_test.exs`; provider DTO assertions are in `test/football_market/providers/ingestion_contract_test.exs`. `test/football_market/synchronization/statistics_test.exs` covers admission and the real Oban worker.

1. `acceptance_test.exs` checks single and multi-match fact totals, no synthesized performance rows, atomic lineage/check/intent publication, replay and changed match/position/metric conflicts, complete-empty versus missing evidence, and admitted fixture fingerprint. `completeness_test.exs` rejects unproven and partial-empty witnesses without advancing accepted facts or checks.
2. `canonical_test.exs` compares source identity despite local-reference/list-order changes and retrieval timestamps, and detects changed match, position, metric and source-binding material. `replay_test.exs` checks unchanged re-fetch after a later retrieval, first-provenance retention and appended observations. `concurrency_test.exs` uses distinct committed PostgreSQL backends to race identical publication; `recovery_test.exs` kills the worker during provider read before commit, while `synchronization/statistics_test.exs` kills it after confirmed publication at the final attempt.
3. `positions_test.exs` checks unique match-count mode, exact retained basis rows, ties, insufficient history, same-player/same-season strict kickoff filtering, excluded proposal batches, unknown-position retention after history grows, and the existing valuation missing-position outcome. Provider contract cases cover direct starter/entrant compatibility and reject unsupported missing-position roles.
4. `metrics_test.exs` persists all nine keys with nil independently from explicit zero and reads them back. `provenance_test.exs` checks provider-qualified identity, first-lineage retention, appended observations, fixture fingerprint and rollback/redaction for hostile references. `synchronization/input_test.exs` rejects execution after admitted fixture bytes drift.
5. `calculation_test.exs` proves receiver idempotence after accept-before-ack, bounded dispatch exhaustion on receiver outage, durable import independence, and no quote writes. `isolation_test.exs` injects a provider failure and confirms accepted history reads remain local and unchanged. These fixtures never enable live retrieval or use real credentials.

Implementation checks are the five commands above. Independent QA reruns them with `--stage qa` and without `--reuse`; final review requires fresh QA evidence. Record only actual check results in `handoffs/develop.md`; this guide is not a passing report.

QA executes the same checks independently using --stage qa without --reuse and challenges each story scenario. Final review uses fresh QA evidence and targeted unresolved risks. Record only actual check results in handoffs/develop.md; never treat this guide as a passing report.
