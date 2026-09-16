# QA Report — TASK-004 SonarCloud Integration

Date: 2026-09-16  
Scope: branch `004-sonarcloud-integration`; independent acceptance review of the current diff. No application HTTP endpoints changed, so runtime HTTP endpoint testing is not applicable.

## Evidence matrix

| Criterion | Evidence | Result |
|---|---|---|
| US1.1 / FR-001–002 / SC-001: every PR revision runs attributable analysis | Workflow declares `pull_request` for `opened`, `synchronize`, `reopened`, `ready_for_review`, checks out the head SHA, and waits for the native gate. Contract suite: `6 passed`. However, `gh pr list --head 004-sonarcloud-integration --state all ...` returned `[]`; no real PR run exists. | **BLOCKED** |
| US1.2 / FR-003 / SC-006: reviewer sees count, threshold, and findings within two actions | Static workflow summary has separate exact-head findings and primary-count headings; Python output includes count, threshold, findings URL, and PASS. No hosted Checks view/navigation exists to exercise. | **BLOCKED** |
| US1.3 / FR-010: update governs latest revision | Static concurrency uses PR number/ref with `cancel-in-progress: true`; head SHA is propagated. No opened/synchronize or superseded-run hosted evidence exists. | **BLOCKED** |
| US1.4 / FR-011 / SC-009: integrated `main` result | Push-to-`main` trigger and strict latest-analysis SHA comparison are contract-tested. The feature is unmerged and has no integrated `main` run. | **BLOCKED** |
| US2.1 / FR-004 / SC-002: 0–9 pass | `python3 -m unittest -v test/scripts/sonar_checkpoint_gate_test.py`: 9 tests passed; fixtures 0, 7, and 9 returned exit 0 with `checkpoint: PASS`. | PASS |
| US2.2 / FR-004: 10+ fail | Same suite: fixtures 10 and 11 returned exit 2 and `diagnostic: threshold`. Workflow has no `continue-on-error` or `|| true`; contract passed. | PASS |
| US2.3 / FR-005–006 / SC-003,005: incomplete/unpublished/error cannot pass | Tests prove auth/authorization/configuration, 429/5xx exhaustion, network/timeout, malformed/missing/ambiguous data, and stale revision are nonzero. Native scanner wait is configured for 300 seconds. Real publication failure is not hosted. | PASS locally; hosted evidence blocked |
| US3.1 / FR-007: threshold diagnostic and findings link | Threshold tests emit `diagnostic: threshold`; successful parsed output includes the unresolved-findings URL before the threshold exception. | PASS |
| US3.2 / FR-007: distinguish service/config/auth failures | Tests verify stable `authentication`, `authorization`, `configuration`, `service`, `network`, `malformed-response`, and `stale-analysis` diagnostics with bounded retries. | PASS |
| US3.3 / FR-008 / SC-007: no credential disclosure | Canary/redaction tests passed. Independent `rg` scan found only protected `${{ secrets.SONAR_TOKEN }}` indirection/assertion; no literal token, bearer credential, mutable action pin, debug logging, or secret argument found. | PASS |
| FR-009: owned source/test scope | `sonar-project.properties` limits sources to `lib,assets/js`, tests to `test`, and enumerated build/vendor/generated exclusions; contract passed. | PASS |
| FR-012: operating documentation | README documents navigation, 0–9 rule, scope, protected setup, diagnostics, and reruns. | PASS |
| FR-013: scope boundary | Diff inspection found CI/config/gate/tests/docs only; no product/domain/persistence implementation changed and no coverage setting exists. | PASS |
| FR-014 / SC-008: preserve baseline | Baseline SHA check: `.github/workflows/quality-baseline.yml: OK`; no diff. `mix format --check-formatted`, warnings-as-errors compilation, and `scripts/ci_unit_tests.sh` passed (`25 passed`). | PASS |
| SC-004: accepted `main` has 0–9 open issues | No accepted/merged revision or authenticated published project result is available. Anonymous SonarCloud project query returned HTTP 401, not issue evidence. | **BLOCKED** |

Additional checks: SonarCloud contract `6 passed`; workflow YAML parsed successfully; `git diff --check` passed. Mix checks were rerun sequentially with permission for Mix's local TCP filesystem lock after sandbox-only `:eperm` failures.

## Blockers

1. No internal pull request or hosted SonarCloud check exists for this feature, so exact-revision publication, PR lifecycle events, latest-head cancellation, visible failure semantics, and two-action navigation cannot be accepted (T031; US1/SC-001/SC-006).
2. No authorized merge and corresponding `main` SonarCloud analysis exists, so integrated SHA/analysis identity, profiles, timestamp, native gate, findings URL, and authoritative `open_issues` value of 0–9 cannot be accepted (T032; US1.4/SC-004/SC-009).

Verdict: FAIL
