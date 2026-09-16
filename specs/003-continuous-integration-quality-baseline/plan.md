# Implementation Plan: Continuous Integration Quality Baseline

**Branch**: `003-continuous-integration-quality-baseline` | **Date**: 2026-09-15 | **Spec**: [spec.md](spec.md)

## Summary

Add one GitHub Actions workflow that validates pull requests targeting `main` and pushes to `main` on the repository's exact Elixir/Erlang toolchain. One job performs ordinary setup and then exposes three category-labelled, fail-fast outcomes: non-mutating formatting, warning-fatal compilation of project-owned application/support code, and the complete default ExUnit suite with test-file warnings fatal. The test category uses a small repository script plus a committed discovery sentinel so an empty or undiscovered suite cannot pass. Before publication, QA proves the workflow contract, local parity, and controlled failures; hosted PR and `main` runs are required post-publication evidence, not a circular pre-publication prerequisite. Do not add coverage, SonarCloud, deployment, end-to-end, architecture, or product behavior.

## Technical Context

**Language/Version**: Elixir 1.20.3, Erlang/OTP 29.0.3 (ERTS 17.0.6); YAML for GitHub Actions  
**Primary Dependencies**: Phoenix 1.8.13 and locked Mix dependencies; `actions/checkout@v4`; `erlef/setup-beam@v1`; GitHub-hosted PostgreSQL service  
**Storage**: Ephemeral PostgreSQL test database only; no schema or persistent-data change  
**Testing**: ExUnit via the repository's unfiltered `mix test` alias, with test-file warnings fatal and a discovery sentinel  
**Target Platform**: GitHub-hosted Ubuntu runner; local equivalent on the documented macOS/Linux exact toolchain with PostgreSQL available  
**Project Type**: Single modular Phoenix web application with repository-native CI  
**Performance Goals**: No product-runtime goal; every eligible revision receives one conclusive workflow result with category-labelled diagnostics  
**Constraints**: No production secrets or live providers; locked dependencies; same SHA for all checks; superseded runs may cancel; formatting never rewrites; exactly three enforced quality categories  
**Scale/Scope**: One workflow, one job, three quality steps, one discovery sentinel, and local documentation

## Constitution Check

*GATE: Passed before research and re-checked after Phase 1 design.*

- **Specification before implementation — PASS**: The workflow and acceptance fixtures trace to FR-001–FR-012 and resolve every material critic finding. Current TASK-003 human feedback supersedes the earlier no-feedback observation and its pre-/post-publication evidence boundary is incorporated below.
- **Domain integrity — PASS**: CI observes existing behavior and introduces no business rule, schema, persistent state, or external integration.
- **Modular simplicity — PASS**: One workflow reuses standard Mix commands and the existing PostgreSQL boundary; no service, abstraction, or product module is added.
- **Evidence-based quality — PASS**: Positive and controlled negative fixtures cover formatting, application/support/test warnings, failing tests, non-empty discovery, triggers, and local parity.
- **Independent verification — PASS**: The independent challenge is resolved here; implementation, QA, and final review remain separate gates.
- **Safety/delivery — PASS**: The workflow uses no credentials beyond GitHub's read-only checkout capability, makes no deployments, and performs no destructive persistent operation.
- **Architecture/checkpoint — PASS**: The design stays outside web/domain/persistence behavior and provides TASK-003's bounded contribution to CP1's green Actions build.

Post-design re-check: **PASS**. The execution-state model, workflow contract, and publication-aware verification lifecycle add no product entity or architecture boundary. The feedback clarifies when evidence can exist and does not deviate from the architecture baseline, so no ADR is warranted. Any implementation that introduces another service, secret, product behavior, or quality category requires a reviewed ADR and scope reassessment.

## Challenge Resolution and Rejected Alternatives

| Material finding | Smallest compliant decision | Alternatives rejected |
|---|---|---|
| Complete suite could be empty or partially undiscovered | A thin script runs the default, unfiltered `mix test` alias, preserves its status, and requires a unique marker emitted by a committed sentinel in the normal discovery scope | Parsing numeric console totals is brittle; a custom test runner/formatter is unnecessary; failing every intentional skip changes normal ExUnit semantics |
| “Every warning” had unclear ownership | Run `MIX_ENV=test mix compile --warnings-as-errors`, then `mix test --warnings-as-errors`; this covers project-owned `lib`, `test/support`, and test files | Dependency-source warnings are upstream and not controlled by this repository; compiling only `lib` misses support/test warnings |
| PR-only trigger weakens green-main evidence | Trigger pull requests targeting `main` and pushes to `main`; key concurrency by workflow plus PR number or branch and cancel superseded runs | All-branch pushes add noise; scheduled/manual-only runs do not gate proposed changes; PR-only lacks a merged-SHA result |
| Three categories could be mistaken for three total steps/jobs | Use one required job with setup steps plus exactly three labelled quality steps | Three jobs repeat setup and make same-environment evidence weaker; hiding setup inside quality commands obscures infrastructure failures |
| Percentage criteria overstate one-time proof | Validate one conforming revision and one controlled negative fixture per defect class on the pinned toolchain; treat universal reliability as the workflow's ongoing contract | Claiming historical 100% reliability from one run is not falsifiable |
| Hosted execution cannot exist before the workflow is published | Permit QA and final review to pass on parsed workflow-contract checks, exact pinned local parity, and controlled negative fixtures; require hosted PR and `main`-push runs as post-publication evidence | Requiring an uncommitted workflow's hosted run creates a publication deadlock; omitting hosted follow-up would leave CP1 evidence incomplete |

