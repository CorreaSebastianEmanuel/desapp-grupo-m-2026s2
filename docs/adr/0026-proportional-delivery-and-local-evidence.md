# ADR-0026: Proportional workflow artifacts and local verification evidence

- Status: Accepted for TASK-064 architecture, 2026-10-15
- Scope: Workflow tooling only; extends ADR-0014, docs/AGENT_CONTEXT_POLICY.md and docs/AGENT_VERIFICATION.md. Application architecture and publication authority are unchanged.

## Decision

Require canonical artifacts at their owning stages. Add an explicit plan-owned machine-readable applicability block for supporting artifacts; missing, malformed or contradictory decisions fail for new-policy features. An applicable artifact must exist and be nonempty. Skill entry points, prerequisite scripts, workflow probes and resume consumers use this same policy. Historical plans without the block retain their established artifact expectations; no bulk migration.

Store new full outputs, check receipts, retry journals, inventories and intermediate reports under ignored .agentflow/runs/checks. Use a schema-2 local namespace keyed by workspace identity, feature identity, stage and check. A compact schema-1 evidence-summary.json is the only new portable structured evidence: one latest result per required check and independent verdict, never an attempt log. Legacy tracked artifacts remain unchanged. Summaries cannot authorize reuse.

Bind execution to repository source and canonical feature inputs. Include workflow/CI definitions, skills, policies, contracts and current feedback; exclude only explicit generated report paths, checkbox completion, disposable output and established operational backlog state. Exclude the active feature's evidence-summary.json, qa-report.md, review-report.md and stage output handoffs by exact path, never arbitrary documentation. All other documentation remains bound. Record both Git base revision and source-content digest, because a candidate may be uncommitted. The summary separately hashes final QA/review reports and records their provenance; it does not hash itself.

Invalidate acceptance before spawning a check. A failed or interrupted attempt leaves no usable older pass. Persist failures by stage/check/command and declared obligation inputs, independently of run/session identity. Full source binding still controls reuse. Relevant repair resets the attempt scope; report changes, unrelated files and session restart do not. For a whole-suite obligation all discovered test inputs are relevant. If relevance is uncertain, stop and require an explicit relevant repair explanation, never infer permission to retry.

## Finalization order

Freeze source/design; development executes and hands off; independent QA reruns and writes its report; review examines fresh QA and runs targeted uncovered checks. Reports must terminate with PASS before publication. Then a deterministic finalizer assembles the bounded summary and verifies report hashes, source/manifest bindings and local evidence without rerunning full profiles. Report-only finalization leaves execution bindings intact. Any source/design/feedback change repeats the affected repair and independent gates. Agentflow publication remains after both gates; no automated merge.

## Compatibility

Old workflow snapshots and supported legacy receipt shapes remain readable and preserved. Their receipts may be inspected for provenance, but cannot authorize schema-2 readiness; rerun checks to produce current proof. Resume runs the current guard before dependent steps even when an old snapshot lacks it. Missing/corrupt local evidence blocks until regenerated; valid new journals survive resume and retain retry stops. Unsupported state formats fail with a diagnostic and no rewrite. This requires no new storage service or secrets.

## Alternatives and consequences

Keeping per-attempt evidence in Git grows indefinitely. Trusting portable summaries confuses review with execution proof. Blanket doc exclusions or resetting retries on every edit weaken verification. Destructive migration harms resumability. The selected approach adds a small shared policy/parser and finalizer to current Python tooling, with negative behavior tests and no dependency or infrastructure change.
