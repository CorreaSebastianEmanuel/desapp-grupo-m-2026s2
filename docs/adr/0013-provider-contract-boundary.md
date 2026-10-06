# ADR-0013: Bounded Provider Reads with Result-local Identity

**Status**: Accepted for TASK-016 implementation
**Date**: 2026-10-06

## Context

TASK-016 requires interchangeable facts without transport payloads, persistence identities, invented statistics or unbounded waits. Its product challenge identified eligibility precedence, identity-aware comparisons and diagnostic leakage. ADR-0002 retains mutable current affiliation; historical facts retain event-time context. No stack deviation/service is needed; this external-adapter boundary is a durable architecture extension.

## Decision

Keep provider DTOs/errors separate from Ecto and web interfaces. Each result has opaque references and separate provider/kind/league-season qualified source bindings. Names and cross-call reference equality do not establish identity.

Performance retrieval validates envelope and eligibility discriminators, excludes provably irrelevant matches, then validates every retained fact and transitive directory closure. Ambiguous eligibility or any retained invalid record fails the whole request. Catalog validation is complete. Preserve lists until duplicate detection; identical duplicates are errors.

Use one cancellable worker and absolute monotonic deadline for retrieval plus normalization. The caller owns one terminal outcome; all pagination/delays/validation share the budget. No retries, fallback, persistence or partial publication. Late work cannot escape a terminal timeout. Adapters cannot detach work or write. Controlled runtime tests require an accompanying real cancellation check.

Generate errors from templates/known fields, never raw messages, exception text or hostile keys. Provenance admits public-safe source IDs; recognizable secret/transport content is rejected rather than rewritten. Arbitrary secrets cannot be recognized from opaque bytes; concrete adapters must select safe identifiers.

Offline comparison uses explicit test-only entity correspondence and reference bijections rather than names. This oracle cannot become production reconciliation.

## Consequences and alternatives

Ingestion retains provenance and establishes persistent identity later. Consumers distinguish empty scope, missing scope, unsupported coverage and failure without understanding vendors. Synthetic checks establish conformance, not live feasibility; TASK-017/TASK-022 own actual coverage/valuation completeness.

Validating irrelevant full facts, name-based comparison, arbitrary diagnostic redaction and post-return timeout measurement undermine scoped retrieval, distinct identity, secrecy or bounded waiting. A worker pool/service adds scope without evidence. No Catalog/Statistics schema, affiliation policy, permission or product invariant changes.
