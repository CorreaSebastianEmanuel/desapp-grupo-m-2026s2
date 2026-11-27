# Feature-specific findings

All material unknowns are resolved locally; no technology survey or external research is needed. Existing stack and ownership remain governed by docs/ARCHITECTURE.md and ADR-0014.

## CI parity boundary

- Decision: Inventory current workflow steps and bind their bytes to verification. Run the existing quality-baseline commands locally; run its complete CI test command once in a disposable checkout containing the current candidate and no private feature pointer. Add explicit discovery and environment assertions.
- Rationale: scripts/ci_unit_tests.sh already runs the default ExUnit collection and checks a discovery sentinel. It does not run Python workflow acceptance tests. test/football_market/market/scope_test.exs reads .specify/feature.json unconditionally; other legacy scope tests also use the pointer for active allowlists. Scope validation must retain its constraints while resolving ownership durably or operating as a historical invariant test without an active task.
- Alternatives considered: A second full unit/integration/coverage sweep duplicates the default collection; weakening scope assertions hides regressions. Remote CI cannot be a prerequisite that requires publication before independent gates. See plan.md for each CI obligation and local evidence.

## Evidence and compatibility

- Decision: Local schema-2 receipts and persistent retry journals, bounded portable final summary, exact report-output exclusions and conservative source binding; see ADR-0026 and data-model.md.
- Rationale: scripts/agentflow_check.py currently versions receipts/history under handoffs; all repository source changes reset its retry scope. Report finalization needs an explicit sequence and retry scope must survive irrelevant edits.
- Alternatives considered: Broad documentation exclusions weaken integrity; deleting historical receipts destroys provenance; blindly accepting legacy passes weakens current verification.

## Feedback and usage

- Decision: Use explicit structured feedback impact, not natural-language guessing; unknown impact blocks dependent execution. Extend existing structured wrapper events with provenance and idempotent aggregation, preserving unknown usage.
- Rationale: agentflow currently accepts a requested stage without validating impact; agentflow_runtime.metrics_summary counts repeated events, while agentflow_codex already conservatively treats ambiguous resumed counters as unknown.
- Alternatives considered: Keyword classifiers cannot establish business impact. Broad historical log scans or a model experiment exceed authorized work. See contracts/workflow-delivery.md for impact and telemetry rules.

## Stage selection and launch failure

- Decision: Add repository JSON defaults and one shared resolver/launch adapter; freeze per-run assignment generations with per-field provenance. Normal resume preserves saved settings; adoption begins a new future attempt/session. See ADR-0027 and contracts/workflow-delivery.md.
- Rationale: Local inspection of agentflow monitor_process/start/resume, scripts/agentflow_codex.py and stage_from_args shows the existing wrapper already intercepts actual launches and emits structured attempt events. `.agentflow/config.toml` currently has no stage model table. A small standard-library JSON configuration avoids new parsing dependencies and changes to global settings. Existing stage markers distinguish six agent stages; architecture also owns tasks synthesis.
- Alternatives considered: Global CLI defaults cannot express six stage pairs; changing saved workflow sessions in place breaks provenance; live availability probes spend without proving future access. Deterministic child-launch rejection fixtures prove failure propagation without paid calls. Unsupported selection fails locally; availability is only known on the authorized actual launch.

All four refreshed critic findings are resolved in the plan and ADR-0026/0027. The original optional Luna trial is superseded by Feedback 1. No technology research agents or external research are needed.
