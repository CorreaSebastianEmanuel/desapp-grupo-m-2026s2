# Tasks delta — TASK-019

38 tasks: setup/foundation 8; US1 9; US2 4; US3 9; developer verification 6; independent gates 2. Only T037/T038 map to deferred task_stages. Every applicable implementation and test task must complete first.

Use the quickstart scenario matrix to author expected results before implementation, especially final-attempt crashes and stable-reference drift. Keep prepared deliveries distinct from begun attempts when testing budget accounting. Crash harnesses must actually terminate owned runtime processes against committed PostgreSQL rows; repeated function calls or shared-connection sandbox races are insufficient.

T005 is necessary integration with existing working-tree scope checks, not permission to relax them. T008 preserves the issuance configuration hash. The receipt extension is limited to the two existing ingestion files plus its neutral protocol/schema; provider and reconciliation rules stay intact.

T009/T010 and T022–T025 have separate-file parallel opportunities; shared Store/dispatcher changes stay sequential with one implementation owner. US1 is the MVP validation increment; all stories are required before QA. No additional agents are requested.

No acceptance test, runtime check, QA or review has been executed by architecture. Run each manifest check after final edits; runtime/services require fresh execution. QA uses independent receipts. No historical CP1 coverage report or duplicate full-profile invocation is added. Source access remains denied outside approved fixtures; CP2 charts/orders/browser E2E remain separately owned.
