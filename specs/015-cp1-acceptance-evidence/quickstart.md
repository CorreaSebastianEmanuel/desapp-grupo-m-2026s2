# Quickstart: Validate CP1 Acceptance Evidence

## Prerequisites

- Clean checkout of the candidate commit.
- Exact Elixir 1.20.3 / OTP 29.0.6 and Node 24.21.0 from `.tool-versions`; Python 3, curl, unzip, Docker, locked Mix/npm dependencies, and installed Playwright Chromium. CI uses PostgreSQL 16; local services use the repository-pinned PostgreSQL 17.6 image.
- Local development/test configuration only; no production credential, data, or provider access.

## Activate the toolchain

With an installed version manager supporting `.tool-versions`, install its three entries and activate the repository versions. Verify with `scripts/check_toolchain.sh --with-node`; the `--with-node` command rejects a different BEAM version or Node major. The default BEAM-only check preserves the locked quality baseline, which installs Node later.

The following is the explicitly tested activation when the system Elixir differs. OTP 29.0.6 and nvm are prerequisites:

```sh
mkdir -p tmp/cp1-toolchain
curl --fail --silent --show-error --location \
  https://github.com/elixir-lang/elixir/releases/download/v1.20.3/elixir-otp-29.zip \
  --output tmp/cp1-toolchain/elixir.zip
unzip -q -o tmp/cp1-toolchain/elixir.zip -d tmp/cp1-toolchain/elixir
export PATH="$PWD/tmp/cp1-toolchain/elixir/bin:$PATH"
nvm install 24.21.0
nvm use 24.21.0
scripts/check_toolchain.sh --with-node
mix deps.get --locked
MIX_ENV=test mix deps.compile
npm ci --prefix tools/openapi
tools/openapi/node_modules/.bin/playwright-core install --only-shell chromium
```

On Linux runners, add Playwright's `--with-deps` option for browser system libraries. First dependency acquisition and service startup precede the demo clock.

## Local preflight

```sh
./scripts/check_toolchain.sh --with-node
./scripts/local_services.sh start
MIX_ENV=test mix compile --warnings-as-errors
mix format --check-formatted
scripts/ci_unit_tests.sh
mix test.unit
mix test.integration
mix test.cp1_coverage
```

Run the acceptance evaluator's fixture tests, then execute the documented demo command twice against its isolated disposable database. The first preparation creates or converges the 44 seed-owned records; the second must preserve the same 5 leagues, 5 seasons, 10 teams, 4 positions, and 20 players without duplicates. Use a fresh documented demo email per run.

```sh
python3 -m unittest test/ci/cp1_acceptance_test.py
MIX_ENV=test mix test test/ci/cp1_demo_contract_test.exs test/ci/cp1_workflow_contract_test.exs
export CP1_DEMO_CONFIRM_DISPOSABLE=yes
export CP1_DEMO_DATABASE_URL=ecto://postgres:postgres@127.0.0.1/football_market_test_cp1_demo
export CP1_CANDIDATE_SHA="$(git rev-parse HEAD)"
scripts/cp1_demo.sh --receipt tmp/cp1-demo-first.json
scripts/cp1_demo.sh --receipt tmp/cp1-demo-second.json
```

The disposable database must be named `football_market_test_cp1_demo`; explicit confirmation and full current HEAD SHA are mandatory. The harness creates/migrates only the guarded `_cp1_demo` partition. Its URL must match the local `POSTGRES_*` configuration; remote hosts are rejected. Stop unrelated project processes before running.

The private Elixir runner seeds twice and queries actual persisted counts and relationships. A shared SQL sandbox transaction then exercises fresh user creation, duplicate rejection, password login, and API-key management through the existing account commands. Catalog and documentation journeys use real loopback HTTP and the browser UI against that transaction. Transient users and keys roll back; deterministic seed data remains. Repeat the same commands for a fresh identity without resetting any database. The harness removes its owned temporary directory and replaces only its specified receipt path.
Expected demo receipts cover user creation and duplicate rejection, API-key one-time issuance/verification/revocation, JWT valid/invalid login, both protected credential forms, catalog list/detail/continuation, all three filters singly and together, empty/invalid results, public OpenAPI JSON/UI, and protected UI requests. Receipts contain behavior IDs, never credentials or raw traffic.

Run the validator against the private receipts. Before publication it should render a revision-bound preflight record; a working-tree snapshot must say `NOT PASSING`, even when checks succeed.

