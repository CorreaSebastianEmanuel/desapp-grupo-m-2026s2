# Test profile audit and usage

## Baseline audit (TASK-063)

Before this change, the default `mix test` run was the sole ExUnit entry point used by `scripts/ci_unit_tests.sh`. `FootballMarket.TestProfileAudit` discovered `test/**/*_test.exs`, required each file's modules to carry one direct `unit` or `integration` tag, and supplied file paths to `mix test --only`. It did not maintain an independent expected population or reconcile individual discovered, started and completed cases. A source audit on 2026-10-16 found 153 ExUnit test files: 53 contain a direct unit module tag and 101 a direct integration module tag, with one file containing both. These are file counts, not case counts; the single mixed file is assigned by module, and native case discovery is required for an exact case inventory.

The baseline native entry points and ownership observed in `.github/workflows/quality-baseline.yml` are:

| Entry point | Baseline scope and assignment | Evidence boundary |
| --- | --- | --- |
| `mix test` via `scripts/ci_unit_tests.sh` | All ExUnit modules selected by the existing `unit` or `integration` tag; existing browser/HTTP tests remain integration by module tag. | The compatibility script checks the profile sentinel and successful summary, not per-case identities. |
| Python unittest discovery under `test/scripts`, pattern `*_test.py` | 24 files and 152 cases (counted with `unittest` discovery, without executing them); workflow, Agentflow, policy and service helper tests. Intended unit ownership. | Baseline workflow runs all together outside ExUnit selection; no independent profile inventory. |
| `npm test --prefix tools/openapi` | `tools/openapi/validate.test.mjs`, 2 top-level Node test cases. Intended unit ownership. | Node test runner result; baseline workflow runs it with OpenAPI contract validation. |
| `sh test/scripts/ci_unit_tests_test.sh` | 18 named fake-child cases in `run_case`. Intended unit ownership. | Standalone shell exit status; no per-case event inventory. |
| `sh test/scripts/local_services_lifecycle_test.sh`, `sh test/scripts/local_services_failure_test.sh` | One lifecycle scenario and two occupied-port failure scenarios, plus helper assertions. Intended integration ownership. | Invoked as integration service regressions; Docker absence currently emits successful `SKIP`, and the baseline had no complete isolated service-component accounting. |

The baseline did not discover these native cases through the ExUnit profile audit. The reviewed assignment rule is: pure runner, workflow, Python, Node/OpenAPI validator and shell contract checks are unit; persistence/HTTP/browser and Docker lifecycle cases are integration; only the new full browser-shell and catalog-sync journeys are E2E. A process exit alone is not case-level proof. Native suite counts above are baseline counts, not yet a committed per-case inventory.

The development environment recorded in current TASK-063 feedback is Elixir 1.20.3 / OTP 29.0.6 from `/tmp/football-market-elixir-1.20.3-otp-29/bin`, Node 24, locked Playwright Core 1.63.0 and installed Chromium. Mix must receive that pinned `PATH` and `ERL_FLAGS=+S 4:4`; the isolated test PostgreSQL 17.6 service is on port 55432 with the `task063_20261016` partition prepared, and Redis is ready on 6379. E2E and integration profile changes must keep their owned schema/resources isolated. The baseline dependency set is pinned by `mix.lock` and `tools/openapi/package-lock.json`; no dependency addition is planned. The CP1 report's provenance binds HEAD, working-tree diff and coverage inventory hashes; its committed inventory controls the denominator and its configured summary threshold remains zero.

The baseline CI contract is `.github/workflows/quality-baseline.yml`: exact BEAM and Node toolchains, PostgreSQL and Redis, formatting, warnings-as-errors compilation, OpenAPI contract validation and validator tests, Python and shell workflow tests, the full unit/integration entry point and Sonar analysis remain required. The separate Sonar workflow retains JavaScript coverage and CP1 analysis. `scripts/coverage_report.sh` owns the CP1 report, uses the committed `config/cp1_coverage_inventory.exs` module/source population, publishes the native report and HTML with provenance, and keeps its threshold at zero. Existing HTTP/browser tests remain integration tests; crossing an application boundary alone does not make them end-to-end.

The native runner audit and case counts are recorded by the committed inventory at `config/test_profiles.json`. See [the feature plan](../specs/065-separate-unit-and-end-to-end-test-profiles/plan.md) and [ADR-0028](adr/0028-independent-test-inventory-and-e2e-profile.md) for the ownership decisions. Toolchain versions and required local services are checked by `scripts/check_toolchain.sh` and `scripts/local_services.sh ready`; no production data or credentials are used.

## Commands

- `mix test.unit` runs only the unit profile.
- `mix test.integration` runs only the integration profile.
- `mix test.e2e` runs only the real browser and durable-worker journeys.
- `python3 scripts/test_inventory.py check` checks source discovery against the reviewed inventory without modifying it.
- `python3 scripts/test_inventory.py update --profile PROFILE` explicitly adds newly discovered cases to a chosen profile; review the resulting diff before committing it.
- `scripts/ci_unit_tests.sh` remains the unit/integration compatibility entry point and emits `FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL` only after both profiles complete.
- `mix test.cp1_coverage` retains the existing CP1 report scope, native report, HTML, provenance and zero threshold. It is not an extra CP2 local gate.

