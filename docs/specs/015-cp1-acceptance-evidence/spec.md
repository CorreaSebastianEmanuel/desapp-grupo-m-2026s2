# TASK-015 — Withdraw automated checkpoint acceptance

The user withdrew automated checkpoint acceptance on 2026-10-03. This specification supersedes the earlier CP1 evidence feature. Checkpoint compliance is assessed by the team during its manual demo.

- FR-001: Remove the CP1 acceptance Actions workflow, automatic demo scripts, manifest, hosted receipt collector, evaluator, fixtures, obsolete contracts and publication instructions.
- FR-002: Remove future TASK-035 CP2 acceptance automation and repair TASK-052 dependencies to retain TASK-034. TASK-051 retains functional scenarios and tests, with manual demonstration; TASK-052 retains release preparation without an acceptance workflow.
- FR-003: Preserve the existing quality baseline, Sonar analysis/gate, Agentflow finalization and TASK-053 optimizations. Retain the independently tested seed failure cleanup fix because it prevents delayed database error logs and baseline flakiness; no checkpoint acceptance claim follows from it.
- FR-004: Obtain independent QA and final review for this withdrawal before publication. Earlier CP1 verdicts are superseded.

SC-001: Automated withdrawal regression checks and the retained quality checks pass; PR metadata describes the resulting scope and makes no automated CP1 acceptance claim.
