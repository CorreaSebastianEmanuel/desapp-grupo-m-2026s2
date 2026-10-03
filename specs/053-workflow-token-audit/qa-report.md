# Independent QA — TASK-053 authorized optimizations

Fresh independent QA session, 2026-10-01; targeted independent follow-ups on 2026-10-03 after the HTTP-contract and nested-step parser corrections. Read PRODUCT, ARCHITECTURE, CHECKPOINTS, constitution and TASK-053 spec/plan/tasks/challenge. Inspected the authorized runner, bridge, readiness modules, artifact probe, workflows, planning skill, tests and adoption documentation. QA modified only this report; it did not inspect real run logs, execute real agents, publish, or mutate TASK-015.

## Executed evidence

| Check | Result |
|---|---|
| `python3 -m unittest discover -s tests -v` on the corrected final implementation, rerun 2026-10-03 | 50 tests PASS |
| `python3 -m unittest discover -s test/scripts -p 'workflow_artifact_probe_test.py' -v` | 7 tests PASS |
| `python3 -m unittest discover -s test/scripts -p 'agentflow_branch_test.py' -v` | 8 tests PASS |
| Specify's installed `WorkflowDefinition` and `validate_workflow`, loading both YAML files | Both PASS: identical workflow 2.3.0, 12 steps, six agent sessions |
| Skill creator `quick_validate.py .agents/skills/speckit-plan`, using Specify's Python environment | PASS |
| Scoped `git diff --check` covering the authorized implementation and documentation | PASS |

Readiness tests reject absent/failed/stale receipts, changed output hashes, changed or deleted tracked source, new untracked source, source changes during execution, incomplete implementation, malformed/duplicate coverage, missing HTTP assertions and mismatched deferred-task tags. Independent synthetic checks additionally verified that an interrupted check cannot reuse earlier success, unknown requirements and duplicate mappings are rejected, and empty runtime expectations fail.

QA found two concrete freshness/runtime defects: supporting feature contracts were not fingerprinted, and `GET /` escaped runtime detection. The implementation owner corrected both and added regressions. Independent reruns now reject changed/deleted contracts and newly added design inputs after a successful receipt; root-route declarations require runtime assertions. No unresolved blocker remains.

The follow-up independently reproduced the original OpenAPI YAML runtime omission fixture against the corrected detector: unit-only evidence is rejected and an assertion-classified runtime check is accepted. Twelve independent fixtures cover YAML/YML block/flow mappings, quoted root paths, custom-action paths, referenced path items, OpenAPI JSON/root/path maps, nested RAML, mixed-case HTTP methods, Markdown and text contracts. All require runtime checks. Non-HTTP JSON/YAML/Markdown remain accepted; malformed and duplicate-key JSON contracts fail validation. The corrected module and new regression tests pass scoped whitespace checks. No additional blocker was found.

The mocked executable pipeline preserves fragmented Unicode human gates and piped stdin while suppressing agent payloads; it returns the runner's nonzero exit. Independent executable probes also cover ANSI prompts without newline, EOF, JSON errors/nonzero agent exits, and SIGINT cancellation: the supervisor returns 130, terminates its isolated runner group and removes the active process marker. Interrupted check receipts retain failure.

Fresh, reused and resumed CLI fixtures preserve unavailable dimensions as null. Resumed threads without a baseline and regressed/subsequent counters remain unknown. Public summaries omit private identities, hashes, prompts and tool sentinels. Failure and incomplete-attempt counts remain visible; aggregate totals count only available dimensions without adding cache twice.

Snapshot fixtures verify both legacy separate planning and current combined planning, saved step indexes, unchanged snapshots, applicable prior human approval retention, product rewind approval invalidation, and task-specific history/status. Both planning artifact gates and independent QA/review remain required. Scoped research guidance preserves plan hooks and supporting artifacts. Documentation describes local evidence, conservative metric limits, unchanged merge authority and future-run adoption without migrating TASK-015.

The parser follow-up independently checks nested `human_product_check` gates under both unindented and two-space top-level lists, in legacy and combined workflows. All four fixtures exclude nested IDs from the execution order, rewind to the exact development index, retain applicable approval, discard it on product rewind and preserve the saved YAML. Both canonical definitions and schema-serialized snapshots match their actual top-level YAML step order (12 steps), without reading a real saved run. The latest complete 50-test suite and scoped whitespace check pass. No blocker remains in this narrow correction.

Limits: mocks establish runner behavior, not future agents' semantic test coverage or realized token savings. No application HTTP behavior changed, so application runtime delivery was outside this scope. POSIX cancellation was executed; Windows forwarding/process behavior remains an explicitly documented platform limit. Earlier retained-log audit evidence was not regenerated; its parser regressions pass in the final suite. TASK-015 preservation has no pre-QA hash baseline.

Verdict: PASS
