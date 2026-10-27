# Outcome specification: Migrate Agentflow 2.3 to ThinFlow

**Feature Branch**: `071-migrate-agentflow-2-3-to-thinflow`

**Task**: `TASK-071`

## Outcome

New work uses a faster, bounded delivery harness with one builder, deterministic
risk-selected checks, one independent evaluator, one aggregate hosted gate, and
human merge. Historical Agentflow 2.3 runs remain resumable without conversion.

## Acceptance

- [ ] `agentflow create` defaults new tasks to `thinflow-v1`; `start --dry-run`
  shows the outcome → builder → checks → evaluator → PR/CI flow.
- [ ] The default workflow launches exactly one builder and one evaluator and
  does not require product, critic, architecture, tasks, or review sessions.
- [ ] A compact spec is sufficient; plan/tasks/research/data-model/quickstart
  and handoffs are optional rather than readiness requirements.
- [ ] The actual diff deterministically selects the highest applicable risk and
  unions checks from rules at that tier; empty or unmapped changes fail closed.
- [ ] Required local checks produce current local receipts, and a third failed
  attempt with unchanged material inputs is refused.
- [ ] Exactly one independent `evaluation.md` with terminal `Verdict: PASS` is
  required before publication; only evidence-backed blocking findings fail,
  re-review is delta-focused, and one grouped repair cycle is the maximum.
- [ ] GitHub exposes one always-reporting `ThinFlow required` result that fails
  unless Quality baseline, End-to-end profile, and SonarCloud all succeed.
- [ ] Application runtime and business behavior do not read workflow metadata.
- [ ] Saved 2.3 workflow snapshots retain their original stage and report gates.
- [ ] Operator docs, repository rules, skills, and automated harness tests agree
  with the new default.
- [ ] Escaped defects feed the earliest executable regression layer; reviewer
  changes replay historical misses offline instead of adding a per-PR loop.

## Scope

- Agentflow CLI dispatch, ThinFlow policy/check runner, workflow definitions,
  independent-evaluation readiness, CI aggregation, tests, skills, and docs.
- One reviewable PR; no automatic merge or repository-protection mutation.

## Non-goals

- No Football Player Market behavior, schema, endpoint, or domain-rule change.
- No bulk rewrite or deletion of historical specs, runs, feedback, or evidence.
- No new orchestration service, package dependency, or LLM risk classifier.

## Risk

- High: this changes delivery and CI gates. Unknown paths fail closed, legacy
  snapshots remain versioned, and rollback is a reviewed revert of the default
  workflow plus CI aggregate while retaining all history.

## Decisions

- Path/risk/check selection is pure deterministic Python plus reviewed JSON.
- Operational receipts stay ignored under `.agentflow/runs/thinflow/`.
- The aggregate hosted gate is configured in code; maintainers enable its
  branch-protection requirement only after observing it on this PR.
- Versioning and compatibility rationale is recorded in ADR-0037.
