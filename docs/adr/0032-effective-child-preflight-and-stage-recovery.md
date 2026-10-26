# ADR-0032: Effective-child preflight and durable stage recovery

- Status: Accepted architecture for TASK-070, 2026-10-24; implementation pending.
- Scope: Agentflow tooling; extends ADR-0014 and ADR-0026. No market or checkpoint scope change.
- References: specs/068-agentflow-preflight-recovery/{spec.md,plan.md,data-model.md,contracts/workflow-recovery.md}.

## Context

Launchers and provider shims independently adjust environments. Existing receipts count checks, but TASK-070 counts failed full stage attempts. QA can terminate before writing a complete report. The current local baseline reruns both profiles even when a development manifest already proves them. Critic findings require concrete operational definitions.

## Decision

Build and probe one final in-memory child context, then launch with that exact context. Recheck on relevant changes and immediately before every provider-stage spawn. The shared typed policy owns prerequisite inventories; stages/checks declare applicability. Pure bounded preflight never writes source, artifacts, saved state or services, creates journals or runs profiles. Service observations are transient; actual commands still verify availability. Unknown readiness fails closed.

Persist a stage attempt and ordered check inventory with atomic started/terminal outcomes outside the pure evaluator. Incrementally render a non-PASS partial QA report; finalize handled interruption and recover abrupt termination at next entry. No promise of a newly written report at SIGKILL/power loss. A dependency-aware ordered runner continues only checks proven independent of failed producers and possibly contaminated state. Missing metadata is conservative. Machine completion cannot substitute for independent QA assessment or provenance.

Count each launched failed full stage attempt once, including recovered interruption and nested execution. Two unchanged failures prohibit a third across resume. Retain existing per-check safeguards separately. Retry relevance uses failing-obligation/dependency component digests; receipt reuse retains complete-source freshness. Unrelated edits, run IDs, report writes and unrelated feedback never reset the budget. Corrupt state blocks rather than resetting it. Feedback 1 supersedes the former cap-16 decision: set the repository policy to three total durable feedback repair cycles, preserving counts across resume/run IDs; refuse a fourth and recommend an explicit human-approved split without resets. Retry accounting remains separate.

Replace local baseline execution with a fast fail-closed wrapper-contract/CI-parity check without full-suite fallback. Iterate with focused tests/cheap checks, then freeze and run the complete manifest once; refresh after relevant repairs only when freshness requires it. QA always runs fresh complete checks for workflow, financial, security and other high-risk work; CI, E2E and real HTTP acceptance remain intact. Adapt only recognized saved baseline steps in memory on resume; never rewrite snapshots or infer unknown command equivalence. No historical CP1 coverage or another clean-candidate/full-profile run is added by default.

Allow at most two registered independent static/contract checks concurrently; exact argv allowlisting and declared disjoint effects are mandatory. Mix/E2E remain serial until build/cache, database, ports and browser isolation and stability are demonstrated separately. Record timings and counts, comparing controlled static jobs rather than rerunning full profiles. The additional bounded scheduling complexity implements explicit human feedback.

Document a Vibecode procedure for future small clear reversible low-risk changes: brief spec, effective-child preflight, focused tests, CI, proportionate independent QA/review and human merge. Exclude security, finance, data-integrity, external-contract and workflow changes; uncertain impact uses full flow. TASK-070 delivers this procedure and policy tests, not a new automated gate bypass or lane selector. Existing docs-only fast lane remains separately guarded.

Feature numbering is already resolved by ADR-0014: TASK-070 owns this exact spec branch in specs/068; do not migrate paths or rewrite an active run to match numbers.

## Alternatives and consequences

Parent-shell/outer-only probes miss actual stage differences. Always-on full profiles in preflight waste attempts and mutate state. Per-command stage counting contradicts the specification. Final-report-only persistence loses interruption evidence. Deleting parity/readiness protection loses safeguards, and accepting stale receipts weakens gates. A receipt-aware native fallback was superseded by Feedback 1 because it can repeat the full profiles. The selected shared modules add bounded local records and optional schema-1 manifest metadata, retain provider/legacy compatibility, and require no new infrastructure or application changes.
