# Task-generation delta — TASK-029 feedback 2

30 tasks: setup 2, foundation 3, US1 6, US2 4, US3 5, final owner work 8, independent gates 2. Preserve recorded T001–T022 completion without claiming current check freshness. T023–T026 add authorized diagnostic regression tests, source correction, exact workflow scope/inventory updates and canonical reconciliation. Prior owner checks move to T027/T028; only T029/T030 are mapped/tagged QA/review gates.

T023 demonstrates meaningful failures before T024 implementation. T025 scope updates are test-first. Native Python cases execute under existing unit ownership; integration/E2E retain actual browser launch. No duplicate full profile or historical CP1 coverage wrapper. Finish all edits before T027, run each manifest check through the existing helper and reach readiness in T028 before QA. Preserve attempt history and retry limits. Current feedback supersedes the previous develop handoff's suggestion to send diagnosis to QA first.

Story criteria remain exact transfer/supply/isolation (US1), one immutable result for sequential/concurrent/lost-ack delivery (US2), and unchanged snapshots plus later same-key recovery after rejection (US3). US1 is the development MVP; all P1 stories remain required. Parallel authoring opportunities stay T006–008, T012–013 and T016–018; recovery shared files remain sequential under one owner.

No extensions.yml exists, so before_tasks/after_tasks dispatch is skipped by skill rules. Reused unchanged planning context in this session. No implementation or publication occurred.
