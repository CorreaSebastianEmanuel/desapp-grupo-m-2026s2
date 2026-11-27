# Shared tooling contract

This is a Python/CLI contract, not an HTTP API. The normative behavior remains spec.md; ADR-0014 selects the internal boundary.

## Python policy boundary

Place pure file/identity policy in `scripts/agentflow_feature.py`. Suggested public operations (names may vary only if all consumers/tests are updated together):

- `task_for_id(root, task_id)` returns the unique validated task; rejects filename/frontmatter mismatches and competing frontmatter claims.
- `expected_branch(task)` preserves Agentflow's existing title-slug rule.
- `resolve_feature(root, task, head_ref=None, allow_missing=False)` returns a FeatureAssociation (or None only for permitted true pre-product absence), never consulting Git, mtime or a local pointer for ownership. A supplied head_ref must equal expected_branch.
- `contained_file(feature, name)` checks readable canonical-file containment before reading; rejects outside or foreign-feature symlink targets.
- `require_reports(association)` checks both final nonempty lines exactly.
- `complete_reviewed_task(root, task, head_ref=None, allow_done_noop=False)` returns the changed task path or None for the authorized post-merge no-op. Caller authorization remains external; the function adds no merge/push capability.

The orchestration layer obtains current Git branch where required, captures adapter failures, and renders errors. Direct-script and package imports must both work (`python3 scripts/reconcile_merged_task.py` and agentflow module loading).

## Strict frontmatter contract (Feedback 1 / QA B1)

Every decision consumer uses the same parser, including Agentflow's `meta()`, task enumeration/identity validation, status/dependency checks and completion writes. This is a deliberately small scalar format, not general YAML:

- Frontmatter has opening/closing `---` lines. Between them allow blank lines, full-line comments and unindented entries whose keys match `[a-z_]+` immediately followed by `:`. Values are single-line text, optionally balanced single/double quoted. Trim value-surrounding whitespace for interpretation; preserve original bytes for writes. Plain scalar content is literal, without YAML coercion, anchors or inline-comment interpretation.
- Reject every unsupported nonblank/noncomment line. Whitespace before a key/colon, quoted keys, uppercase key variants, explicit mapping syntax, nested values or unquoted values starting with collection/block/tag/anchor/alias markers (`[`, `{`, `|`, `>`, `!`, `&`, `*`), or malformed quotes must produce an actionable metadata error. Never skip these lines or use a second permissive parser. For example `feature_directory : specs/099-other` and `status : blocked` refuse even beside valid canonical keys.
- Reject duplicate keys (including critical `id`, `title`, `status`, `active_run`, `depends_on`, `feature_directory`); unknown keys in supported scalar form are preserved. No fallback or mutation may follow an invalid parse. Missing required fields retain operation-specific validation.
- All metadata refusals leave **every backlog file byte-identical** through discovery, verify/finalize/publication, explicit completion, dependency reconciliation and post-merge. No status-to-blocked write, pointer update, verifier dispatch, commit, push or PR may follow a metadata refusal. Dependency failure may emit a diagnostic and continue the existing loop, leaving the invalid dependency untouched.

Completion replacement uses the same parsed canonical field boundaries; accepted CRLF, quoting and surrounding value whitespace remain preserved. Read-only parsing never rewrites metadata. A post-merge done retry still parses all frontmatter first: malformed/duplicate metadata cannot be hidden by the no-op.

## Resolution order and failure scope

