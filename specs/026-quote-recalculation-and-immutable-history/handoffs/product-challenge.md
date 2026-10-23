# Product challenge — TASK-026

## Findings for architecture

- **Pin queued work to the accepted fact membership.** FR-008 requires changed imports to leave recoverable valuation work, while FR-010 makes membership part of calculation identity and says changed membership yields a distinct result. The spec does not explicitly say whether the request snapshots membership when import acceptance commits or whether a delayed worker may read a later membership. Recommend an import transaction/outbox request carrying the immutable membership/version; keep later membership as a separate calculation. Otherwise delayed work can silently skip an accepted scope or collapse two identities.
- **Define the downstream delivery contract at the boundary.** FR-009/010 require one durable request per committed quote, but “duplicate delivery does not create duplicate effective work” in Story 3 leaves TASK-060’s idempotency key and acknowledgement/recovery ownership implicit. Recommend the request identify the immutable quote and have a stable unique key; treat delivery as retryable and let TASK-060 own evaluation deduplication. Keep evaluation behavior itself out of this feature per FR-014.
- **Make error-state assertions explicit in the test matrix.** Story 2, scenario 4 groups absent, insufficient, unsupported, and inconsistent data under no-quote; FR-007 also separates unsupported-strategy failure, and FR-015 names unknown/unsupported data without assigning exact outcomes. Recommend map each case to valid no-quote versus terminal validation/strategy failure, and separately assert whether it is retryable. This prevents operationally different states from being collapsed by implementation.

## Checkpoint and scope

`docs/CHECKPOINTS.md` retains immutable quotes and trading as CP2 requirements, while charts and the conditional-order product feature are separate deliverables. FR-014 correctly excludes those surfaces. Keep this task’s durable quote-evaluation interface sufficient for TASK-060 without allowing it to absorb that task’s worker or the required frontend/demo work.
