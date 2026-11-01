# Feedback — TASK-078

## Feedback 1

- Time: 2026-10-31T11:52:27+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Implement the settled TASK-078 outcome. The candidate currently changes only backlog metadata and spec: catalog search misses still return an empty list and no scout is admitted. Add strict name validation; durable normalized-name deduplication, 10 new names per rolling hour, 24-hour negative cache and next nightly retry after the five full-catalog-request budget; non-blocking search status; catalog-only ingestion via existing idempotent path and post-persistence PubSub; provider-failure isolation; and explicit tests proving financial/quote isolation plus preserved demand-refresh/nightly-close behavior. Update docs/PLAYER_SEARCH_WORKFLOW.md and ADR-0016. Use the approved full-catalog-per-league strategy for the configured season, maximum five provider requests per run.

