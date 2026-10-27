# ThinFlow 3.0

ThinFlow is the default delivery harness for new backlog tasks. It keeps the
behavioral contract and independent evidence while removing mandatory sessions
and documents that repeated the same context.

```text
outcome task → compact spec → one builder → risk-selected checks
             → one independent evaluator → one PR
             → ThinFlow required CI → human merge
```

## Contract

New tasks created by `./agentflow create` carry `workflow: thinflow-v1`.
`start` creates a compact `spec.md` with Outcome, Acceptance, Scope, Non-goals,
Risk, and material Decisions. The builder must make those sections concrete
before changing behavior. `plan.md`, `tasks.md`, research, data models,
quickstarts, handoffs, and duplicate QA/review reports are not default
artifacts. Add an ADR or contract only for a durable decision or interface.

An unresolved choice pauses only when it materially changes observable
behavior, business rules, scope, permissions, security, data integrity, or an
expensive and difficult-to-reverse design.

## Risk and checks

`.agentflow/thinflow.json` is the reviewed path-to-risk/check registry. The
actual diff is classified after building; the highest tier wins and matching
rules at that tier contribute the required check union. Lower-tier fast-lane
checks are alternatives, not extra gates on a higher-risk change. Unmapped
paths and empty change sets fail closed. The builder may use focused tests while iterating, but
`scripts/thinflow.py check TASK-NNN` owns the authoritative local selection,
execution, receipt, and freshness check.

Operational receipts live under `.agentflow/runs/thinflow/` and are not
versioned. They bind the policy, changed paths, material file content, command
result, elapsed time, and bounded log hash. `evaluation.md` is excluded only as
the downstream evaluator output. After two failures with the same material
digest, a third attempt is refused until a relevant input changes.

## Evaluation, repair, and CI

The evaluator is a fresh non-builder session. It reads the compact contract,
`REVIEW.md`, diff, implementation, classification, and current receipts; it
runs only targeted checks needed for a concrete discrepancy. Findings must be
validated against code or runnable evidence and classified as blocking or
advisory. Nits, speculative cleanup, and pre-existing issues cannot fail the
change. `evaluation.md` must end exactly in `Verdict: PASS`.

One grouped feedback repair returns to the same builder and requires fresh
checks plus a fresh evaluation of the repair delta and affected surfaces.
Repeated findings are not new work, and all instances of one root cause are
repaired together. A second blocker requires a human decision, a different
approach, or a task split. Feedback text, spec changes, and policy changes are
material inputs; unrelated edits do not reset check failure history.

Publication creates one PR in pending-CI state. GitHub Actions exposes the
stable `ThinFlow required` job with `if: always()` over Quality baseline,
End-to-end profile, and SonarCloud. Configure that single status as required on
`main`; keep existing required statuses until it has been observed on a PR.
Only the exact PR head may authorize human merge.

## Learning from misses

An escaped defect or revert is feedback about the system, not a reason to add
another mandatory reviewer. The incident review identifies the earliest layer
that could have caught it and adds the smallest durable regression there: a
test/check first, then a concise rule in `REVIEW.md`, AGENTS.md, or the relevant
skill only when executable coverage is not enough. Reviewer prompt, model, or
tool changes must be exercised against those historical regressions before
becoming the default. This replay is an offline harness-maintenance activity,
not another per-PR loop.

## Compatibility and recovery

`.specify/workflows/desapp-delivery/workflow.yml` remains the Agentflow 2.3
definition for saved runs. `resume` replays the workflow snapshot captured by a
run; it never converts historical artifacts or evidence. New work must not use
`--legacy` unless a maintainer explicitly requests a 2.3 task.

Useful commands:

```sh
./agentflow create "Title" --outcome "Observable result"
./agentflow start TASK-NNN --dry-run
./agentflow start TASK-NNN
./agentflow status TASK-NNN
./agentflow resume TASK-NNN
python3 scripts/thinflow.py select TASK-NNN
```
