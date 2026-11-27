# Architecture deltas — TASK-066

Resolved all three product-challenge findings in plan.md: discovered defects stay separate; named Credo config covers maintained source with independent inventory reconciliation; changed paths select causal regressions before final profiles. No product behavior decision reopened.

Focused local inspection found the archived flat Credo config is unsupported and misses full test scope; its open version constraint also fails the exact pin. ADR-0029 records the correction. Archive is optional, independently reviewed input with digest verification; no historical test credit. Do not apply it wholesale.

TASK-065 currently declares depends_on: none. Implementation must set TASK-066 as its prerequisite and preserve blocked/todo state. Do not execute its quality integration.

verification.json reuses existing unit/integration/E2E runners. Integration/E2E carry actual assertion-based HTTP/browser checks and internal readiness; separate service preflight checks migration/Redis. No duplicate standalone HTTP run, CP1 collector or new CI integration. QA must challenge semantic preservation and hunk ledger: automatic regressions cannot prove equivalence or future independent verdicts.

All supporting-artifact decisions are plan-owned; research and quickstart apply, data model/contracts do not. Extension hooks are absent (.specify/extensions.yml does not exist); both plan hook phases skipped under skill rules. No implementation or publication performed.
