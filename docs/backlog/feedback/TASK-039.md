# Feedback — TASK-039

## Feedback 1

- Time: 2026-11-22T00:46:28+00:00
- Author: shebi
- Restart from: develop
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

The user approved protecting GET /metrics with a dedicated Prometheus scrape token. Use a deployment-configured Bearer token, deny access with missing or invalid credentials, and keep the scrape closed when no token is configured. Leave the public health endpoints and existing product authentication behavior as they are. Settle this policy in the compact spec, implement the metrics families and permission tests, and document the scraper configuration using placeholders. Keep the ThinFlow acceptance checklist structure, register the exact task paths with the existing workflow scope guard and reconcile affected test and source inventories before returning to verification.
