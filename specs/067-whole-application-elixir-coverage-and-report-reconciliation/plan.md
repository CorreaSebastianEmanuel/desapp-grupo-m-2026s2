# Implementation Plan: Elixir Coverage Reconciliation

**Branch**: `067-whole-application-elixir-coverage-and-report-reconciliation` | **Date**: 2026-10-20 | **Spec**: [spec.md](spec.md)

## Summary

Add an informational application-only report using native exports from the existing audited unit/integration profiles. Reconcile every TASK-065 path against an explicit coverage role inventory, retain every normal ExUnit partition, bind all exports to one content snapshot and publish only after complete validation. Human feedback in `backlog/feedback/TASK-067.md` controls the denominator. Tests/support never contribute. No threshold, Sonar import, application behavior change or runner redesign.

## Technical Context

- **Language/version**: Elixir 1.20.3 / OTP 29.0.6; Python 3 standard library; existing shell wrappers. Node 24 and locked Playwright/Chromium are existing profile prerequisites.
- **Dependencies**: existing Mix native coverage, OTP `:cover`, Jason, Git, existing audit/formatter/supervisor. No new package or service.
- **Storage**: explicit reviewed JSON inventory in `config/`; private invocation staging and ignored `cover/application/` output. PostgreSQL/Redis are existing test services, not coverage stores.
- **Testing**: Python unittest for orchestration/accounting; ExUnit for native-cover fidelity and Mix/profile compatibility; existing audited profiles and E2E. New cases are explicitly registered in `config/test_profiles.json`.
- **Platform/type**: existing Linux modular Phoenix application; change is developer tooling. No production code in `lib/` is changed.
- **Performance**: one unit and one integration profile per collection; one native export per scheduled top-level ExUnit invocation; no extra full-profile pass for HTML, documentation, receipt verification or CP1. Existing profile deadlines and cleanup remain authoritative.
- **Scope**: all tracked Elixir entries in `config/credo_inventory.json`; coverage includes exact maintained application implementation paths rooted under `lib/`. Report size is linear in source/partition line records. No coverage percentage target.
- **Unknowns**: resolved by focused local native-code inspection in [research.md](research.md). Established architecture and versions remain as documented in `docs/ARCHITECTURE.md`, ADR-0009, ADR-0028 (independent test inventory), ADR-0029 and ADR-0030.

## Constitution Check

| Principle | Before design | After design |
| --- | --- | --- |
| Specification first | PASS: approved spec/feedback; no product decision pending | PASS: FR/SC traceability in verification.json; tasks are test-first |
| Domain integrity | PASS: informational tooling only | PASS: no production code, migration, provider or financial change; existing invariant regressions run in audited profiles |
| Modular simplicity | PASS: existing services/native tools | PASS: scripts and test helpers only, no new production boundary |
| Evidence-based quality | PASS: required checks specified, not claimed executed | PASS: native fidelity and negative oracles, one profile pair, real service preflight, preserved CI |
| Independent verification | PASS: critic findings incorporated | PASS: implementation checks precede independent QA and final review; each report must end `Verdict: PASS` |

No constitution exception is needed. ADR-0031 records the durable coverage tooling extension and its separation from CP1. Architecture-stage validation establishes design consistency, not implementation acceptance.

## Phase 0: Focused resolution

See [research.md](research.md) for the three concrete uncertainties: native export scope, integration partition scheduling and missing snapshot binding. No technology survey or research agents. Critic resolutions are recorded in ADR-0031: exact path/role inventory, content-bound sidecars and current-attempt status separated from historical success.

## Phase 1: Design

### Source reconciliation (US1; FR-001–004)

`config/credo_inventory.json` is the TASK-065 oracle, not the old CP1 allowlist. Independently enumerate tracked `.ex`/`.exs` paths using NUL-delimited Git output; validate sorted unique maintained/excluded entries and their union against Git. Add `config/application_coverage_inventory.json`, with one exact path/role/disposition/reason record per oracle entry. Do not edit TASK-065 classifications to make coverage pass. All current maintained `lib/` application implementation entries are included; all other entries are excluded as tests, fixtures, test support, configuration, migrations, scripts, root tooling or archived evidence. Roles must agree with the canonical entry and actual source location. Every exclusion has a specific path-associated reason. New/renamed/reclassified files require reviewed inventory changes; no prefix automatically adds source to the metric. A helper/generated non-application source newly placed under `lib/` needs an explicit supported role and rationale review; it cannot silently enter or bypass the current agreed application scope.

