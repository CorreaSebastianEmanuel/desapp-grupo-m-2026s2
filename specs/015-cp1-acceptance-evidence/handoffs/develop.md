# Development handoff — TASK-015

## Changes and decisions

- Q1/Q2 follow-up ownership: the root agent corrected the final two QA blockers after the runner exhausted its three feedback entries (one was a technical rewind correction). No feedback limit or saved run state was changed. New independent QA must pass before resuming the existing QA gate and final review.
- Manifest validation now enforces nonempty criteria, complete unique FR/SC traceability, and governing receipt/class/supporting-regression mappings. A Sonar obligation cannot consume a demo receipt. Malformed-manifest/remapping tests failed before the correction and pass afterward.
- The sanitized seed failure boundary now stops only an application started by that failed invocation before restoring logging. A deterministic 1.5-second observation test reproduced late Postgrex retry output before the fix; all 13 seed tests and the complete baseline pass afterward. Existing successful seeding and borrowed application ownership are preserved.

- Earlier B1–B4 corrections remain in the implementation and `contracts/cp1-acceptance.md`: governing hosted identity, mandatory matching local evidence, cited-content safety, and source-free coverage publication. Verify them alongside Q1/Q2. Toolchain activation and complete commands remain in `quickstart.md`.

## Command outcomes

After Q1/Q2: formatter, warnings-as-errors compile and diff checks passed; seed tests: 13; complete baseline: 196 passed/4 excluded. Full coverage completed both profiles (21 unit/32 integration audited files), 20 sources. Python: 28 passed using the newly generated real HTML. Two final demos: PASS, 6 seconds each, all 26 behaviors and current matching snapshot fingerprints. Exact commands/artifacts are in `quickstart.md`. Earlier unchanged CP1 contracts and OpenAPI checks passed; independent QA must execute applicable checks afresh.

## Risks and exact QA guidance

Independently rerun the complete quickstart sequence, including coverage and two demos. Set `CP1_REAL_COVERAGE_DIRECTORY` to that run's report directory for the Python suite. Reproduce remapping a failed Sonar receipt, malformed criteria/traceability, and delayed database retry output; retain governing-run, missing/unsafe bundle and real coverage checks. Confirm dirty evidence stays NOT PASSING. Earlier isolated successes did not replace failed complete checks; latest complete baseline/coverage are passing.

T001–T043/T047/T048 reconciled; T044/T045/T046 remain unchecked. Hosted exact-SHA acceptance is unobserved. TASK-053 is preserved. Proceed to fresh independent QA, then the runner's fresh final review before publication.
