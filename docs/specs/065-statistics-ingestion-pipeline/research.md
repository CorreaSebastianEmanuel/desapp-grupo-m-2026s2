# Feature-specific resolved questions

Local inspection only; established dependencies are governed by docs/ARCHITECTURE.md and ADR-0010/0013/0018/0019/0025. No external dependency behavior or live feasibility claim is introduced.

## Position boundary

- Evidence: Providers.Performances.validate requires position membership; Providers.Validator rejects extra envelope keys; Scraping.Translator calls position! on positionId. Statistics.Input requires position_id; the existing migration makes it NOT NULL. Merely changing the publisher cannot reach an unknown-position success.
- Decision: extend the existing DTO with closed participation evidence and completeness, permit nil only for evidenced entrants, add guarded persisted evidence states while retaining strict direct-write validation and all immutable triggers.
- Rationale: this is the minimum compatible reconciliation mandated by FR-011 and current feedback; no unknown position catalog row or profile inference.
- Alternatives: an ingestion-only validator duplicates TASK-016; a sentinel known position fabricates facts; broadly nullable positions weaken starter validation.

## Multi-match derivation and replay

- Evidence: spec Assumptions explicitly says 'already accepted'; critic recommends considering proposed batch facts. TASK-020 rows are immutable and historical arrivals can change current interval membership (ADR-0010).
- Decision: freeze committed prior history before any proposed inserts; exclude every proposed row and equal/later kickoff. Retain exact basis and source material; replay reuses stored evidence.
- Rationale: list ordering cannot affect a batch; counting proposed rows changes product's accepted-history rule. This resolves the finding without adopting its incompatible recommendation. Later imports may see larger history but never revise accepted positions.
- Alternatives: chronological incremental insertion makes order significant; a union of proposed and existing rows expands the eligible history; recalculating on replay makes identical source results conflict with themselves.

## Completeness and lineage

- Evidence: Scraping.Source.portion! verifies terminal/witness and assessments internally, but Providers.Result exposes only operation/scope/facts/provenance. Existing Provenance retains fixture_id but lacks content digest/origin/date/expected case.
- Decision: expose safe explicit completeness evidence through the same result, require it in ingestion, and persist contained sanitized fixture inventory metadata with actual digest.
- Rationale: an empty list cannot prove complete-empty, and an opaque fixture name is not raw-fixture traceability. Source witness semantics remain TASK-055-owned and live access remains denied.
- Alternatives: infer from HTTP/counts (false completeness), retain raw payload (unsafe), add a parallel provider interface (forbidden).

## Durable runtime and downstream boundary

- Evidence: Synchronization.Input/Store/Recovery, CatalogSync and catalog_delivery_receipts are catalog-specific. Policy already implements finite attempts and persisted waits. Valuation exposes prepare/score/evaluate/replay and managed variants, but no durable calculation request API.
- Decision: add operation dispatch to the existing runtime, keep catalog compatibility, and add transactional intent plus idempotent receiving domain request. Dispatcher recovers pending dispatch after commit.
- Rationale: reuse retry ownership/fencing; a bare callback after commit can be lost. Request acceptance does not select scoring or produce quotes.
- Alternatives: second scheduler/runtime, Oban retry accounting as domain ledger, or synchronous valuation/quote creation all violate boundaries. Pretending an existing async receiver exists would leave FR-013 unimplemented.

Durable combined decision: docs/adr/0028-atomic-statistics-ingestion-and-position-evidence.md.
