# Feedback — TASK-077

## Feedback 1

- Time: 2026-10-29T22:12:34+00:00
- Author: sebo
- Restart from: develop
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

Human product decision approved in this conversation: include recorded-match count and totals for minutes played, goals and assists for the player's catalog season in both the player card and player-detail API. Reuse one domain read for the API and LiveView, using the latest locally stored performance facts. Preserve explicit unknown/missing values and existing freshness/valuation status; do not imply complete season coverage or live provider data. Existing ingestion and TTL refresh drive updates; live transport remains TASK-080. This resolves the sole material decision in the compact spec; implement the complete original TASK-077 outcome, including player card, atomic idempotent buy/sell forms, owner-scoped portfolio reloads, active-strategy ranking and actual browser E2E coverage. Maintain domain/web/persistence boundaries and register required inventories. No new charts, valuation rules or ingestion policy. The user accepts that the choice of displayed metrics may be revised in a later task.

