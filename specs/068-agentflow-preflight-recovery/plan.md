# Implementation Plan: Agentflow Preflight and Failure Recovery

**Branch**: `070-agentflow-preflight-and-efficient-failure-recovery` | **Date**: 2026-10-24 | **Task**: TASK-070 | **Spec**: [spec.md](spec.md)

## Summary

Extend the existing Python delivery tooling with one effective-child launch context, read-only prerequisite evaluation, dependency-aware check execution, durable partial QA outcomes and stage-attempt accounting. Preserve current feature ownership, receipt validation and independent verification. Replace the redundant local `ci_baseline` execution with a fast wrapper-contract/CI-parity check; execute the complete manifest once after stabilization, retaining current-receipt reuse for explicit development recovery. No market application code or HTTP interface changes.

The spec remains behavioral truth. Operational definitions below resolve the critic's findings without changing requirements. ADR-0032 records durable decisions; ADR-0014 already resolves task/feature numbering. The current Git branch and the exact spec declaration identify TASK-070; `068` is an independently allocated feature number, not TASK-068 ownership. Keep `.specify/feature.json` pointing here; do not rename the directory, rewrite the active run or derive feedback identity from its prefix. Setup-plan reports the directory basename as BRANCH; the actual Git delivery branch above is authoritative. Current `backlog/feedback/TASK-070.md` Feedback 1 is authoritative. It supersedes the prior baseline fallback, cap-16 and serial-only decisions. The unchanged spec already permits these verification/governance refinements (FR-006/008/009/011/013); no product rule is reopened.

## Technical Context

- **Language/runtime**: existing Python 3 standard-library CLI and POSIX shell; retain supported Windows provider launcher behavior. Python syntax compatibility follows existing scripts; no new package/runtime minimum.
- **Dependencies**: `subprocess`, `signal`, `hashlib`, `json`, existing provider/model registry, feature resolver and receipt helpers. No new service, library, agent session or hosted API.
- **Storage**: ignored local atomic JSON journals under the established workspace/feature/stage namespace; existing immutable evidence outputs and compact post-review summary. No application schema migration.
- **Testing**: `unittest` process/environment fixtures in `test/scripts/`, existing `tests/` regressions, shell/profile contracts and the existing CI unit/integration runner. Real short-lived fixture subprocesses exercise launch/interruption; no provider API calls in tests.
- **Platform**: existing macOS/Linux development and CI; Windows shims retain argument/environment equivalence and receive mocked compatibility tests. POSIX handled-signal subprocess tests run on POSIX with explicit platform applicability.
- **Performance**: preflight runs only bounded read-only probes, never tests, installs, browser launch, migrations or service startup. Each executable/service probe has a five-second timeout; ordered evaluation has a finite inventory. Success claims concern invocation counts and correctness, not an invented speed target.
- **Scope**: delivery tooling, its workflow definitions, skills/policy documentation and tests. `lib/`, application behavior, `priv/`, assets and `.github/` are outside implementation scope. The sole planned `config/` edit is registering new workflow test identities in `config/test_profiles.json`, preserving all existing assignments; this requires the full flow. Existing profile tests run as safeguards. A diagnosed fresh-process integration test may be moved into its own existing integration partition without changing test source or profile membership.

## Constitution Check

Before research: PASS by design. I: all work traces to the existing 13 FRs, four stories and seven SCs. II: no player supply, money, trading, audit, quote, provider or portfolio change. III: extend shared tooling seams; do not add application layers or external infrastructure. IV: tests precede each behavior change, including refusals, corruption and compatibility. V: development executes manifest checks; independent QA reruns freshly and review requires both terminal PASS reports. Human merge/publication authority remains unchanged.

After design: PASS by design with no constitutional exception. Preflight purity is distinct from later launch bookkeeping; handled interruption finalizes while abrupt termination is recovered truthfully. Neither schema migration nor weaker verification is authorized. This is workflow behavior and uses the full delivery flow, not the documentation fast lane.

