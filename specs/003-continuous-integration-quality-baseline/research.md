# Research: Continuous Integration Quality Baseline

## Workflow shape and triggers

**Decision**: Use one GitHub Actions job for pull requests targeting `main` and pushes to `main`, with concurrency keyed by workflow and PR number or branch.

**Rationale**: One checkout proves all categories evaluate the same revision. PR runs provide review gating; push runs provide an unambiguous green result for the integrated CP1 revision. Cancelling superseded runs prevents stale PR results from being mistaken for current evidence.

**Alternatives considered**: PR-only was rejected because it lacks merged-main evidence. Three jobs were rejected because they duplicate setup and weaken the single-environment proof. All-branch push validation adds scope without checkpoint value.

## Warning-fatal scope

**Decision**: Under `MIX_ENV=test`, run `mix compile --warnings-as-errors` for `lib` plus `test/support`, and run `mix test --warnings-as-errors` for test-file compilation and execution.

**Rationale**: `mix.exs` includes `lib` and `test/support` in test compilation, while Mix's test warning flag applies to loaded test files. Together they cover repository-owned executable test scope without making upstream dependency source warnings a team-controlled obligation.

**Alternatives considered**: Application-only compilation leaves support/test gaps. Making dependency compilation warnings fatal is unstable and outside repository ownership. A new compiler wrapper adds no value.

## Complete, non-empty test discovery

**Decision**: Keep Mix's default unfiltered `test/**/*_test.exs` loader and add a stable discovery sentinel within it. A thin shell script preserves the test command's status and also requires the sentinel's unique execution marker.

**Rationale**: The marker establishes deterministic, machine-checked evidence that the intended default discovery path executed. The canonical command still executes every matching test file and has no filters that silently narrow scope.

**Alternatives considered**: Parsing the numeric CLI summary is coupled to formatter text. A custom formatter/runner is excess machinery. File existence alone does not prove execution. Treating all intentional skips as failures confuses an explicit test disposition with an incomplete run.

## Execution environment

**Decision**: Use the exact documented Elixir 1.20.3 / OTP 29.0.6 toolchain (ERTS 17.0.6), locked Mix dependencies, and an ephemeral PostgreSQL service; do not start Redis or external providers.

**Rationale**: The canonical `mix test` alias prepares PostgreSQL. Existing ExUnit tests do not require live Redis or providers. Exact versions maximize local/CI parity.

**Alternatives considered**: A version matrix is broader than TASK-003. Docker Compose in CI starts unnecessary Redis. Bypassing the test alias would make local and hosted scopes diverge.

## Quality presentation and evidence

**Decision**: Present setup separately and exactly three labelled quality steps in one required job. Prove behavior with one positive fixture and one temporary negative fixture per defect class.

**Rationale**: Reviewers can identify the category while setup failures remain honest workflow failures. Controlled fixtures are finite evidence; ongoing trigger behavior is the operational contract.

**Alternatives considered**: A literal three-step workflow cannot perform checkout/toolchain/dependency setup transparently. Percentage claims without an observation set overstate one-time acceptance evidence.

## Publication-aware verification

**Decision**: Before publication, QA validates the parsed workflow contract, runs the exact three commands locally on the pinned toolchain with PostgreSQL, and exercises isolated negative fixtures. QA and final review may pass on that evidence. Hosted PR-head and subsequent `main`-push runs are verified after those refs exist and recorded as post-publication checkpoint evidence.

**Rationale**: GitHub cannot execute an uncommitted workflow, so making hosted execution a pre-publication prerequisite creates a circular gate. Static contract validation plus local positive and negative execution proves the implementation before Agentflow publishes it, while post-publication runs prove actual hosted behavior without weakening either evidence layer.

**Alternatives considered**: Requiring a hosted run before commit/push/PR is impossible in the authorized delivery sequence. Skipping local parity in favor of a later hosted run weakens pre-publication QA. Treating hosted evidence as optional would leave PR-trigger and green-`main` behavior unverified.
