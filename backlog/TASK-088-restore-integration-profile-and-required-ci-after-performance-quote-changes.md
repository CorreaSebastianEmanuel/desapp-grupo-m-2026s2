---
id: TASK-088
title: Restore integration profile and required CI after performance quote changes
type: task
checkpoint: CP2
priority: critical
workflow: thinflow-v1
status: review
depends_on: none
active_run: 13d50a0d
---

## Outcome

Reproduce and repair the integration-profile failures reported by main CI run 41729746562 on revision 43122ca, including conditional orders, purchases, sales, portfolio, provider scope and browser workspace cases. Diagnose shared root causes before changing code; preserve the performance-derived quote requirement and all financial, authorization and transaction invariants. Keep existing assertions meaningful, update only stale fixtures or implementation defects supported by evidence, and retain required CI, coverage accounting, inventories and security checks without exclusions or weakened gates. Verify representative regressions first, then the selected local checks and the exact PR head passing ThinFlow required. Keep architectural reorganization outside this repair.
