# Alquimistas Constitution

## Principles

### I. Specification before implementation

Every feature starts from a backlog outcome and a testable `spec.md`. Architecture and code must trace to acceptance criteria. Material ambiguity blocks implementation; reversible details receive documented conservative assumptions.

### II. Domain integrity

Token supply, monetary precision, quote history/versioning, transactional trading, idempotency, and immutable audit rules in `docs/PRODUCT.md` are non-negotiable.

### III. Modular simplicity

Prefer a modular monolith and the smallest design satisfying the active checkpoint. Maintain explicit web, domain, persistence, worker, cache, and external-adapter boundaries. New infrastructure or services require evidence and an ADR.

### IV. Evidence-based quality

Behavioral changes require automated tests. Formatting, compilation, tests, static analysis, architecture checks, and checkpoint-specific evidence must be executed rather than asserted. External sources use deterministic fixtures in tests.

### V. Proportional independent verification

One accountable builder owns the settled outcome through implementation. A separate evaluator challenges acceptance, risk classification, architecture, security, regression scope, and current evidence without modifying implementation. Human feedback is authoritative. Only unresolved decisions that materially affect behavior, business rules, scope, permissions, security, data integrity, or a costly irreversible design pause delivery. A task reaches `review` only when risk-selected local checks pass and `evaluation.md` ends exactly in `Verdict: PASS`; the exact PR head must then pass the aggregate hosted gate before human merge. Saved Agentflow 2.3 runs retain their captured gates and are never silently rewritten.

## Safety and delivery

`agentflow start` is explicit approval to commit, push its task branch, and create one PR after local readiness. Agents never merge, expose secrets, weaken checks, or execute destructive operations without explicit human approval. Operational evidence stays under `.agentflow/runs/`. Failure produces a visible blocked state rather than false completion.

## Governance

This constitution governs generated specs and plans. `docs/CHECKPOINTS.md` defines delivery obligations; `docs/PRODUCT.md` defines domain truth; `docs/ARCHITECTURE.md` defines the technical baseline. Amendments require an explicit reviewed change.

**Version**: 2.0.0 | **Ratified**: 2026-09-06 | **Last Amended**: 2026-10-27
