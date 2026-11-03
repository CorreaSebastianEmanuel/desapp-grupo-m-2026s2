# Independent evaluation — TASK-084

Reviewed the compact spec, backlog task, REVIEW.md, repository principles, full candidate diff, affected implementation/tests, protected router and OpenAPI paths, and the current ThinFlow receipt. No TASK-084 feedback or previous evaluation exists. Implementation was not modified; no other evaluator was invoked and no workflow logs were inspected.

## Acceptance and evidence

| Acceptance surface | Evidence and assessment |
| --- | --- |
| Every protected operation has reachable UI and supported inputs/details | All 14 OpenAPI paths match the protected router and the matrix's operation families. Context-based UI destinations exist. Overall parity is **not established**: allocation totals disappear for closed portfolios (B1), and required field-level acceptance evidence is incomplete (B2). |
| Catalog browsing, combined name/league/team/position, sizes 1–100, continuation and restoration | Query composes filters; v3 cursors bind name and filters while retaining v1/v2 handling. Added pagination/cursor tests cover >10 matches and criteria mismatches. LiveView tests and the passing browser journey cover combined filters and detail/back/reload restoration at 1280, 768 and 390 pixels. Scouting checks the unfiltered local name result and excludes filtered misses from admission. |
| Player detail, recorded statistics, freshness and valuation | Existing summary exposes count/minutes/goals/assists, season and coverage; template renders these and statistics_status. Current provenance is rendered. New tests primarily assert section presence rather than returned values (B2). |
| Current/history/dated quotes and unavailable states | Context reads, complete history iteration and date lookup are implemented. Existing quote contracts are unchanged. Invalid-date and unavailable components have assertions; successful dated lookup only asserts a status element, not the selected quote/value (B2). |
| Purchases/sales and full confirmation | Existing authenticated domain execution and immutable retry terms remain authoritative. Confirmation adds side, amount, timestamps and provenance. Passing LiveView tests exercise buy/sell/idempotency; new confirmation coverage only checks the word “Cotización” (B2). |
| Account transaction history, sizes, cursors and links | New authenticated route delegates to owner-scoped transaction history. One-row pagination and purchase display pass LiveView and browser tests. UI-specific isolation and exact page identity/details are not demonstrated by the new tests (B2). |
| Allocation totals/metrics, empty and missing-data states | New accessible table and totals exist for open positions. **Fails** for a closed allocation despite valid nonzero domain totals (B1). Existing chart gap tests exercise the chart component, not the new allocation table (B2). |
| Portfolio from/to, defaults, validation and daily table | Reuses Analytics.Input.range and domain validation; controls and daily metric columns exist. LiveView tests exercise invalid ranges and unavailable reads; browser proves table/header presence, not populated metric values or gaps (B2). |
| Ranking and conditional-order lifecycle/detail | Ranking preserves domain order and adds quote/effective date; exact membership/order assertion remains in the passing browser journey. Conditional-order tests assert execution purchase/quote references, lifecycle updates and cancellation. No trading/order rule changes found. |
| Regression inventories, boundaries and selected risk | Required inventories and task scope were updated. Deterministic tier is high with no unmapped paths, appropriate for account/financial UI and cursor changes. No migration, REST/OpenAPI mutation, provider adapter coupling, new HTTP-from-LiveView calls or authorization bypass found. |

## Deterministic evidence integrity and targeted checks

Read `.agentflow/runs/thinflow/TASK-084/candidate.json` and its named deterministic check evidence. Called `scripts.thinflow.readiness(..., require_evaluation=False)`: current task/branch, recomputed selection/material digest, required check membership and evidence hashes validate. All five selected checks passed: format, compile, unit-profile (699/699), ci-contracts (27), harness-tests (382). Empty format/compile output is consistent with successful no-output commands. These receipts do not execute the integration or browser acceptance profiles.

To resolve that uncovered UI execution risk, ran only the affected acceptance surfaces:

- `MIX_ENV=test mix test test/e2e/portfolio_analytics_test.exs:54 --include e2e`: **1 passed, 1 excluded**. Real browser market journey, including three viewport sizes, exact ranking membership/order, transactions and analytics table presence.
- `MIX_ENV=test mix test test/football_market_web/live/portfolio_live_test.exs test/football_market_web/live/catalog_scouting_live_test.exs test/football_market_web/live/conditional_orders_live_test.exs test/football_market_web/live/workspace_navigation_test.exs`: **17 passed**.
- An inline, disposable ExUnit probe through `MIX_ENV=test mix run -e`, using the existing E2E Runtime: **1 passed** confirming B1. It initialized a player, funded buyer/issuer, bought one token and sold it, asserted allocation positions `[]`, purchases `1`, sales `1`, then rendered authenticated `/portfolio` and asserted that `portfolio-allocation-totals` was absent while the daily history table was present. No test file or implementation was changed.
- `git diff --check`: passed. No full suite was rerun.

## Blocking findings

### UI completeness

**B1 — Keep allocation totals visible when all positions are closed.** `lib/football_market_web/live/workspace_live.ex:1096` gates both the table and `#portfolio-allocation-totals` on `@allocation.positions != []`. Allocation deliberately retains cumulative purchase expenditure, sale proceeds and realized profit/loss after liquidation (`lib/football_market/market/analytics/projection.ex`, `value/2`). Reproduction above confirms nonzero purchase/sale totals disappear from the allocation UI after selling the final token. This violates the allocation totals/empty-state parity requirement; the history table is a separate dated projection. Render successful allocation totals independently of position rows, retain the empty-position message, and add regression assertions for a closed portfolio and a never-traded account.

### Acceptance evidence coverage

**B2 — Assert the promised result values and required scenarios, not only new container/header presence.** `test/football_market_web/live/portfolio_live_test.exs:35` expects unavailable analytics because its sandbox transaction prevents successful analytics reads. Its component tests exercise the existing charts, not the newly added allocation/history tables. The real-runtime complement at `tools/openapi/e2e_market.mjs:139` checks table counts and headers only. Consequently no delivered acceptance assertion verifies the new tables' totals, daily financial values or missing-quote cells, despite the spec explicitly requiring these. The same pattern affects provenance/statistics (`portfolio_live_test.exs:379`), dated lookup (`:389`, status existence only), confirmation (`:403`, label only), and transaction pagination (`:99`, same generic purchase assertion on both pages). The new route also lacks a UI owner-isolation/mismatched-cursor assertion. Passing these tests therefore does not establish the spec's explicit requirement that meaningful returned fields and required scenarios are asserted. Add focused field/value oracles against deterministic fixtures/domain results, including selected-date identity, distinct continuation rows, account-scoped transaction rows, and populated/empty/incomplete allocation/history projections. Bind the matrix to concrete tests and execute those affected checks; a full-suite rerun is unnecessary to address this finding.

## Advisory findings

None beyond the blocking root causes above.

## Residual risks

The successful browser journey uses a small deterministic fixture and does not establish every matrix scenario. Full integration/E2E profiles and hosted exact-head CI were not run by this evaluator. Existing authentication, precision and financial execution boundaries remain intact on inspection; hosted `ThinFlow required` and human merge remain mandatory after repair and reevaluation.

Verdict: FAIL
