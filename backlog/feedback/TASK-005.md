# Feedback — TASK-005

## Feedback 1

- Time: 2026-09-17T12:31:57+00:00
- Author: ezequielgonzalez
- Restart from: develop

Independent QA found three implementation blockers: (1) SC-007's 100,000-player EXPLAIN fixture places every row under identical filters, so PostgreSQL correctly chooses sequential scans; redesign representative data and evidence to prove individual and combined lookup paths are selective and index-capable without forcing planner settings. (2) FR-014 requires stable UUID lookup for every entity; add get_season/1 and get_player/1 plus acceptance tests. (3) SC-003 requires representative correctness across all five leagues, at least two seasons, multiple teams, and configured positions; add the missing dataset and filter assertions. Preserve the domain/persistence-only boundary and rerun focused/full suites.

## Feedback 2

- Time: 2026-09-17T12:41:08+00:00
- Author: ezequielgonzalez
- Restart from: develop

Independent QA found incomplete mandatory acceptance coverage: add the full exact/case/whitespace uniqueness matrix for every declared uniqueness scope, explicit unsupported league code/name rejection, missing player position relationship rejection, and protected league deletion with unchanged-state assertions. The unrelated workflow artifact-probe changes have been removed from the TASK-005 working tree and preserved separately. Preserve the approved catalog domain/persistence boundary and rerun all focused, query-plan, full-suite, formatting, compilation, and diff checks.

## Feedback 3

- Time: 2026-09-17T12:47:32+00:00
- Author: ezequielgonzalez
- Restart from: develop

The user explicitly requires preventing stuck tasks. Treat the workflow artifact-probe repair as an approved, narrowly scoped delivery-tool exception now documented in FR-020, plan.md, and T035. It must safely expand repository-relative globs, reject unmatched or escaping paths, and remain isolated from runtime product behavior. Verify its regression tests together with all catalog acceptance coverage and proceed through independent QA/review.

