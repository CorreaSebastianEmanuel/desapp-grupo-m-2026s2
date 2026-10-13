# ADR-0020: Authoritative Valuation Replay and Trusted Scorers

**Status**: Accepted for TASK-022 design under Feedback 1 and AGENTS rule 9
**Date**: 2026-10-13

## Context

The independent challenge identifies coordinated fact tampering, scorer requirements/configuration mismatch and absent group contributions. Approved product behavior remains specs/058-valuation-contract-normalization/spec.md. ADR-0010 makes local facts immutable; TASK-026 owns durable quote evidence. Statistics' inclusive history differs from valuation's half-open weeks.

## Decision

Replay resolves original player/match pairs through Statistics, verifies retained performance IDs and compares all raw match/performance fields before recomputing. Caller snapshots/digests are comparison evidence, never alternative authority. Missing originals fail; late rows never enter original membership. Descriptor origin/configuration are trusted internal inputs; authentication, durable snapshots and signatures remain downstream retention concerns. This does not claim to detect wholesale replacement with another legitimate descriptor.

An explicitly supplied reviewed module owns strategy ID/version, config validation and derived requirements. Prepared requirements must agree. Replay requires the original exact definition/config; no active defaults. The callback sees rounded features only, never raw minutes/affiliation. Trusted modules must honor deterministic read-only conformance; no untrusted code service/module deserialization/sandbox. Illustrative modules remain test support. Expected scorer errors, absent required contributions and invalid return types produce ordinary no-score outcomes.

Preparation preserves applicable features when another declared group is absent. It fails for no applicable required scope or unknown required metrics in present scopes. Explicit strategy rules may require absent contributions and fail, or combine populated groups; TASK-024 owns production combination.

Valuation reads inclusive Statistics history, filters the closing instant exclusively and canonicalizes by kickoff/stable match identity bytes/performance identity bytes. Existing Statistics semantics/schema stay unchanged. Exact integer coefficient/exponent arithmetic with quotient/remainder rounding avoids ambient Decimal context and double rounding. Public features/scores are six-place strings; finite Decimal scorer output is rounded once.

Legacy Statistics/Providers scope-test worktree allowlists may add this active feature's exact plan inventory only. Preserve purity, module inventories and unrelated-path rejection. No new infrastructure/dependency is needed.

## Consequences and alternatives

Original rows and reviewed scorer rules must remain available; otherwise replay fails explicitly. TASK-026 must protect retained descriptors. Test coordinated counts/derived-value and position/kickoff tampering, incompatible requirements and mixed present/absent policies.

Caller-only snapshots cannot establish originality; fresh selection breaks replay. Arbitrary callbacks/raw evidence conceal scoring violations. Globally failing absent groups contradicts spec. Changed Statistics bounds break consumers. Fixed-precision division risks near-half and large-count errors. Blanket allowances weaken architecture gates. These contract refinements and bounded test boundary additions do not change approved product scope.
