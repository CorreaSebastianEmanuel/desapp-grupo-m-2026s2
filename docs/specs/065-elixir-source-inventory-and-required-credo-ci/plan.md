# Implementation Plan: Elixir Credo CI Enforcement

**Branch**: `065-elixir-source-inventory-and-required-credo-ci` | **Date**: 2026-10-20 | **Spec**: [spec.md](spec.md)
**Backlog owner**: TASK-065 (feature directory numbering does not change ownership).

## Summary

Make TASK-066's existing Credo analysis mandatory in the existing Quality baseline workflow, independently of SonarCloud. Reconcile a committed, reviewable source inventory against Git and the actual valid source files returned by Credo's analysis pipeline. Preserve every existing regression job and findings policy. No application changes.

## Technical Context

- Language/runtime: existing Elixir 1.20.3 / OTP 29.0.6; shell orchestration and Jason JSON already available.
- Dependencies: exact Credo 1.7.19 dev/test runtime-false pin; stock named default configuration, `strict: false`, existing includes and empty exclusions remain unchanged (ADR-0029).
- Storage: committed `config/credo_inventory.json`; ignored `tmp/credo-ci/` evidence; GitHub Actions artifact. No database schema.
- Tests: ExUnit `:unit` temporary Git repositories and real Credo subprocess probes; existing independently inventoried unit/integration/browser profiles.
- Target: repository tooling on Linux, local and GitHub Actions. Scope: maintained tracked `.ex`/`.exs` across lib, config, priv, scripts, test and root, including dotfiles.
- Constraints: no new dependency, service, analyzer rules, coverage pipeline, runner redesign, remediation or domain refactor. Entire lists retained without log truncation. Two lint passes are acceptable; no repeated full test-profile executions.
- Performance: bounded CI timeout; no numeric product latency obligation. Git enumeration and sorted comparisons linear apart from sorting.

## Constitution Check

Pre-design: PASS. Specification and approved fresh TASK-065 outcome control scope. TASK-066 feedback is relevant only to preserving cold-database preparation; archived broad TASK-065 feedback is not acceptance evidence. No unresolved human choice.

Post-design: PASS. Tests precede each tooling behavior change. Product invariants (100-token supply, exact money, atomic/idempotent trades, immutable audit/quotes, local reads, reproducible valuation) are preserved by zero application changes plus all existing regression profiles. Web/domain/persistence/external boundaries remain unchanged. Independent QA and review stay downstream and require separate terminal PASS verdicts. No constitutional exception.

## Phase 0: Focused research

The only technical unknown was how pinned Credo exposes its effective source set. Resolved from installed 1.7.19 source; see [research.md](research.md). No web research or research agents. Existing technology decisions remain in docs/ARCHITECTURE.md and ADR-0029.

## Phase 1: Design

### Inventory and reconciliation (US1)

`config/credo_inventory.json` stores schema 1, sorted unique maintained paths and explicit per-path exclusions with category and reason. Enumerate all tracked Elixir paths using NUL-delimited `git ls-files --cached -z`; require files to exist and reject duplicates/unsafe paths. Maintained baseline is TASK-066's roots/root files. Enumerate other tracked Elixir paths too: every one must have an exact approved exclusion record, otherwise fail. Known historical standalone probes under `specs/` are archived evidence, not maintained tests; list each separately with its archival reason. No broad specs/vendor/generated glob exemption. An exclusion cannot cover any TASK-066 maintained path. A newly maintained directory outside the baseline requires explicit inclusion and matching Credo scope approval, never an automatic exclusion.

A deliberate `--write-inventory` mode regenerates maintained membership for tracked files only and preserves reviewed exclusion records; unknown outside-boundary paths fail until classified. Normal checks never regenerate expected inventory. Local contributors stage new source before refreshing; unstaged content edits remain supported and labelled working-tree evidence. Unexpected untracked files entering Credo's effective inputs cause mismatch, with actionable diagnostics. Compare all three sets: Git-derived maintained set, committed maintained inventory and Credo valid effective inputs. Missing, deleted/renamed/stale paths, unexplained exclusions, invalid/timed-out parse results, unexpected extras and unreadable files fail closed.

### Effective-input oracle (US1)

`mix run --no-start scripts/credo_inventory.exs` starts Credo explicitly and runs `Credo.run(["--format", "flycheck"])`; read `Credo.Execution.get_source_files/1`, each filename/status, completed timing assignments and `get_exit_status/1`. This is the same default pipeline used by `mix credo`, not a second hand-written glob or issue-only output. Reject halted/incomplete execution, nonzero status and set mismatch. Real temporary-repository probes exercise syntax-invalid files and default-priority findings, not only mocked sets.

