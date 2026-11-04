---
id: TASK-089
title: Reorganize Elixir application around cohesive responsibilities
type: task
checkpoint: CP3
priority: high
workflow: thinflow-v1
status: done
depends_on: none
active_run: none
---

## Outcome

First vendor only the three selected skills from https://github.com/igmarin/elixir-phoenix-skills into `.agents/skills/`: `elixir-essentials`, `ecto-essentials`, and `code-quality`. Use the skill-installer helper with an explicit repository-local destination, reading `/home/shebi/.codex/skills/.system/skill-installer/SKILL.md` first. Resolve and pin the upstream commit; retain the applicable license and source/revision attribution. Read the installed instructions before refactoring. Do not install `elixir-thinking` or the rest of the catalog: the user chose these three skills instead. The user explicitly requires repository-local versioned skills for all contributors. Repository rules, ThinFlow and the existing stack take precedence over upstream workflow suggestions. Include installation paths in the compact spec and risk classification; do not weaken ThinFlow mappings.

Audit the complete lib/ and corresponding test/ organization and implement a behavior-preserving architectural refactor using the three repository-local Elixir/Phoenix skills selected above. Identify overloaded modules, needless fragmentation and directories/modules without an actual responsibility using callers and data flow, not line counts alone. Refactor the concrete issues found, especially WorkspaceLive, WorkspaceComponents, Quotes and statistics ingestion Publisher where evidence warrants it: organize cohesive responsibilities under existing Phoenix contexts, keep web/domain/persistence/workers/providers separated, consolidate redundant abstractions and remove genuinely unused code only after verifying dynamic/runtime references. Keep public context APIs, URLs, HTML identifiers, UI behavior, monetary precision, locks/transactions, idempotency, quote history, provider contracts and retry semantics unchanged. No new dependencies, services, OTP processes, umbrella conversion, or broad renaming for aesthetics. Keep file/module names aligned and colocate corresponding tests. Before implementation settle the compact spec with explicit findings, scope and acceptance; record dispositions of reviewed hotspots so this is a project organization change rather than arbitrary file splitting. Update maintained source/coverage/Credo/profile inventories and documentation as required without weakening gates. Validate with focused behavioral regression tests and risk-selected required checks, then independent evaluation; preserve human merge. User requested the reorganization to be implemented, not only a proposal.
