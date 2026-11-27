# Task-generation delta — TASK-026

31 tasks: 8 US1, 6 US2, 6 US3, 5 setup/foundation, 4 developer verification/handoff, 2 independent gates. Tests precede behavioral implementation; file-level parallel opportunities exist among each story's test tasks. Shared production edits remain sequential under one implementation owner.

US1's internal MVP proves fixed-strategy accepted-membership scoring and exact explicit-scale conversion; US2 proves protected original replay, history and canonical deduplication; US3 proves import/crash recovery, fenced bounded retries and stable quote-keyed delivery. The scenario matrix in tasks.md maps all 14 acceptance scenarios to concrete test files/checks. Foundation installs atomic result/quote/event constraints before US1 confirmation; US3 adds automatic delivery/recovery rather than delaying atomicity.

Final checks in verification.json run each full profile once; targeted fresh-BEAM runtime assertions include service readiness. No historical CP1 coverage report or extra full suite is added. T030/T031 are the only deferred gates and are mapped in task_stages. All implementation/applicable tests and developer checks must complete before QA.

Execute T028 handoff before final T029 readiness because readiness requires handoffs/develop.md. Do not infer readiness from generated files or mark a task complete without its named artifacts and passing checks. Architecture checks validate design/manifest structure only; implementation and runtime checks remain for the implementation owner, then independent QA.
