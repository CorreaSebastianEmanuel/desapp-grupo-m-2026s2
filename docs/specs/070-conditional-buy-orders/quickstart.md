# Conditional order validation guide

Use the pinned `.tool-versions`, locked dependencies, Node 24 and Playwright/Chromium setup in docs/TEST_PROFILES.md. Existing test PostgreSQL and Redis must be available through normal local configuration; never reset shared data. Configure credentials through existing environment, not commands/manifest. Test helpers fund deterministic fixture accounts only; no user funding feature is added.

After implementation, from repository root:

```sh
python3 scripts/agentflow_check.py preflight --reuse
python3 scripts/agentflow_check.py http --reuse
```

Preflight must pass PostgreSQL SELECT 1 and Redis PONG. Runtime check starts its own server/isolated schema, exercises all four routes in contracts/orders.md through actual HTTP, checks status, JSON/headers and persisted effects, and exits nonzero on readiness or assertion failure. No fixed server port or external provider is needed. Existing test/runtime/purchase_http.exs is the isolation precedent; do not run against production data.

Runtime journey: initialize fixture player with 100 tokens, provision existing test buyer credits, issue owner/other-user API keys. Create below-current-limit order -> 201 pending, Location, unchanged money/tokens. GET/list -> only owner terms. Foreign access/cancel -> indistinguishable 404; anonymous -> 401/challenge. Invalid terms/owner injection -> 400 without effects. At expiry reads retain pending and expiry_reached true, with unchanged row/job counts; invoke evaluator explicitly -> persisted expired. Create qualifying fixture -> evaluate by ID -> executed once, GET actual quote/total. Repeat evaluation -> identical operation cardinalities. Qualifying unfunded/short-inventory fixtures -> rejected with correct reason and no transfer. Cancel separate pending fixture -> cancelled and never executes. This demo calls the domain evaluator manually: automated dispatch and UI belong to TASK-060/061.

Before final verification finish all source, inventory and canonical edits. Execute:

```sh
python3 scripts/agentflow_stage_checks.py --stage develop --reuse
python3 scripts/workflow_artifact_probe.py develop --readiness
```

The manifest includes format, warning-free compile, Credo inventory, OpenAPI, profile inventory, unit/integration once each, built assets, actual browser E2E regression, HTTP and handoff-contract. Do not separately run historical CP1 coverage or another whole-profile wrapper. QA repeats with --stage qa and without --reuse, starts runtime independently and challenges the mapping; two unchanged failures stop an obligation. Final review uses fresh QA and targeted checks. Developer results are recorded in handoffs/develop.md; independent QA remains required.
