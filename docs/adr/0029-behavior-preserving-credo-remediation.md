# ADR 0029: Behavior-preserving Credo remediation boundary

- Status: Accepted
- Date: 2026-10-18
- Feature: TASK-066

## Context

TASK-065 quality integration exposed existing lint debt. Its archived draft is partial, uses a flat analyzer configuration and omits maintained tests. Product decision limits this prerequisite to behavior-preserving cleanup and forbids weakened rules/assertions.

## Decision

TASK-066 owns the minimal exact Credo 1.7.19 dev/test runtime-false prerequisite and all existing first-party default-priority findings. Use Credo's supported named default configuration, inherit stock rules unchanged, independently reconcile all maintained Elixir inputs, and preserve findings-to-change-to-regression evidence. Include full maintained tests, config, migrations and root Elixir configuration. Reject blanket draft reuse. Record hunk assessment before reuse and measure the completed source as a whole.

Discovered behavior defects remain separate work unless explicitly approved. Preserve original evaluation, exception, transaction, locking, ownership and assertion semantics. Use existing unit/integration/E2E profiles and their native runtime assertions, once per final source state; do not add the historical CP1 report as another local CP2 gate. TASK-065 owns later CI/quality/report integrations and depends on this prerequisite.

## Consequences and alternatives

The supported measurement boundary may reveal findings beyond the historical 71; all must be remediated. Exact pin and scope contract tests prevent accidental relaxation. Integration prerequisites include Docker and Chromium as already required by ADR-0028; absence blocks verification rather than allowing skips. No product architecture, external contract or persistence model changes. Reject suppressed findings, restricted test inclusion, strict-priority expansion and duplicated tooling declarations.