## Proportional supporting artifacts

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete launch seams, feature identity, stage retry boundaries and duplicate profile execution found by the critic."},
  "data_model": {"required": true, "reason": "New launch/prerequisite, stage-attempt and per-check outcome records plus optional manifest dependency metadata."},
  "contracts": {"required": true, "reason": "Changed internal CLI, diagnostic, dependency and report interfaces need explicit compatibility contracts."},
  "quickstart": {"required": true, "reason": "Feature-specific failure injection, interruption/recovery and invocation-count validation are required."}
}
```

## Phase 0: Focused investigation

[research.md](research.md) records local evidence only. Existing stack and tool versions come from `docs/ARCHITECTURE.md`, `.tool-versions`, `scripts/check_toolchain.sh` and current profile tooling. No unsettled external technology question remains; no web survey or research agents are needed.

## Phase 1: Design and implementation boundary

### Launch and preflight (US1)

Add `scripts/agentflow_preflight.py` as the shared pure evaluator/context builder. Refactor `agentflow.monitor_process`, `start`, `resume` and both provider forwarding shims to consume its result rather than independently mutate PATH/defaults. Build the final environment after existing operator overrides, provider shim choice, Node resolution, model assignment selection and working-directory resolution. Resolve executable paths once. Use that exact in-memory context for probes and Popen; re-evaluate if relevant environment, configuration file digest, assignment digest, cwd or resolved executable identity changes. Immediately before each actual provider-stage Popen, run the same guard; checking only the outer Specify launcher is insufficient. External service readiness remains a time-bounded observation and must be checked again by service-dependent commands.

The authoritative inventory is the typed built-in policy in `agentflow_preflight.py`, selected by launch role and stage, plus strictly validated optional `prerequisites` on manifest checks; contracts define the only allowed probe types. Reuse provider/model validation and existing toolchain versions, not duplicated version constants. Before feature creation the bootstrap inventory requires Python, Git, Specify, selected provider/override executable and readable launch configuration. Afterward resolve task/feature canonically. Product/architecture stages do not require database/browser tooling. Development/QA application-profile obligations add toolchain/Node/locked dependency presence and PostgreSQL/Redis read-only readiness; final review requires only declared targeted checks. Publishing prerequisites remain in the existing authorized publishing path and never imply publication from preflight.

When task/manifest applicability requires the project toolchain, bootstrap preflight checks Elixir and OTP through `mise exec --` against `.tool-versions` and checks Node 24 through the shared effective-PATH nvm resolver before launching product work. Docs-only tasks may set `toolchain_required: false`; other manifests default to requiring the project pins. Every manifest Mix, toolchain, profile, Credo and inventory command runs through `mise exec --`. The local full-profile command is mise-wrapped while parity still validates its underlying CI wrapper/profile contract.

Pure evaluation neither creates output directories nor changes backlog, pointer, assignments, journals, services or databases. Existing start/resume orchestration may write its normal state only after the outer preflight passes; model preparation must be possible in memory before `models.save/bind`. Provider preflight occurs before stage metrics/attempt records are created. On failure return diagnostics to the caller; the caller may record failure outside the evaluator. Never launch a child or count a full attempt on preflight failure. Specify remains an external CLI; no modification to its installed package is in scope.

### Outcomes, execution and partial QA (US2)

Add `scripts/agentflow_stage_checks.py` as the ordered manifest executor. Keep `agentflow_check.py CHECK_ID` compatible; both use shared safe diagnostics and existing receipt validation. Optional `depends_on`, `isolation`, `state_reads`, `state_writes` describe independence. Validate unknown dependencies, cycles, paths/types and conflicts before executing anything. Preserve dependency order and stable report ordering. Run at most two explicitly allowlisted independent static/contract checks concurrently; all others remain sequential. See the concurrency boundary below. On a failed/unknown/blocked check, skip consumers and any later check whose declared state may have been corrupted. Missing isolation information means unknown independence, so block later unproven checks. Explicit isolated checks with complete dependency/state declarations may continue. Runtime/service checks always execute. Unknown effects never qualify for concurrency.

Persist the required-check inventory before execution, each started transition and each terminal outcome atomically afterward. Render `qa-report.md` incrementally from this journal and after every outcome, ending `Verdict: FAIL` until all required checks pass freshly in the current QA attempt. On SIGINT/handled SIGTERM, stop active work, account for interrupted/unexecuted checks, flush, and exit nonzero. SIGKILL/power loss cannot run a finalizer: last durable report remains non-PASS; next entry recovers running checks as interrupted once, records remaining work and never promotes old results into a fresh QA pass. A provider-wrapper finalizer creates a partial report even when the agent never invoked the batch runner. Machine outcomes supplement, rather than replace, independent QA's semantic assessment and report; they cannot independently authorize PASS or an attestation. Recovered historical completions remain visible separately from fresh acceptance.

Use allowlisted diagnostic categories and field names. Never include arbitrary exception strings, command arguments, environment values, raw stdout, connection URLs or transcript excerpts. Store protected local evidence references and a safe cause/recovery code; secret-canary tests inspect console, JSON, Markdown and journals. Elapsed time is monotonic and excluded from deterministic readiness equivalence.

### Retry and feedback (US3)

A full attempt begins at the successful preflight followed by actual child-stage launch (or standalone batch launch), has one shared attempt token for nested checks, and ends when that stage exits or is recovered interrupted. A failed full attempt increments the stage budget once regardless of failed check count. Retry identity is scoped to failed checks and their transitive dependency closure, so changing only an independent check input cannot reopen the same failure. A material change to a failed check or dependency input/edge makes recovery eligible. Missing or legacy scope uses the complete stage snapshot conservatively. Two unchanged scoped failures prohibit a third across start/resume; check-level two-failure guards remain an additional safeguard. No counter increment on successful stages, preflight refusal or duplicate nested finalization. Existing per-check journals are not reinterpreted as historical full attempts; unsupported/corrupt journals block with recovery instructions, never reset silently. A persistent nonblocking OS lock serializes the complete per-stage journal lifecycle; a second active launcher is refused before it can read or replace the journal.

Retry identity is separate from full-source receipt freshness. Key by canonical task/feature, stage, provider/command/configuration identity and failing obligation IDs, with content/deletion digests for validated `retry_inputs`, its dependency producers, owning code/tests and applicable canonical decisions/current scoped feedback. Persist component digests so a relevant repair lists changed component paths/codes without contents. Missing selectors conservatively use the documented obligation scope, not arbitrary repository edits; unresolved relevance blocks an automatic retry. Changing an unrelated doc, checkbox, session/run ID, output, handoff or unrelated feedback entry cannot reset a failing obligation. Every unchanged failing obligation must be repaired or explicitly resolved before a new stage attempt. Identical failure scope across a changed full-source state retains its budget. Readiness/reuse still binds the complete current source and canonical inputs under ADR-0026; this task does not weaken that conservative acceptance binding. Consequently implementation-only feedback preserves settled artifacts, but final freeze may require all manifest checks to refresh even when only cited regressions are rerun during repair.

Keep existing impact classification: product→product (including challenge), architecture/verification→architecture, implementation→develop, QA→QA, review→review; mixed impact chooses earliest. Pending/conflicting material impact blocks dependent work. Preserve upstream bytes and saved attempt history when rewinding; repair canonical artifacts before gates reopen. Feedback 1 supersedes the checked-in cap 16: set the repository cap to three total feedback repair cycles, counting existing durable feedback across resume and run IDs. The third repair may finish; a fourth is refused before rewind/launch. Preserve the submitted feedback and current evidence at exhaustion, report remaining scope and recommend an explicit split for human consideration; do not create a replacement task or reset counts automatically. Existing tasks already at/above the cap retain history and block new cycles. Validate positive configuration and use three as the absent-key default; do not silently clamp an explicitly configured future policy. Keep stage-attempt and per-check two-failure budgets independent. Implement the current repository policy as three and document overrides as explicit reviewed policy changes, never recovery tricks.

### Obligation audit and deduplication (US4)

Produce `verification-audit.md` during implementation: enumerate command/profile/configuration, discovered membership, stage/source identity, receipt and consumer for every full-profile invocation; inspect `scripts/test_profile.sh`, `ci_unit_tests.sh`, current manifest, both delivery workflow copies and CI definitions. `ci_unit_tests.sh` without a filter already executes unit and integration. One `ci_profiles` manifest check runs that command in development; do not add separate full unit, full integration, historical CP1 coverage, clean-candidate suite or an unfiltered mix test that executes the same profiles again. Targeted new feature tests during TDD remain appropriate.

Change both current workflows' `ci_baseline` shell step to `python3 scripts/agentflow_stage_checks.py --ci-parity`. This is a fast contract/parity check, never a fallback native profile runner: verify both workflow copies agree, the designated manifest full-profile command/env matches the remote CI wrapper contract, unit/integration identities are preserved, and the wrapper's isolated stub contract (`test/scripts/ci_unit_tests_test.sh`) fails closed for missing/partial/stale receipts and output leakage. Inspect CI definitions read-only and compare command/profile invocations rather than brittle entire-file hashes. An absent or mismatched obligation fails with architecture/verification repair guidance; it never triggers another full suite. `develop_ready` still requires all current development receipts before this step; parity cannot replace them. Features with older manifests must reconcile the obligation before using current definitions. New runs use the parity check. Spec Kit resume reloads the saved workflow and exposes no workflow override, so legacy snapshots remain byte-for-byte unchanged and resume their saved baseline command exactly once. The adapter must not intercept the CLI or rewrite snapshots.

During iteration run changed behavioral tests and cheap checks only. At stabilization freeze all source/design/feedback inputs and execute the complete manifest once; a failure continues independent checks and stops unsafe dependents. After correction refresh required stale evidence through explicit development `--reuse`; never add an unconditional second full run, clean-candidate suite or historical CP1 coverage. Existing full-source freshness still applies, so a relevant post-freeze repair can require a new full profile; this is necessary execution, not a duplicate. QA always runs its own fresh complete manifest for TASK-070 because workflow changes are high risk. Financial/security/high-risk features retain full independent QA; E2E, real HTTP acceptance, remote CI and final review remain required wherever applicable.

### Bounded static concurrency and measurement (US2/US4)

Add optional `execution_class: "static"` only for the supported artifact-policy and parity commands; the executor validates the exact registered argv, declared isolation and empty shared reads/writes. Merely labeling arbitrary commands static is rejected. Default worker count is two with `--static-workers 1|2` for measurement/diagnosis. Only ready checks with disjoint declared effects may overlap; missing metadata, services, provider processes, Python behavioral subprocess suites and all Mix/build/cache/database/E2E/browser checks stay serial. Drain the static group before any serial check. Failure handling is identical in serial/parallel modes, and stable declaration-order reporting does not discard completions from concurrent workers. Signal handling joins/terminates owned workers and persists every result.

Do not add parallel Mix/E2E in this task. It requires separate evidence of isolated build/cache paths, database names, ports and browser contexts plus repeated stability checks. Implementation records monotonic check durations, sum and critical-path wall time, invocation counts and concurrency peaks in `verification-audit.md`. Compare worker=1/2 with controlled stub static checks, not duplicate full-profile executions; record actual local measurements without invented savings or token estimates.

### Proportional Vibecode procedure (US4; design deliverable)

Add a documented opt-in procedure to `docs/WORKFLOW_SPEED.md` for future small, clear, reversible low-risk changes. It requires a brief canonical spec with acceptance checks, mandatory effective-child preflight, focused tests, CI and proportionate independent QA/final review with human merge. Keep independent terminal PASS gates. Avoid separate deliberation/research sessions for already settled decisions; resolve a concise plan/tasks/verification map in one planning session. Unresolved material choices return to the full product/architecture flow. Security/auth/permissions, financial/data-integrity, migrations, external contracts and all workflow/gate/tooling changes are excluded; unknown impact defaults to full flow. Record scope, risk rationale and rollback in the brief spec. This task delivers the procedure and tested exclusion/policy examples, not a new executable lane selector or automatic gate bypass; TASK-070 itself always uses the full flow. The existing non-behavior docs fast lane remains separately governed by its mechanical route guard.

Existing HTTP detector/runtime requirements remain mandatory and receive negative compatibility tests. This feature declares no affected HTTP route: `runtime_required: false`; no unrelated application endpoint is added merely to force a runtime demo. If implementation changes an HTTP interface, it exceeds this plan and requires architecture feedback plus service-ready status/header/body assertion checks before readiness.

## Source and artifact structure

```text
agentflow                                  launch ordering, feedback/retry orchestration
scripts/agentflow_preflight.py              new read-only policy, context and CLI
scripts/agentflow_stage_checks.py           new ordered executor, journals, parity adapter
scripts/agentflow_check.py                  per-check compatibility and diagnostics
scripts/agentflow_verification.py           manifest extensions, identity/readiness guards
scripts/agentflow_codex.py                  final-context preflight and stage finalization
scripts/agentflow_opencode.py               same provider-neutral guarantees
scripts/agentflow_runtime.py                shared safe diagnostic/report utilities
scripts/agentflow_evidence.py               bounded summary compatibility as needed
.agentflow/workflow.yml                     parity adapter and check/report guidance
.specify/workflows/desapp-delivery/workflow.yml  matching source definition
.agents/skills/{start,resume,feedback,verify,speckit-implement}/SKILL.md
 test/scripts/agentflow_{preflight,stage_checks,recovery,dedup}_test.py (new)
 test/scripts/agentflow_{feedback,providers,workflow_gate,evidence}_test.py (existing)
 config/test_profiles.json                  register new unit test identities only
 tests/test_agentflow.py; tests/test_agentflow_delivery.py (existing)
 docs/AGENT_CONTEXT_POLICY.md; docs/AGENT_VERIFICATION.md; docs/WORKFLOW_SPEED.md; README.md
