human_check_required: true

Two unresolved choices materially affect observable behavior and data integrity; no TASK-006 human-feedback file or governing document resolves them.

1. **Normalized target identities:** When an existing identity differs from the manifest only by TASK-005 normalization (case or surrounding whitespace), must the run preserve and reuse it, reject it, or rewrite it?
   - Preserve/reuse: honors FR-011 and normalized reuse, but “same target dataset” must mean semantic rather than byte-identical equality.
   - Reject: keeps manifest values exact, but contradicts the stated normalized-reuse outcome.
   - Rewrite: makes output exact, but violates the prohibition on modifying matching developer data.

   **Recommendation:** preserve/reuse normalized-equivalent identity values; define convergence by normalized business identity and relationships, with exact comparison only for non-identity canonical attributes.

2. **Production invocation:** Is manual execution against a production runtime forbidden, or is only automatic loading forbidden?
   - Fail closed outside explicitly allowed development/demo environments: protects authoritative data; production-like demonstrations need a designated non-production environment.
   - Permit deliberate production invocation: offers flexibility but allows fictional records to contaminate live catalog data.

   **Recommendation:** fail closed in production and expose the action only through an explicit development/demo entry point.
