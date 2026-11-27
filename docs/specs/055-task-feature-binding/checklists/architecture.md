# Architecture alignment and coverage

This is architecture-stage design review, not implementation acceptance. Spec remains unchanged. Existing test modules remain the executable entry points; feedback assertions are planned extensions and have not been implemented or accepted by architecture.

## Critic disposition

| Finding | Resolution | Tasks / future assertions |
|---|---|---|
| Dependency done bypass | Common guard after existing merged-PR confirmation; dependency-only iteration retained | T018/T021, local-completion: failed/foreign evidence produces no metadata write; unmerged/unrelated tasks untouched |
| Wrong full branch in legacy | Exact deterministic title/ID branch required before legacy/metadata resolution | T003/T012, resolver/post-merge: valid syntax wrong suffix and filename/frontmatter mismatch refuse |
| Symlinked foreign evidence | Canonical spec/publication files/reports resolve inside selected feature; contained links allowed | T017/T020, resolver plus consumer rejection checks: external/foreign links refuse; harmless links succeed |
| Unrelated malformed specs | Candidate-scoped failure, duplicate expected declarations still fail | T017/T020, resolver: valid explicit owner beside unrelated malformed declaration succeeds |
| Already-done retry boundary | Strict metadata/unique identity/title/full branch/status first; no association/reports required after done | T012/T014, post-merge: missing reports/feature no-op, wrong branch or hidden metadata rejects unchanged |
| Feedback 1 / QA B1 | One strict scalar parser; unsupported/duplicate forms refuse before any write, including blocked handling | T003/T004, T012, T017–T022: resolver and every consumer snapshot all backlog bytes; no verifier/commit/push/PR/pointer side effect |
| Feedback 1 / root probe | Valid different-task declarations excluded from legacy counting; pre-product None only without own/eligible legacy/invalid claims | T005/T007/T011: one/two foreign numeric specs and actual start path succeed; unique headerless resolves; multiple/malformed/unsafe/same-task/explicit-conflict candidates refuse |

ADR-0014 records each durable choice. No material human decision remains; Feedback 1 in backlog/feedback/TASK-054.md is authoritative. The product decision and QA report describe the earlier no-feedback state; do not override the later feedback. Source fixture availability and hashes were checked read-only, not its provider behavior.

## Acceptance scenarios (numbered in spec)

| Scenario | Concrete executable check(s) | Assertion and owner tasks |
|---|---|---|
| US1.1 | local-delivery, resolver | TASK-017/055 full path and all captured publication artifact links; unchanged task/branch; T003/T005/T009 |
| US1.2 | local-delivery, resolver | TASK-020/054 beats misleading numbers/mtime; T003/T005 |
| US1.3 | local-delivery | Both PASS, workflow code zero, branch/artifacts required, captured publication review awaiting human merge; nonzero/invalid variants refuse; T005/T009/T010/T019 |
| US1.4 | resolver, local-delivery | Exactly one readable declaration-free legacy candidate succeeds, contradictions/multiplicity refuse; T003/T005/T017 |
| US1.5 | resolver, local-delivery | One/two validated foreign numeric specs permit pre-product None and actual start product dispatch/pointer clearing; required lookup Missing; headerless legacy remains unique/ambiguous, malformed/same-task/metadata conflict refuses; T005/T007/T010/T011 |
| US2.1 | tooling-preflight, actual-provider | Pinned source hashes and actual CLI first-run exact two-value copied delta; real source unchanged; T001/T002/T013/T016 |
| US2.2 | post-merge | TASK-020/054 completion using own reports; unrelated backlog bytes unchanged; T012/T015 |
| US2.3 | post-merge, actual-provider | Second run unchanged success; done without surviving reports/feature also succeeds after identity; T012/T013/T014 |
| US2.4 | post-merge, workflow-scope | Invalid/non-review state refuses with no backlog write; workflow non-delivery branch skips; T012/T015/T024 |
| US3.1 | resolver, local-delivery, local-completion, post-merge | Missing/ambiguous/conflicting association and concealed/duplicate key matrix refuses with task/path/key diagnostics, all backlog bytes identical and no blocked overwrite or consumer side effects; T017/T018/T019/T022 |
| US3.2 | local-delivery, local-completion, post-merge | Each bad QA/review report independently fails all delivery/completion consumers; no push/PR/review promotion/done transition; T018/T019 and post-merge matrix T012 |
| US3.3 | resolver, local-delivery, local-completion, post-merge | Foreign PASS reports or feature paths cannot replace selected failed evidence; T017/T018/T019 |
| US3.4 | resolver, local-delivery, stage-probe | Stale/absent/foreign pointer and differing mtime never change selected ownership; T005/T006/T017 |
| US3.5 | resolver, local-delivery, local-completion, post-merge | Invalid metadata path/declaration disagreements and unsupported/duplicate metadata forms refuse without number/time fallback or backlog mutation; T017/T018/T019/T022 |