.agentflow/config.toml                      three feedback cycles; preserve history
 docs/adr/0032-effective-child-preflight-and-stage-recovery.md
 specs/068-agentflow-preflight-recovery/{verification.json,verification-audit.md,handoffs/}
```

Only change existing modules above where required by a named task; avoid unrelated remediation. [data-model.md](data-model.md) and [contracts/workflow-recovery.md](contracts/workflow-recovery.md) define validation/compatibility, [quickstart.md](quickstart.md) defines validation setup. `verification.json` is the executable map; planned new scripts/tests become executable during implementation, not during architecture.

## Verification and checkpoint coverage

Implementation owner freezes inputs, executes every manifest check through `agentflow_check.py`, then readiness; QA independently reruns required checks with `--stage qa`, never `--reuse`. Preflight/service readiness, toolchain, formatting, warning-free compilation, Credo, assets/database preparation, targeted workflow behavior and exactly one full profile pair per current development state are included. The baseline runs only fast parity assertions, never either full profile; each fresh QA attempt runs its own pair. Existing CI remains required remotely and is not declared passed by local results. No historical CP1 coverage job is added locally. CP2 charts, conditional orders, actual E2E scope and every market invariant remain unchanged. No task completion or independent verdict is claimed at architecture time.

## Complexity Tracking

No constitution violation. Two shared modules avoid provider drift and leave Specify internals untouched. A bounded static worker pool is justified by Feedback 1; Mix/E2E concurrency stays excluded. Optional schema-1 manifest fields retain old command compatibility; unknown versions and unsafe evidence fail closed. No new daemon, scheduler, storage service or application dependency.
