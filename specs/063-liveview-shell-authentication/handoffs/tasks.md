# Task-generation delta — TASK-046

29 tasks: US1 six, US3 five, US2 three, US4 three; six setup/foundational and six final acceptance/gate tasks. Order follows P1 US1 then P1 US3 before P2 US2/US4. Test authoring precedes behavioral implementation with explicit red/green checks. Each story has independent acceptance criteria and paired test-authoring opportunities in different files; one implementation owner remains responsible.

Only T028/T029 are QA/review gates, mapped in verification.json. All implementation, browser harness work and developer checks T001–T027 must finish before QA. US1 is the first demonstration increment, not a releasable subset.

Reuse existing tagged profiles and Chromium tooling. Runtime HTTP and browser suites run inside the integration profile, not as another full-profile execution. T024 names the real-listener assertion harness; T014/T022 cover actual browser lifecycle/accessibility. T025 must ensure discovery and missing prerequisites fail closed. No historical CP1 coverage report gate is added; preserve infrastructure and CI.

Before receipts freeze source/design; run six manifest checks and record only helper outcomes in one develop handoff. QA reruns independently, review follows fresh QA PASS. No implementation or publication occurred in architecture.
