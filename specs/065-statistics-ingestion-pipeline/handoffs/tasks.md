# Tasks handoff — TASK-021

32 tasks: setup 2, foundation 4, US1 7, US2 6, US3 7, developer polish/verification 4, downstream gates 2. The three story test pairs can be authored independently after their prerequisites; one implementation owner, shared publisher/runtime edits sequential.

Foundational tests precede provider/schema changes. US1 is a known-direct-position MVP; US3 completes the approved unknown/derived-position behavior. Do not advertise MVP as feature completion. Frozen committed history deliberately excludes all newly proposed batch rows, and replay must preserve prior derivation after late history arrives.

T028 closes design/source edits before T029 runs the manifest. Only T031 Independent QA and T032 Final review are tagged/mapped as downstream gates. All other tasks, including runtime/process acceptance and test execution, must finish before QA. No historical CP1 coverage report or second full-profile aggregate is required.

No .specify/extensions.yml exists, so before/after tasks hooks are inapplicable. setup-tasks.sh used the already loaded plan/support context and resolved the active feature correctly. Required structural probes and exact identifier coverage are checked during architecture; behavioral checks remain implementation/independent QA obligations, not architecture PASS evidence.
