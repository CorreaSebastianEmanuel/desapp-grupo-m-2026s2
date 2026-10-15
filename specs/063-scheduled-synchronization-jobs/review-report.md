# Final independent review — TASK-019 unfiltered CI discovery repair

2026-10-15. Fresh final review of the discovery follow-up to PR #38, against commit `9008f36`; ready for human review/merge. Blockers: none.

Read AGENTS.md, product, architecture, checkpoints, constitution, canonical specification/plan/tasks/verification manifest, focused diff and current development/QA handoffs. No implementation edits, delegation, Agentflow invocation or prohibited workflow-run inspection. Earlier implementation review, missing/stale metadata checks and catalog fixture timeout evidence remain historical; they are not claimed as fresh review execution.

The only implementation delta adds the exact `test/fixtures/synchronization/expected.exs` path to Mix's non-test discovery inventory and the provider guard's expected inventory. Direct inspection confirms that file contains a bare expected-value map, without a test module. Synchronization fixtures still explicitly load it using `Code.eval_file/1`. No test is excluded; exact dependency version, duplicate-Oban and unrelated dependency mutation assertions remain intact. No production API, schema, permissions, provider access or financial/statistical behavior changes.

The plan explicitly permits this bounded discovery correction. The manifest adds the actual `sh scripts/ci_unit_tests.sh` command, mapped to FR-016. Direct inspection confirms that command runs unfiltered tests with warnings treated as errors, propagates the exit status and requires the discovery sentinel. This closes the concrete gap left by explicitly listed profile files rather than replacing either profile. No specification change or downstream backlog adjustment is needed.

After QA explicitly released the shared database, reviewed refreshed qa-report.md, handoffs/qa.md and all eleven canonical receipts. Fresh independent QA executed every command with stage `qa`, no receipt reuse and zero exits: unit 15.944 seconds, integration 111.359 seconds, runtime HTTP 3.433 seconds and exact CI discovery 91.808 seconds. The profiles and runtime checks retain the maintained acceptance coverage; exact CI discovery also passes warnings-as-errors and its complete-discovery sentinel. No test totals are inferred from receipts.

Review-time validation independently recomputed source and design fingerprints and every manifest command identity. All eleven QA receipts bind current source `8d835de6e1e90ff1ffc042f333c5dac5d47fd500646325380171a31af7116f04` before and after execution and current design `fb0391a7bb1f074902cf9473e0cddc8aac85a25c087cda651f27261b178970b8`. Receipt stages, exit codes and reported durations match QA; QA attempt histories record zero consecutive failures. Evidence references/digests were inspected in canonical receipts without opening prohibited evidence directories. Independently ran `git diff --check`: exit zero. No uncovered runtime risk warrants another duplicate suite.

Publication must retain these reviewed inputs and successful PR checks. Humans retain merge authority. Browser E2E, charts, valuation and conditional orders remain separately owned; this repair does not claim CP2 completion.

Verdict: PASS
