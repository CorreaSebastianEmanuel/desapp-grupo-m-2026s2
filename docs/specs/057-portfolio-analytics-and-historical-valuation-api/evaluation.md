# Independent evaluation — TASK-057

Evaluated on 2026-10-29 by a separate agent against the compact specification,
the approved plan, repository architecture, and the actual diff from
`origin/main` at `edc5d8889bd3b27f42dfefc9947cbccdd40f49df`.

## Outcome and review

All acceptance criteria are satisfied. No blocking findings remain.

- Both authenticated endpoints derive ownership from the actor, preserve JWT
  and API-key authentication, reject invalid date inputs, and return private,
  non-cacheable financial data with sanitized storage failures.
- Historical replay includes opening trades and lifetime flows, retains realized
  profit after full sales, separates flows from profit, and carries eligible
  quotes forward without admitting future effective prices. Missing quotes
  produce explicit gaps rather than invented zero values.
- The extracted ledger preserves TASK-032's transaction ordering, 200-digit
  local Decimal context, and half-up 18-place weighted-average rule. Current
  portfolio behavior remains covered by its existing regressions.
- The persistence adapter uses one read-only repeatable-read snapshot and
  batched reads. The separate-connection concurrency test proves that a quote
  committed between reader queries cannot enter that response. Query-count and
  persisted-state assertions cover read-only behavior and bounded query count.
- Web rendering, domain accounting, and persistence remain separated. No new
  dependencies, migrations, provider calls, or financial/job writes are added.
  The redundant outer Decimal wrapper was removed without changing accounting.
- UTC final-microsecond/leap-day boundaries, partial today, complete quote
  tie-breaking, large values, hostile Decimal contexts, weighted purchases,
  sales, repurchase, owner isolation, and actual authenticated HTTP execution
  have automated coverage.

## Executed checks

Checks ran sequentially using Elixir 1.20.3 / OTP 29.0.6, PostgreSQL and Redis,
with the QA partition `task057qa`. No task orchestration was invoked.

| Command/check | Result |
| --- | --- |
| `mix format --check-formatted` | PASS; repeated after the repair, 0.61 s |
| `mix compile --warnings-as-errors` with `MIX_ENV=test` | PASS; repeated after the repair, 0.39 s |
| `sh scripts/credo_ci.sh` | PASS; final source-bound run 6.94 s, 615 maintained files and 28 explicit exclusions |
| `node tools/openapi/validate.mjs` | PASS, 0.16 s |
| `mix test.prepare` | PASS, 2.86 s |
| `mix test test/ci/sonarcloud_contract_test.exs test/ci/quality_baseline_contract_test.exs test/ci/credo_ci_contract_test.exs test/ci/test_profiles_quality_contract_test.exs` | PASS, 26 tests, 1.63 s |
| `python3 -m unittest discover -s test/scripts -p '*_test.py'` | PASS, 363 tests, 68.82 s command time |
| `sh scripts/test_profile.sh unit` | PASS, 660/660 cases, 146.58 s |
| `sh scripts/test_profile.sh integration` after repair | PASS, 696/696 cases, 676.75 s |
| `sh scripts/test_profile.sh e2e` after repair | PASS, 4/4 cases, 34.40 s |
| `mix test test/football_market_web/openapi_browser_test.exs test/ci/portfolio_analytics_scope_test.exs` after repair | PASS, 3 tests, 3.09 s |

The three genuine profile receipts reconcile expected, discovered, executed, and
passed counts: **1,360 registered cases**. Components are 271 ExUnit / 363 Python /
8 Node / 18 shell unit cases, 687 ExUnit / 9 shell integration cases, and 4 ExUnit
E2E cases. The new portfolio HTTP E2E case is registered as
`d7c4ed83e641de4c93e80682` and is included in the passing E2E receipt.

Evidence is retained locally under `/tmp/task057-qa/`, including command logs,
actual profile receipts, timings, and before/after input hashes. All receipts use
the current test inventory digest
`d5a6f91211e3cc8019b1b3d2a0e3ea08a0865a55aaab1b41b1139066f6d0f70c`.
The final 29-path input snapshot remained unchanged throughout fresh repair
validation, integration, E2E, and final Credo; its aggregate SHA-256 is
`65ca5d80ea2f92affa38cbd46e3884960d9437ca367c833a256296e5922b10cf`.

## Findings and repair evidence

The initial complete integration attempt failed after 632.04 s: 635 regular
ExUnit cases passed and one failed in the existing OpenAPI browser test. Its
exact discovery oracle still required 13 operations after this feature added
two. The builder changed only that browser test adapter to require all 15
distinct operations, with explicit allocation/history lookups, and added its
exact filename to this feature's scope allowance. Existing operation and
uniqueness assertions remain enforced. Independent targeted browser/scope checks
and the fresh complete integration/E2E profiles passed after this repair.

Unit, harness, OpenAPI, and CI-contract results were retained after verifying
that only the integration browser adapter and exact scope-helper allowance
changed; application source, API contract, policy, and inventories were
byte-identical. The changed scope helper's two cases were rerun,
formatting/compilation repeated, and configured Credo rerun on the final inputs.
The earlier copied OpenAPI 503 cache-header/schema mismatch
was also corrected before the frozen checks; actual storage-error HTTP coverage
now pins the sanitized body and `private, no-store` header.

## Delivery compatibility and limits

Independent checks resolved exact TASK-057 branch/spec ownership, validated the
compact specification, reconciled all 643 source inventory roles, and confirmed
high-risk selection of `ci-contracts`, `harness-tests`, `format`, `compile`, and
`unit-profile`. The new E2E allowance is an exact filename; unrelated E2E and
unmapped paths still fail closed. No workflow runs or stage receipts are claimed.

Other backlog tasks are untouched. Existing duplicate TASK-074–076 records and
the repeated `active_run` field in TASK-074 scouting remain outside this change;
this evaluation does not claim repository-wide backlog hygiene is repaired.
Historical values intentionally use currently retained effective facts, and
the documented weighted-average rounding policy remains in force.

This verdict establishes local readiness. The exact published PR head must still
pass hosted `ThinFlow required`, and completion still requires human merge.

Verdict: PASS