```sh
python3 scripts/cp1_acceptance.py validate \
  --manifest config/cp1_acceptance.json \
  --receipts <downloaded-private-receipts.json> \
  --candidate-sha "$(git rev-parse HEAD)" \
  --local-evidence <downloaded-local-artifact-directory> \
  --output tmp/cp1-acceptance/preflight
```

Missing or invalid evidence produces a safe record with all ten obligations non-passing and a nonzero exit. Fixture evaluation belongs to the Python suite, which supplies a synthetic candidate; fixtures cannot establish real acceptance.

Both demo receipts must have the exact schema, complete ordered behavior IDs, two exact seed assertions, no provider access, elapsed time at most 1200 seconds, and committed source identity before hosted PASS. Local dirty-tree receipts explicitly carry `working-tree-snapshot` provenance and a source fingerprint, and cannot establish hosted acceptance. The fingerprint covers application, tests, scripts, configuration, workflows, locked browser tooling, and build inputs; it excludes feature discussion and workflow logs.

Coverage validation requires the matching base SHA, an empty committed diff, the current source-inventory hash and complete source scope, both complete nonempty profile receipts, and accessible summary/source pages. The workflow scans and stages only `manifest.json`, `report.html`, the declared inventory line-status pages, and the two demo receipts before upload and final atomic publication. Native Mix HTML source listings are excluded. The final evaluator requires this bundle and matches its content against the aggregate receipts; missing evidence cannot yield a committed PASS. Referenced JSON evidence is parsed and scanned before publication.
Expected fixed demo behavior IDs are `SEED_FIRST`, `SEED_SECOND`, `SEED_RELATIONSHIPS`, `USER_CREATE`, `USER_DUPLICATE`, `JWT_VALID_LOGIN`, `JWT_INVALID_LOGIN`, `JWT_PROTECTED_ACCESS`, `API_KEY_ISSUE`, `API_KEY_VERIFY`, `API_KEY_PROTECTED_ACCESS`, `API_KEY_REVOKE`, `API_KEY_REVOKED_REJECTED`, `CATALOG_LIST`, `CATALOG_DETAIL`, `CATALOG_CONTINUATION`, `CATALOG_FILTER_LEAGUE`, `CATALOG_FILTER_TEAM`, `CATALOG_FILTER_POSITION`, `CATALOG_FILTER_COMBINED`, `CATALOG_EMPTY`, `CATALOG_INVALID`, `OPENAPI_JSON_PUBLIC`, `OPENAPI_UI_PUBLIC`, `OPENAPI_JWT_REQUEST`, and `OPENAPI_API_KEY_REQUEST`.

## Hosted final validation

After reviewed changes are committed and published, inspect the exact-head PR checks. After merge, use the `CP1 acceptance` workflow run for the integrated `main` SHA. It must rerun checks, require exact workflow paths/names, repository identity, `main` branch and a governing push/dispatch event, correlate the completed Sonar `main` analysis to that SHA, and publish `cp1-acceptance-<sha>`.

Open `acceptance.md` from that artifact and confirm ten entries, direct evidence references, one candidate SHA throughout, safe receipts, and overall `PASS`. Missing/inaccessible artifacts or any mismatched SHA mean NOT PASSING; never substitute an older green run.

## Timing and cleanup

For the 20-minute measure, start immediately before isolated database preparation and stop after the second seed-invariant assertion and safety scan. Dependency acquisition, first service/image startup, hosted latency, and teardown are excluded. Use the demo's scoped cleanup command only for its disposable database and private temporary directory.

If a safety scan fails, do not open or publish the capture. Delete staging, revoke/rotate affected credentials, correct the capture boundary, and rerun from a clean isolated state.

## Latest development verification — Q1/Q2, 2026-10-03

After repairing governing manifest mappings and the seed's delayed-log failure boundary:

