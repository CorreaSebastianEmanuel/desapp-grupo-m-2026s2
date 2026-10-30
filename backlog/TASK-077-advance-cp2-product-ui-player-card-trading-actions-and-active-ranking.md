---
id: TASK-077
title: Advance CP2 product UI: player card, trading actions and active ranking
type: task
checkpoint: CP2
priority: critical
workflow: thinflow-v1
status: done
depends_on: TASK-027, TASK-029, TASK-030, TASK-033, TASK-046
active_run: none
---

## Outcome

Deliver the minimal, demo-visible UI slice inside the existing authenticated workspace LiveView: (1) player card view showing catalog identity plus the current quote with its effective-at timestamp, freshness status and derived statistics via the existing player detail API; (2) trading actions (buy/sell) as forms calling the atomic idempotent purchase and sale rules with visible errors and instant portfolio/positions reload through the existing PubSub-driven reload path; (3) active-strategy ranking view (read-only ordering with the active strategy label). This advances a bounded CP2 slice of TASK-047/048, which remain the CP3 owners of filters, full history and detailed refresh flows; do not duplicate those screens, and charts remain the exclusive scope of TASK-058 (no chart duplication). Tests: E2E Spin each flow with the unit/E2E profiles (search to order to purchase visibility, selling owning tokens, ranking reflects the active strategy) plus unauthenticated redirects. Keep server-driven UI (no client-side framework); reuse core components.
