# ADR-0036: Versioned outcome-first ThinFlow delivery

- Status: Accepted
- Date: 2026-10-27
- Scope: delivery harness and CI topology; application behavior unchanged

## Context

Agentflow 2.3 repeatedly reconstructed the same context across product, critic,
architecture, implementation, QA, and review sessions. Per-feature plan/tasks,
handoffs, generated verification maps, and source fingerprints tied to feedback
caused large PRs and full-stage reruns. Recent tasks required manual completion
after the harness exhausted time or feedback budgets.

## Decision

New tasks use `thinflow-v1`: one compact outcome spec, one accountable builder,
deterministic maximum-severity path/check selection, one independent evaluator,
one PR, one aggregate required CI status, and human merge.

The selected checks and operational receipts are repository policy plus local
evidence, not LLM-authored feature manifests. Unknown paths fail closed. A third
unchanged failed check attempt and a second feedback blocker are refused.
`evaluation.md` is the only versioned independent verdict. ADRs and interface
contracts remain optional when a durable decision actually warrants them.

`.agentflow/workflow.yml` is ThinFlow 3.0. The Agentflow 2.3 definition remains
at `.specify/workflows/desapp-delivery/workflow.yml`, and saved runs replay their
captured snapshot without conversion. No workflow metadata is read by
application runtime code.

`ThinFlow required` aggregates Quality baseline, End-to-end profile, and
SonarCloud using an always-reporting job. Repository maintainers configure that
stable exact-head status as required after observing it; the harness does not
mutate protection rules or merge.

## Consequences

Routine work carries less context and fewer agent boundaries. Risk policy and
check mappings become explicit reviewed code and need updates when new paths are
introduced. Local evidence is intentionally unavailable in another checkout;
hosted CI and the versioned evaluator verdict remain the portable review signal.
Rollback is a reviewed revert of the default workflow and aggregate job while
preserving tasks, saved runs, feedback, and evidence.
