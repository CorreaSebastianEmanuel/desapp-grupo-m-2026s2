# TASK-025 validation guide

These commands validate the implemented internal configuration and managed valuation surface. Final development receipts are under `handoffs/check-*.json`; QA must execute independently. Run from repository root. Contracts: [configuration-context.md](contracts/configuration-context.md); full acceptance matrix: [acceptance-map.md](contracts/acceptance-map.md).

## Prerequisites and readiness

Use the pinned toolchain and existing local service setup in README.md. PostgreSQL/Redis targets must match the current operator environment; the current session feedback records PostgreSQL port 15432 and Redis 6379, so preserve/export those overrides when applicable. Keep credentials in environment and out of commands/evidence. Guarded test database identity is `football_market_test` plus any `MIX_TEST_PARTITION`, never development storage. Integration profile requires existing Node 24/OpenAPI dependencies and actual installed Chromium.

When services are not running, use documented reversible `./scripts/local_services.sh start` (preserves volumes). Do not reset data. Preflight:

```bash
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py services --reuse
```

Services executes guarded test preparation and an actual migrated PostgreSQL read plus Redis PONG; unavailable dependencies fail. Sandbox socket denial needs authorized expanded execution, never weakened checks. After two unchanged failed executions diagnose instead of repeating; after a meaningful source/environment correction preserve attempt history and continue.

## Incremental acceptance

Write each story's tests first, record expected missing behavior, implement the corresponding source correction, then rerun. Execute the complete commands through the manifest helper.

| Check | Expected assertions |
|---|---|
| rules-codec | both formulas, strict structures, all-zero requirements, typed exact numeric canonical equality |
| versions | complete durable saves, no activation, unknown/empty distinctions, ordered ties, DB update/delete/truncate/identity guards |
| selection | activate/switch/restore, stale/no-op, ordered history, distinct-backend committed races and A→B→A behavior |
| managed | balanced 1 versus 2, position-aware concentrated 2 versus split 4, barrier-controlled fixed UUID and ordinary no-score outcomes |
| replay | original membership after late facts, full-rule mismatch/tamper rejection and ≥20 canonical permutations |
| durability | separate fresh BEAM application instances reload committed exact rules/selection/history and replay externally held original envelope |
| legacy-metadata | four inherited metadata suites inspect only the current schema while protected private fixtures remain retained |
| architecture | exact inventory/roles, inherited purity, no providers/events/jobs and SQL mutation exclusions with visible infrastructure failure |

For example:

```bash
python3 scripts/agentflow_check.py rules-codec
python3 scripts/agentflow_check.py versions
python3 scripts/agentflow_check.py selection
python3 scripts/agentflow_check.py managed
python3 scripts/agentflow_check.py replay
python3 scripts/agentflow_check.py durability
python3 scripts/agentflow_check.py architecture
```

Ordinary tests roll back. The test-only `record/3` helper uses existing Input/changeset/database acceptance directly because the inherited identity-trimming utility explicitly targets the default Repo; this keeps every fixture operation in its owned namespace. Committed restart/race fixtures use a unique guarded test-only schema with matching migration/connection namespaces, no disabled guards and no fixture deletion; stop owned processes and restore dynamic Repo. First activation begins with empty history. Reconnect alone cannot replace separate fresh BEAM application-instance assertions. Trusted test descriptors may use ignored temporary harness fixtures, never a production quote store or public term deserializer.

## Final owner verification, then independent QA

Finish source/design edits before final checks. Execute every manifest ID; current intact development receipts may use explicit `--reuse`. Services is always fresh. Full profiles run once each at final verification, not additionally through a historical CP1 coverage report:

```bash
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py services --reuse
python3 scripts/agentflow_check.py unit-profile --reuse
python3 scripts/agentflow_check.py integration-profile --reuse
```

Complete all feature checks above against final inputs as well. Then create concise handoffs/develop.md with evidence references, reconcile completed artifacts/tasks, and run `python3 scripts/workflow_artifact_probe.py develop --readiness`. No implementation/test task may be left unchecked; only tagged Independent QA/Final review may defer. QA reruns every check independently with `--stage qa` and no reuse; final review uses that fresh evidence with targeted uncovered-risk checks.

No HTTP endpoint changes exist; no curl/runtime HTTP assertion is applicable. Runtime service readiness still must pass. Fixture scores are not production presets; TASK-026 must obtain intentional configuration and durably bind versions/evidence to dated quotes. TASK-025 alone does not establish complete CP2 delivery. Never publish or merge from implementation/QA/review sessions.
