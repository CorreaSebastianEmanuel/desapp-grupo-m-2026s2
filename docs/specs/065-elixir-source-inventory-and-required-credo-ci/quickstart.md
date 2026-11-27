# Local validation — TASK-065

Use the existing README toolchain/service setup (Elixir 1.20.3, OTP 29.0.6, PostgreSQL, Redis, Python, Ruby, Docker Compose, Node 24 and locked OpenAPI packages/Chromium). No provider credentials or SonarCloud tokens are needed. All commands below run at repository root after implementation.

1. Stage newly maintained Elixir files before deliberate inventory refresh; ordinary content edits may remain unstaged. Review exact archived exclusions in `config/credo_inventory.json` and run:

   ```sh
   MIX_ENV=test mix run --no-start scripts/credo_inventory.exs --write-inventory
   git diff -- config/credo_inventory.json
   ```

2. Reproduce standard analysis and complete audited evidence together:

   ```sh
   MIX_ENV=test sh scripts/credo_ci.sh
   ```

   Expect exit zero, full maintained/effective equality, exact exclusions, both exit statuses zero and complete=true in `tmp/credo-ci/evidence.json`. Standalone analyzer command remains `MIX_ENV=test mix credo --format flycheck`; standalone reconciliation is `MIX_ENV=test mix run --no-start scripts/credo_inventory.exs`.

3. Execute manifest checks in order via `python3 scripts/agentflow_check.py CHECK_ID`: preflight, format, compile, inventory, credo, regression, e2e. Preflight prepares the test database before profile discovery, validates PostgreSQL/Redis through existing clients, Docker and Chromium readiness, builds assets and validates OpenAPI. Regression runs unit/integration once through `scripts/ci_unit_tests.sh`; e2e runs once. Do not additionally run the historical CP1 coverage report. QA repeats every ID with `--stage qa` and no reuse.

4. Review temporary-repository failure tests through the unit profile: newly added/removed/renamed paths, missing or stale inventory, effective mismatch, unjustified exclusion, invalid source, CLI failure and incomplete oracle all fail. Do not break the working repository to demo failures.

5. In a subsequently authorized CI run, open Quality baseline -> Artifacts -> revision/run-attempt-specific Credo evidence; download full JSON/log, check both revision fields and complete lists. Retention is 14 days; failures retain evidence too, but incomplete evidence never means pass.

Zero Credo findings establish neither absence of bugs nor equivalence to SonarCloud native Java analysis. A dirty local snapshot is labelled and cannot be represented as clean revision evidence. No HTTP endpoint changes; existing integration/browser runtime assertions remain mandatory.
