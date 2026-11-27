# Product challenge — TASK-066

## Material findings

1. **FR-008 leaves room for scope expansion.** The backlog outcome and FR-005 prohibit behavior changes, while FR-008 says a behavior correction discovered during cleanup must be tested. That could be read as authorizing fixes to unrelated bugs. **Recommendation:** Treat any discovered defect as evidence to report and route to a separate task; only a behavior correction explicitly approved through scope change should be implemented here. This preserves the stated compatibility baseline.

2. **“Every existing first-party finding” needs an auditable measurement boundary.** FR-004 names broad source categories, but neither the spec nor handoff defines how the standard invocation covers them or excludes generated/third-party code. Zero findings (SC-001) is measurable only once that boundary is explicit. **Recommendation:** Have architecture record the exact Credo command, scanned paths, and any exclusions in the plan or command documentation; exclusions must not omit maintained first-party source. Capture the pre-cleanup finding inventory as comparison evidence, while keeping zero findings as the completion criterion.

3. **“Relevant” regressions are not selected by a stated rule.** FR-009 requires relevant unit, integration, and browser E2E checks but does not define how changed files map to affected behavior. **Recommendation:** Require the implementation/QA handoff to name the changed paths and corresponding regression commands, including browser E2E coverage where authentication, financial, or native-profile paths are touched. This makes the preservation claim reviewable without prescribing a new product requirement.
