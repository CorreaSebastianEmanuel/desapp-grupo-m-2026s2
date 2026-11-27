# Task/feature association data model

No Ecto schemas, database tables or market entities change. All paths are relative to the explicit repository root unless the API accepts an already-normalized Path.

## BacklogTask

- `path`: unique immediate `backlog/TASK-NNN-*.md` file selected for the requested ID; frontmatter ID and filename prefix must agree.
- `id`: exactly `TASK-` plus three digits; one matching filename and one matching frontmatter identity. A second frontmatter claim elsewhere is an ambiguity even if its filename disagrees.
- `title`: existing nonempty frontmatter title, used by the unchanged slug rule to derive the expected full delivery branch.
- `status`: unique field; completion requires review, while post-merge done retries allow a no-op after identity validation.
- `active_run`: unique field required before a completion write; completion writes `none`.
- `feature_directory`: optional unique scalar. If present it must name exactly `specs/<child>` without absolute/traversal/nesting, and exist with a readable contained canonical spec. Absence differs from an empty invalid value.
- `depends_on`: existing dependency IDs, unchanged; the caller identifies dependencies and supplies existing human-merge confirmation.

Unknown supported scalar fields and body text are preserved; read-only resolution never rewrites tasks. The shared strict parser rejects unsupported frontmatter lines and duplicate keys before any critical decision, including whitespace-colon, indented, quoted or case-variant critical keys and structured YAML. No consumer may silently discard an alternate key form or overwrite status after a metadata error. See contracts/task-feature-binding.md for the accepted scalar grammar. Required metadata is parsed only from frontmatter, never task body text.

## DeliveryBranch

- `head_ref`: exactly three digits plus the existing lowercase slug syntax.
- `task_id`: derived from the branch number for branch-based consumers.
- `expected`: `task.id` number plus existing `slug(task.title)`; complete head_ref equality is required. No directory basename contributes to branch identity.

## FeatureAssociation

- `task`: validated BacklogTask.
- `expected_branch`: validated DeliveryBranch.
- `feature`: normalized immediate-child directory below the real repository specs root.
- `source`: `spec_branch`, `task_metadata`, or `legacy_equal_number`; source does not change guard strength.
- `spec_path`: readable UTF-8 canonical `spec.md`, resolved within feature.
- `declared_branch`: absent or one exact backtick-delimited `**Feature Branch**:` declaration with valid full branch syntax. Malformed/duplicate relevant declarations fail.

A scanned numbered directory is classified as exact owner, metadata target, eligible headerless legacy, validated foreign owner, or invalid relevant candidate. Only eligible legacy candidates count toward legacy ambiguity; a valid different-task declaration excludes a directory from that set. Zero candidates permit None solely under pre-product allow_missing; required consumers fail missing ownership. Multiple headerless candidates, malformed/unreadable numbered specs, same-task wrong claims or invalid explicit metadata refuse even under allow_missing.

One task has at most one canonical association. Metadata does not hide two distinct canonical features declaring its branch. Resolved aliases to one directory are one feature. Candidate errors carry task ID, expected branch, paths and reason without dumping file contents.

## VerificationReport

- `kind`: `qa-report.md` or `review-report.md` in the association feature.
- `resolved_path`: must remain within feature, including symlink resolution; contained symlinks allowed.
- `terminal_line`: last nonempty UTF-8 line trimmed at both ends, exactly `Verdict: PASS`.

Missing, unreadable, invalid UTF-8, empty, alternate spelling, earlier PASS followed by content, FAIL or escaping reports fail closed. Reports are never searched in a different feature.

## Completion transition

1. Validate task/head identity (full branch where supplied).
2. Post-merge only: if status is already done, return unchanged no-op without needing spec/reports.
3. Require review and the existing caller's acceptance/human-merge authorization.
4. Resolve association and validate both reports; require unique status/active_run metadata.
5. Prepare a replacement changing only those two field values; write once to the target task, preserving other bytes. Any validation failure precedes writing.

Local explicit completion remains review-only; it does not gain a done retry shortcut. Dependency reconciliation keeps its existing review plus merged-PR condition. Publication remains a separate review transition with its existing workflow/artifact/branch gates and no merge authority.
