# Local validation guide

Use the exact `.tool-versions` BEAM toolchain, Node 24, Python 3, Docker Engine/Compose (including the real integration service lifecycle cases), locked Mix dependencies and existing PostgreSQL/Redis services. From repository root:

```sh
./scripts/check_toolchain.sh
./scripts/local_services.sh start
MIX_ENV=test mix infrastructure.verify
mix deps.get --locked
npm ci --prefix tools/openapi
tools/openapi/node_modules/.bin/playwright-core install --with-deps --only-shell chromium
MIX_ENV=test mix test.prepare
MIX_ENV=test mix assets.build
```

Use only the configured safe test database and deterministic local accounts/provider fixtures. E2E creates a uniquely owned schema, migrates it and runs a separate BEAM/HTTP listener/real Oban queue; it never resets a database. Integration service-script cases also create uniquely named projects/volumes on reserved loopback ports; they must never stop or reset your shared football_market_local project. External football access and production credentials are not needed. Do not supply secrets through command arguments or enable browser tracing/screenshots/debug output.

After implementation, review the explicit inventory diff and execute:

```sh
python3 scripts/test_inventory.py check
sh scripts/test_profile.sh unit
sh scripts/test_profile.sh integration
sh scripts/test_profile.sh e2e
```

Each profile must report matching expected/discovered/executed/passed totals and complete only for its assigned cases. Unit/integration retain their old ExUnit ownership. E2E signs in through the form, observes the connected Portfolio shell, signs out, exercises invalid/expired recovery, then requests deterministic synchronization through the trusted local interface, waits for real durable completion and verifies catalog identities via authenticated HTTP. Invalid scope, missing API auth and invalid page size leave state unchanged; replay exposes no duplicate identities. No charts or conditional orders are expected.

For final developer evidence, freeze source/design edits and run each check ID in verification.json using `python3 scripts/agentflow_check.py CHECK_ID --reuse`, in manifest order. This replaces the direct profile demonstration above; do not run both forms as additional final gates. Service-dependent checks and E2E always execute fresh. Unit/integration/E2E each execute once per final evidence cycle. Do not add the historical combined CP1 report. QA independently repeats checks without --reuse. Required quality baseline and Sonar categories remain in CI; the new End-to-end profile job must also pass.

Missing prerequisites, wrong database, empty discovery, skip, child interruption or sync timeout must produce failure with only a safe category and opaque ID. Startup and terminal waits are bounded to 30 seconds; E2E ceiling 180 seconds. See docs/TEST_PROFILES.md (implementation deliverable) for category-specific recovery and inventory updates. Stop after two unchanged failed gate attempts per docs/AGENT_VERIFICATION.md.

For the current dedicated local fixture environment, prepend `/tmp/football-market-elixir-1.20.3-otp-29/bin` to PATH and set `ERL_FLAGS="+S 4:4"`, `POSTGRES_PORT=55432`, `MIX_TEST_PARTITION=task063_20261016`, `MIX_ENV=test` as recorded in current feedback. The manifest carries these development overrides. Do not redirect the shared Compose project or volumes.
