# Implementation Plan: CP1 Acceptance Evidence

**Branch**: `015-cp1-acceptance-evidence` | **Date**: 2026-09-29 | **Spec**: [spec.md](spec.md)

**Input**: TASK-015 specification, product challenge and approved product decision, current human feedback (none recorded in `backlog/feedback/TASK-015.md`), architecture baseline, and constitution.

## Summary

Add a version-controlled CP1 evidence manifest, a fail-closed validator/renderer, an ordered local demonstration, and one GitHub Actions acceptance workflow. The workflow evaluates all ten checkpoint obligations for its exact committed SHA, publishes one human-readable acceptance record plus sanitized receipts, and reports PASS only when every obligation is current, safe, accessible, and passing. Local working-tree results remain useful preflight evidence but cannot produce the final CP1 PASS.

### QA corrections Q1–Q2

Validate manifest criteria, complete FR/SC traceability and the governing obligation-to-receipt/class/regression mappings; an editable manifest cannot replace Sonar or another gate with a passing demo. Correct the existing sanitized CLI failure boundary in `lib/mix/tasks/catalog.seed.ex`: on failure, stop only an application started by that invocation before restoring logging, so its connection retries cannot leak database errors. Successful seeding and already-running application ownership remain intact. Add deterministic delayed-output coverage in `test/mix/tasks/catalog.seed_test.exs`. This repairs the existing safety contract and required baseline without changing authentication, catalog behavior, persistence rules or quality thresholds.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`, Erlang/OTP `29.0.6`; POSIX shell; Python 3 from the existing GitHub runner; Node.js `24.x` for OpenAPI browser verification.

**Primary Dependencies**: Existing Phoenix/Ecto/PostgreSQL application, ExUnit profiles, coverage publisher, deterministic seed, OpenAPI/Playwright tooling, GitHub Actions, and SonarCloud gate; no new runtime or package dependency.

**Storage**: Existing PostgreSQL for the isolated demo; version-controlled manifest/guide; generated JSON, Markdown, and sanitized receipts in a GitHub Actions artifact. No schema or product-data change.

**Testing**: ExUnit for application journeys; Python standard-library tests for manifest validation/rendering; shell/workflow contract fixtures for revision, missing/stale evidence, redaction, and aggregation.

**Target Platform**: Supported macOS/Linux checkout and `ubuntu-24.04` GitHub Actions with PostgreSQL 16, exact BEAM toolchain, Node 24, and Chromium.

**Project Type**: Modular Phoenix web service plus repository verification tooling.

**Performance Goals**: A prepared local demonstration completes within 20 minutes; validator evaluation is negligible relative to existing quality, profile, and browser checks.

**Constraints**: Verification/documentation only. No authentication, API, domain, persistence, quality-threshold, coverage-policy, provider, or post-CP1 behavior change. Never emit or retain credentials or raw child-process output. Final PASS requires committed exact-SHA evidence and completed hosted checks.

**Scale/Scope**: Ten checkpoint entries, the existing five-league/5-season/10-team/4-position/20-player seed, two credential forms, catalog list/detail/pagination/filter cases, and existing quality/unit/integration/OpenAPI surfaces.

## Constitution Check

### Pre-design gate

- **Specification before implementation — PASS**: `spec.md` is testable; the approved human check selects whole-project unresolved Sonar issues on the governing branch.
- **Domain integrity — PASS**: this feature observes existing CP1 behavior and introduces no domain or financial rule.
- **Modular simplicity — PASS**: orchestration stays in scripts, tests, workflow, and documentation; the monolith and all web/domain/persistence boundaries are unchanged.
- **Evidence-based quality — PASS**: a machine manifest and fail-closed validator replace subjective aggregation; fixtures cover stale, missing, unsafe, and failed evidence.
- **Independent verification — PASS**: the critic's findings are resolved below; implementation, QA, and final review remain separate gates.

### Post-design gate

**PASS.** [research.md](research.md), [data-model.md](data-model.md), the [acceptance contract](contracts/cp1-acceptance.md), [quickstart.md](quickstart.md), and [ADR 0010](../../docs/adr/0010-cp1-exact-revision-acceptance-record.md) resolve all unknowns without a constitutional exception.

## Design

### Canonical manifest and fail-closed evaluator

1. Commit `config/cp1_acceptance.json` as the source of truth. It declares schema version, exactly the ten stable obligation IDs from FR-003, criterion, evidence class, required receipt types, and safe durable references. It contains no manually editable overall verdict and no literal self-referential commit SHA.
2. `scripts/cp1_acceptance.py` resolves the candidate as the full clean `HEAD`, ingests allowlisted machine receipts, validates their schema and candidate SHA, scans all retained outputs for prohibited material, and emits `acceptance.json` and `acceptance.md`. It rejects unknown/duplicate/missing obligations or receipts, non-PASS states, inaccessible/unpublished indicators, mixed revisions, unsafe output, malformed values, and any status other than the closed allowlist. Any evaluator error is nonzero and overall `NOT PASSING`; only ten passing entries yield `PASS`.
3. The generated record contains candidate SHA, UTC collection time, each criterion/observation/outcome/provenance/reference, evidence class (`automated`, `demonstrated`, or `hosted`), and aggregate verdict. JSON is authoritative; Markdown is a deterministic rendering checked against it.
4. Fixture tests change the revision and force every non-pass class required by FR-006/SC-007. Secret sentinels cover passwords, API-key secrets, JWTs, verification values, provider payloads, shell tracing, HTTP captures, and child failure text. Unsafe staging is deleted and credentials are considered compromised; guidance requires rotation/revocation before rerun.

### Exact-revision publication sequence

1. Local development and QA run the same evaluator in preflight mode against a committed SHA or explicitly labelled working-tree snapshot. A snapshot may validate mechanics but can never emit final PASS.
2. After Agentflow publishes the reviewed feature commit, the PR workflow runs the quality baseline, unit/integration profiles, coverage, demonstration, and exact-head PR analysis. These are pre-merge evidence only because the governing whole-project count is `main`.
3. Merge triggers the `main` acceptance workflow at the integrated SHA. It reruns every local/automated check, waits for the Sonar workflow/result for that same SHA, and evaluates the governing `main` analysis. No earlier green result is copied forward.
4. The workflow publishes a single named `cp1-acceptance-<full-sha>` artifact containing only the generated record and sanitized receipts, writes the record summary to the run, and exposes links through a stable README acceptance section and the workflow runs page. Artifact/run access uses normal repository authorization. Failure still publishes a safe NOT PASSING record when possible.

### SonarCloud decision

Use project `CorreaSebastianEmanuel_desapp-grupo-m-2026s2`, branch `main`, metric `open_issues`, and the latest completed analysis whose revision equals the candidate SHA. The accepted population is every Open issue type produced by active quality profiles; Accepted, Fixed, and False Positive issues are excluded. Record analysis key/URL, profile identities, retrieval time, SHA, and count. Counts 0–9 pass; 10+, missing, stale, incomplete, inaccessible, or unpublished evidence do not. This applies ADR-0001 and the approved product recommendation.

### Demonstration boundary

1. Start from a clean checkout at the candidate SHA, stopped project processes, and an isolated disposable local PostgreSQL database. Dependency download, first service/image startup, and hosted-service latency are prerequisites and excluded from SC-004 timing. Start timing immediately before database preparation; stop after the second seed-invariant assertion and final safe-artifact scan. Teardown is excluded.
2. Use only deterministic local data and existing application boundaries. Seed twice and require stable totals: 5 leagues, 5 seasons, 10 teams, 4 positions, 20 players (44 records), two teams/four players per season, two players per team, and one GK/DEF/MID/FWD per season.
3. Use a fresh unique demo email per run. Exercise user creation, duplicate rejection, one-time API-key issuance without capture, API-key verification, JWT login, invalid credentials, both protected credential forms, revocation, catalog list/detail, bounded continuation, league/team/position filters singly and combined, one valid empty result, one invalid input, public OpenAPI JSON/UI, and protected requests from the UI.
4. A demo harness owns transient credentials in private files/environment (`umask 077`, tracing disabled), asserts responses internally, and emits only fixed behavior IDs and PASS/non-pass receipts. It never records request headers, bodies containing credentials, raw responses, database rows, or SQL debug output.

### Checkpoint gates versus supporting regression

The ten FR-003 rows alone determine CP1. Pagination, filter combinations, revocation, separate integration execution, and coverage are supporting regression evidence nested under their named catalog, API-key, and automated-test obligations because prerequisite task contracts already require them. They do not become eleventh or independent checkpoint gates; failure still makes the containing obligation non-passing because it contradicts that obligation's governing contract.

## Critic Findings and Rejected Alternatives

1. **Revision circularity**: generate the record after checkout and bind it to the workflow SHA; rerun on integrated `main`. Rejected: committing generated evidence back into the candidate (creates a new SHA), copying PR evidence to `main` (stale), and claiming a working-tree snapshot as final.
2. **Manual aggregation**: JSON manifest plus validator is authoritative. Rejected: a hand-edited PASS document or review-only algorithm, which cannot reliably detect missing/stale entries.
3. **Sonar ambiguity**: apply the approved whole-project Open-issue population and exact-`main` revision check. Rejected: new-code and PR-only counts because they can pass with ten or more project issues.
4. **Scope inflation**: map prerequisite regressions beneath the ten named obligations. Rejected: eleven-plus top-level gates and weakening existing prerequisite contracts.
5. **Undefined repeatability/timing**: isolate data, define clock boundaries, assert exact seed invariants twice, and keep teardown/prerequisite acquisition outside the clock. Rejected: reuse of ambient developer data or timing network/bootstrap work.
6. **Secret inspection after disclosure**: capture privately, emit allowlisted receipts, scan before atomic publication, and destroy unsafe staging. Rejected: terminal transcripts followed by redaction, because disclosure has already occurred.

## Project Structure

### Documentation and contracts

```text
specs/015-cp1-acceptance-evidence/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/cp1-acceptance.md
└── handoffs/architecture.md
docs/adr/0010-cp1-exact-revision-acceptance-record.md
README.md                                      # stable acceptance/demo entry points
```

### Implementation boundary

```text
config/cp1_acceptance.json                     # ten-obligation canonical manifest
scripts/cp1_acceptance.py                      # validate, aggregate, render
scripts/cp1_demo.sh                            # safe ordered local demonstration
.github/workflows/cp1-acceptance.yml           # exact-SHA orchestration/publication
test/ci/cp1_acceptance_test.py                 # manifest/evaluator/adversarial fixtures
test/ci/cp1_demo_contract_test.exs             # demo behavior and safe receipt contract
test/fixtures/cp1_acceptance/                   # synthetic safe pass/non-pass inputs
```

**Structure Decision**: acceptance tooling consumes existing public/domain commands and verification scripts but does not enter application modules. The workflow orchestrates existing checks and produces evidence; it does not redefine their behavior.

## Verification Strategy

1. Validate exact manifest membership and schema; exercise missing, duplicate, unknown, malformed, failed, skipped, canceled, timed-out, inaccessible, stale, unpublished, mixed-SHA, and unsafe fixtures.
2. Prove deterministic JSON-to-Markdown rendering, exact-SHA binding, no final PASS for dirty/snapshot inputs, all-ten conjunction, and safe NOT PASSING publication.
3. Run the demo twice from isolated state and assert fixed seed invariants, unique-user procedure, every security/catalog/contract behavior ID, no live provider use, and zero secret sentinel leakage.
4. Run formatter, warnings-as-errors compilation, locked quality baseline equivalent, `mix test.unit`, `mix test.integration`, `mix test.cp1_coverage`, manifest/evaluator tests, and demo contract tests.
5. On published PR and then integrated `main`, require same-SHA GitHub and Sonar evidence, verify durable links under normal reviewer authorization, and inspect only sanitized artifacts. Record commands actually run; never infer hosted success locally.

## Complexity Tracking

No constitution violation requires justification.
