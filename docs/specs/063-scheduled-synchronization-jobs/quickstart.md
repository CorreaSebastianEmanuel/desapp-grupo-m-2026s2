# Validation guide — TASK-019

This is a plan for implementation validation, not evidence of executed behavior. Existing provider and ingestion contracts remain authoritative. Use fixtures only; no live activation or source credentials.

## Prerequisites

Use Elixir 1.20.3 / OTP 29.0.6. TASK-018 feedback identifies `/private/tmp/task018-elixir-1.20.3/bin` as an available corrected toolchain; verify availability with scripts/check_toolchain.sh, or install the repository-pinned toolchain. Prepend that directory to PATH when present and use a non-login shell so PATH is retained. Do not store a machine-specific PATH in verification.json or repurpose HOME/CODEX_HOME.

Install locked dependencies after implementing the dependency task (`mix deps.get`); start existing services with `sh scripts/local_services.sh start`, run `sh scripts/local_services.sh ready`, and prepare ONLY the guarded test database with `MIX_ENV=test mix test.prepare`. Never reset local volumes or use production credentials. Browser prerequisites for the existing integration profile remain required: Node 24, `npm ci --prefix tools/openapi` and its pinned Playwright Chromium installation per existing OpenAPI tooling documentation. Missing prerequisites are blockers, not skipped tests.

## Authoritative acceptance commands

After all source and design edits, execute every verification.json check with `python3 scripts/agentflow_check.py CHECK_ID --reuse` in manifest order. Runtime/service checks disallow reuse. The helper may store evidence in ignored run directories; do not inspect workflow history. Stop and diagnose after two failures with unchanged inputs, recording duration and evidence. Earlier RED development runs are targeted to the new failing tests; successful final profile runs are not repeated without changed inputs or a concrete risk.

The manifest invokes toolchain, local services readiness, application-client service verification, formatting, compilation, unit and integration profiles, actual runtime assertions, and whitespace. Each full profile runs once per final source/design fingerprint. Do not add mix test.cp1_coverage or a duplicate unfiltered full suite. Preserve existing CI and coverage infrastructure. No source mutation is allowed during final validation.

The runtime check invokes `MIX_ENV=test mix run -e 'FootballMarket.Synchronization.RuntimeProbe.run!()'`. This implementation artifact must fail unless PostgreSQL responds, the actual loopback listener becomes ready within a bounded deadline and all HTTP assertions pass. It starts its own isolated runtime/listener, uses fixture data and ephemeral test credentials, and tears down only its owned resources. Confirm list/detail 200 + JSON content type + persisted player identity/body during queued work and after safe source failure, unauthorized 401 + WWW-Authenticate, missing player 404 + safe error, and zero provider calls caused by reads. Credentials never appear in output. Redis absence is tested with an isolated runtime whose cache points to an unavailable port; do not stop shared services to prove optional-cache behavior.

## Acceptance scenario map

All named files below are under `test/football_market/synchronization/` unless a full path is given. Test outcomes are authored independently in `test/fixtures/synchronization/expected.exs`; no expectations computed by the production retry/scheduler/canonicalizer. Module tags select exactly one profile: pure input/policy are unit; all database/runtime tests are integration. RuntimeProbe is under test/support, outside ExUnit discovery.

| Scenario | Concrete assertions / planned file |
|---|---|
| US1.1 | request_test.exs: persisted run/job survives requester death; no provider work before acceptance; execute fixture and confirm counts/reference |
| US1.2 | inspection_test.exs: changed/unchanged/replay and complete empty success, attribution, replay historical counts versus zero applied counts |
| US1.3 | input_test.exs + request_test.exs: invalid scope/source/policy/runtime contract makes no executable work and zero retrieval; malformed scraper runtime rejects both initial and manual triggers |
| US1.4 | request_test.exs: unavailable job store returns no usable ID; no catalog mutation |
| US1.5 | integrity_test.exs + RuntimeProbe: queued/failed source cannot affect local list/detail; zero read-triggered calls |
| US2.1 | scheduler_test.exs: exact due UTC per configured scope and scheduled origin, persisted association; invalid effective runtime rejects configuration and persisted due admission without jobs, restoring original source admits the due occurrence |
| US2.2 | scheduler_test.exs: disabled/unconfigured/no-catalog cases create no jobs or startup import; removing a configured key disables its persisted schedule without cancelling accepted work |
| US2.3 | scheduler_test.exs: five missed instants yield only latest per enabled scope; superseded evidence, no pre-enable backfill |
| US2.4 | scheduler_test.exs: repeated concurrent due admissions across runtime restart and terminal completion yield no new run |
| US2.5 | scheduler_test.exs: disabling prevents future admissions, accepted work/retries continue; re-enable and exact boundary begin new interval |
| US3.1 | concurrency_test.exs: ten real distinct-backend mixed-trigger admissions yield one active run and one execution |
| US3.2 | concurrency_test.exs: conflicting source/fixture/instructions never mutate active run; reordered equivalent instructions coalesce |
| US3.3 | retry_test.exs: same run, numbered attempts, persisted deadline, success after retry and retained safe failure |
| US3.4 | policy_test.exs + retry_test.exs: three begun attempts, waits >=60/300s, never fourth; new manual run after terminal |
| US3.5 | retry_test.exs: each closed non-retryable category stops first; no fallback; unknown failure safe terminal |
| US3.6 | recovery_test.exs: stop and restart actual worker/Oban/dispatcher plus disposable BEAM runtime against same test DB; queued/retry/executing survive, delays/budget retained |
| US3.7 | recovery_test.exs + test/football_market/catalog/ingestion/delivery_receipt_test.exs: crash before/after publication and during completion on attempt three; receipt confirms without retrieval or absent evidence ends exhausted/unconfirmed; no fabricated success |
| US3.8 | integrity_test.exs + RuntimeProbe: absent/reconnected isolated Redis loses no admission/history/correctness |

