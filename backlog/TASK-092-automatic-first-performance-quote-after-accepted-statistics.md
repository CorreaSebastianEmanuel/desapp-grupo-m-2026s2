---
id: TASK-092
title: Automatic first performance quote after accepted statistics
type: task
checkpoint: CP3
priority: critical
workflow: thinflow-v1
status: review
depends_on: TASK-025, TASK-026, TASK-056, TASK-079, TASK-091
active_run: 03f8f55d
---

## Outcome

Deliver the product change explicitly approved in this conversation: once accepted verified statistics are available and an administrator-selected strategy and valid mapping exist, asynchronously compute and publish the first positive performance-derived quote for a player without waiting for the nightly close. The one-credit issuance reference is not a performance quote. Existing performance-priced players continue to publish subsequent quotes only at the nightly close; opening a page never performs provider IO or synchronous valuation. Reuse existing durable calculation requests, Oban execution, immutable evidence and quote confirmation, configuration version binding, locks, leases, exact money, deduplication and conditional-order notifications. Concurrent imports, retries, recovery and nightly close must not create duplicate first quotes or permit additional daytime recalculations after the first performance quote. Missing inputs, unconfigured strategy or mapping, insufficient data and nonpositive results remain explicit pending/no-quote states; do not activate a formula automatically, invent zero inputs, add a price floor or rewrite history. Update the compact spec and current architecture/UI messages to distinguish initial preparation from later nightly updates. Add focused tests for initial quote before close, later updates remaining pending until close, issuance-only state, missing/nonpositive inputs, selected configuration, retries and separate-connection concurrency. Reconcile source/test/profile/scope inventories and existing nightly-close, purchase, ranking, conditional-order and configuration integration contracts before selected checks; preserve all CI gates. Read and apply .agents/skills/elixir-essentials/SKILL.md and .agents/skills/ecto-essentials/SKILL.md as requested by the user. The second authorized delivery is a separate dependent task for initial preloading plus scheduled background statistics refresh, with durable recovery at server startup, deduplicated/rate-limited work, local reads, and preparing states with automatic card updates rather than showing the no-statistics empty state while imports are active. Capture that follow-up as one backlog task depending on this task; do not implement it in the first quote task. Both deliveries are authorized, but work on one implementation at a time and never merge automatically. The first-quote exception to TASK-079 is settled by the user; do not ask again for authorization of that product change.
