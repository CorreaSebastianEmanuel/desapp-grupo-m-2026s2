# Architecture alignment audit — 2026-10-06

This audit concerns design completeness and executable acceptance preparation, not implementation/QA success. Authoritative TASK-017 feedback 1 corrects B1 through ADR-0015; prior QA FAIL remains historical evidence until fresh verification. `spec.md` and approved product decision are unchanged.

| Critic finding | Resolution | Implementation/test tasks | Manifest evidence |
| --- | --- | --- | --- |
| Actual source scope evidence | Documented discovery dates/current season + team competition evidence, final discovery; no invented squad discriminator; atomicity limitation explicit in ADR-0014 | T009–T014 | adapter-catalog, adapter-errors, transport-runtime |
| One-sided stale transfer | Verify every person's currentTeam against enclosing squad; missing/contradictory evidence fails whole request | T010–T013 | adapter-catalog, adapter-fixtures |
| Complete collection and quotas | Sequential 3+T+P, 523-call example, call-11 quota exhaustion, no waiting/retry; live-feasibility bound explicit | T002, T021, T026–T030 | adapter-errors, adapter-deadline, adapter-fixtures |
| Transport credential containment/cleanup | Fixed verified TLS origin, numeric paths, no redirects/proxies, redacted state, status preservation without raw bodies; real peer-close evidence | T004–T008, T015–T020, T022, T027, T037 | adapter-safety, transport-runtime |
| Checkpoint overclaim | Current catalogs conditional; historical/performance unsupported; TASK-021 source suitability risk and separate valuation path remain visible | T031, T034, T042, T045/T046 | adapter-errors, adapter-fixtures, scope |
| QA B1: stale retry delay at complete readiness | Original header receipt pair + worker-local expiry registration; only Runner.run/4/private helpers refine valid rate_limited at existing ready_us; Error/Runtime/public shapes and legacy adapters unchanged | T021/T022/T024/T025 before T026–T028; T030/T033/T036/T037/T043–T046 | retry-expiry, adapter-errors, transport-runtime, scope, provider-contract, regression |

## Coverage and ordering

- All 17 FR and six SC identifiers map exactly to existing executable check IDs. No AC identifiers occur in the canonical spec. Every one of its 19 numbered scenarios has a stable fixture prefix in contracts/fixtures.md.
- Setup/foundation precede four story phases in spec priority order. T004/T005 precede configuration/transport implementation, T009/T010 precede catalog/evidence implementation, T015/T016 precede operator safety changes, T021/T022/T023/T024 and constrained guards T025 precede B1 failure/deadline/readiness integration T026–T028, T031 precedes final fixture/documentation completion. Foundation transport assertions do not depend on the later facade.
- Tasks use 46 unique sequential IDs, explicit paths and correct story labels. Only Independent QA T045 and Final review T046 carry gate tags and task_stages entries; every other task must complete before readiness.
- Product invariants remain protected by no financial/domain/persistence mutations, exact state-isolation assertions, AST boundaries and full regressions. CP2 support is documented without implying performance-to-quote completion. Existing CP1 profiles/coverage and CP3 layer boundaries are preserved.
- Preserve unaffected historical completion; reopen B1 tasks and every owner-check task. New retry-expiry is portable; original /tmp QA probes remain unchanged and supplement tracked independent assertions. No previous receipt proves this correction.
- Fixture checks require no external services/network; separate actual TLS checks include failing readiness and HTTP status/header/body/destination assertions. Existing local service preflight precedes isolation/application/profile evidence. Independent expected facts plus actual adapter execution prevent success-shaped invented fields.

## Executed architecture checks

`setup-plan.sh --json` and `setup-tasks.sh --json` succeeded and resolved the active 055 directory. The actual Git branch remains 017. `workflow_artifact_probe.py plan --readiness` and `tasks --readiness` accepted the artifacts/manifest. Local structural audit checked sequential IDs, story counts/labels, unique gate mapping, all 23 requirements, 20 checks, required support artifacts and handoff word limits. `git diff --check` passed. A targeted final audit validates all 19 scenario links, local Markdown links, test-first dependencies, exact gate mapping, completed-task outputs, current feedback/ADR alignment and untouched production/spec/fixtures. Evidence command: `python3 /tmp/task017-architecture-audit.py`; no behavioral acceptance ran in this session.

`.specify/extensions.yml` is absent: all four before_plan/after_plan/before_tasks/after_tasks hook discovery points found no registered hooks to invoke. No hooks were simulated, no behavioral checks/receipts fabricated and no implementation/publishing performed. The implementation owner executes the manifest before fresh independent QA/review.