1. Validate unique requested task ID, frontmatter, title and supplied full branch. Parse optional unique `feature_directory` metadata; invalid explicit paths fail immediately.
2. Scan immediate specs children deterministically, inspect canonical branch declarations, and normalize contained aliases. The current task's relevant candidate set includes metadata target, directories with the task-number prefix, exact expected branch declarations anywhere, and any declaration claiming the same task-number branch with a different/malformed suffix. A duplicate declaration in a file mentioning the expected branch is relevant even if another declaration claims a foreign task.
3. Reject unsafe/unreadable/malformed/duplicate information within relevant candidates. Invalid information in unrelated historical specifications is ignored; no global repository repair requirement. Include a regression with an unrelated malformed spec beside a valid exact match. A malformed declaration claiming this task is never silently used as declaration-free legacy information. For an otherwise unrelated unreadable spec with no readable ownership claim, do not infer ownership from it; if it is the metadata or task-number candidate, refuse. Distinct duplicate exact matches always fail, even with metadata pointing at one.
4. If exactly one canonical spec declares expected_branch, select it. Incidental equal-number specs declaring another task are not fallback owners and do not override a valid explicit match. However a candidate explicitly claiming this task's number with a contradictory suffix is relevant invalid ownership and fails. Metadata, when present, must resolve to the same feature; the metadata target's declaration must be absent or match expected_branch.
5. With no exact match, valid metadata may identify the feature if its spec has no declaration; a different, malformed or duplicate declaration is a conflict. A same-task explicit conflicting claim elsewhere also prevents metadata-only selection.
6. First classify a numbered candidate with a readable contained spec and exactly one valid canonical branch declaration for **a different task ID** as positively foreign. Exclude it from this task's legacy candidate set; never select it. This is permitted only when it is not the explicit metadata target and has no duplicate/malformed declaration or same-task ownership claim. Invalid numbered candidates remain relevant failures. A foreign equal-number candidate does not displace an exact owner or a unique legitimate headerless legacy candidate.
7. With neither durable source identifying a feature, allow legacy only if exactly one eligible equal-number candidate remains, with contained readable spec and no declaration/metadata contradiction. Headerless readable specs are true legacy candidates: one resolves; two or more fail even with allow_missing. Malformed/unreadable/unsafe numbered candidates, same-task wrong branches and invalid explicit metadata always fail, including during pre-product lookup.
8. Otherwise report missing ownership. allow_missing permits None only in pre-product lookup when there are no own/eligible legacy candidates and no invalid relevant claims or explicit metadata. One or two validated foreign equal-number specs can therefore coexist with a new TASK-055 without blocking creation. Required resolution still reports missing ownership; verification/publication/completion may never use foreign reports. Start clears stale session context and reaches its existing product workflow without renumbering anything.

Metadata is a unique frontmatter scalar `feature_directory: specs/<child>` (optionally consistently quoted). Reject empty values, absolute paths, dot/traversal segments, nested directories, missing targets, duplicate keys and resolved boundary escapes. Directory selection requires both lexical immediate-child shape and a resolved immediate child under the real repository specs root. A spec/report must resolve strictly inside its selected feature. Do not read foreign content to treat it as passing evidence.

A relevant spec's canonical declaration is exactly one line `**Feature Branch**: ` followed by a backtick-delimited delivery branch and optional surrounding whitespace. A heading/declaration-shaped line with malformed value is invalid, not absent. Unrelated declarations do not establish task ownership. No guessing from Input prose, newest timestamps or session state.

## Consumer requirements

| Consumer | Required policy / adapter boundary |
|---|---|
| Local discovery/history | Shared association; history may allow genuine pre-product absence |
| start/resume | Validate delivery branch; resolve existing feature; set pointer only from resolution; clear stale pointer on genuine pre-product absence |
| Python stage/check active_feature | Obtain current delivery branch from Git; validate task/full branch and shared resolution; ignore pointer ownership |
| verify | Resolve before existing verifier dispatch; absent/conflicting association never dispatches a specs-wide verifier |
| finalize / no-pr | Workflow exit code zero; canonical required artifacts and both terminal reports; existing readiness gates remain mandatory |
| publish | Full branch match and same authoritative feature; recheck canonical artifacts/reports before any review/commit/push/PR action; captured PR links use resolved directory |
| complete | Existing explicit human acceptance/merge prerequisite; review-only; common completion guard |
| dependency reconciliation | Existing dependency list and confirmed merged PR; review-only; common guard; no unrelated task mutation |
| post-merge | Branch-derived identity on merged checkout; full expected branch match; common guard, done no-op boundary |

Canonical publication spec/plan/tasks also require contained readable files, not just is_file(). A verification result never authorizes a caller-supplied foreign feature path. Current source/receipt rules in docs/AGENT_VERIFICATION.md remain unchanged.

## Post-merge command

`python3 scripts/reconcile_merged_task.py --head-ref 017-football-data-api-adapter --root <isolated-root>`

Default root stays the repository containing the script. Success is exit zero, with either one target task changed or the existing already-finalized message. Invalid branch, task, state, association or reports return nonzero with actionable context and no backlog write. No current Git feature branch/session pointer is required when an explicit merged head is supplied.

Only `status` and `active_run` values may change; preserve surrounding text, line endings, task body, other metadata and all unrelated files. Require both fields uniquely before constructing the complete replacement; use one same-directory atomic replacement after validation. No partial status-only update. For a done retry validate unique ID, title, full branch and unique status before returning; reports, feature and active_run are not needed when no write occurs.

## Workflow and publication

Preserve `agentflow-finalize.yml` merged closed PR to main guard, non-delivery skip, checkout pin/ref, contents permission and serialized reconciliation. Tests must cover actual CLI execution plus these guards; no network mutation.

PR generation includes the versioned task Outcome in the existing body, alongside resolved spec/plan/tasks/report links. For TASK-054 that text explicitly requires its separate correction PR to merge before PR #28. Record human merge sequencing in review evidence; no automated merge or actual publication belongs to test execution.
