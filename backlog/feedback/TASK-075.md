# Feedback — TASK-075

## Feedback 1

- Time: 2026-10-29T02:27:44+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

Product decisions: measure TTL from the player's latest quote (effective_at); for TTL-due recalculation use only the latest accepted fact scope per player/season; configure independent close recurrences per league/season, separate from catalog-sync occurrences. These decisions are recorded in the compact spec.

