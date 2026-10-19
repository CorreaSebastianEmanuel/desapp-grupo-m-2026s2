# Implementation Plan: Existing Credo Findings Remediation

**Branch**: `066-credo-remediation` | **Date**: 2026-10-18 | **Spec**: [spec.md](spec.md)

## Summary

Deliver TASK-066 as the behavior-preserving prerequisite of TASK-065. Pin Credo exactly, measure all maintained first-party Elixir, review the archived draft independently, and remediate the complete current inventory in small causal batches. Existing behavior and assertions are the oracle. Product challenge findings are resolved below; FR-008 does not authorize defect fixes. Discovered behavior defects require a separate backlog item or explicit scope approval before correction.

## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6 (`.tool-versions`).
**Primary Dependencies**: Existing Phoenix/LiveView, Ecto/PostgreSQL, Oban and Redix; add exactly Credo 1.7.19 with `only: [:dev, :test], runtime: false`, plus its locked transitive prerequisite only. Reuse identical prerequisites when TASK-065 lands; never duplicate declarations.
**Storage**: Existing PostgreSQL test databases/owned schemas; disposable Redis. No schema or persisted data changes.
**Testing**: Existing ExUnit, Python, Node, shell inventories and Chromium profiles; `verification.json` is the executable acceptance map.
**Platform/Type**: Local Linux modular Phoenix application; maintenance refactor, no new service.
**Performance goals**: Preserve existing performance assertions and timing contracts; no new optimization target.
**Constraints**: No behavior changes, reset of shared databases, assertion weakening, suppressions, baseline, raised thresholds, or new mandatory CI integration. Preserve credential-safe diagnostics.
**Scale/Scope**: Every current finding, not only the 71 archived source refactors (40 application files). Scope comes from fresh measurement, not historical counts.

## Constitution Check

Pre-design: PASS. Specification and product decision bound remediation; no unresolved product decision. Domain invariants remain mandatory. Existing module boundaries and fixtures remain authoritative. Evidence must be executed; historical receipts cannot establish success. Independent QA/review and human merge remain required.

Post-design: PASS. No new infrastructure, interfaces, schema, financial rule or exception to the constitution. ADR-0029 records the tool measurement decision; settled architecture remains in docs/ARCHITECTURE.md and ADRs 0006, 0013, 0024, 0025, 0026 (browser session), and 0028 (test inventory). No new architecture research is needed for these choices.

## Measurement and source boundary

The one standard command is `MIX_ENV=test mix credo --format flycheck`, run at repository root. Normal default priority applies: no `--strict`, `--all-priorities`, priority override, ignore/only checks, suppression or exit-status masking. Credo's issue exit status must propagate.

Use the supported `%{configs: [%{name: "default", files: ..., strict: false, color: false}]}` schema. Include `lib/`, `config/`, `priv/`, `scripts/`, all of `test/`, and root `mix.exs`, `.formatter.exs`, `.credo.exs` plus any other maintained root Elixir discovered by inventory. Do not override the stock check list or its parameters. Exclude only generated/third-party trees (`_build`, `deps`, `node_modules`, vendored/generated assets, ignored disposable tmp); no maintained source exclusions. Inventory git-listed tracked and nonignored untracked `.ex`/`.exs` sources independently and reconcile every path against effective analyzer inputs. Existing low-priority findings are outside the default-priority outcome; they must not be promoted or hidden by configuration changes.

Before source remediation, retain the fresh complete finding inventory locally, with source revision/diff identity, analyzer version, command, check/path/line/category and file inventory hash. Keep a bounded `handoffs/remediation.md` ledger linking each original finding to a causal change and affected test command; enumerate newly exposed findings too. No claim based on the archived count. Final measurement must contain zero findings and no parse/config omissions.

## Draft reuse and compatibility design

The local archive is `../task066-split/TASK-066-draft.patch` relative to this worktree, with sibling `manifest.json`. Its base is 57b26cc and its expected draft SHA256 is af9164af764551ad12f7bfbac2c16d33a62ff666a53541fd2fce938d8c9012c8. It is optional input, never a permanent verification dependency. If unavailable, remediate from fresh inventory. Verify digest/base and review every proposed hunk against current source before applying a bounded portion; do not blanket-apply the archive. Record accepted/rejected hunks and reasons. No QA credit is inherited.

