# Feedback — TASK-075

## Feedback 1

- Time: 2026-10-30T23:57:08+00:00
- Author: sebo
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Automated required-check finding from the authorized TASK-075 run; this is not a new human product decision. The candidate failed its first deterministic check, ci-contracts, at test/ci/sonarcloud_contract_test.exs:11/19: the approved Quality baseline workflow additions changed the actual SHA-256 to ef45f6b915217301fee281bbb509a665edee0da0c17eb82eb4ca331381f73476 while test/ci/fixtures/quality-baseline.sha256 still records ac8bf5d1c5333ea6fba9e137da4eb06563aa025ff61eb41a8d49df6523006fd4. Review the final workflow diff, refresh only the matching byte oracle, and preserve the assertion and all existing gates. Group the complete verification bookkeeping repair now: register the exact actual TASK-075 tracked/untracked diff in test/support/workflow_scope.ex, including the oracle, scripts/config inventories, this feedback and docs/WORKFLOW_LESSONS.md; extend focused scope allowance/refusal assertions; verify every new native test is in the unit inventory and all helper/source inventories reconcile. Preserve the Feature Branch/Task metadata and acceptance checkboxes already restored in the compact spec. Do not change application behavior, suppress warnings, weaken contracts or alter ThinFlow selection policy. Run the full focused CI contract set selected by ThinFlow plus inventory/scope checks, and rerun only any other focused control needed for this repair. Leave the complete risk-selected checks and fresh independent evaluation to the saved workflow. The cold/warm analyzer results and real unsafe/corrected controls are already documented; do not repeat cold benchmarks without a changed relevant input. This is the single grouped repair for the observed verification-bookkeeping root cause. Do not inspect workflow run directories.