## Implementation Design

### Workflow and revision identity

- Create `.github/workflows/quality-baseline.yml` for `pull_request` branches `[main]` and `push` branches `[main]`.
- Grant only `contents: read`. Checkout the triggering revision and keep formatting, compilation, and tests in one job/checkout so all categories evaluate the same SHA.
- Use concurrency grouped by workflow and pull-request number when present, otherwise the branch ref; cancel superseded runs. The current commit's check is authoritative, while a cancelled older run cannot appear as its result.
- Use a pinned Ubuntu runner label plus the exact Elixir/OTP values already enforced by `scripts/check_toolchain.sh`. Cache only fetched/build dependencies keyed from `mix.lock`; caches are optional optimizations, never sources of mutable product state.
- Supply an ephemeral PostgreSQL service with non-production credentials and readiness checking because the canonical `mix test` alias prepares the test database. Redis and external football providers are not required by the ExUnit baseline.

### Setup and three quality outcomes

- Setup checks out code, installs the exact BEAM toolchain, verifies it with `./scripts/check_toolchain.sh`, installs Hex/Rebar, and fetches `mix.lock`-locked dependencies. Any setup failure fails the same required job.
- **Formatting** runs `mix format --check-formatted`; it examines the repository's standard formatter inputs and never mutates files.
- **Warnings-as-errors** runs `MIX_ENV=test mix compile --warnings-as-errors`. The test step additionally uses `mix test --warnings-as-errors`, making warnings from test files fatal while test-environment compilation includes `lib` and `test/support`.
- **Unit tests** runs `scripts/ci_unit_tests.sh`, which invokes the standard unfiltered `mix test --warnings-as-errors` alias against the ephemeral PostgreSQL database, preserves its exit status, and then requires the sentinel marker in captured output. It must not use `--stale`, path filters, exclusions, or early-success wrappers. Normal assertion failures name the failed test.
- Add one stable, side-effect-free discovery sentinel test beneath the default ExUnit path; it emits one unique marker only when executed. The script fails if the test command fails or the marker is absent, and cleans its temporary output. Intentional ExUnit skips remain visible in the summary and do not alone fail the job.

### Local reproducibility and acceptance

- Add a concise README section listing prerequisites and the same three category commands in workflow order. Local and CI commands share `MIX_ENV=test`, the exact toolchain check, locked dependencies, and PostgreSQL-backed default test alias.
- Pre-publication QA parses the workflow YAML and asserts its triggers, pinned toolchain/runner, permissions, concurrency, PostgreSQL service, checkout, and exactly three labelled commands. It also rejects failure masking, mutating formatting, scope-reducing test flags, secrets, Redis/providers, and out-of-scope quality categories.
- Positive pre-publication acceptance runs the exact three commands locally on one conforming revision with the pinned toolchain and PostgreSQL, recording the revision/toolchain and category results.
- Negative pre-publication acceptance uses temporary, uncommitted fixtures independently: an unformatted project file; a warning in project application/support code and a warning in a test file; a failing test; and a removed/renamed discovery sentinel. Each applicable command must fail. Restore the fixture after each trial and verify the working tree is not left with fixture changes.
- QA and final review may return `Verdict: PASS` when these pre-publication checks pass. The absence of a hosted run for the not-yet-committed workflow is not a blocker.
- After Agentflow publishes the feature commit and opens the PR, verify the hosted PR run against that head SHA. After merge, verify the separate `main` push run against the integrated SHA. Record these as post-publication checkpoint evidence; they do not replace or weaken local parity checks.

## Project Structure

```text
.github/workflows/quality-baseline.yml
README.md
scripts/ci_unit_tests.sh
test/ci/quality_baseline_discovery_test.exs
test/ci/quality_baseline_contract_test.exs
test/scripts/ci_unit_tests_test.sh
specs/003-continuous-integration-quality-baseline/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/quality-baseline.md
└── handoffs/architecture.md
```

**Structure Decision**: Keep CI at the repository boundary and use the existing Phoenix project commands. The only test addition is a discovery sentinel in the standard ExUnit tree; no web, domain, persistence, worker, cache, or adapter code changes.

## Complexity Tracking

No constitution violations or justified complexity exceptions.
