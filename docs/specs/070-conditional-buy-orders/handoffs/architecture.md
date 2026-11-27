# Architecture delta — TASK-059

ADR-0036 resolves the critic within approved scope: expiry dominates evaluation, no execution deadline or global winner policy, and reads remain pure. It supersedes ADR-0017's default-expiry/dispatch suggestions. Local inspection found public purchase rejects nested transactions and arbitrary direct keys can collide with order-derived keys. Extract a transaction-local purchase participant; preserve public direct behavior and partition evidence identities by nullable conditional_order_id. Tests must prove direct-key collision isolation and historical direct replay.

Spec identifier FR-004a is now FR-022 because the verification parser recognizes numeric IDs only. Behavior is unchanged. Retain directory 070 and branch/task 059.

Implementation risks: business rejection must occur before financial writes; transient failure rolls back rather than commits rejected. Sample database wall clock after blocking locks. Use one authoritative quote under the shared player lock. Test both quote serialization orders with committed connections, cancellation winners, lock waits across expiry, and shared-account contention without choosing a fairness winner.

TASK-060 must compose create/quote work durably and exercise contracts/task060-handoff.json. Current manifest validates the handoff and replayable seams only; it cannot establish future worker delivery. Preserve that limitation in QA. TASK-061 owns UI.

No extensions.yml exists, so no configured pre/post hooks were executable. Finish plan artifact validation before task setup; final structural probes validate both stages. Do not implement or execute feature runtime checks during architecture.
