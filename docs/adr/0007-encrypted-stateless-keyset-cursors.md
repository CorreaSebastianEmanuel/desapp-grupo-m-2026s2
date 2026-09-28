# ADR 0007: Encrypted Stateless Keyset Cursors

- **Status**: Accepted
- **Date**: 2026-09-26
- **Feature**: TASK-011 player catalog API

## Context

The player catalog must provide bounded, deterministic continuation while rejecting tampered or foreign cursors and exposing no cursor contents. It is a shared authenticated catalog, not actor-specific data. PostgreSQL is authoritative and the architecture discourages new infrastructure without evidence.

## Decision

Use stateless encrypted-and-authenticated keyset cursors. A versioned payload identifies its endpoint scope and the complete normalized ordering anchor. Encryption/integrity keys are derived from the existing deployment secret with a dedicated cursor salt. Decoding validates cryptography, version, scope, shape, and types before any catalog query; every failure maps to the endpoint's generic invalid-cursor response.

Cursors are independent of page size and authenticated actor. They can be replayed or transferred between authorized actors. Queries resume strictly after the embedded ordering tuple and never require the anchor row to exist. Cursor contracts are non-snapshot contracts.

## Consequences

- No cursor table, cache, cleanup job, or provider dependency is needed.
- Payload values are not visible to clients and tampering is detected.
- Contract/key rotation can intentionally invalidate old cursors and must be managed through the payload version/scope.
- Any endpoint adopting this convention needs a unique scope and salt plus tests for cross-scope rejection and non-disclosure.
- Inserts, ordering-key changes, and deletions between requests retain documented keyset behavior rather than snapshot isolation.

## Rejected alternatives

- Plain signed cursors reveal payload contents.
- Random stateful cursors require persistence and lifecycle semantics.
- Offset pagination is unstable under mutations and inefficient at depth.
- Actor binding prevents legitimate reuse without protecting actor-specific information.
