# Product handoff — TASK-018

## Decisions and next-stage guidance

- No unresolved product question requires a human check at this stage. Conservative defaults are explicit in spec.md and remain subject to independent product challenge.
- Challenge the recovery ergonomics of explicit correspondence on source replacement and retrieval-time ordering. Recommend retaining both defaults unless evidence establishes a safer rule; automatic identity matching materially changes data integrity behavior.
- Architecture should define semantic equivalence precisely, independently of result-reference spelling and collection order. Include mutable affiliation and qualified bindings; distinguish replay from a later unchanged observation.
- Demonstrate publication/replay recovery with failure injection and overlapping attempts, rather than relying on future scheduler deduplication. Check shared canonical constraints across distinct scopes.
- Keep the provider deadline confined to retrieval/normalization. A persistence bound or retry policy needs planning rationale without altering catalog behavior.
- Feature directory 057 follows Spec Kit's next sequential number, independently of TASK-018 and branch 018-idempotent-catalog-ingestion. Resolve through .specify/feature.json rather than numeric equality.

## Remaining dependency risk

Inspect TASK-055's canonical source assessment when designing integration. Its offline completion is not evidence of permitted recurring retrieval. No external research or contact was necessary for this product stage.
