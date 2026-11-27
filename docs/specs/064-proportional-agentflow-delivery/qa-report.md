# Independent QA — TASK-064

Candidate: base `9f9611465bf1afef4c5018a64d1410b3f946c14d` plus current diff; source SHA-256 `f77731bd63d292bf09e8ce71812a25f232dd89c31f75beab25f80be2d87d37d5`. Reviewed canonical spec/plan/tasks, architecture/develop handoffs, Feedback 1–3, manifest and affected changes. No implementation edits, live model calls, workflow launches or publication.

## Command evidence

Executed every manifest ID using `python3 scripts/agentflow_check.py CHECK_ID --stage qa`, without reuse. Each command explicitly prefixed PATH with pinned Elixir, Node and Erlang directories from Feedback 2. All 16 current QA receipts independently validate against unchanged source/inputs. Successful check execution totals **343.454 seconds**.

Evidence namespace: `.agentflow/runs/checks/690733e0322742a58e830fe6fcccf5d9/064-proportional-agentflow-delivery/qa/CHECK_ID/receipt.json`; receipts identify immutable output files. Compact session index: `/private/tmp/task064-qa-current/evidence-index.json`. These are local check outputs, not portable proof in another checkout.

| Checks | Observed result |
|---|---|
| preflight | Exact Elixir 1.20.3, OTP 29.0.6/ERTS 17.0.6; Node 24.21.0; locked dependencies; Chromium launched; pinned PostgreSQL 17.6 and Redis 8.2.1 ready; CI digests matched. |
| script-syntax; shell-discovery | 40 Python/shell files parsed; shell discovery contract PASS, including zero/partial/failed collection rejection and child exit propagation. |
| workflow-tests | 152 tests, OK, nonempty discovery, no skips. |
| format; compile | Both exit 0; warnings-as-errors compilation executed. |
| openapi-tests; openapi-contract | 2 tests passed, 0 failed; OpenAPI 3 validation passed. |
| clean-ci-tests | `Result: 527 passed, 4 excluded`; discovery sentinel present; `private_pointer: false`, `full_suite_invocations: 1`. |
| us1-tests; artifact-tests; evidence-tests | 19 / 11 / 11 tests, all OK. |
| model-tests; feedback-tests; metrics-tests; policy-tests | 10 / 4 / 9 / 6 tests, all OK. |

Initial sandbox attempts failed preflight (54.727s), compile (0.655s) and clean-ci-tests (11.511s): browser/Docker/service access or BEAM TCP filesystem locks were denied. Host execution corrected the execution environment; each affected check then passed. Failures remain recorded; no unchanged-input two-failure limit was reached.

## Acceptance matrix

All 28 numbered scenarios and 32 FR/SC identifiers are accounted for below. Checked assertions and implementation paths against behavioral requirements; manifest labels alone were not acceptance proof.

| Acceptance criteria | Independent evidence and challenge | Result |
|---|---|---|
| US1.1–1.4; FR-001–004; SC-001 | Preflight, clean-ci, US1, shell and workflow checks: CI drift/unavailable evidence, wrong versions/missing service, empty discovery, pointer-independent candidate overlay, deletions/untracked tests and single full collection. Diff preserves application/checkpoint scope. | PASS |
| US2.1–2.4; FR-005–006; SC-002 | Artifact/probe tests exercise necessary/minimal documents, malformed decisions, required canonical files, direct shell consumers and genuine historical provenance. Independent disposable fixture removed the entire block: plan/tasks/develop each refused with `no historical legacy provenance`. | PASS |
| US3.1–3.5; FR-007–010; SC-003–004 | Evidence tests exercise real receipts, tampering, freshness, stage/workspace isolation, explicit reuse, failed/interrupted predecessors, retry budgets, historical preservation and bounded/idempotent summaries. Independent fixture obtained intact real passing receipts while research was absent: readiness and finalization both refused `research.md`. | PASS |
| US4.1–4.4; FR-011–013; SC-005, SC-008 | Feedback, policy, completion and repaired readiness tests cover earliest-owner routing, conflicts without mutation, pending impact, preserved artifacts, current/legacy resume consumers, mandatory regressions and independent verdict/provenance gates. | PASS |
| US5.1–5.4; FR-014–016; SC-006–007 | Metrics fixtures cover replay/conflicting/cumulative/reset/resumed/interrupted usage, unknown identity/dimensions, subsets and partial coverage. Pilot documents reproducible next-authorized-task observations, baseline gaps and separate workflow/model factors; no savings or benchmark claim. | PASS |
| US6.1–6.7; FR-017–022; SC-009–010 | Actual fake-child argument capture proves all six pairs; resolver/launcher fixtures challenge precedence, overrides, rejection, no fallback, saved/legacy/frozen/adopted settings and independent sessions. Observed identity remains unknown where absent. | PASS |

Additional evidence: `/private/tmp/task064-qa-current/adversarial.log` records independent B1/B2 challenges. `python3 scripts/workflow_artifact_probe.py STAGE --readiness` passed for plan, tasks and develop. Only independent QA/review tasks remain deferred.

HTTP runtime testing is inapplicable: no endpoint or application behavior changes; spec/contracts and diff agree. Remote Sonar and post-merge actions retain the manifest’s explicit exclusions; no remote PASS is claimed. Final review and actual post-review summary finalization remain downstream requirements, not completed-task claims. Frozen-run model execution was not inferred.

Blockers: none.

Verdict: PASS