The archived flat Credo configuration is not the supported named configuration and misses maintained test files; replace it. Its `~> 1.7.19` dependency is not an exact pin; use `"1.7.19"`. Private helper extraction, equivalent control-flow simplification and alias/documentation cleanup are allowed only with preserved evaluation and exception boundaries. Keep queries and locks inside their original transaction; preserve rollback/error precedence and short circuiting. Never move writes or callbacks across a guard, rescue, transaction or lock.

All seven product invariants remain fixed: 100-token supply, Decimal monetary values, atomic/idempotent trading, append-only transactions/audit, immutable quotes, local reads during provider failure, and reproducible valuation. Authentication keeps owner checks, revoked/expired authority, public error shapes and safe diagnostics. Native profile receipt identity, source/provenance and child-process ownership remain intact. E2E map patterns stay subset matches, including catalog nested maps; equality against projected data is not a substitute.

## Test-first delivery and regression selection

Before each refactor, identify affected existing assertions and execute the smallest useful tests; add characterization tests first for any uncovered ordering, malformed-input, rollback, concurrency or ownership branch. New characterization asserts current behavior and passes before refactoring. The tooling contract tests are written red before dependency/configuration changes. No product correction is implemented under FR-008 without renewed explicit scope authorization and failing regression first.

| Changed paths | Causal regression commands / preservation oracle |
|---|---|
| mix.exs, mix.lock, .credo.exs, README.md | new test/ci/credo_remediation_contract_test.exs: exact pin/lock, dev/test runtime exclusion, effective complete scope, inherited stock rules and documented invocation |
| lib/football_market/accounts*, web session/auth/components | mix test test/football_market/accounts test/football_market_web; HTTP/browser status, errors, revoked/expired authority, owner separation |
| lib/football_market/market*, valuation* | mix test test/football_market/market test/football_market/valuation; supply, exact Decimal values, rollback, concurrency, immutable inputs/history/replay |
| statistics*, catalog*, providers*, synchronization* | mix test test/football_market/statistics test/football_market/catalog test/football_market/providers test/football_market/synchronization; malformed-input/error precedence, whole-result rejection, local read independence, durable retry behavior |
| lib/mix/tasks*, infrastructure*, config/, priv/ | mix test test/football_market/infrastructure test/integration; guard/identity and migration behavior, no migration semantics change |
| test/support/, test/ci/, test/e2e/ | native profile inventory/audit, existing receipt/ownership negative cases, real HTTP and E2E subset assertions; affected tests before full profiles |

These commands are selection examples for causal batches, not extra full-profile gates. Use file-level subsets within them and record exact commands for changed paths. All final profiles run once each after all source/design edits: unit, integration and E2E. Integration already owns the real workspace HTTP assertions and its browser fixture; E2E owns connected shell and durable Oban/catalog journeys. `runtime: true` on both profiles captures those existing assertions without a duplicate standalone HTTP run. Their internal readiness waits and browser launch fail closed. Service preflight also verifies PostgreSQL migration and Redis PONG. Docker is required for the owned integration lifecycle tests; never operate against shared service identities.

## Verification and checkpoint coverage

Run manifest checks through `scripts/agentflow_check.py CHECK_ID` before QA. Check toolchain, prepare locked dependencies/assets/Node24/Chromium outside final verification, establish a unique safe test partition and live service mappings, then execute preflight and final checks. Do not hardcode the archive's old PostgreSQL port as current truth. Pass safe selected service/partition environment to the helper; never put credentials in artifacts. Compile/format, all three complete profiles, zero-finding measurement and source/scope contract cover CP2 regression duties. Existing CI/coverage stays unchanged; no CP1 coverage collector, Sonar probe or whole-application quality integration is added. This task does not claim delivery of future charts or conditional orders.

Manifest mappings are executable regression evidence, not a proof of semantic equivalence. FR-005/006/007/008/010 additionally require hunk review and the ledger, challenged by fresh QA. FR-011/SC-005 developer checks validate the downstream gate declarations; only actual independent reports ending exactly `Verdict: PASS` satisfy their eventual outcome. Do not require nonexistent future reports as developer acceptance checks. TASK-065's `depends_on: none` metadata is currently inconsistent with FR-012: implementation must change it to TASK-066 and keep TASK-065 todo/blocked until completion; never start or complete it here.

