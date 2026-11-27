# Focused research — TASK-070

## Task and feature identity

- Decision: retain the active directory and Git branch; resolve TASK-070 through its exact spec branch declaration.
- Rationale: `docs/adr/0014-durable-agentflow-feature-ownership.md` explicitly permits independently allocated feature numbers. `scripts/agentflow_feature.py:resolve_feature` and `workflow_artifact_probe.py:active_feature` already implement canonical ownership; actual Git branch is `070-agentflow-preflight-and-efficient-failure-recovery`. Setup's BRANCH field reflects the directory basename. The critic's suspected numbering conflict requires an explanation and regression, not a migration.
- Alternatives considered: renumbering directories or rewriting active state would break stable references and reopen a settled decision.

## Effective environment and stage launch

- Decision: share context assembly and probe before both outer workflow launch and each provider-stage launch.
- Rationale: `agentflow:monitor_process` adds Node PATH/defaults, provider overrides and assignment fields; `agentflow_codex.py` independently changes Node/defaults, while both shims invoke real provider subprocesses. Outer-only checks cannot establish the actual stage environment. `start/resume` currently save/bind state before monitor dispatch, requiring explicit ordering tests.
- Alternatives considered: parent-shell checks miss child differences; probing only once before a multi-stage workflow misses later changes; editing installed Specify internals adds an unnecessary dependency.

## Durable reporting and budgets

- Decision: add a stage journal and incremental fail-closed report, retain existing per-check receipts and guards.
- Rationale: `agentflow_check.py` accounts individual checks, whereas spec FR-007 explicitly counts full attempts. ADR-0026 already separates retry relevance from complete-source freshness. Signal handlers cannot survive SIGKILL; durable started/terminal transitions and recovery are necessary. Existing `feedback_stage` already maps verification to architecture; checked-in feedback cap is 16 but Feedback 1 now requires three cycles; keep this separate from two failed full attempts and per-check stops.
- Alternatives considered: counting each command as a stage failure violates the spec; a final report only on normal exit loses interrupted outcomes; resetting on arbitrary source changes allows retries without repair.

## Concrete duplicated profile consumer and current feedback

- Decision: replace local baseline with fast contract/parity assertions without any native-suite fallback. Keep one full manifest at stabilization and fresh full independent QA for this workflow change.
- Rationale: both workflow copies invoke `MIX_ENV=test scripts/ci_unit_tests.sh`; inspection confirms that command loops unit and integration. The existing shell contract uses a private fake child and proves wrapper receipt failures safely without running either real profile. Feedback 1 explicitly rejects another baseline full run. CI files remain unchanged; compare their actual wrapper/profile command contract read-only. Current receipt guards remain the readiness authority, not parity success.
- Alternatives considered: a receipt-aware fallback still permits duplicate native execution and contradicts feedback; deleting all parity/readiness protection weakens gates. On resume adapt only the known baseline step in memory; preserve saved snapshots and reject unknown commands.

## Concurrency and proportional procedure

- Decision: permit a two-worker allowlisted static/contract group, keep all Mix/E2E and behavioral subprocess checks serial; measure with stub static jobs and actual invocation counts. Deliver a documented Vibecode procedure, without adding an executable shortcut selector.
- Rationale: `docs/WORKFLOW_SPEED.md` explicitly warns that current shared Mix cache is unsafe concurrently. Feedback 1 requires isolation/stability evidence before relaxing it, excludes workflow changes from Vibecode and preserves independent QA/CI/human merge.
- Alternatives considered: parallel full suites can collide in shared build/database/browser state; a new automatic lane changes authority beyond the requested design. Separate docs-only fast lane remains unchanged.

No external research was necessary. Settled application architecture, exact toolchain versions, ownership and evidence rules remain in their existing canonical documents. All concrete unknowns above were resolved through scoped local inspection.
