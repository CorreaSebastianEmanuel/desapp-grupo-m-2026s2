# Research: CP1 Test and Coverage Profiles

## Test membership

**Decision**: Audit every default-discovered `test/**/*_test.exs` ExUnit module; require exactly one direct `:unit` or `:integration` module tag and run selected audited files with `--only <profile> --include performance`.

**Rationale**: The audit makes a new untagged module fail before a profile can claim success, while preserving legacy default performance behavior.

**Alternatives considered**: Directories and voluntary manifests can silently omit new tests.

## Safe diagnostics

**Decision**: Capture child output privately and release only runner-owned fixed categories and metadata after validation.

**Rationale**: Browser and test failures can format credentials, expected payloads, exceptions, or command environment. A post-print scan is too late.

**Alternatives considered**: `cat` plus grep, regex-only redaction, and raw assertion messages can disclose unknown values before validation.

## Browser prerequisite

**Decision**: Integration preflight verifies Node 24, lock-installed Node tooling, and a usable Playwright Chromium executable.

**Rationale**: The browser regression is required. Missing tools need safe nonzero failure, never a skip.

**Alternatives considered**: Package metadata, deferred `System.cmd` failure, and CI-only execution do not prove the documented local environment.

## Coverage and scope

**Decision**: Use native Mix executable-line coverage, export unit/integration datasets, import them in one VM, and publish an aggregate inventory report from `:cover`. Derive native `:ignore_modules` from an exact committed path/module allowlist.

**Rationale**: Mix 1.20 merges exports and emits module HTML but no aggregate index. Exact inventory data must be consumed by the collector; current glob metadata misses nested files.

**Alternatives considered**: ExCoveralls adds unnecessary dependency; default scope misstates denominator; a metadata-only inventory cannot prove actual scope.

## Provenance

**Decision**: Hash base HEAD plus complete binary `git diff HEAD`, reject untracked non-generated inputs, and revalidate immediately before publication. Label nonempty diffs as working-tree snapshots.

**Rationale**: This is the approved broad policy, allowing truthful pre-commit evidence without subjective relevance omissions.

**Alternatives considered**: Clean HEAD conflicts with FR-017; an enumerated diff subset can omit execution inputs.
