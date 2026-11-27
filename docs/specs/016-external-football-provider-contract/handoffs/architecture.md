# Architecture handoff — TASK-016

The critic's findings are resolved in plan.md and ADR-0013. No human feedback file exists for this feature and no further human decision is required. Existing affiliation/statistics ADRs were reused; no vendor or technology research session was launched.

Implementation cautions: a player directory must include the current team even when only an earlier team participated. Retain lists through duplicate validation; indexing first loses identical/conflicting duplicates. Eligibility filtering must not erase an undecidable match discriminator or dangling performance-to-match reference.

The test-only reference oracle is deliberately different from production matching. Exercise its negative cases; passing two happy fixture translations alone does not prove same-name separation. TASK-017 can reuse ProviderContractCase, but must provide actual capability expectations and public-safe source IDs.

Cancellation needs real-process evidence in addition to controlled-clock cases. The owner must not join blocked work after choosing timeout; reply correlation must survive a subsequent request. Arbitrary opaque bytes cannot reveal every secret, so diagnostic templates plus identifier safety checks do not replace a concrete adapter's source-ID classification.

The offline bootstrap is necessary because existing Mix test aliases prepare a database. Pure modules/support must stay loadable without application/dependencies. Existing profile discovery rejects missing/unknown tags. Coverage refuses untracked files, including receipts the helper creates before execution. The feature .gitignore excludes only local check receipts; readiness still validates them. Stage completed inputs before checks and the final develop handoff before QA coverage reruns, without committing/publishing or changing the inventory.

TASK-017 owns real coverage/access evidence; TASK-022 owns incomplete valuation input policy. Synthetic compatibility does not establish usable statistics across five leagues or complete CP2 readiness. No HTTP check is required for this internal feature. All manifest receipts are future developer obligations, followed by independent QA; this handoff is architecture guidance, not behavioral acceptance.