Resolve compiled application modules from fresh compiler/BEAM source metadata, not regex matching `defmodule`. Cover normal, nested and generated modules whose source belongs to an included path; reject stale/missing source bindings or ambiguous ownership. Preserve all included files in output. A genuinely non-executable file may have zero native executable lines and a documented reason with percentage `null`; failure to instrument/analyse is never interpreted as zero. Denominator is positive for the aggregate. No test/support module contributes even when present in native exports.

### Opt-in capture without changing profile ownership (US2; FR-005–009)

The Python report command launches `sh scripts/test_profile.sh unit` and then `integration` with private receipt paths and a new `APPLICATION_COVERAGE_DIR` opt-in. The existing supervisor still owns discovery, expected cases, event reconciliation, all child deadlines, cleanup, failure handling and final receipts. Its normal scheduling remains unchanged. Add capture only at its existing top-level `execute_exunit` invocation boundaries: unit main, integration regular if nonempty, and each audit-owned committed-file invocation. Add `--cover --export-coverage UNIQUE_PARTITION` to those existing calls. Preserve their database partitions, files, tags and formatter. Reject simultaneous application and historical CP1 coverage options. E2E and recursive test subprocesses do not inherit application collection options; they retain existing behavior. Nested BEAM execution is not measured by the parent export and is a documented limitation, not an invented new partition requirement.

Record expected partitions before any profile child executes: derive file membership from the existing audit-owned committed-file list, not from whichever exports happen to exist. Each scheduled partition has a stable logical ID, profile, exact selected-file list hash and unique run-qualified export name. Existing randomized database partition IDs are recorded separately. Profile receipts remain byte/schema compatible and still belong to their owner. New separate coverage sidecars bind their nonce and file hash only after genuine profile completion, including all non-ExUnit components and resource cleanup. A profile's own success cannot make an absent/invalid native export acceptable.

`mix.exs` only adds the opt-in native output directory, leaving existing CP1 allowlist, ignore list, threshold-zero behavior and default output intact. Local inspection confirms native Mix exports all instrumented app BEAMs before applying summary filtering; do not expand the CP1 ignore list or use its denominator. Export success must be checked by presence, digest, native import and expected module/line population: Mix's exporter can log an export error without raising.

### Snapshot, native parsing and aggregation

Before discovery/preflight collection, generate a run UUID, HEAD and SHA-256 over a canonically JSON-encoded sorted manifest of every Git-listed tracked and nonignored untracked path and its bytes (including deletion markers). This includes tests, configuration, inventories, scripts, locks and execution-affecting assets. Exclude only ignored generated outputs and documented post-execution QA/review/handoff artifacts; normalize task checkboxes, not task descriptions. Include the snapshot algorithm version and toolchain identity. Do not substitute HEAD alone or the profile inventory digest. Validate the same identity before/after each profile and before publication; reject dirty-source mutation and mismatched sidecars. Dirty and new feature inputs are supported without staging or committing.

Native `.coverdata` inputs are only private same-run outputs. Hash before import; use a fresh isolated `:cover` instance per partition via `scripts/application_coverage_native.exs`. Validate expected compiled-module/source mapping and executable line sets independently against freshly compiled app BEAM metadata and zero-call native instrumentation. No application execution in the reader (`mix run --no-start`). Native records must have valid module, source, positive in-range line and nonnegative integer call count; non-executable compiler markers are explicitly classified, not counted. Unexpected/missing modules, truncated input, failed import, duplicate records, conflicting executable sets or incomplete normalized JSON fail closed. Import each partition separately so a combined native import cannot erase provenance or conceal a missing partition. Escape report HTML and expose only safe diagnostic categories, paths and logical IDs; never raw child output or payloads.

Aggregate by `(repository-relative included source path, executable line)`, with coverage as Boolean OR across modules and partitions, never summed percentages or module totals. Duplicate native `(module,line)` records are invalid; legitimate same-source lines shared by different modules count once. Enforce each partition's expected executable population for included source. Aggregate covered and uncovered sets partition the executable set. Retain per-file lines, totals, every included/excluded file and expected/observed profile partitions. A low percentage is valid; no minimum is introduced.

### Publication and stale success (US3; FR-010–012)

Use an invocation lock for the application output root. Write `status.json` as running with a fresh attempt ID before collection; a report is current only when status says complete and binds that exact immutable run, snapshot and report hash. Stage outputs privately, validate a reread, then atomically publish an immutable run directory and finally atomically update status. On failure/interruption, current status is failed/incomplete and the command exits nonzero; a process killed before cleanup leaves running, never complete. Previous successful directories remain labeled with their own snapshots and historical status, and are never selected as the current result. Refuse unsafe output paths/symlinks and writes into existing CP1, JS or receipt roots. Readers fail on missing/malformed/current-status mismatch. See contract for CLI/output specifics.

