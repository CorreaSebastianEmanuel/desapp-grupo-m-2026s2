## Outcome

**Feature Branch**: `088-restore-integration-profile-and-required-ci-after-performance-quote-changes`

**Task**: `TASK-088`

Reproduce and repair the integration-profile failures reported by main CI run 41729746562 on revision 43122ca, including conditional orders, purchases, sales, portfolio, provider scope and browser workspace cases. Diagnose shared root causes before changing code; preserve the performance-derived quote requirement and all financial, authorization and transaction invariants. Keep existing assertions meaningful, update only stale fixtures or implementation defects supported by evidence, and retain required CI, coverage accounting, inventories and security checks without exclusions or weakened gates. Verify representative regressions first, then the selected local checks and the exact PR head passing ThinFlow required. Keep architectural reorganization outside this repair.

## Acceptance

- [ ] Reproduce the reported integration failures using focused cases and identify their shared causes before editing implementation.
- [ ] Conditional orders, purchases, sales and portfolio scenarios establish the performance quote they require; issuance-only purchases remain rejected and issuance-only conditional orders remain pending without financial effects.
- [ ] Concurrent and idempotent operations retain their original ordering, quantity, balance, ownership and immutable-evidence assertions.
- [ ] Provider scope checks recognize this task's exact repair paths without relaxing unrelated ownership checks. Browser workspace assertions match the current visible interface and prove the intended navigation and authentication behavior.
- [ ] The quality-baseline job has a bounded 60-minute timeout; all existing steps, analyzers, audited profiles, coverage reconciliation, exclusions and required gates remain unchanged. Its byte oracle and exact task scope agree with the repair.
- [ ] All repaired cases pass focused tests, with existing profile membership, coverage accounting and required security/CI gates preserved. ThinFlow performs selected checks, independent evaluation and exact-head hosted validation after development; human merge remains required.

## Scope

- Repair stale fixtures, assertions or evidenced implementation defects in the integration cases reported by CI run 41729746562 at 43122ca, plus directly affected test support and inventories.
- Apply Feedback 1’s narrow quality-baseline job timeout repair, including the workflow byte oracle and affected contract/scope assertions.

## Non-goals

- New product rules, architectural reorganization, workflow-policy changes beyond the approved job timeout, runner redesign, test exclusions and weakened checks.

## Risk

- Financial regression risk: fixture quotes and concurrent ordering must represent the authority actually used by trades. Preserve positive performance quote eligibility, supply of 100, decimal precision, atomicity, idempotency, authorization and append-only evidence. Deterministic path classification is authoritative.

## Decisions

- Keep the existing product contract. Provide explicit performance quotes only in scenarios requiring executable trades; retain explicit issuance-only negative controls. Do not fabricate a product exception to restore legacy fixture expectations.
- Compare monetary values with exact decimal equality, independent of stored scale; count jobs added by the action against the fixture baseline. Keep the original financial and durability assertions.
- Scope the browser's active-page assertion to workspace navigation. The secret-storage check permits only LiveView's existing `phx:nav-history-position` session key with a nonnegative integer value; local storage and all other session keys remain forbidden.
- Feedback 1 reports PR #98 head `28e87c9`, hosted run `41748789435`, quality job `126308391946`: execution started around 00:42 UTC on 2026-11-04 and was cancelled at 01:17 during `application_coverage.py`, at the existing 35-minute limit. No profile failure diagnostic was emitted before cancellation; E2E and SonarCloud passed on that head. Increase only this job’s timeout to the recommended 60 minutes to leave bounded room for setup, analysis and audited profiles. This evidence does not establish a completed quality pass; fresh ThinFlow checks, independent evaluation and exact-head hosted validation remain required.