`scripts/credo_ci.sh` first runs the unchanged `MIX_ENV=test mix credo --format flycheck` and then the programmatic observation pass. Both operate on identical pre/post content hashes, configuration, lock and Git path snapshots; mutation fails the result. Always preserve both exit statuses; observation failure never masks CLI failure. This intentionally performs two cheap static-analysis passes, avoids a plugin/config change, and keeps the literal standard invocation required by FR-001/006. No profile runs inside either script. Parity tests verify CLI/API success and finding failure on the same fixtures. See ADR-0030.

### CI evidence and failure behavior (US2)

Add a mandatory `Credo and source inventory` step to existing `quality-baseline` after dependency compilation and before profile execution. Keep job ID/name, triggers, permissions, service preparation, E2E job and independent SonarCloud workflow unchanged. No `needs` on SonarCloud, conditions based on its outcome, continue-on-error, path filters or success masks. The existing required Quality baseline result carries Credo failures; this task does not change hosted branch protection.

Clear prior evidence before starting. Produce schema-1 JSON and full text log in `tmp/credo-ci/`, with checked-out HEAD and triggering GITHUB_SHA, local dirty marker/content digest, commands, analyzer version, priority, complete maintained/effective lists, exact exclusions, both statuses, completeness flag and interpretation limits. Status is failed on missing/partial oracle; never label incomplete paths complete. On an early crash no complete report is manufactured. Add `actions/upload-artifact@v4`, `if: always()`, retention 14 days, revision/run-attempt-specific name, `if-no-files-found: error`; artifact failure must also fail the job. Retain complete structured evidence and logs after success and failure, without credentials. Tests assert full-list round-trip and failure artifact behavior. No external GitHub write is performed during development.

### Documentation (US3)

README documents standalone standard Credo command, wrapper and inventory refresh/reconciliation commands, staging requirement, boundaries, all per-path reasons by inventory reference, default priorities, artifact retrieval/retention, revision/dirty distinction and limitations. Explicitly state zero findings proves neither absence of bugs nor equivalence to SonarCloud native Java analysis. See quickstart.md and contracts/quality-evidence.md.

## Project Structure and Implementation Boundary

New: `config/credo_inventory.json`, `scripts/credo_inventory.exs`, `scripts/credo_ci.sh`, `test/ci/credo_inventory_test.exs`, `test/ci/credo_ci_contract_test.exs`.

Modify only as needed: `.github/workflows/quality-baseline.yml`, `README.md`, `config/test_profiles.json`, `test/ci/quality_baseline_contract_test.exs`, `test/ci/test_profiles_quality_contract_test.exs`, `test/ci/fixtures/quality-baseline.sha256`, `test/support/workflow_scope.ex`, `test/ci/workflow_scope_test.exs`. Extend finite scope allowances for this feature only, retaining negative assertions and every existing invariant. Refresh the exact baseline digest only after reviewed YAML changes; no blanket bypass. Use existing `scripts/test_inventory.py update` for changed/new cases, then check; do not modify runners. Scripts must be explicitly formatting-checked because scripts/ is outside default formatter inputs.

No lib/, migrations, assets, dependencies, lock, existing `.credo.exs` or coverage/Sonar workflow changes. If new files introduce findings, fix only those new files within scope; newly discovered existing debt is separate work.

## Verification, checkpoint coverage and sequencing

[verification.json](verification.json) maps all 12 FR and 5 SC identifiers (spec defines no AC identifiers). Story acceptance cases are mapped by the contract's test matrix. Owner executes every check after all source/design edits, then QA independently reruns every check ID using `--stage qa` without reuse. Only downstream QA/review tasks are deferred. Test-first red evidence precedes implementation; final profiles once each via existing CI wrapper (unit + integration) and E2E runner. Focused tests are included in unit profile, not repeated as a second final suite.

Service preflight checks exact toolchain, Docker/Compose, Node/Chromium, prepared PostgreSQL/Redis via application-owned connectivity checks, builds browser assets and validates existing OpenAPI. This feature changes no HTTP endpoint; runtime_required=false and no new endpoint assertion harness is applicable. Existing integration/E2E profiles retain native runtime readiness and HTTP/browser assertions. CP2 quality safeguards remain covered; this tooling does not claim delivery of charts/orders. Preserve historical CP1 reports and SonarCloud CI unchanged, but do not execute the historical coverage report as an additional local CP2 gate. No credential-dependent hosted analysis is newly required locally; assert unchanged Sonar configuration in unit contracts.

## Supporting artifact applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve pinned Credo effective-input and CLI exit-status oracle."},
  "data_model": {"required": true, "reason": "Define new inventory and revision-bound evidence JSON structures."},
  "contracts": {"required": true, "reason": "Define local tooling commands and required CI evidence/failure interface."},
  "quickstart": {"required": true, "reason": "Feature-specific inventory refresh, local reproduction and artifact retrieval."}
}
```

## Complexity Tracking

No constitution violation. Two static-analysis passes preserve literal CLI behavior without extending analyzer configuration; no duplicate test profiles or new general-purpose framework.
