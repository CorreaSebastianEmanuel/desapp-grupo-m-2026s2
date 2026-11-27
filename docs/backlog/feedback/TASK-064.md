# Feedback — TASK-064

## Feedback 1

- Time: 2026-10-16T01:35:43+00:00
- Author: ezequielgonzalez
- Restart from: product
- Impact: product

The user explicitly extends the authorized scope: implement both workflow optimization and model assignment now, rather than only documenting an optional future Luna pilot. Supersede the original outcome sentence that keeps Sol Medium everywhere and prohibits automatic model routing. Implement configurable repository-scoped defaults: product and product_challenge use gpt-6-luna high; develop uses gpt-6-luna high; architecture and final review use gpt-6.1-sol medium; independent QA uses gpt-6.1-sol low. Preserve independent sessions and all verification obligations. Provide an explicit per-task or per-run model/effort override for development using Sol for concurrency, transactions, idempotency or security when the task warrants it. Do not add speculative autonomous classification, hidden automatic retry escalation, new global user settings, paid benchmarks, recursive agents or extra product behavior. Model availability/configuration failures must be visible and must not silently fall back. Preserve legacy saved runs and make model/effort provenance observable where actually known. Apply this to future starts and documented resumes safely; this active frozen run may continue with its original launch settings and must report that honestly. Tests should prove stage selection, overrides, CLI/config precedence, unsupported model/effort failure, telemetry provenance, legacy compatibility and unchanged independent gates. Keep this and the already authorized efficiency work within TASK-064, preserving useful existing artifacts while updating affected canonical requirements, plan and manifest. No percentage quality or token savings claims until a real measured task supports them.

## Feedback 2

- Time: 2026-10-16T11:43:39+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Development readiness repair only; preserve settled product and architecture. Fix the already failing pinned ExUnit collection regression in scripts/agentflow_ci_check.py assert_collection and scripts/ci_unit_tests.sh: accept Result: 527/527 passed, 4 excluded as a nonzero successful collection while retaining sentinel enforcement, nonzero checks, failed/partial-result rejection and child exit propagation. Extend meaningful negative fixtures for zero and partial/failed pinned summaries. The preflight failure came from the ambient system Elixir 1.20.4 and Node 20; the installed correct binaries are /private/tmp/task019-elixir-1.20.3/bin and /Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin, with Erlang at /usr/local/opt/erlang@29/bin. Explicitly prefix PATH on every check command after the login shell, or use an equally explicit executable environment; do not rely on inherited PATH surviving zsh -l. Fix actual relevant inputs before retrying, retain all prior failures and do not reset counters by irrelevant edits. Parser correction is relevant to preflight/clean-ci check script and shell suite; this recorded environment correction is actual causal recovery guidance. Use host access when sandbox denies Docker/browser/TCP; do not count sandbox denials as checks passing. Execute every required manifest check with the corrected inputs, reconcile named files and task checkboxes, and obtain plan/tasks/develop readiness. Reuse only genuinely fresh successful development evidence. Implement these small repairs rather than returning another blocked handoff for the same already identified code defect; stop if genuinely unresolvable. Independent QA and review remain mandatory. No product/spec/plan expansion or model reassignment is requested.

## Feedback 3

- Time: 2026-10-16T12:31:25+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Independent QA found implementation blockers B1 and B2; repair within existing spec/plan, with no product or architecture expansion. Read qa-report.md and QA adversarial evidence at /private/tmp/task064-qa/adversarial-artifacts.log and adversarial-readiness.log. B1: scripts/agentflow_artifacts.py cannot treat any missing applicability block as legacy. Establish reliable historical provenance independent of the removable block; reject whole-block deletion in a new-policy feature while preserving genuine historical plans and saved legacy workflows. Cover the actual plan/task readiness entry points with behavioral regressions. B2: scripts/agentflow_verification.readiness called from resume/finalization must enforce the same shared required-artifact validation as validate(feature,stage=develop). Reproduce a fresh real receipt plus missing required research.md, demonstrate refusal from actual resume/finalization consumers, and cover legacy saved snapshots as well as current probes. Preserve independence, all required checks, safe compatibility and existing historical files. These are implementation defects against FR-005/006/013 and SC-008, not a new behavioral decision. Retain passing evidence only where genuinely fresh after repairs, execute regressions and every required manifest check, reconcile task completion, and pass readiness before fresh QA. Next QA should use agentflow_check.py CHECK_ID --stage qa without reuse to produce genuine local receipts needed by post-review finalization; never manufacture receipts or reinterpret the preceding direct-command QA as a PASS. Host access and explicit pinned Elixir/Node PATH remain required. No new live model benchmark or task is authorized.

