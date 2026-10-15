# Independent QA — TASK-019 CI repair

2026-10-15. Fresh QA session inspected AGENTS.md, product/architecture/checkpoints, constitution, canonical specification/plan/tasks/manifest, and current repair diff. No implementation edits, delegated work, Agentflow invocation, receipt reuse or workflow-run inspection.

## Repair assessment

The provider dependency guard now derives exact Oban approval from the committed synchronization plan. Required Oban `~> 2.24.2`, discovery inventory, changed-version, duplicate-Oban and unrelated-dependency rejection assertions remain executable. Ignored session metadata no longer controls dependency approval. Independently executed `mix test test/football_market/providers/scope_test.exs:140 --warnings-as-errors` with metadata absent and with a stale TASK-013 pointer: **one passed in each case**. Original metadata restored byte-for-byte. Direct command outputs: `/tmp/task019-qa-scope-missing.log`, `/tmp/task019-qa-scope-stale.log`; command statuses/digests: `/tmp/task019-qa-metadata-results.json`.

The catalog query-plan repair changes only the bulk seed INSERT timeout to 60 seconds. The 99,999 inserted rows, five filter-plan assertions and ANALYZE remain unchanged. Exact catalog/query_test.exs allowances in provider/statistics/market scope guards match the revised plan; unknown/nil features and unplanned production paths remain rejected by synchronization scope regressions. No production behavior/API/schema changed.

## Fresh verification

Executed every manifest command independently using `python scripts/agentflow_check.py CHECK --stage qa`, without reuse. Environment: pinned Elixir 1.20.3/OTP29, `POSTGRES_PORT=55432`, `MIX_TEST_PARTITION=task019_20261015`, `ERL_FLAGS='+S 4:4'`; dedicated pinned PostgreSQL17.6, configured Redis, Node24 and Chromium. These settings avoid the host PostgreSQL18 compatibility/pool issue without changing shared data.

| Manifest check | Seconds | Result |
|---|---:|---|
| toolchain | 0.673 | PASS |
| browser_preflight | 0.357 | PASS |
| services | 0.123 | PASS |
| service_clients | 0.504 | PASS |
| format | 0.518 | PASS |
| compile | 0.384 | PASS |
| unit | 15.876 | PASS |
| integration | 102.917 | PASS |
| runtime_http | 4.157 | PASS |
| whitespace | 0.004 | PASS |

All ten commands exited zero on the first QA attempt. Canonical `handoffs/check-CHECK.json` receipts contain fresh stage `qa`, exact evidence references, digest and elapsed time; `handoffs/check-attempts-qa-CHECK.json` records zero consecutive failures. No prohibited evidence directories were inspected. Manifest command status capture: `/tmp/task019-qa-manifest-results.json`.

All receipts retain source fingerprint `9fa66bd05011b9ae71558afa42c02ebff446a7fd227ddd7dafdf850eec81c24e` and input fingerprint `edc4541948aef4b68bbec930b39d485a5547b35ea4262813d499f1854c9318d3`; before/after source and check inputs were unchanged. Test totals are not inferred from profile-file audit counts.

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
