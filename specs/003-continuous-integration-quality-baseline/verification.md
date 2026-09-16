# Development Verification

Verified at `2026-09-15T21:33:27Z` against revision `a7dbc0c0199b6c9bc66ea6fc0e67260ce27cf49f` with PostgreSQL ready on `127.0.0.1:5432`.

## Environment and positive parity (T017/T018)

- `PATH=/private/tmp/elixir-1.20.3-otp29/bin:$PATH ./scripts/check_toolchain.sh` — exit 0; Elixir 1.20.3, Erlang/OTP 29.0.3, ERTS 17.0.6, Mix 1.20.3.
- README-order preparation: `mix deps.get --locked` and `MIX_ENV=test mix deps.compile` — exit 0. Dependency compilation emitted upstream warnings; the project warning-fatal category below remained clean.
- `mix format --check-formatted` — exit 0.
- `MIX_ENV=test mix compile --warnings-as-errors` — exit 0.
- `scripts/ci_unit_tests.sh` — exit 0; 19 tests passed and `FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL` was observed.
- Local commands and `.github/workflows/quality-baseline.yml` use the same three commands in the same order; parity PASS.

## Controlled negatives (T014)

Each fixture was introduced alone, run with the pinned PATH, then removed/restored before the next probe.

| Fixture | Command | Exit | Diagnostic |
|---|---|---:|---|
| Unformatted `lib/ci_format_fixture.ex` | `mix format --check-formatted lib/ci_format_fixture.ex` | 1 | named unformatted file and diff |
| Application unused variable | `MIX_ENV=test mix compile --force --warnings-as-errors` | 1 | named `lib/ci_warning_fixture.ex` warning |
| Test-support unused variable | same compile command | 1 | named `test/support/ci_warning_fixture.ex` warning |
| Test-file unused variable | `MIX_ENV=test mix test --warnings-as-errors` | 1 | suite aborted after warning |
| Failing assertion | `scripts/ci_unit_tests.sh` | 3 | named failing test and assertion values |
| Renamed sentinel marker | `scripts/ci_unit_tests.sh` | 1 | marker-not-observed error after 19 passing tests |

Restoration: fixture paths are absent, the sentinel contains its canonical marker, the final positive suite passed, and `git diff --check` exited 0.

## Contract, regression, and scope audit (T019/T020)

- Ruby YAML parse — exit 0.
- `MIX_ENV=test mix test test/ci/quality_baseline_contract_test.exs` — exit 0; 4 passed.
- `test/scripts/ci_unit_tests_test.sh` — exit 0; wrapper contract PASS.
- `python3 test/scripts/workflow_artifact_probe_test.py` — exit 0; 3 passed, preserving Agentflow 2.2.1 completed-task artifact enforcement.
- Final diff reviewed against `spec.md`, `plan.md`, `contracts/quality-baseline.md`, `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, and `docs/CHECKPOINTS.md`: no product/domain/persistence/provider behavior or architecture deviation; no secret, live provider, extra quality category, coverage, SonarCloud, deployment, release, E2E, or architecture-check enforcement was added.

Hosted PR-head, merged-`main`, and cold-cache evidence remain post-publication obligations.
