# Architecture delta — TASK-028

Local inspection found no existing balance/holding/quote persistence. The bounded new Market inventory and shared quote table are in plan.md; ADR-0024 records recipient fixation, coordinated financial writes and fixed-rule separation. Do not turn missing balances into an Accounts expansion.

Critic finding 1: model pre-commit rollback separately from lost acknowledgement after commit. SC-003 covers attempts that did not complete; committed issuance must survive and be returned on a valid retry. No compensating deletion.

Findings 2/3: validation checks contradictory linked evidence and nonnegative whole holdings as well as conserved aggregate. Run distinct committed connections with barriers, including retry versus transfer and first issuance versus a quote insert. Pure/isolated legacy fixtures cover corrupt states; never disable production guards.

Finding 4: initialize fresh players before downstream performance valuation. TASK-026 must extend/reuse market_quotes; TASK-029/030 must honor player locks and conservation. No automatic backfill or ingestion hook is authorized.

The spec's branch label differs from resolved delivery directory; retain feature.json's 062 binding. No current TASK-028 feedback file was found; approved product-decision has no material unresolved choice.

No HTTP interface changes; verification's internal DB runtime evidence is supplied by integration/durability tests. Implementation must produce all inventory files, run every manifest check before QA, and preserve existing audited profiles/CI. Do not add the historical coverage report as a duplicate CP2 gate. This handoff does not establish test success.
