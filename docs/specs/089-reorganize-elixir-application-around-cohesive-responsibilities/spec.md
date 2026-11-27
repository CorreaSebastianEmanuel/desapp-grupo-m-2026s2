# Outcome specification: Reorganize Elixir application around cohesive responsibilities

## Outcome

Refactor concrete responsibility overlaps found in the `lib/` and corresponding `test/` audit while preserving all existing product contracts. Repository-local guidance for the refactor is pinned at upstream commit `f69eb69a7bd66f5d45921f1c220e35b87bf934b4` in `.agents/skills/elixir-essentials/`, `.agents/skills/ecto-essentials/`, and `.agents/skills/code-quality/`, with license `.agents/skills/LICENSE.elixir-phoenix-skills` and attribution `.agents/skills/UPSTREAM.md`.

The audit found that `FootballMarket.Statistics.Ingestion.Publisher` combines persistence orchestration with FotMob-specific source binding/name resolution. Extract that binding responsibility into a cohesive ingestion module and colocate focused tests. Portfolio chart/table rendering and chart math are a distinct responsibility bundled into `FootballMarketWeb.WorkspaceComponents`; move them into a portfolio component module and keep their rendering tests beside the web component tests.

## Acceptance

- [x] Only the three selected skills are vendored, with their source commit, applicable MIT license, and attribution recorded; their installed instructions are followed.
- [x] Source binding and portfolio rendering/chart responsibilities live in modules whose names and paths identify those responsibilities, with corresponding focused tests colocated under `test/`.
- [x] `WorkspaceLive` remains the stateful workspace and URL boundary; `Quotes` remains the quote context facade because its request, recovery, replay, and persistence helpers already delegate to cohesive `Quotes.*` modules and share transaction/fencing invariants. These reviewed hotspots receive no speculative splits.
- [x] Existing public context APIs, URLs, HTML identifiers and UI behavior, monetary precision, locks/transactions, idempotency, quote history, provider contracts, and retry semantics remain unchanged.
- [x] Maintained source, coverage, Credo, and test-profile inventories and documentation reflect moved or added files without weakening checks or ThinFlow mappings.

## Scope

- Refresh only the existing Sobelow fixture-read exception for Publisher at its new exact line and source hash. The complete suffix beginning with `fixture_artifact!/1` is byte-identical to `origin/main`; the reader uses a fixed repository path and validates the fixture inventory digest. Extend the existing exception regression to check the moved fixture reader source hash, alongside its original control, and refusal on changed identity. Hosted CI found the stale exception; its isolated reconnect E2E passed locally (one test), so no reconnect behavior change is introduced.

- Vendor only `elixir-essentials`, `ecto-essentials`, and `code-quality` with the installer helper and an explicit repository-local destination.
- Extract FotMob source binding from statistics ingestion publication and portfolio chart/table rendering from the general workspace component module, based on the audited callers and responsibility boundaries.
- Preserve the existing `WorkspaceLive` and `Quotes` module boundaries for the reasons recorded above.
- Keep the already-required Codex launcher compatibility repair in `scripts/agentflow_codex.py` and its existing regression test in `test/scripts/agentflow_models_test.py`; `--approve-for-me` already selects workspace-write, so do not pass a conflicting explicit sandbox. Preserve automatic approval review, workspace-write, and network configuration, and refuse incompatible read-only mode.
- Update directly affected tests, maintained inventories, and documentation. Register the exact TASK-089 file allowance in `test/support/workflow_scope.ex` and cover allowed and refused paths in the existing workflow scope tests. Keep the vendored Ecto snippet as Markdown reference documentation (`changeset_snippets.ex.md`), preserving its upstream contents and recording the adaptation in `.agents/skills/UPSTREAM.md`; it is not application source. Do not add dependencies or services.

## Non-goals

- Product behavior, public API, provider-contract, data-model, or operational-policy changes.
- Broad renaming, umbrella conversion, new OTP processes, speculative module splitting, or removal without checking static and dynamic references.
- Changes that weaken ThinFlow classification or any quality gate.

## Risk

High: changes touch statistics persistence and Phoenix-rendered financial views, so behavioral and data-integrity regressions are possible. The vendored paths are `.agents/skills/elixir-essentials/`, `.agents/skills/ecto-essentials/`, `.agents/skills/code-quality/`, `.agents/skills/LICENSE.elixir-phoenix-skills`, and `.agents/skills/UPSTREAM.md`; they remain covered by their existing deterministic ThinFlow classification. The application/test mapping remains authoritative and is not changed. Validate with focused ingestion and LiveView/component regressions, then the risk-selected local checks.

## Decisions

- Pin upstream skill source to `igmarin/elixir-phoenix-skills` commit `f69eb69a7bd66f5d45921f1c220e35b87bf934b4`; install only the three requested skill paths. The FotMob source binding and portfolio visualization extractions are the selected architectural findings. Keep `WorkspaceLive` as the routing/state owner and `Quotes` as the quote context because their callers and existing submodule boundaries show cohesive responsibilities with shared stateful invariants.
