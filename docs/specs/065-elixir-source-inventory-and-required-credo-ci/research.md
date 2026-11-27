# Focused research — TASK-065

## Effective analyzed sources

Decision: use the exact pinned Credo pipeline's returned execution, alongside the mandatory literal CLI invocation; require identical source/configuration snapshots before and after both.

Evidence inspected locally: `deps/credo/lib/mix/tasks/credo.ex` calls `Credo.CLI.main/1`; `deps/credo/lib/credo/cli.ex` calls `Credo.run/1` and translates `Execution.get_exit_status/1` to process failure. `deps/credo/lib/credo.ex` documents the returned execution. `deps/credo/lib/credo/cli/task/load_and_validate_source_files.ex` stores only valid parsed sources; invalid/timed-out files are omitted. `deps/credo/lib/credo/cli/command/suggest/suggest_command.ex` runs analysis on those stored sources and records timing assignments. Therefore filename discovery or zero issues alone cannot establish completeness; compare valid inputs against independent Git/inventory sets and assert execution completed.

Rationale: exact pipeline reuse, no parsing truncated human output, no modified stock configuration. Run CLI/API parity fixtures for good code, a real default-priority finding and invalid syntax before integration.

Alternatives considered: issue-format output lacks zero-finding filenames; reimplementing `Path.wildcard` is not an effective-input oracle; a plugin could observe one CLI pass but adds configuration and loading complexity to TASK-066's reviewed boundary. Two bounded lint passes are acceptable; full test profiles remain single executions.

## Exclusions and evidence retention

Decision: exact per-path archival exclusions for existing historical probe sources outside maintained roots, no broad category glob; retain structured JSON/full log using the existing workflow's upload-artifact facility for 14 days, on failure too.

Rationale: local Git inspection found historical standalone probe `.exs` files under specs/, while all maintained roots remain included by `.credo.exs`. Path accountability prevents new source silently inheriting an exclusion. Full retained files avoid transient/truncated console evidence.

Alternatives considered: category-only exemption hides unknown paths; console-only output is insufficient to resolve the critic's retention finding. No unresolved technology choices remain. Settled stack and lint policy: docs/ARCHITECTURE.md and ADR-0029.