Generate `report.json`, `report.html` and `measurements.md` together: measured aggregate and per-file numbers, snapshot, complete exclusions and limitations are documentation attached to that successful report. Contributor instructions in `docs/APPLICATION_COVERAGE.md` link those measured artifacts instead of hard-coding a number that becomes stale. Finish all source/design/contributor-doc edits before the final run. Store a concise result pointer in `handoffs/develop.md` afterward; no historical metrics are current evidence.

## Project Structure

```text
config/application_coverage_inventory.json        # new exact source roles
scripts/application_coverage.py                   # CLI, snapshot, validation, aggregation, publication
scripts/application_coverage_native.exs           # native export normalization, fresh isolated reader
scripts/test_profile_runner.py                    # opt-in export attachment at existing invocation boundaries
mix.exs                                          # opt-in output directory only
config/test_profiles.json                         # register new native/ExUnit cases
test/test_helper.exs                              # clear inherited collection options after Mix configuration
test/support/workflow_scope.ex                    # finite tooling-only planned allowance
test/ci/workflow_scope_test.exs                    # reject application/CI scope expansion
test/football_market/providers/scope_test.exs      # exact approved Mix output normalization; retain all other AST checks
config/credo_inventory.json                       # account for new Elixir scripts/tests per TASK-065 policy
scripts/credo_inventory.exs                       # unchanged oracle
test/scripts/application_coverage_test.py         # accounting/export/publication/failure oracles
test/ci/application_coverage_native_test.exs       # native fixture fidelity and edge cases
test/ci/application_coverage_contract_test.exs     # default/opt-in compatibility
docs/APPLICATION_COVERAGE.md                      # reproducible commands and measured-artifact links
docs/TEST_PROFILES.md                             # optional export mode and retained ownership
docs/adr/0031-application-only-coverage-evidence.md
cover/application/status.json                     # ignored current-attempt status
cover/application/runs/RUN_ID/                     # ignored immutable report, measurements, exports, sidecars
specs/067-whole-application-elixir-coverage-and-report-reconciliation/
  plan.md research.md data-model.md quickstart.md verification.json tasks.md
  contracts/coverage-cli.md handoffs/architecture.md handoffs/tasks.md
```

Existing CP1 publisher, wrapper, inventory, JS coverage and CI workflow definitions remain intact. Any additional helper must stay inside these tooling/test boundaries; production refactors and CI expansion require a scope decision.

## Validation and checkpoint coverage

`verification.json` maps all 12 FR and eight SC identifiers; the spec contains no AC identifiers, so story scenario numbers are mapped here rather than invented IDs. US1 scenarios 1–3 map to accounting/source/denominator tests and final report validation; US2 scenarios 1–3 map to partition/native/fault tests and live capture; US3 scenarios 1–3 map to reproduction/doc/failed-publication tests and the live report. All edge cases are negative fixtures, including zero-executable files and prior successful runs followed by failures.

The implementation owner runs all manifest checks before QA, using `scripts/agentflow_check.py`; QA independently reruns without reuse. The application-report check performs service/toolchain/Chromium preflight, prepare/build, exactly one audited unit/integration pair (which includes all new focused tests), verifies the profile receipts, normalizes exports and asserts report accounting. E2E runs once separately to preserve the existing CP2 gate and exercise runner compatibility. No new HTTP endpoint or application interface is affected, so endpoint runtime obligations are inapplicable; existing HTTP/browser assertions remain in integration/E2E. No bare HTTP request is evidence. Unavailable services fail the checks.

The first manifest check is preflight: prepare services/database before any native case discovery and reconcile the test inventory. Other checks are formatting, warnings-as-errors compilation, current Credo/inventory oracle and OpenAPI validation. The collection command repeats readiness inside its own check so unavailable services cannot reuse an earlier successful preflight. Do not separately rerun full unit/integration after the application-report check. Do not invoke `mix test.cp1_coverage` as an added CP2 gate: preserve its code/contracts and hosted workflow instead. CI remains mandatory under existing jobs; this feature does not add a percentage gate or change hosted settings. CP2 domain/charts/conditional-order scope is untouched; this is engineering evidence, not delivery of unfinished capabilities. CP3 cache/monitoring work is out of scope. Re-run changed/failed checks according to AGENT_CONTEXT_POLICY; do not bypass the two-failure budget.

## Complexity Tracking

No violation. ADR-0031 extends evidence contracts rather than adding a production abstraction, dependency or service. Separate native normalization is necessary to preserve per-partition integrity; modifying test scheduling or duplicating full runs would be larger and would violate FR-011/012.

