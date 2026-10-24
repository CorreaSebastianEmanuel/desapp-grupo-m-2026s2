# Architecture delta — TASK-029 feedback 2

Preserve the approved self-purchase rejection, funding exclusion, quote decision point and financial invariants in spec.md and ADR-0032. Historical product-decision.md remains challenge provenance; the stage instruction explicitly confirms human approval. No new product decision is pending.

Current feedback authorizes one shared-tooling exception: actionable safe browser launch causes. Local inspection identifies the inline preflight catch, supervisor output filter and safe_failure_diagnostics consumer as the missing chain. ADR-0033 and contracts/profile-diagnostics.md define a closed five-cause enum, fail-closed forwarding and compatibility. Add only the named runner/helper/test paths to workflow scope; no package/browser install or application behavior change.

Owner must write refusal/compatibility tests first, implement the relevant source correction, register native unit cases and freeze all source/design inputs before retrying integration through the existing helper. Do not clear attempt history or treat planning edits as a recovery fix. Preserve reported prior attempts. Unit runs the new regression cases; integration/E2E retain real preflight. No duplicate full profiles or historical CP1 coverage gate.

verification.json retains all FR/SC mappings, service preflight and fresh assertion-based live HTTP checks. Existing receipts may be stale after revision; helper freshness decides explicit development reuse. Owner must complete every applicable check and development readiness before independent QA. This supersedes diagnosis-first QA guidance in the previous develop handoff. QA reruns independently.

No extensions.yml exists: before_plan/after_plan dispatch is skipped by skill rules. Only architecture artifacts changed in this session; no implementation, runtime checks or publication performed.
