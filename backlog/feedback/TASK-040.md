# Feedback — TASK-040

## Feedback 1

- Time: 2026-11-24T18:44:24+00:00
- Author: shebi
- Restart from: develop
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

Confirmed product decision: implement the recommended snapshot of currently retained local records. Report performance quotes and quote request state, conditional order status, completed purchases/sales and token quantities, accepted statistics scopes and performance records, and retained Oban jobs by state. Label retention semantics explicitly and distinguish empty from unavailable. Completed trades are the portfolio activity basis. Keep the administrator-only API and safe aggregate allowlist.

