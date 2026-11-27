## Outcome

Publish a player's first positive performance quote asynchronously from accepted verified statistics and an administrator-selected configuration with a valid mapping, without waiting for market close. Issuance at one credit remains only a reference. Subsequent imported valuations remain subject to nightly close.

## Acceptance

- [ ] Accepted immutable snapshots produce durable requests; recovery admits initial work and enqueues Oban calculation without a page visit or provider IO. Issuance alone does not block this first valuation.
- [ ] The existing calculation, evidence, configuration binding, exact conversion, quote confirmation and conditional-order notification paths publish one first quote before close using the selected configuration and mapping.
- [ ] Competing snapshots, separate database connections, retries and recovery cannot publish a second daytime quote. Losing initial requests remain pending for close; nightly admission can safely overlap initial execution.
- [ ] After the first performance quote, changed statistics remain visible but their calculation requests wait for nightly admission. Nightly and TTL behavior for existing quotes remains intact.
- [ ] No active configuration or valid mapping leaves initial requests pending. Missing/insufficient data and nonpositive scores retain explicit existing failure/no-quote outcomes with no invented inputs, floor or financial effects. Retried work retains its bound version.
- [ ] Architecture and user messages distinguish initial preparation from subsequent nightly updates. Focused tests cover these paths and affected purchase, ranking, conditional-order and configuration contracts; maintained inventories reflect actual changes.
- [ ] Capture one dependent backlog task for initial preloading and scheduled background refresh, startup recovery, deduplication/rate limiting, local reads and preparing cards that update automatically. Do not implement that follow-up here.

## Scope

Initial admission and confirmation fencing on existing imported calculation requests, durable recovery, focused tests, current architecture/UI wording, inventories and the dependent backlog task.

## Non-goals

Daytime recalculation after a performance quote; changing explicit valuation commands; automatic strategy activation; provider acquisition/preloading/scheduling changes; new pricing formulas, input defaults or floors; rewriting immutable history; workflow-policy changes.

## Risk

High: asynchronous financial publication and concurrent admission/confirmation. Preserve player-before-request lock order, write-once binding, leases, immutable evidence and atomic quote/event confirmation. Deterministic path classification remains authoritative.

## Decisions

- The user approved the first-quote exception to TASK-079. Eligibility is player-wide, across seasons, and ignores issuance quotes; later imports still require close.
- Persist initial-only eligibility separately from immutable nightly admission. Recheck eligibility under the existing player and request locks immediately before persistence; work superseded by another first quote returns to pending for close without consuming a calculation attempt.
- Recovery revisits pending unadmitted initial requests when configuration/mapping becomes available. Configuration binds through the existing worker lease; an already bound configuration or mapping is never replaced.
- Scored evidence serializes the exact Decimal score as a string, including nonpositive and rounded-to-zero outcomes. Failures without a score keep the separate evidence path with no score key; replay preserves both forms.
