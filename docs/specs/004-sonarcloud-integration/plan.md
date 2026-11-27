# Implementation Plan: SonarCloud Integration

**Branch**: `004-sonarcloud-integration` | **Date**: 2026-09-16 | **Spec**: [spec.md](spec.md)

## Summary

Add a separate, required GitHub Actions workflow that publishes CI-based SonarCloud analysis for every internal pull-request head targeting `main` and every push to `main`. The workflow waits for server-side processing, preserves SonarCloud's native analysis/quality-gate result, and then runs a small fail-closed checkpoint gate. That gate reads the primary branch's authoritative `open_issues` measure and passes only for 0–9. Pull requests therefore expose both the exact-revision PR analysis and the current whole-project CP1 count; `main` runs refresh that whole-project count for the integrated SHA. Deterministic JSON fixtures prove the 9/10 boundary and failure classifications; one real published `main` result supplies final CP1 evidence. TASK-003's workflow remains unchanged.

## Technical Context

**Language/Version**: Python 3 from `ubuntu-24.04` for the standard-library gate; YAML for GitHub Actions; repository application remains Elixir 1.20.3 / Erlang/OTP 29.0.6  
**Primary Dependencies**: `SonarSource/sonarqube-scan-action` and `actions/checkout` pinned to reviewed immutable commits; SonarCloud Web API v1; Python standard library only  
**Storage**: N/A; SonarCloud stores analysis results, with no application database/cache change  
**Testing**: Python `unittest` fixtures and repository contract tests for workflow/configuration; live hosted smoke evidence after publication  
**Target Platform**: GitHub-hosted Ubuntu; SonarQube Cloud EU endpoint (`https://sonarcloud.io`)  
**Project Type**: Repository CI integration for one modular Phoenix application  
**Performance Goals**: One conclusive SonarCloud result per supported revision; bounded server-side polling (300 seconds) and bounded API retries  
**Constraints**: Internal branches only; no forks; fail closed on missing/malformed/stale/unpublished data; never print `SONAR_TOKEN`; whole-project threshold is strictly `< 10`; no coverage gate or product change  
**Scale/Scope**: One workflow, one scanner configuration, one small gate script, fixture/contract tests, documentation, and one ADR

## Constitution Check

*GATE: Passed before research and re-checked after Phase 1 design.*

- **Specification before implementation — PASS**: The design traces to FR-001–FR-014 and resolves every critic finding. Recorded human feedback authoritatively limits support to trusted internal branches and requires every PR plus `main`.
- **Domain integrity — PASS**: No business rule, product entity, database, cache, or external football adapter changes.
- **Modular simplicity — PASS**: CI owns the integration. A standard-library script isolates API response validation; no application module, service, or dependency is added.
- **Evidence-based quality — PASS**: Captured fixtures cover 9, 10, malformed/missing data, API/auth failures, stale revision evidence, and incomplete processing. Live evidence is limited to one PR analysis and one integrated `main` analysis.
- **Independent verification — PASS**: The independent challenge is resolved below; implementation, QA, and final review remain fresh gates.
- **Safety/delivery — PASS**: The token is a protected GitHub secret, passed only to scanner/API processes and never echoed. Read-only API operations and repository permissions are used.
- **Architecture/checkpoint — PASS**: The feature stays at the repository automation boundary and directly implements CP1's SonarCloud obligation while preserving TASK-003.

Post-design re-check: **PASS**. The contract, state model, and validation guide introduce no architecture-boundary violation. [ADR-0001](../../docs/adr/0001-sonarcloud-cp1-whole-project-gate.md) records the durable choice to combine exact-revision PR analysis with a primary-branch whole-project gate because SonarCloud applies PR quality gates only to new code.

## Challenge Resolution and Rejected Alternatives

| Material finding | Smallest compliant decision | Alternatives rejected |
|---|---|---|
| Governing count was ambiguous | Use SonarCloud metric `open_issues` on project key + `branch=main`. It counts every issue type emitted by the active per-language profiles whose status is Open; Accepted, Fixed, and False Positive are excluded. Record profile names/keys, revision, value, and timestamp as evidence. | `violations` includes issues in all states; summing type metrics risks double counting/version drift; a new-code metric changes CP1's whole-project rule. |
| Exact 9/10 live analyses are unstable | Unit-test the decision with captured API fixtures at 9 and 10, then verify one real published `main` result. | Deliberately polluting the CP1 project or editing profiles is unsafe and non-deterministic. |
| “Every PR” lacked events | Support `opened`, `synchronize`, `reopened`, and `ready_for_review`, including drafts; reruns use `workflow_dispatch` only as supplemental evidence. Key concurrency by PR number or `main`, cancel older work, and require the completed check attached to the latest head SHA. | `pull_request_target` is unnecessary and privileged; allowing an obsolete cancellation to satisfy the latest SHA is incorrect. |
| Failure and cancellation semantics were conflated | Authentication, scan, compute, publication, query, malformed-response, timeout, and threshold failures are visible non-passing conclusions. A canceled obsolete run is merely obsolete; the latest governing run must complete and pass. | Artificial live auth/timeout failures risk credentials/service stability; treating every superseded cancellation as a defect creates noise. |
| Scope exclusion was unsafe | Set `sonar.sources=lib,assets/js`, `sonar.tests=test`; exclude only `_build/**`, `deps/**`, `assets/vendor/**`, `priv/static/assets/**`, and generated digests/source maps. Do not exclude files because they may contain secrets. | Broad `config/**`, filename-based “secret” exclusions, or SCM-secret heuristics could hide findings. |
| Navigation/regression lacked an oracle | Measure from the PR Checks view: open the required SonarCloud check, then its findings link (at most two actions). Re-run TASK-003's documented commands and assert its workflow file is byte-for-byte unchanged. | Informal visual claims and undefined “before/after” comparisons are not reproducible. |

