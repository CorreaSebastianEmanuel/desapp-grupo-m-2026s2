# Product handoff — TASK-063

No unresolved product decision remains. Human feedback corrected the earlier assumption that chart and conditional-order journeys could be required before their owning tasks are implemented. Keep the dependency boundary aligned with TASK-014 and TASK-046; use TASK-019 as the implemented background-work foundation.

Planning should first inventory current unit/integration discovery, coverage, and required CI checks. Choose the end-to-end CI gate and document its prerequisites without changing that baseline. Keep implementation limited to test profiles and evidence; future chart/order journeys belong to their owning tasks and TASK-034.

The current branch declaration is `063-separate-unit-and-end-to-end-test-profiles`; the canonical feature directory is `specs/065-separate-unit-and-end-to-end-test-profiles`. No run directories were inspected, and this product-stage work makes no implementation or execution claims.
