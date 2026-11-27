# Feedback — TASK-038

## Feedback 1

- Time: 2026-11-21T20:37:32+00:00
- Author: shebi
- Restart from: develop
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

The user approved Redis-only degradation. If PostgreSQL and Oban are ready, /health/ready returns HTTP 200 and identifies Redis as degraded when its bounded probe fails. Return HTTP 503 when PostgreSQL or Oban is unavailable. Liveness remains independent of dependencies. Record this decision in the compact spec, implement the accepted endpoints and focused regressions, and continue through ThinFlow.

