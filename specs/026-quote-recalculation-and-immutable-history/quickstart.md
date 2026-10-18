# TASK-026 validation guide

Implementation must create the test modules and runtime driver named in tasks before these checks can pass. Architecture does not execute unfinished feature checks.

Use the repository `.tool-versions`, installed Mix dependencies, PostgreSQL and Redis with the documented local environment; preserve credential handling. Integration additionally requires Node v24, installed `tools/openapi` dependencies and Playwright Chromium (`scripts/test_profile.sh` preflights these). Use the existing infrastructure database workflow, never a production database. Do not drop protected historical fixtures.

```sh
MIX_ENV=test mix test.prepare
python3 scripts/agentflow_check.py preflight --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py unit --reuse
python3 scripts/agentflow_check.py integration --reuse
python3 scripts/agentflow_check.py runtime
```

Run final checks only after all source/design edits; perform them once each. Full profiles include new feature tests and existing regression/static-scope guards. Do not also run the historical CP1 coverage report or an extra full `mix test`. QA repeats the same checks independently with `--stage qa` and no reuse. After two unchanged failures stop and diagnose according to `docs/AGENT_VERIFICATION.md`.

Fixture setup must create an existing account and initialized player using the TASK-028 boundary, accepted deterministic statistics through trusted TASK-021 fixtures, saved explicit strategy configuration through TASK-025, and a saved mapping with explicit fixture scale (e.g. 1.25). No provider credentials/network or production preset. Seed neither implicit scale nor active rules. Demonstrate active and inactive explicit-version calculations. A score 2.000000 at fixture scale 1.25 produces 2.50. Demonstrate ties (1.005 at scale 1 -> 1.01), nonpositive scores and positive results rounding to zero as no_quote.

`runtime` runs `scripts/verify_quote_runtime.exs` under MIX_ENV=test after service preflight inside that command. It must allocate a safe isolated committed-fixture database using existing partition guards, prepare migrations there, and spawn separate BEAM application processes: first accepts import/pins membership, kills dispatch before calculation, then recovers and confirms a quote; next process reads and replays it, checks the original initial quote and 100 holdings, and finds exactly one pending evaluation. Accept late facts/activate B between executions; replay retains A and original membership. Check lost acknowledgement and redelivery do not duplicate quote/event. Assert persisted values, safe status categories, event key and unchanged financial snapshots. Exits nonzero if any assertion, service readiness, child startup or bounded child timeout fails. No printed credential/descriptor dump. Safe isolated fixtures remain protected; no disabling triggers for cleanup.

US1 acceptance: exact positive conversion and frozen strategy across a controlled switch; no provider calls. US2: original replay after late facts/restart, direct-write immutability and canonical concurrent deduplication. US3: recoverable accepted-import snapshot and pending request after crash, fenced retries/exhaustion, atomic quote/event, fake-consumer redelivery and independently accepted import state. See the manifest for the executable ownership and `contracts/calculation.md` for exact error assertions. CP2 browser E2E regressions remain in integration; this feature adds no HTTP route or screen.
