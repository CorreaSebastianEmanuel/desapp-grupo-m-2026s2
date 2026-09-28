# Research: Player Catalog List and Detail API

## Cursor model

**Decision**: Use an encrypted-and-authenticated, versioned, endpoint-scoped stateless keyset cursor containing the normalized display-name anchor and player UUID.

**Rationale**: It supports deterministic replay without server-side state, survives anchor deletion, rejects tampering and foreign endpoint/version tokens, and does not expose cursor contents. Catalog pages are shared data, so cursors remain portable between authenticated actors.

**Alternatives considered**: Plain signed payloads reveal contents; random stateful tokens require storage and lifecycle policy; offset pagination shifts under inserts and does not encode the documented position; actor binding adds friction without protecting user-specific data.

## Ordering and index

**Decision**: Order and seek on `lower(btrim(display_name)), id`, backed by a matching PostgreSQL expression index.

**Rationale**: TASK-005 already defines normalization with `lower(btrim(...))`; UUID identity gives a total order for duplicates and case variants. The index avoids full sorts at the 100,000-player target.

**Alternatives considered**: Raw string ordering conflicts with the spec; name alone is not total; sorting in Elixir is unbounded and bypasses database pagination.

## Public identity and field types

**Decision**: Serialize Ecto `:binary_id` values as canonical UUID strings, years as integers, and all text fields as non-empty strings; no representation field is nullable. Publish `catalog_identity` unchanged as the local, season-scoped domain identity.

**Rationale**: Schema and migrations enforce UUIDs, required relationships, and non-blank identity/name fields. `catalog_identity` is created and constrained inside the local catalog and is not a provider identifier or payload field.

**Alternatives considered**: Hiding `catalog_identity` contradicts FR-013; treating it as globally unique contradicts its season-scoped uniqueness; exposing association or provider keys violates FR-021.

## Query parameter multiplicity

**Decision**: Inspect raw query pairs before decoded-map use; reject more than one occurrence of either supported key. Ignore unknown query keys and prove they cannot alter results.

**Rationale**: Phoenix map decoding can collapse repeated parameters. Early multiplicity validation makes “repeated” mean duplicate occurrences in one request while preserving valid cursor replay across requests. Ignoring unsupported keys avoids inventing an unspecified error contract while keeping filtering and search out of scope.

**Alternatives considered**: Last-value-wins and first-value-wins for supported keys are ambiguous; rejecting cross-request replay contradicts FR-007; rejecting unknown keys would add an error behavior absent from the specification.

## Mutation behavior

**Decision**: Retain non-snapshot keyset semantics and decode anchors without looking up the anchor row.

**Rationale**: This is the smallest CP1 design and exactly guarantees traversal only for unchanged ordering data. Inserts follow the spec; deleting an anchor still permits continuation. Updates/deletes may cause gaps or duplicates and must be documented.

**Alternatives considered**: Snapshot transactions cannot span client requests; materialized snapshots add state, expiry, and cleanup outside scope.

## Performance evidence

**Decision**: Treat SC-008 as diagnostic: fixed 100,000-row dataset, 10 warm-ups, then 100 sequential full HTTP requests for each of first page, continuation page, and detail, reporting each p95.

**Rationale**: This is reproducible enough for regression evidence while making no unsupported hardware, concurrency, or production-capacity claim. CP1 defines no latency gate.

**Alternatives considered**: An ad hoc run is not reproducible; making it a release gate invents an SLA; omitting it ignores an explicit success criterion.
