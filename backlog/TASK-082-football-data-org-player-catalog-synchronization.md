---
id: TASK-082
title: Football-Data.org player catalog synchronization
type: task
checkpoint: CP2
priority: critical
workflow: thinflow-v1
status: review
depends_on: none
active_run: 3a2beef4
---

## Outcome

Populate the local searchable catalog with current teams and player squads from Football-Data.org for the Premier League, Bundesliga, La Liga, Serie A, and Ligue 1. Provide an idempotent daily synchronization and an operator-invokable one-off initial/manual run using the existing durable synchronization and catalog-ingestion pipeline. Preserve the last valid local catalog if a provider response is incomplete or fails; do not create quotes, token issuance, balances, orders, or transactions. Store the provider credential only in runtime secret configuration, respect rate limits, and record source provenance and synchronization outcomes.