For consumer coverage, reuse the same association/evidence case definitions logically across local publication, explicit completion, dependency completion and post-merge tests. A pure resolver failure test alone is not a consumer safety assertion: assert each consumer's unchanged unrelated files and absent unauthorized actions.

## FR/SC and edge coverage

verification.json is the authoritative 17-identifier executable map; this checklist adds scenario granularity rather than duplicating it. The spec contains no AC identifiers. Concrete test tasks cover all listed edges: explicit vs incidental number match; duplicate exact declarations even with metadata; conflicting metadata; malformed/duplicate/same-task foreign branch; unsafe directory/file paths; multiple legacy directories and unusable specs; missing/duplicate/disagreeing task identity; exact terminal spelling and later content; status/active_run all-or-nothing; merged checkout without local pointer. Same-task claims with wrong suffix fail; truly foreign validated incidental declarations cannot displace a valid exact owner or block a new pre-product task. One headerless eligible legacy candidate resolves; multiple refuse. Missing required ownership never selects foreign evidence. Strict parser regressions include whitespace before colons, indentation, quoted/case-variant keys, structured/malformed values, canonical duplicates and hidden contradictory values, across all named consumers and done retries.

FR-008's existing human acceptance boundary is procedural in the complete skill; tests assert review/report prerequisites and do not invent a new CLI authorization mode. FR-009's workflow safety is asserted by WorkflowScopeTest plus real-command execution. FR-011 uses only the exact four pinned actual source files; generated successful substitutes fail the preflight hashes.

SC-004's actual independent terminal verdicts occur only in T028/T029; local-delivery tests exercise the enforced report guard beforehand. SC-005's actual separate PR and merge order occur after both verification gates; workflow-scope and captured PR body assertions verify scoped delivery preparation. Passing developer checks do not claim these later events occurred.

## Ordering, invariants and checkpoint

Shared-matrix metadata regressions T003 precede strict parsing T004; US1 T005/T006 include new-task resolver/start cases before classification/adapter changes T007/T008; US2 T012/T013 precede completion mutation/CLI; US3 T017–T019 precede further hardening/explicit/dependency integration. T024 adds assertions only for retained workflow/scope, and T025 changes documentation only. Only unchanged fixture work T001/T002/T013 stays checked. All reopened developer tests and artifact tasks through T027 must finish with refreshed checks/readiness before independent QA T028 and review T029. Those are the only gated/deferred IDs.

All seven PRODUCT invariants are preserved by excluding application, financial, persistence and provider changes. The web/domain/persistence/external separation is unchanged. CP1 gains reliable task/evidence ownership and completion; existing application checkpoint acceptance is neither rerun nor claimed here. This feature does not reopen provider CP2 or CP3 scope. Runtime HTTP/service assertions are inapplicable to the CLI-only interface; tooling preflight and real CLI execution provide the affected executable boundary checks.

## Architecture validation evidence

Record only commands actually executed in this stage. The architecture and tasks artifact probes with --readiness validate artifact presence and manifest shape; they do not execute planned tests or certify behavior. Checklist syntax, unique sequential IDs, story labels, deferred-gate mapping, handoff limits and exact requirement coverage are checked structurally. No independent QA/review verdict is issued by architecture.

Architecture rewind evidence is recorded after the structural validation below. Earlier passing receipts and QA's ten passing commands do not establish acceptance: QA B1 remains FAIL and all receipts must be refreshed against amended inputs. The unchanged root probe currently exits 1; this reproduces the feedback and is not acceptance. No implementation check receipt or QA/review verdict is created by this architecture session.

Executed in this architecture rewind: both skill setup scripts resolved specs/055-task-feature-binding (delivery branch remains 054-agentflow-task-feature-directory-binding); no extensions.yml exists at any of the four required hook points, so no registered hook requires dispatch. `python3 scripts/workflow_artifact_probe.py plan --readiness` and `python3 scripts/workflow_artifact_probe.py tasks --readiness` exited 0. `python3 /tmp/task054-architecture-validate.py` exited 0: exact 17-identifier/10-command manifest, 29 unique sequential checklist tasks (US1 7 / US2 5 / US3 7), three retained fixture tasks, 24 reopened developer tasks, only T028/T029 gated, all supporting artifacts, executable test entry points, test-first dependencies, no unresolved placeholders and no HTTP obligation. Handoffs are 217/400 and 207/300 words. Its source hashes confirm implementation, README, workflow, tests/fixtures and both original diagnostics were unchanged during architecture. Bounded structural evidence: /tmp/task054-architecture-validation.json. `git diff --check` exited 0. The unchanged root probe exited 1 as recorded in research.md; code correction, all ten refreshed checks, developer readiness and independent QA/review remain downstream.
