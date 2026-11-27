# Validation quickstart

Run from the repository root on TASK-054's delivery branch. This guide is for the implementation owner and independent QA after the planned files/tests exist; architecture does not execute future implementation checks or create receipts.

## Prerequisites

Python 3.10+ and Git are sufficient for acceptance checks. GitHub CLI and authenticated publication are not needed: publication adapters are captured in isolated tests. Phoenix, PostgreSQL and Redis are not affected. No HTTP runtime is required. `tooling-preflight` must fail if Python/Git or the pinned fixture snapshots/provenance are unavailable or inconsistent.

Retain existing snapshots if their pinned hashes match. If unavailable, implementation exports exactly the four files identified in research.md from commit `1aa2731f048efcb1056a589b3b2ea938b843edd4` using read-only `git show COMMIT:PATH`. Place bytes under `test/scripts/fixtures/task_feature_binding/provider/` with original backlog/spec paths and a provenance.json manifest. Verify research.md hashes before use. If the source object is unavailable, obtain that same immutable object read-only; do not fabricate reports or change the real provider branch/task. Once snapshots exist the suite works without a local provider ref or network.

## Feedback diagnostics

Feedback 1 in backlog/feedback/TASK-054.md is authoritative; QA B1 remains a FAIL until independent re-verification. Preserve the original diagnostics and hashes in research.md. `/tmp/task054-independent-qa/adversarial_checks.py` asserts successful exploitation; it is historical diagnostic evidence, not an acceptance check. New tracked shared-matrix cases must assert refusal, no publication/verifier side effects and byte-identical snapshots of all backlog files across resolver, publication, explicit completion, dependencies and actual post-merge CLI.

Before correcting foreign candidate classification, observe the unchanged root probe failure. After the fix, run:

```bash
python3 /tmp/task054-root-missing-feature.py
```

Require exit 0 and the unchanged hash. Track equivalent resolver and actual start-path tests for one/two foreign equal-number specs, stale/absent pointers, unique/multiple headerless candidates, malformed/unsafe/duplicate/same-task declarations and explicit metadata conflict. CI requires those tracked tests; it does not depend on local `/tmp` files. Strict unsupported frontmatter refusal must include whitespace-colon/indented/quoted/case-variant keys and hidden duplicates, with successful canonical quoting/CRLF cases retained.

## Owner execution

Write and run each phase's regressions first; observe that the relevant new assertions fail for the current implementation, then implement that phase. After all code, documentation and test edits, execute the complete manifest through the receipt helper:

```bash
python3 scripts/agentflow_check.py tooling-preflight
python3 scripts/agentflow_check.py resolver
python3 scripts/agentflow_check.py local-delivery
python3 scripts/agentflow_check.py local-completion
python3 scripts/agentflow_check.py post-merge
python3 scripts/agentflow_check.py actual-provider
python3 scripts/agentflow_check.py workflow-scope
python3 scripts/agentflow_check.py stage-probe
python3 scripts/agentflow_check.py syntax
python3 scripts/agentflow_check.py whitespace
```

All previous receipts are stale after this architecture rewind. After all ten manifest checks pass, create handoffs/develop.md and mark T001–T027 complete only after their named outputs/checks exist. Then run `python3 scripts/workflow_artifact_probe.py develop --readiness`; it requires the handoff and complete developer checklist, so cannot run before them. Only Independent QA and Final review stay deferred. Any source or canonical manifest change after checks requires refreshed checks under the conservative receipt rules. Follow docs/AGENT_VERIFICATION.md; do not inspect runner logs or manufacture receipts. Put bounded outcomes and residual risks in handoffs/develop.md, including the root probe and new refusal/start-path assertions. Do not treat the existing QA FAIL or prior developer receipts as fresh acceptance.

## Independent QA

Rerun every verification.json argv directly from repo root, independently of developer receipts. The concrete unittest modules/classes are the test entry points specified in tasks.md. Challenge the following outcomes against contracts/task-feature-binding.md and checklists/architecture.md:

1. TASK-017/055 and TASK-020/054 resolve with unchanged identities; branch matches beat incidental foreign equal-number directories. Legacy only works when its strict preconditions hold. Pointers and mtime do not influence results.
2. Capture local verify/publication calls: links belong to the resolved directory; invalid ownership/reports/workflow code or wrong branch produce no push/PR/review promotion. The TASK-054 captured PR body explicitly says merge before PR #28.
3. Independently challenge strict metadata parsing at every consumer, with single unsupported/duplicate critical-key forms: all backlog bytes must remain identical, with no blocked overwrite or unauthorized side effect. Run post-merge, explicit completion and dependency completion matrices. Assert review/human-merge prerequisites, both terminal report gates and no unrelated mutations. A done post-merge retry with absent reports succeeds unchanged; a wrong full branch still fails.
4. The ActualProviderFixtureTest executes the repository's real reconciler command against a temporary copy of the four exact source snapshots plus distracting/unrelated files. First run changes exactly status review to done and active_run to none, second run changes nothing. Every other input and real source file/ref remains unchanged. Runtime root is always temporary, never the real provider task root.
5. WorkflowScopeTest proves the existing finalize trigger/permissions/concurrency/skip and declared changed-file allowlist. Compare tracked and untracked files with the task's baseline; do not run Elixir suites absent a concrete application impact.

The command exercised inside item 4 is:

```text
python3 scripts/reconcile_merged_task.py --head-ref 017-football-data-api-adapter --root <temporary-fixture-root>
```

Never replace `<temporary-fixture-root>` with the repository root for the actual-provider test. Invalid/missing services or source inputs must fail a relevant check rather than skip it. Independent QA writes qa-report.md and handoffs/qa.md; final review independently inspects implementation, scope and fresh QA, writes review-report.md and handoffs/review.md. Both reports must end exactly `Verdict: PASS` before publication. Humans merge TASK-054 before PR #28.