- `python3 -m unittest test/ci/cp1_acceptance_test.py`: 28 PASS. The new remapping/criteria/traceability assertions failed before implementation.
- `MIX_ENV=test mix test test/mix/tasks/catalog.seed_test.exs`: 13 PASS. The delayed retry-output regression failed before implementation.
- `scripts/ci_unit_tests.sh`: 196 PASS, 4 performance exclusions, discovery marker present; seed 94793. This replaces the failed QA baseline, not merely its isolated rerun.
- `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, `git diff --check`: PASS.
- `mix test.cp1_coverage`: complete, profiles audited 21 unit/32 integration files; 20 sources. [Latest coverage](../../cover/cp1/95bfd0dd0fad95395155e1433f3f9b65b09c38a0-20261003T142839Z-26209/report.html) has a sibling manifest. A disposable intent-to-add index included untracked inputs without changing the real index.
- `CP1_REAL_COVERAGE_DIRECTORY=cover/cp1/95bfd0dd0fad95395155e1433f3f9b65b09c38a0-20261003T142839Z-26209 python3 -m unittest test/ci/cp1_acceptance_test.py`: 28 PASS with actual generated HTML staging/publication.
- Two consecutive `scripts/cp1_demo.sh` executions: PASS, 6 seconds each. Receipts `tmp/cp1-demo-q1q2-first.json` and `tmp/cp1-demo-q1q2-second.json` match the current implementation fingerprint, all 26 behaviors, invariant counts and working-tree provenance. They cannot establish hosted CP1 PASS.

Only feature evidence/handoff updates followed these snapshots. Independent QA and final review remain required. The saved run remains at its QA gate; its state and feedback limit were not edited.

## Prior B1–B4 development verification, 2026-10-03

These are actual command outcomes for the resumed B1–B4 implementation. Local evidence is a working-tree snapshot; no hosted CP1 PASS is asserted.

- PASS — `scripts/check_toolchain.sh --with-node`: Elixir 1.20.3, OTP 29.0.6 / ERTS 17.0.6, Node 24.21.0. The Python suite verifies rejection of Node 20 and preservation of the default BEAM-only baseline check.
- PASS — `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, `sh -n scripts/cp1_demo.sh scripts/check_toolchain.sh`, and `git diff --check`.
- PASS — `scripts/ci_unit_tests.sh`: 195 passed, 4 excluded, discovery marker present. `sha256sum -c test/ci/fixtures/quality-baseline.sha256` confirms the locked workflow is unchanged.
- PASS — `mix test.unit` (21 audited files), `mix test.integration` (32 audited files), and the final coverage execution of both complete profiles.
- PASS — `MIX_ENV=test mix test test/ci/cp1_demo_contract_test.exs test/ci/cp1_workflow_contract_test.exs`: 7 tests.
- PASS — `npm test --prefix tools/openapi`: 2 tests; `node tools/openapi/validate.mjs priv/static/openapi.json`.
- PASS — `mix test.cp1_coverage`, using a temporary `GIT_INDEX_FILE` with intent-to-add entries for untracked repository inputs. The real index remained unchanged. Final [coverage summary](../../cover/cp1/95bfd0dd0fad95395155e1433f3f9b65b09c38a0-20261003T135545Z-21849/report.html) and sibling `manifest.json` declare working-tree provenance, 20 sources, and both complete profile receipts. Only evidence documentation and handoff updates followed this snapshot.
- PASS — final consecutive `scripts/cp1_demo.sh` executions: 7 seconds each. Both receipts match the final implementation fingerprint, validate with `require_committed=False`, declare `working-tree-snapshot`, contain all 26 behavior IDs, retain exact double 5/5/10/4/20 assertions, and declare no provider access. Capture locations: `tmp/cp1-demo-first.json`, `tmp/cp1-demo-second.json`.
- PASS — `CP1_REAL_COVERAGE_DIRECTORY=cover/cp1/95bfd0dd0fad95395155e1433f3f9b65b09c38a0-20261003T135545Z-21849 python3 -m unittest test/ci/cp1_acceptance_test.py`: 26 tests. This exercises actual generated HTML staging/publication, branch/workflow identity, mandatory matching local evidence, inaccessible references, quoted secret keys, JWT/sentinels, and safe failure output. The HTML regression changes identity only in a disposable synthetic copy; original evidence is untouched. CI sets this variable automatically after coverage.

Before implementation, the new adversarial regressions failed for missing workflow identity, optional local evidence, quoted secret fields, and broad scanning of native source HTML. Two intermediate full coverage attempts failed with `profile-integration`; neither is acceptance evidence. An isolated coverage run passed 142 integration tests, the wrapper passed independently, and the final complete command passed. QA must rerun the complete sequence rather than infer success from isolated results. Raw child captures and diagnostics were private and removed. No commit, push, PR, merge, or hosted acceptance was performed.
