# ADR 0008: Filter-Bound Player Catalog Cursors

- **Status**: Accepted
- **Date**: 2026-09-28
- **Feature**: TASK-012 composable player catalog filters
- **Extends**: [ADR 0007](0007-encrypted-stateless-keyset-cursors.md)

## Context

ADR 0007 establishes encrypted, stateless, non-snapshot keyset cursors for the shared player list. TASK-012 adds filters to that same route, while requiring old unfiltered tokens to work and filtered tokens to reject any change to their effective filter set. The original v1 payload has no filter identity.

## Decision

Keep the v1 unfiltered encoder and decoder compatible with previously issued TASK-011 tokens. For a nonempty filter set, issue a version 2 payload within the existing encrypted and authenticated list-cursor envelope. Include the ordering anchor and only the present filter names and canonical lowercase UUID values. Decode both versions, but accept v1 only for an unfiltered request and v2 only when its exact canonical filter map equals the current request. Reject malformed maps, extra filter keys, version/scope failures, and any mismatch with the same generic `invalid_cursor` response before catalog SQL. Page size and actor remain outside cursor identity. Key rotation continues to determine cryptographic lifetime.

## Consequences

- A pre-change literal v1 token under the fixed test secret is required as a migration fixture; tests must not regenerate it through the revised encoder.
- Query order and UUID letter case do not change effective filter identity. A changed, added, or removed filter does.
- No cursor table, cache, provider call, user binding, expiry policy, or snapshot promise is introduced.
- Cursor format changes require explicit version handling and compatibility tests. The public token stays opaque.

## Rejected alternatives

- Replacing unfiltered v1 tokens would violate TASK-012 compatibility.
- Accepting v1 with filters would allow continuation under a different result set.
- A plain or merely signed payload would expose IDs and anchors.
- Persisted cursor sessions would add lifecycle infrastructure without a product need.
