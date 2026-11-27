# Focused findings — TASK-066

## Analyzer configuration and pin

Decision: use the named default Credo configuration, preserve inherited stock rules, expand inclusion to every maintained Elixir source and pin exactly 1.7.19.
Rationale: local `deps/credo/lib/credo/config_file.ex` from_data reads `data[:configs]` by name; `deps/credo/.credo.exs` documents the supported shape and directory expansion. `deps/credo/lib/credo/cli/command/list/list_output.ex` documents default vs all-priority switches. The archived flat config cannot establish effective coverage, omits test cases and uses an open dependency constraint. Implementation tests must prove the effective configuration rather than merely searching its text. Dependencies are primary local reference inputs, not new tracked source.
Alternatives considered: accepting the archived configuration or using strict mode would respectively leave coverage unaudited or change the agreed priority boundary. Neither is acceptable.

## Regression execution

Decision: reuse all three existing profiles, mark integration and E2E as runtime checks, and run the existing service preflight once.
Rationale: scripts/test_profile_runner.py validates inventory/per-case execution and launches Chromium before integration/E2E. test/support/e2e/runtime.ex owns its schema, listener readiness and deadline. test/support/e2e/fixtures.ex asserts API status, content type, subset bodies, authentication challenge and unchanged financial tables. tools/openapi/workspace_browser.mjs asserts session status/header/body/security outputs. These are concrete executable assertions; a new smoke endpoint or duplicate full run adds no obligation coverage.
Alternatives considered: historical CP1 coverage repeats profiles; a bare curl fails the assertion requirement. Follow ADR-0028 and docs/AGENT_VERIFICATION.md instead. No stack survey or external research was necessary.

## Scope and dependency discrepancy

Decision: discovered defects are routed separately; TASK-065 metadata must depend on TASK-066.
Rationale: product-decision.md interprets FR-008 within the no-behavior-change boundary. Current TASK-065 has depends_on: none, which does not enforce FR-012.
Alternatives considered: treating the prose prerequisite alone as blocking, or silently correcting product behavior, would leave acceptance unenforced. See ADR-0029 for the durable measurement policy.