## Supporting artifact applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve native export scope, normal integration partition capture and absent content snapshot identity using pinned local sources."},
  "data_model": {"required": true, "reason": "New exact coverage inventory, partition sidecars, run status and reconciled report structures."},
  "contracts": {"required": true, "reason": "New contributor CLI, opt-in environment and versioned file evidence interface; no HTTP interface."},
  "quickstart": {"required": true, "reason": "Feature-specific collection, service preflight, measured output and failure reproduction procedure."}
}
```

Implementation clarification: Mix 1.20 requires `Mix.ensure_application!(:tools)` before standalone native reads; OTP 29 `:cover.import/1` returns `:ok` and imported modules use `:cover.imported_modules/0`. Compiler line-zero records are explicitly excluded. Report HEAD records the collection origin; current content digest controls freshness, so committing identical measured content does not invalidate evidence. Native validation re-instruments the bound BEAM files and reimports each native export before trusting normalized JSON.

Compatibility correction: preflight uses `mix assets.build`, not deployment/digest generation; distribution artifacts are unnecessary test inputs. The existing provider Mix-boundary regression normalizes only the exact complete approved output override plus conflict guard; threshold/filter/dependency mutations remain rejected.

Measured validation cost required one bounded refinement: generate and independently re-instrument the complete module baseline once per report validation, then check each partition against that fresh baseline using current source/BEAM hashes, fresh isolated native imports and complete executable sets. Do not re-instrument identical BEAMs for every partition or repeat the complete validation after atomic publication. Recheck content immediately before publication. The public CLI always selects MIX_ENV=test and preflight rejects Node majors other than the existing CI Node 24. These changes preserve all profiles, partitions, performance gates and native completeness checks.

Receipt-contract correction: coverage validates exact schema-1 versions and nonnegative integer receipt counts before comparison or consumption, including audit_count derived from the same distinct ExUnit-file inventory used by the runner. Module executable lines/compiler markers and normalized native line/call values are typed before cross-artifact comparisons; coherent negative fixtures retain a nonempty real native control. Existing runner schemas and scheduling remain unchanged.

## Consolidated integrity matrix (feedback 9)

The existing schema remains unchanged. Validate these bindings in both collection and consumption before native work; final seven-check acceptance remains pending execution; feedback 11 renews authorization to complete development and downstream independent gates.

| Requirement | Fields / kind | Independent oracle and binding |
| --- | --- | --- |
| FR-006/007, SC-002/003 | profile, partition ID, selected_files (derived) | Current test inventory + TestProfileAudit.audit!("integration").committed_files; exact ordered normal schedule, no empty/extra/reassigned partition |
| FR-007 | selected_sha256 (derived) | SHA-256 of compact JSON selected_files, recomputed for every observed/report declaration; expected membership equals derived schedule |
| FR-006/007 | export, export_sha256, profile/id (cross-artifact) | Run-qualified export basename; one distinct contained path per partition; report equals sidecar observed identities and expected schedule; equal byte hashes remain legal |
| FR-007/008 | receipt nonce/hash, sidecar schema/profile/run/snapshot (cross-artifact) | Strict receipt numeric/schema contract + owner verifier; sidecar binds exact bytes and current run |
| FR-003/007 | receipt/sidecar/module/export/normalized/report/render paths (authority boundary) | Shared resolver rejects symlinks and escapes through any ancestor on reads/writes; trusted absolute BEAM metadata retains native freshness rules |
| FR-007, SC-003 | UUID, started_at, run directory (authority/format) | Canonical UUID, timezone-aware ISO timestamp; status/report/sidecars/export names agree with runs/UUID; HEAD records origin, not current Git equality |
| FR-005/007/009 | native counters, numeric counts/schema, derived totals | Preserve fresh native counter population checks (B1), exact integer/schema validation (B2–B4), native hash reimport and Boolean-OR arithmetic |

Focused tests use valid UUID/date, complete selection digests, the actual audited schedule and distinct run-qualified exports. Cheap coherent mutations precede native work; genuine nonempty native controls bracket the matrix. Replays are diagnostic only. No new format, runner redesign or final acceptance claim.

Integrity implementation uses shared schedule/identity/sidecar validators for collection and consumption, with the existing auditor invoked without application startup. Containment rejects symlinks at every artifact ancestor; absolute trusted BEAM bindings remain native-reader inputs. All cheap normalized type/hash/population comparisons precede fresh native work. Focused mutation loops retain the real precomputed audit oracle to avoid repeating discovery; positive controls execute the actual oracle and native backend before and after. Feedback 11 renews authorization after the prior integration failure was not reproduced in bounded diagnostics; focused evidence does not replace or accept full preflight/profile/CI/QA/review checks.