Additional critic regressions: scheduler_test.exs holds incompatible work through five due instants, restarts, and only admits the latest after release; an equivalent absorbed occurrence is never re-admitted after failure. integrity_test.exs changes fixture bytes/instructions behind stable references and revokes access without changing identity: terminal safe rejection, no mutated inputs, no unauthorized call. recovery_test.exs drops the guard connection while old retrieval is paused, revokes its fence, then releases it: old publication rejected; already-confirmed publication remains discoverable. Verify no partial domain writes at every failpoint.

## Requirement and invariant map

| IDs | Test evidence in profiles / runtime |
|---|---|
| FR-001–003, SC-001 | request/inspection/input tests; retained provider and ingestion regressions; receipt tests |
| FR-004–005, SC-002 | migration/concurrency/recovery/integrity tests; PostgreSQL uniqueness, separate scopes/budgets |
| FR-006–007, SC-003 | scheduler/input tests; controlled UTC and durable generations/occurrences |
| FR-008–009, SC-006 | inspection/recovery tests; safe durable history, pagination/invalid queries, no secrets/raw exceptions |
| FR-010–011, SC-004 | policy/retry/recovery tests; closed classifications, ceiling provider milliseconds, positive finite policy and restart waits |
| FR-012 | concurrency/policy/recovery tests; queue/global slots bounded, sleeping retries release capacity, different scopes progress |
| FR-013, SC-005 | receipt/recovery/migration tests; prefix correctness, atomic failure rollback, no pruning, final-attempt lost completion |
| FR-014, SC-007 | integrity/input tests and retained scraper/provider suites; zero live calls, no credentials, revoked access denied; RuntimeProbe |
| FR-015–016 | scope/integrity tests and every scenario above; unchanged market, immutable quote history and performance state |

Snapshot financial/token/quote/performance table rows before/after fixtures; assert exact equality, token supply stays 100 and monetary types stay exact. History is metadata, not financial audit mutation. Provider failures preserve local data. Catalog reads never retrieve. Catalog completion makes no statistics freshness, quote, issuance or conditional-order claim. Prefix migration regression uses an isolated schema with a different search_path and cleans up only that schema; no global migrations rollback.

## Handoff protocol

### Local Docker connectivity recovery

Container health is not sufficient: verify application-client access from the host. On 2026-10-15 both containers answered internal probes while host PostgreSQL and Redis connections timed out. Restarting the containers alone did not repair this; restarting Docker Desktop and starting the existing project services restored access without deleting volumes. After service readiness, `MIX_ENV=test mix infrastructure.verify` returned PostgreSQL OK and Redis OK. Diagnose this distinction before changing application connection settings. Check other running containers before restarting Docker Desktop; retain failed check history.

For this local run the pinned Elixir installation is `/private/tmp/task019-elixir-1.20.3/bin`; preserve `/usr/local/bin` in PATH for Erlang. This temporary location is operator setup, not a committed application dependency. Re-run canonical preflight against the recovered services and the updated operator instructions before implementation.

Implementation completes all non-gate tasks and writes handoffs/develop.md with evidence references. Run `python3 scripts/workflow_artifact_probe.py develop --readiness` before QA. QA reruns every applicable check independently using `--stage qa` without reuse; final review uses fresh QA evidence and targeted risk checks. Both require terminal `Verdict: PASS`. No acceptance commands were run by architecture, and CP2 browser E2E/charts/orders remain separately owned.

## Implemented operator and test details

Load stable source entries in `config/synchronization.exs` under `FootballMarket.Synchronization`: a safe string reference maps to `provider`, `runtime` and a readable `fixture_path` whose bytes are pinned at admission. Production accepts the existing scraper boundary; test adapters exist only in the test build. Reconciliation instructions are explicit typed request inputs, persisted canonically; changing effective provider configuration or fixture/instruction material cannot alter accepted work. Live access remains denied by the existing provider controls.

Each `schedules` entry is `{config_key, definition}` with `scope`, `source_ref`, optional fixture/instructions/policy and `recurrence`; scheduling requires global `enabled: true` and an enabled valid definition. Omitted recurrence is daily midnight UTC. Use the trusted facade's `configure_schedule/2`, `request_catalog/2`, `get_run/1` and `list_runs/2`; requests never accept provider modules or runtime callbacks. Dispatcher failures remain inspectable in its last result; automatic tick failures emit a static safe warning.

The runtime probe creates and removes only its owned schema/listener/Redis container. Docker must be accessible to run the exact cached compose Redis image. Its disposable BEAM helper is in `test/support/synchronization/case.ex`; third-attempt completion failure rolls back bookkeeping while retaining a confirmed ingestion receipt. The probe asserts real Oban execution, scheduled-generation preservation across application restart, PostgreSQL readiness, HTTP JSON/auth/error bodies, no read-triggered retrieval, finite crash recovery and unchanged financial/statistical rows. Additional nonempty balance/issuance/quote/performance sentinels are exercised across all triggers and retries in `integrity_test.exs`.

Use Node 24's installed bin directory alongside the pinned Elixir/Erlang PATH. `browser_preflight` checks the actual Node major version and launches Chromium with an assertion-based page probe. All developer verification commands still run through the Agentflow helper; QA runs fresh independent evidence.
