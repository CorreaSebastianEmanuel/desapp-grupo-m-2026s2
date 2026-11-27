human_check_required: true

Decision needed: define the exact input scope and untracked-input policy for the “relevant working-tree diff” used to bind a coverage report.

Why it matters: the report’s principal product claim is that it describes the exact tested snapshot (FR-016/017). The current specification and product handoff intentionally defer this definition. Different choices can either invalidate harmless reports unnecessarily or allow a changed test/configuration input to go unrecorded, making coverage provenance misleading.

Options:

1. Hash all tracked repository changes, and fail when known execution-affecting untracked inputs are present. This is broad and may invalidate reports for unrelated edits, but provides the strongest truthful provenance before commit.
2. Hash only an enumerated CP1 input set (application/test sources, inventory, configs, locks, browser assets), with generated outputs excluded. This is more convenient, but requires ongoing maintenance; an omitted input weakens the report’s claim.
3. Require a clean tree. This is simpler, but conflicts with approved feedback and FR-017.

Recommendation: option 1, with documented checks for untracked execution-affecting inputs and an explicit exclusion for generated report output. It honors pre-commit reporting while avoiding subjective “relevance” omissions.
