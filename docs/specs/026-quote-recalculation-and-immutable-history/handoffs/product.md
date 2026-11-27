# Product handoff — TASK-026

## Decisions and guidance

- Product feedback resolves score conversion: each mapping version must declare a strictly positive exact-decimal scale; illustrative fixtures do not approve a production scale/default. The spec requires retaining mapping, scale and rounding rule as reproducibility evidence.
- No product decision remains open. Preserve same-price quote history and per-quote durable follow-up semantics, plus canonical retry identity, when planning.
- Reuse TASK-021 accepted statistics, TASK-025 managed strategy identities and TASK-028 quote history; do not create parallel sources of truth. Keep calculation outcome separate from import outcome. Preserve initialization history and ensure accepted changed imports leave recoverable calculation work.
