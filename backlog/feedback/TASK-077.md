# Feedback — TASK-077

## Feedback 1

- Time: 2026-10-29T22:12:34+00:00
- Author: sebo
- Restart from: develop
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

Human product decision approved in this conversation: include recorded-match count and totals for minutes played, goals and assists for the player's catalog season in both the player card and player-detail API. Reuse one domain read for the API and LiveView, using the latest locally stored performance facts. Preserve explicit unknown/missing values and existing freshness/valuation status; do not imply complete season coverage or live provider data. Existing ingestion and TTL refresh drive updates; live transport remains TASK-080. This resolves the sole material decision in the compact spec; implement the complete original TASK-077 outcome, including player card, atomic idempotent buy/sell forms, owner-scoped portfolio reloads, active-strategy ranking and actual browser E2E coverage. Maintain domain/web/persistence boundaries and register required inventories. No new charts, valuation rules or ingestion policy. The user accepts that the choice of displayed metrics may be revised in a later task.

## Feedback 2

- Time: 2026-10-29T23:31:11+00:00
- Author: sebo
- Restart from: develop
- Impact: verification, implementation
- Required regressions: cited discrepancy plus required manifest checks

Human explicitly authorized one additional bounded repair, fresh required checks, a fresh independent evaluation, and updating the existing PR #74 after being told the ThinFlow feedback limit had already been used. Authorization: user replied "si mandale" to that exact request. Do not expand product scope. Hosted Quality baseline on head 5a6725294139943f3133ff619465c994eaba05ca failed integration case 59914b9ffb83491931ebec39, test/football_market/market/scope_test.exs:137: initial issuance configuration was not restored to the fail-closed default. The two new trading tests in portfolio_live_test.exs call MarketCase.fixture(), which mutates the global initial_issuance_recipients setting without registering its own cleanup. A directed post-module probe reproduced the leak even when all six UI tests passed. The prepared repair captures/restores the setting in per-test setup, preserving absence with fetch_env/delete_env, and replaces the older one-test-only cleanup. The same probe then passed with all six UI tests. Review and retain this bounded repair, add a durable regression if needed, and run affected isolation/architecture controls before returning the settled candidate. Required local checks and a fresh independent evaluation remain mandatory; the exact updated PR head must pass ThinFlow required and merge remains human-controlled. Do not rerun the full regression suite during development or weaken the existing market scope assertion.

