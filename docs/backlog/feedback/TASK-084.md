# Feedback — TASK-084

## Feedback 1

- Time: 2026-11-03T02:44:32+00:00
- Author: mateo
- Restart from: develop
- Impact: implementation, verification
- Required regressions: cited discrepancy plus required manifest checks

Independent evaluation B1/B2 are accepted and grouped into one repair. Repairs are already applied in the working tree: successful allocation totals render independently of open rows; portfolio tables are shared components used by the actual page and exact-value fixture tests. New PortfolioAnalyticsTest case covers persisted never-traded/open/fully-closed allocations and daily values against authoritative domain reads, plus incomplete pure projections without modifying immutable history. PortfolioLiveTest now verifies distinct transaction-page identities, owner isolation and foreign-cursor rejection; complete current/history/selected dated quote provenance and prices, recorded statistics and freshness values, and exact trade confirmation references/amounts. Selected dated quotes now expose full provenance through the same quote-details renderer as current/history. Targeted results: portfolio LiveView 12 passed; analytics runtime/browser 3 passed before final provenance renderer extraction (rerun affected checks). Preserve all existing assertions including exact browser ranking order. Finish by validating the repair delta and required inventory registrations, format/Credo and focused tests; do not reimplement completed features or run full profiles within builder. Bind matrix to these concrete tests. The harness owns required checks and fresh evaluation. Environment: inherited MIX_TEST_PARTITION=task084 is the prepared disposable test database; default unpartitioned local test database has pre-existing inconsistent migrations and must not be dropped or rewritten. Keep all Mix invocations sequential.

