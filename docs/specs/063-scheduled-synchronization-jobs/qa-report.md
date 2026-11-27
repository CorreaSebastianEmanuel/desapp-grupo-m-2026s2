# Independent QA — TASK-019 unfiltered CI discovery repair

2026-10-15. Fresh independent QA read AGENTS.md, product/architecture/checkpoints, constitution, canonical specification/plan/tasks/manifest and current repair diff. No implementation edits, delegation, Agentflow invocation, receipt reuse or prohibited workflow-run inspection.

## Repair assessment

The exact `test/fixtures/synchronization/expected.exs` path is added to Mix's ignored non-test inventory and the provider guard's expected list. Independently inspected the fixture: it is a bare expected-outcome map without any test module. `test/support/synchronization/fixtures.ex` explicitly loads it through `Code.eval_file/1`, so fixture assertions remain active. No actual test is ignored. Exact Oban version, duplicate-Oban and unrelated dependency rejection assertions remain in the provider guard. The existing missing/stale metadata repair and catalog fixture INSERT timeout are unchanged from independently verified commit9008f36.

The revised manifest adds actual `sh scripts/ci_unit_tests.sh` discovery, mapped to FR-016. That script executes unfiltered `mix test --warnings-as-errors`, propagates failure and requires the complete-discovery sentinel. This detects the concrete fixture warning that explicit unit/integration file lists missed. The later dated plan explicitly authorizes this additional check; earlier general guidance against duplicate suites does not remove this concrete regression check. No production API, schema, provider or domain behavior changes.

## Fresh verification

Executed all eleven manifest commands independently using `python scripts/agentflow_check.py CHECK --stage qa`, without reuse. Environment: pinned Elixir1.20.3/OTP29 PATH, `POSTGRES_PORT=55432`, `MIX_TEST_PARTITION=task019_20261015`, `ERL_FLAGS='+S 4:4'`; pinned PostgreSQL17.6, Redis, Node24 and Chromium. Checks ran sequentially after developer release to avoid shared-database contention.

| Manifest check | Seconds | Result |
|---|---:|---|
| toolchain | 1.966 | PASS |
| browser_preflight | 0.343 | PASS |
| services | 0.126 | PASS |
| service_clients | 0.511 | PASS |
| format | 0.521 | PASS |
| compile | 0.389 | PASS |
| unit | 15.944 | PASS |
| integration | 111.359 | PASS |
| runtime_http | 3.433 | PASS |
| ci_discovery | 91.808 | PASS |
| whitespace | 0.005 | PASS |

All commands exited zero on their first QA attempt. In particular the exact unfiltered CI command passed with warnings treated as errors and its discovery sentinel observed. Canonical `handoffs/check-CHECK.json` receipts record stage `qa`, evidence references/digests and elapsed times; `handoffs/check-attempts-qa-CHECK.json` record zero consecutive failures. Status capture: `/tmp/task019-qa-discovery-manifest-results.json`. Prohibited evidence directories were not inspected, and test totals are not inferred from command status or file inventory.

All receipts bind unchanged source fingerprint `8d835de6e1e90ff1ffc042f333c5dac5d47fd500646325380171a31af7116f04` and design/input fingerprint `fb0391a7bb1f074902cf9473e0cddc8aac85a25c087cda651f27261b178970b8`. Report/handoff output updates do not alter those fingerprints.

## Acceptance challenge

The independently rerun unit/integration profiles cover all 18 numbered scenarios; runtime_http adds actual listener, restart and isolated Redis assertions. Mapping inspected against current maintained test cases:

| Scenarios | Freshly exercised maintained coverage |
|---|---|
| US1.1–1.2 | request/concurrency/inspection: durable asynchronous admission; acceptance, changed/unchanged/replay attribution and counts |
| US1.3–1.4 | input/request: invalid scope/source/runtime/policy rejected before work; unavailable store yields no usable identifier |
| US1.5 | integrity/runtime: queued or failed synchronization leaves local reads available without provider calls |
| US2.1–2.2 | scheduler/recovery: configured UTC due occurrence, default disabled and removed/unconfigured scopes |
| US2.3–2.4 | scheduler/concurrency/runtime: latest missed occurrence only; durable due/coalesced/terminal deduplication across restart |
| US2.5 | scheduler/recovery: disable stops new admission and retains accepted work |
| US3.1–3.2 | concurrency/request/input: ten independent connections, equivalent triggers, incompatible source/fixture/instructions preserve existing run |
| US3.3–3.5 | retry/policy: persisted waits/provider guidance, finite three-attempt budget, explicit first-attempt terminal categories |
| US3.6–3.7 | recovery/delivery_receipt/runtime: queued/retry/interrupted recovery, retained budget, fenced publication and confirmed lost completion |
| US3.8 | runtime: absent/cleared/reconnected isolated Redis preserves durable jobs/history |

Integrity/scope regressions additionally retain zero live-access authorization, safe redaction, unchanged nonempty financial/quote/statistics state and domain boundaries. This repair does not claim browser E2E, charts, conditional orders or complete CP2 delivery. Earlier adversarial evidence remains historical and is not represented as freshly executed here.

Blockers: none. Fresh independent final review remains required.

Verdict: PASS