After causal fixes run targeted checks, then finish all edits before final manifest execution. Development may explicitly reuse matching receipts; runtime checks always rerun. Stop/diagnose after two unchanged failures. QA executes independently without reuse. Only QA and review tasks are deferred via task_stages; all developer tests, inventory reconciliation and readiness complete first.

## Project Structure

Existing directories stay in place: lib/football_market (domain/adapters/persistence), lib/football_market_web (web), lib/mix/tasks (tooling), config/, priv/repo/migrations/, test/ and scripts/. Changes require an actual inventory finding; the archive is not a scope expansion warrant.

Feature outputs: spec.md, plan.md, research.md, quickstart.md, verification.json, tasks.md and concise handoffs/. Implementation adds test/ci/credo_remediation_contract_test.exs and handoffs/remediation.md; any characterization belongs in the existing affected test files. No data model or external contract is changed.

## Supporting-artifact applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete archived Credo config, source scope and regression-runner compatibility using local analyzer/runner source."},
  "data_model": {"required": false, "reason": "No entities, fields, schema, persistence transitions or validation structures change."},
  "contracts": {"required": false, "reason": "No external interface changes; preserve existing HTTP and profile contracts and execute their existing runtime assertions."},
  "quickstart": {"required": true, "reason": "Feature-specific analyzer setup, inventory/draft review and independent regression validation need a runnable guide."}
}
```

## Complexity Tracking

No constitution violations or durable deviation from the product architecture. ADR-0029 documents the narrower tooling decision and corrects the unsafe archived measurement boundary.

Implementation scope compatibility: existing cross-feature scope guards reject the authorized lint edits. Extend `test/support/workflow_scope.ex` with a finite TASK-066 path list derived from the fresh finding inventory plus its exact tooling/scope-test prerequisites. Add negative allowance checks in `test/ci/workflow_scope_test.exs`. The provider Mix contract permits the one exact nonruntime Credo declaration while retaining dependency mutation/duplication refusals. No application boundary changes.

CI fixture correction (2026-10-19): preserve both original occupied-port failure
assertions, but reserve each port on the same Docker daemon as Compose using a
short-lived container from the already pinned Redis image. WSL-local listening
sockets are not a portable Docker host reservation: isolated probes reproduced
successful Compose startup while those sockets were listening. A daemon-published
blocker instead produced the required collision for both PostgreSQL and Redis.
Verify the blocker is running and publishes the exact loopback port before the
existing startup refusal and diagnostic assertions. Use no persistent volumes or
Redis persistence for the blocker. Track its ID in an invocation-private cidfile
and release it on each case and traps; affect only invocation-owned resources.
Before each case, remove only the stopped service containers from the isolated
project so a previously failed startup cannot reuse its port allocation. The
intermediate workaround alone was insufficient; daemon reservation is also needed.
Production
lifecycle behavior and public application behavior stay unchanged. Permit only
that exact shell test path in the native scope guard, keeping unknown-path refusals.
Validate repeated isolated runs, then all manifest checks and the exact CI wrapper.

Final development check additions: `tooling-contract` verifies actual merged stock enabled checks and adversarial config/source omissions; `inventory` runs the analyzer API with default CLI options, validates parsing, reconciles all maintained git-listed roots and writes `tmp/task066/effective-measurement.json` with check identities and source hashes. Causal argv arrays remain in verification.json as executable evidence for the reviewed batches, including isolated seed selection. Full unit/integration/E2E gates remain mandatory and unchanged. Preserve all 877 previously registered case identities; add seven new cases and register six existing fast-lane cases absent from the baseline inventory.

CI output contract correction (explicit user request, 2026-10-19): preserve the
exact CI command, both profiles, full receipt validation and nonzero failure exits.
`scripts/ci_unit_tests.sh` emits only a schema-1 JSON completion object on stdout
after validation; existing component/sentinel diagnostics move to stderr. This
repairs the existing JSON-declared Agentflow gate without altering saved workflow
state, deleting the gate or adding CI integrations. Extend the existing seven-case
shell contract to parse the entire success stdout as JSON and require empty stdout
on profile/receipt failures. Preserve secret-redaction and discovery sentinel checks.
The native test allowance and manifest permit only these exact repair paths.