## Implementation Design

### Workflow, events, and revision identity

- Add `.github/workflows/sonarcloud.yml`; do not modify `.github/workflows/quality-baseline.yml`.
- Trigger `pull_request` targeting `main` for `opened`, `synchronize`, `reopened`, and `ready_for_review`, and `push` to `main`. Draft PRs are analyzed on open/synchronize. A manual dispatch may aid diagnostics but cannot replace automatic events.
- Use `contents: read` and no write permission. Checkout the event SHA with full history (`fetch-depth: 0`) so SonarCloud can identify PR base/head correctly.
- Use concurrency `sonarcloud-${event PR number or ref}` with cancellation. The GitHub check attached to the latest PR head SHA governs; a prior canceled/completed SHA never substitutes.
- Pin third-party actions to reviewed immutable commit SHAs in implementation. Dependabot updates are outside this task.

### Analysis, publication, and threshold

- Disable SonarCloud automatic analysis for the project to prevent duplicate/conflicting results; CI-based analysis is authoritative.
- Commit `sonar-project.properties` with non-secret project/organization identifiers, UTF-8 encoding, `lib,assets/js` sources, `test` tests, and only the enumerated generated/vendor/dependency/build exclusions. Coverage import and coverage thresholds remain absent.
- Run the scanner with `SONAR_TOKEN` from the protected repository secret and `sonar.qualitygate.wait=true`, `sonar.qualitygate.timeout=300`. Do not enable debug logging. Let SonarCloud/GitHub derive PR parameters from the event; on `main`, publish a normal main-branch analysis.
- A successful scan requires upload, completed compute-engine processing, publication, and native quality-gate success. The scanner metadata/response must identify the submitted task/analysis; missing or failed processing is not success.
- Then execute `scripts/sonar_checkpoint_gate.py`. Before accepting a count on a `main` run, it calls `/api/project_analyses/search?project=<key>&branch=main&ps=1` and requires the latest published analysis revision to equal the triggering Git SHA. It then calls `/api/measures/component?component=<key>&branch=main&metricKeys=open_issues`, requires exactly one non-negative integer measure, prints only project/branch/revision/metric/count/threshold and a findings URL, and exits zero only for 0–9. On a PR, the count is explicitly labelled as the current published `main` count and is not required to equal the PR SHA. HTTP errors, 401/403, 404, 429 after bounded retries, timeouts, stale or missing revision evidence, missing measures, invalid JSON, and non-integers exit nonzero with sanitized classifications.
- On PRs, the check summary distinguishes: (1) exact-head PR scan/native gate and link, and (2) current primary-branch `open_issues` CP1 count. It never labels the PR-only issue set as the whole-project count. On `main`, both refer to the newly integrated SHA after processing.
- Configure SonarCloud project `main` as the primary branch. Use the active assigned quality profile for every detected language; do not create/change profiles in this task. CP1 evidence records each profile name/key so later profile drift is visible rather than silently changing the meaning of a historical result.

### Tests, diagnostics, and evidence

- Unit-test the gate with committed sanitized fixtures for counts 0, 9, 10, and >10; matching, missing, and stale latest-analysis revisions; absent/duplicate/non-numeric/negative measures; malformed JSON; and representative auth, rate-limit, timeout, and server failures. Assert stdout/stderr never contains a fixture token.
- Contract-test workflow parsing, automatic event matrix, permissions, concurrency, full-history checkout, pinned actions, secret indirection, wait settings, main query, source/test scope, exact exclusions, and preservation of the TASK-003 workflow.
- Do not induce authentication or timeout failures against the live project. Fixture tests prove classification; a real failed hosted run, if naturally encountered, may supplement but is not required.
- Before publication, run unit/contract tests and TASK-003 parity commands: `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, and `scripts/ci_unit_tests.sh`.
- After publication, record one hosted PR run for its current head SHA. After integration, record one `main` run with analysis ID/revision/timestamp, `open_issues`, active profile identities, native gate, and findings URL. This is required CP1 evidence but is not fabricated during pre-publication QA.
- README documents where to find the PR check, the two-part result, the exact count definition, scope/exclusions, retry/failure categories, secret setup, and remediation paths.

## Project Structure

```text
.github/workflows/
├── quality-baseline.yml             # unchanged TASK-003 baseline
└── sonarcloud.yml                    # new analysis/checkpoint workflow
sonar-project.properties             # non-secret project and scope configuration
scripts/sonar_checkpoint_gate.py     # fail-closed open_issues evaluator
test/ci/sonarcloud_contract_test.exs  # repository/workflow contract
test/scripts/
├── fixtures/sonarcloud/              # sanitized Web API responses
└── sonar_checkpoint_gate_test.py     # deterministic boundary/failure tests
README.md
docs/adr/0001-sonarcloud-cp1-whole-project-gate.md
specs/004-sonarcloud-integration/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/sonarcloud-ci.md
└── handoffs/architecture.md
```

**Structure Decision**: Keep SonarCloud entirely at the CI/repository boundary. The application, its domain contexts, persistence, web layer, workers, cache, and football-provider adapters remain untouched.

## Complexity Tracking

No constitution violations or justified complexity exceptions.
