# ADR-0014: Durable Agentflow feature ownership and completion evidence

- Status: Accepted for TASK-054 architecture (2026-10-06)
- Scope: Delivery tooling; supersedes historical task-number/mtime association, not application architecture.
- References: specs/055-task-feature-binding/spec.md; handoffs/product-challenge.md; contracts/task-feature-binding.md; docs/AGENT_VERIFICATION.md.

## Context

Task numbers and Spec Kit feature numbers are independently allocated. TASK-017 owns specs/055-football-data-api-adapter and TASK-020 owns specs/054-player-match-statistics. Ignored session pointers and timestamps cannot establish durable ownership in merged checkouts. Existing explicit and dependency completion bypass the report gates. Directory containment alone does not prevent foreign evidence through file symlinks.

## Decision

Use one standard-library Python resolver/guard shared by all delivery consumers. Exact canonical Feature Branch declarations are sufficient; optional versioned task `feature_directory` metadata uses a validated immediate-child specs path and must agree. Duplicate relevant declarations, unsafe paths and conflicting sources fail closed. Legacy number equality remains only a unique eligible declaration-free compatibility case; validated different-task declarations are foreign and excluded from legacy cardinality, even with no exact current owner. Full deterministic task/title branch equality is required before metadata-only/legacy selection and before a done reconciliation no-op.

Validate candidate-scoped ownership: unrelated malformed historical declarations do not block a correct association. Metadata targets, invalid fallback-number candidates and claims to the requested task/branch remain subject to refusal. A numbered foreign candidate must have exactly one syntactically valid declaration and safe/readable containment before exclusion. One/two foreign specs permit pre-product None; required consumers still refuse missing ownership. Headerless candidates retain unique legacy resolution or ambiguity refusal. An incidental equal-number spec belonging to another task cannot override an exact match. Canonical directory aliases normalize to one target; distinct matching targets remain ambiguous.

Spec, publication artifacts and report resolved paths must remain inside their selected feature. Allow contained symlinks and reject external/foreign-feature escapes. Every transition to done uses the same review-state and two-terminal-PASS guard, retaining explicit human acceptance or existing human-merge confirmation. Prepare both metadata updates before one same-directory atomic replacement, preserving other bytes.

Post-merge done retries validate unique task identity and the full branch first, then return an unchanged no-op without surviving reports/feature requirements. This is not a completion transition. Python stage/check feature selection uses the current Git delivery branch and resolver; a populated session pointer is only a downstream Spec Kit convenience.

## Alternatives

Renumbering/migrating features breaks stable identities. Independent consumer fixes drift. Pointer/mtime ownership is not versioned. Global spec repair expands scope. A blanket symlink ban restricts harmless contained layouts. New merge/approval flags would alter established authorization boundaries. Requiring reports on done retries conflicts with unchanged idempotence.

## Consequences

No task/branch migration, dependency, service, database or application change is required. Resolver and consumer tests must cover all five critic findings and fail before side effects. Existing tests with incomplete synthetic identity/spec fixtures need realistic updates. Snapshot four exact TASK-017 files with pinned provenance for a portable real-command regression. This preserves the provider work and human-controlled merge sequencing: TASK-054 before PR #28.

## Feedback 1 amendment (2026-10-06)

QA B1 and the preserved new-task probe require two clarifications without changing spec, permissions or application scope. All critical decisions use one strict scalar-frontmatter parser. Unsupported lines (including whitespace-colon, indentation, quoted/case-variant keys and structured YAML) and duplicate keys refuse before any backlog/pointer write or delivery side effect; canonical unknown scalar fields remain preserved. Agentflow's permissive `meta()` cannot remain an independent critical reader. A parser error must not trigger a blocked-state overwrite.

Validated foreign ownership excludes an incidental numeric directory from legacy candidate counting. Unsafe/unreadable/malformed numbered candidates, same-task wrong branches, explicit metadata conflicts and ambiguous headerless legacy candidates still fail closed in pre-product mode. This resolves US1.5 without changing Spec Kit allocation.

Normalize-only parsing was considered; strict rejection avoids inconsistent normalization and replacement semantics in the existing scalar-only format. Counting foreign directories was rejected because the new task owns neither; ignoring all numbered candidates in allow_missing was rejected because it hides true legacy ambiguity. Original diagnostics remain unchanged; tracked inverse-refusal and actual start-path regressions provide portable acceptance. All ten scoped receipts, readiness, independent QA and final review must be refreshed before separate publication and human merge ahead of PR #28.
