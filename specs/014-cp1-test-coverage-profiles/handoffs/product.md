# Product Handoff: CP1 Test and Coverage Profiles

## Decisions

- The supported local path for the CP1 browser/public-contract regression includes Node.js 24, its package toolchain, and a browser runtime; absence is a safe, failing prerequisite condition, never a skip.
- Diagnostic secrecy is fail-closed. No raw credential or verification value may be emitted before sanitization/validation succeeds, including on child-process startup failures.
- Coverage must be demonstrably scoped by the committed CP1 source inventory, not merely annotated with it.
- Coverage may publish before QA commit as a labelled working-tree snapshot, bound to base HEAD and a deterministic relevant-diff hash. The clean-worktree precondition is removed.

## Unresolved Assumptions

- Planning must enumerate the exact relevant working-tree inputs and deterministic hash/change-detection procedure. It must cover all inputs capable of affecting the profiles, coverage scope, inventory, or provenance while excluding generated output.

## Guidance

- Add controlled failure tests for a missing Node runtime and for every output channel that could otherwise forward unredacted child diagnostics.
- Demonstrate that the actual coverage denominator equals the committed inventory in an executable contract, including both inclusion and exclusion cases.
- Preserve zero coverage threshold and the locked three-category baseline. Do not change CP1 product behavior.