Each profile reports expected, discovered, executed and passed totals and fails closed on assignment, skip, prerequisite, child, timeout or interruption errors. Output and retained summaries contain only safe categories and opaque inventory IDs. Integration's Docker lifecycle tests use invocation-owned resources; they never target the shared `football_market_local` project. E2E uses deterministic fixtures and real browser, HTTP and Oban processing. It does not cover unfinished charts or conditional orders.

When additions span multiple profiles, run the explicit update once for each affected profile. An update reports `status=updated` and the number of pending unassigned additions; it does not claim a complete validation. Existing assignments cannot change through this command. Run `check` afterward to require the complete discovered population. This applies to ExUnit additions as well as native-runner additions.

Each Node test file runs in its own supervised Node process with `--test-isolation=none`. The native runner reports individual cases in that process; profile isolation comes from the supervisor's separate process per file. Port-allocation unit tests use controlled sockets, while integration service setup still binds actual loopback ports and requires real services.

## Reviewed inventory after implementation

| Profile | ExUnit | Python | Node | Shell | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| unit | 190 | 213 | 8 | 14 | 425 |
| integration | 440 | 0 | 0 | 9 | 449 |
| e2e | 2 | 0 | 0 | 0 | 2 |

The committed cases are independent expectations. Validation compiles ExUnit declarations (including generated names), enumerates Python with unittest, validates supported explicit Node declarations, and enumerates named shell cases. Execution uses ExUnit formatter, native Python/Node events and adjacent shell case events. Equal counts with different identities fail. New unsupported/dynamic Node declarations require a reporter/discovery adapter change; they cannot silently pass. Review `python3 scripts/test_inventory.py update --profile PROFILE` diffs explicitly; normal checks do not rewrite this file. Module tags declare new ExUnit ownership. Helper exclusions are reasoned in `config/test_profiles.json`; the offline provider/scraper entry points are nested helpers owned by their existing ExUnit scenarios. The consecutive lifecycle case owns its nested three-cycle acceptance leaf, which is not launched twice.

CI category map: Formatting and warnings-as-errors stay in Quality baseline; OpenAPI document validation stays explicit. Python workflow, shell wrapper, validator Node and workspace Node cases now execute once inside unit. Workflow behavior tests consumes their reconciled component receipts after the complete unit/integration orchestrator. Existing integration HTTP/browser cases stay integration. SonarCloud and its JavaScript/CP1 coverage commands stay unchanged. The new mandatory End-to-end profile job runs only the two complete journeys with the same pinned services, toolchain, Chromium and assets.

Local preflight uses `MIX_ENV=test mix infrastructure.verify` against the configured PostgreSQL partition and Redis, rather than the shared Compose project's container status. This checks the dedicated 55432 database described by current feedback. Runtime also asserts SELECT 1, Redis PING and real Endpoint/browser readiness. Safe failure categories distinguish browser prerequisite, component, ExUnit, inventory/service and timeout failures; opaque discrepancy IDs resolve through the reviewed inventory. Raw child output uses unlinked private captures, and browser artifacts are disabled. Invocation receipts bind the inventory digest and nonce and are removed before discovery begins.

Existing nested Catalog/Statistics committed-race subprocesses receive `PROFILE_CONCURRENCY_POSTGRES_PORT` from the invocation-owned Docker project. Their main integration process continues using its configured partition. This avoids stale historical database ledgers without rewriting or resetting them; the invocation volumes are removed after ExUnit and before publishing completion. Event records carry the invocation nonce, and ExUnit records unexpected profile execution for rejection rather than filtering it away.

Recursive shell discovery includes `test/integration/infrastructure_verify_test.sh` and `redis_disposability_test.sh`. Both execute in the invocation-owned service component, fail if Docker is absent, and emit named case events. Redis disposability selects the configured test partition when MIX_ENV=test. The inventory refresh also reconciles previously authored ExUnit/Python negative cases before the final evidence freeze.

The independent infrastructure CLI regression explicitly uses MIX_ENV=dev inside its owned Docker project: malformed configuration must exercise the independent development probes, rather than the separate test-database fail-fast guard. This does not target the contributor’s development database; the wrapper supplies private ports and volumes. Unfinished shell cases emit only their opaque ID on failure.

Owned schemas are atomically registered before creation in a private per-child resource registry. After a child exits, times out or is terminated, a separate cleanup process validates the test database, partition, invocation nonce and schema prefix before dropping only registered schemas. This fallback works even when the BEAM cannot execute its cleanup block. Integration regressions kill the actual runtime through the supervisor and require an unrelated control schema to survive. Cleanup failures fail the profile with the safe resource-cleanup category.
