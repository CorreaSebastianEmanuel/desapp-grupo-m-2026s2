# Validation guide — TASK-055

This guide names commands the implementation owner must make executable and run; planning does not claim adapter tests already exist or pass. No source contact, credentials or captured temporary files are prerequisites.

## Prerequisites

Use the repository toolchain (`sh scripts/check_toolchain.sh`) and installed Mix dependencies. Pure offline checks need Elixir and Jason on the code path; the bootstrap must locate the installed Jason ebin path without starting Phoenix/Ecto. The full regression/state checks require local PostgreSQL/Redis and existing browser prerequisites for the integration profile. Never purchase access or retrieve source samples to unblock tests.

```sh
sh scripts/local_services.sh start
sh scripts/local_services.sh ready
MIX_ENV=test mix infrastructure.verify
```

Readiness must fail on unavailable services; no skipped integration test substitutes for it. Setup uses existing infrastructure, not new services.

## Executable acceptance

Run every ID in verification.json through `python3 scripts/agentflow_check.py CHECK_ID --reuse`, after implementation. Keep all receipts current before QA. Equivalent direct commands for inspection:

```sh
elixir test/scraping_adapter_offline.exs assessment
elixir test/scraping_adapter_offline.exs catalog
elixir test/scraping_adapter_offline.exs performances
elixir test/scraping_adapter_offline.exs safety
elixir test/scraping_adapter_offline.exs deadline
elixir test/scraping_adapter_offline.exs matrix
elixir test/scraping_adapter_offline.exs equivalence
elixir test/scraping_adapter_offline.exs repeat
elixir test/provider_contract_offline.exs all
MIX_ENV=test mix test test/football_market/providers/scraping/isolation_test.exs
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
sh scripts/test_profile.sh unit
sh scripts/test_profile.sh integration
python3 -m unittest tests.test_agentflow_delivery
```

`repeat` executes all seven offline suites twice in fresh controlled states, compares independently checked outcomes with a fixed retrieval clock, and fails for zero tests, unknown selector, external fetch or credential usage. The `deadline` suite includes existing production Runtime cancellation, no-late-message checks and large timeouts; controlled-time checks alone are insufficient. All fixture input passes source parsing before normalization. Inventory fingerprints and independently authored expected outcomes must be checked, never regenerated to make a failing test pass.

No HTTP endpoint is affected or added, so no HTTP runtime smoke command is appropriate. Integration isolation asserts runtime service readiness and exact persisted catalog/statistics state and local-read equality before/after every scenario. The safety selector also asserts new production modules have no persistence/web/financial calls.

## Expected scenarios and interpretation

See fixture-matrix.md for every story scenario and contracts/source-mapping.md for observed versus hypothetical shapes. Verify forbidden access returns unsupported_capability with zero transport requests; whole-scope failures publish no facts; zero and unknown metrics differ; missing positions fail; explicit completed empty appearances succeed. Both operation equivalence tests compare football facts via independent bijections while retaining distinct qualified source provenance.

Record delivery status in handoffs/develop.md: implemented/offline verified versus live BLOCKED, with exact remaining permission, completeness, limits and position evidence. A passing adapter cannot refresh statistics or quotes. TASK-021 owns substitute derivation; downstream CP2 demo uses explicitly labelled fixtures. QA reruns all checks independently and final review assesses the current QA evidence.

## Development environment delta

The system installation reported Elixir 1.20.4; the strict toolchain check was preserved. Development uses the official Elixir 1.20.3/OTP-29 release installed at `/tmp/football-market-elixir-1.20.3`:

```sh
export PATH=/tmp/football-market-elixir-1.20.3/bin:/Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin:$PATH
python3 scripts/agentflow_check.py toolchain
```

QA must use the required version or an equivalent compliant installation. Mix requires its local TCP lock and the service checks need Docker/PostgreSQL/Redis access; the restricted sandbox needs escalation for those commands. Offline suites load Jason from `_build/test/lib/jason/ebin` and refuse missing dependencies, unknown selections, zero tests and application startup. No external football source is contacted.

The corpus now contains 170 source-shaped cases, with literal expected outcomes in `test/fixtures/scraping/expected.exs` and byte hashes in `inventory.exs`. Synthetic reference inputs in `cases.exs` use the existing FixtureSourceA decoder through a test-only overload; its original cases and four fixture files remain untouched.

Full-profile verification exposed the existing provider/statistics scope tests' pre-scraper file inventories. They now retain the original inventories and add only the named scraper paths; the provider AST dependency prohibitions also cover all seven new production modules. Mix exclusions name the five new bootstrap/data files exactly. No original football-contract expectation, source fixture or fingerprint was changed.

The integration profile needs Node 24; the session uses the existing nvm v24.21.0 installation (the shell default was v20.18.1). Shared fixture reservations use atomic owner leases so negative monotonic origins and killed Runtime workers do not strand concurrency; deadline tests exercise recovery without detached monitoring.

The resumed unit profile exposed a TASK-014-specific exclusion assertion in `test/ci/coverage_report_contract_test.exs`. That regression now asserts the general report/handoff exclusions authorized by feedback; the statistics scope inventory permits this exact test path. The Python snapshot regression still proves source/spec/plan changes invalidate the snapshot. Two unchanged unit attempts failed (61.241 seconds total); development stopped, diagnosed the obsolete assertion and corrected the relevant inputs before another attempt.

## Current human verification decision

The user removed the duplicate CP1 coverage gate for TASK-055. Unit/integration profiles remain mandatory. Finish source and design edits before final checks; development may use `--reuse` only for intact evidence matching the current command/source/design. QA uses direct commands or `python3 scripts/agentflow_check.py CHECK_ID --stage qa` without reuse. After two failures with unchanged inputs in a stage, stop and diagnose; do not keep rerunning suites or modify inputs to evade the limit. Outputs show elapsed check time and evidence. Historical failed cp1-coverage evidence is retained as history, not a current obligation. The current develop-stage invocation resumes developer verification; independent QA and final review remain pending.

## Final-publication regression

Run `python3 scripts/agentflow_check.py publication-gate` for the unchanged six-case human reproduction. The assessment selector additionally checks all six cases during final Validator clock advancement and preserves deadline precedence. Existing adapters need no publication guard; Scraping captures and rechecks current assessment through Runner after successful validation. This changes no consumer DTO or transport enablement.
