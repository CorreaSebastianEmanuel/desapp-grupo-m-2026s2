# Feature-specific research

The canonical architecture and technology remain governed by `docs/ARCHITECTURE.md`, `docs/PRODUCT.md` and `.specify/memory/constitution.md`. No unsettled dependency choice or external research is required. Feedback 1 in `backlog/feedback/TASK-054.md` is authoritative and rewinds architecture after QA B1. The earlier product decision remains applicable to unchanged requirements; its statement that no feedback existed describes its earlier stage only.

## Shared policy instead of duplicated discovery

- Decision: Introduce `scripts/agentflow_feature.py`, reused by Agentflow, the reconciler and Python stage/check active-feature selection.
- Rationale: `agentflow:feature_for_task()` currently chooses by equal number and mtime; reconciliation requires equal numbers; `workflow_artifact_probe:active_feature()` trusts the session pointer. `agentflow_check.py` already delegates active selection to the probe. One boundary fixes ownership before evidence is consumed.
- Alternatives considered: Three patches retain divergent rules; migrating task/feature numbers breaks stable identities; local pointer/mtime cannot survive merged checkout. See ADR-0014 for the durable decision.

## Completion consumers and retry boundary

- Decision: Guard explicit completion, post-merge completion and merged-dependency completion with the same association and two contained terminal reports. Validate identity/full branch before a post-merge done no-op, then skip feature/report validation because no transition occurs.
- Rationale: `agentflow:reconcile_merged_dependencies()` and `complete()` currently update metadata without reports. The reconciler's early done return currently precedes full branch ownership validation. Existing `review_pr_merged()` supplies dependency human-merge evidence; the complete skill supplies explicit human-acceptance guidance. Preserve those authorization boundaries.
- Alternatives considered: Adding a new merge authority/approval CLI is out of scope; demanding reports on done retries breaks FR-007 when archived artifacts disappear.

## Candidate scope and file containment

- Decision: Scope invalid-declaration refusal to expected-branch matches, same-task branch claims, metadata target and fallback candidates; allow unrelated malformed specs without hiding duplicate expected branches. Require resolved spec/report containment in the selected feature; contained symlinks remain compatible.
- Rationale: A global repair policy expands scope. Feature-directory containment alone allows foreign PASS reports. The five critic findings are resolved in ADR-0014 and the contract, with explicit regressions.
- Alternatives considered: Ban all symlinks (unnecessary compatibility restriction); ignore invalid declarations universally (unsafe legacy fallback); validate every historical spec (unrelated blockers).

## Actual TASK-017 fixture availability

- Decision: Implementation exports four exact files from local source commit `1aa2731f048efcb1056a589b3b2ea938b843edd4` to versioned test snapshots, retaining the unequal-number layout and source reports. No checkout, provider test run, task completion or network mutation is needed.
- Rationale: Read-only `git show` confirmed source availability, TASK-017 review state, exact branch declaration and two terminal passing report lines. Those verdicts are inputs to a tooling regression, not acceptance of provider behavior. A pinned snapshot avoids a test dependency on a local branch name surviving in CI.
- Alternatives considered: Synthetic TASK-017 artifacts do not satisfy FR-011; requiring an unpinned remote ref on every run makes evidence unstable; copying the entire provider feature exceeds scope.

| Source path | Bytes | SHA-256 |
|---|---:|---|
| backlog/TASK-017-football-data-api-adapter.md | 262 | fa36022776fccf0228b8bff58d41cf9fd4bce39606b3fea3c57799fee52dc13c |
| specs/055-football-data-api-adapter/spec.md | 23308 | 36d29071eaf11739503e289b9d7f842ab6f5c1f7473561e79569252f03618386 |
| specs/055-football-data-api-adapter/qa-report.md | 5949 | b80d21e503597d65390774f962f3ec0ad7367a49d74ac258f20e77092016a462 |
| specs/055-football-data-api-adapter/review-report.md | 3668 | 03578ff095635a889f4f10c21a91295687bea5052a2dfe60ac54e12e5eea5b48 |

## Applicable checks

- Decision: Use existing standard-library unittest style, Python syntax compilation, Git whitespace checks, workflow/scope assertions and real isolated CLI execution. No Elixir formatting/compile/suites, market services or HTTP probes apply.
- Rationale: Existing `test/scripts/agentflow_branch_test.py`, `reconcile_merged_task_test.py` and `workflow_artifact_probe_test.py` define the relevant test seam. The patch touches only delivery tooling; CP1 support is delivery integrity. No Python formatter configuration is present; do not add tooling to satisfy a fictitious formatting requirement.
- Alternatives considered: Application suites add no evidence about this bug; mocked reconciler-only coverage misses the actual command/import path.

## Feedback 1: metadata and new-task ownership

- Decision: Reject unsupported scalar-frontmatter forms and duplicate keys in one shared parser, used by Agentflow adapters as well as the resolver/guard. Reject before any backlog or pointer write, including blocked diagnostics. Preserve supported unknown fields and bytes.
- Rationale: QA B1 demonstrates that the resolver silently ignores whitespace-key lines while Agentflow's separate `meta()` strips whitespace and sees different values. A validated ownership result cannot be trustworthy when consumers interpret the same task differently. No general YAML dependency is needed for the established scalar format.
- Alternatives considered: Normalizing a carefully defined subset is possible but introduces duplicate-normalization and writer ambiguity. A general YAML loader changes accepted typing/format and dependencies. Silently ignoring unsupported forms repeats the defect. ADR-0014 records the strict choice.

- Decision: Validated different-task declarations exclude equal-number directories from legacy ownership. Retain strict failure for metadata targets, unsafe/unreadable numbered specs, malformed/duplicate declarations and same-task claims; one headerless legacy spec still resolves, multiple fail. Pre-product None is permitted only when no own/eligible legacy claim survives.
- Rationale: Feedback 1 explicitly approves this US1.5 interpretation. The unchanged `/tmp/task054-root-missing-feature.py` was executed in architecture and exited 1 with contradictory-legacy ownership for two foreign specs; evidence is `/tmp/task054-architecture-root-probe.log`. The existing `legacy.append` includes every numbered spec, even after discovering foreign ownership. The correction changes classification, not numbering, delivery authorization or report gates.
- Alternatives considered: Count all numeric directories (reproduces the blocker); allow any missing lookup to ignore malformed/ambiguous candidates (unsafe); select foreign reports (violates ownership). No external research is needed.

Preserve diagnostics unchanged: `/tmp/task054-independent-qa/adversarial_checks.py` SHA-256 `2466482bef088bde56fafa44fc527c21c1c4d64d257783db4e873070f8d9d6a5`; `/tmp/task054-root-missing-feature.py` SHA-256 `1a640fefaebbb2177e6ee2362ffd05bdde0d6971a27dc4e5fcf87e6932b11125`. The adversarial diagnostic asserts successful exploitation and is not an acceptance command. New tracked refusal assertions must prove nonzero refusal and byte-identical backlog instead. Owner reruns the preserved root probe unchanged and requires exit 0; CI uses tracked equivalent resolver and actual start-path assertions without depending on `/tmp` evidence.
