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

### V. Independent verification

Product specification receives an independent challenge before architecture synthesizes a decision. Implementation, QA, and final review run in fresh agent sessions. Implementation has one code owner; QA and final review do not modify implementation. A task reaches `review` only when QA and review reports both end exactly in `Verdict: PASS`; humans retain merge authority.

## Safety and delivery

Agents do not push, merge, expose secrets, weaken checks, or execute destructive operations without explicit human approval. Runs are local and logs stay under `.agentflow/runs/`. Failure produces a visible `blocked` state and evidence rather than a false completion.

## Governance

This constitution governs generated specs and plans. `docs/CHECKPOINTS.md` defines delivery obligations; `docs/PRODUCT.md` defines domain truth; `docs/ARCHITECTURE.md` defines the technical baseline. Amendments require an explicit reviewed change.

**Version**: 1.0.0 | **Ratified**: 2026-09-06 | **Last Amended**: 2026-09-06
