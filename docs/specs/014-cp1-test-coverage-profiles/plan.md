# Implementation Plan: CP1 Test and Coverage Profiles

**Branch**: `014-cp1-test-coverage-profiles` | **Date**: 2026-09-29 | **Spec**: [spec.md](spec.md)

**Input**: TASK-014 specification, product challenge, approved human remediation in `backlog/feedback/TASK-014.md`, architecture baseline, and constitution.

## Summary

Provide independently runnable CP1 unit and integration profiles and an informational executable-line coverage report for the exact Git working-tree snapshot tested. A strict profile audit classifies every default-discovered ExUnit module exactly once. A safe runner captures untrusted test output without releasing it, publishing only allowlisted receipts. Native Mix merges both profile exports; a small publisher derives an aggregate report from the native coverage VM. The existing three-category CI baseline remains unchanged.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`, Erlang/OTP `29.0.6`, Node.js `24.x` for the browser regression.

**Primary Dependencies**: Existing Mix/ExUnit/Phoenix/Ecto SQL Sandbox and pinned `tools/openapi` npm packages; no new Hex or npm dependency.

**Storage**: Existing PostgreSQL test database; ignored `cover/cp1/` output; committed coverage inventory; no product-data change.

**Testing**: ExUnit classification/runner contracts, deterministic fixture cases, Node/Chromium browser regression, native Mix executable-line coverage, and shell failure fixtures.

**Target Platform**: Supported macOS/Linux local checkout and existing GitHub Actions BEAM/PostgreSQL environment. Node 24, npm, and Playwright Chromium are integration prerequisites.

**Project Type**: Modular Phoenix monolith; test tooling and documentation only.

**Performance Goals**: Focused profiles run only their classification with deterministic local data and no live provider, Redis, production data, or production credentials.

**Constraints**: Threshold zero; no coverage CI gate. Preserve `quality-baseline.yml` and `scripts/ci_unit_tests.sh` byte-for-byte. No Sonar, deployment, schema, route, domain, provider, or credential-policy change. No child output is released before safety validation.

**Scale/Scope**: Default-discovered ExUnit modules, CP1 behavioral regressions, runner/publisher contracts, source inventory, and documentation.

## Constitution Check

### Pre-design gate

- **Specification before implementation — PASS**: `spec.md` is behavioral truth. Approved feedback resolves all material ambiguity.
- **Domain integrity — PASS**: Existing account, credential, authentication, catalog, filtering, and OpenAPI behavior is verified, not changed. No financial/product rule changes.
- **Modular simplicity — PASS**: Work stays at test, Mix, script, configuration, and documentation edges. Web/domain/persistence/worker/cache/provider boundaries remain untouched.
- **Evidence-based quality — PASS**: Executable contracts prove classification, safe errors, prerequisites, actual coverage scope, snapshot mutation, and CP1 journeys.
- **Independent verification — PASS**: Challenge findings are resolved by authoritative feedback; fresh implementation, QA, and final review remain required.

### Post-design gate

**PASS.** [research.md](research.md), [data-model.md](data-model.md), the [profile](contracts/test-profiles.md) and [coverage](contracts/coverage-report.md) contracts, and [quickstart.md](quickstart.md) resolve the design. [ADR 0009](../../docs/adr/0009-cp1-coverage-snapshot-provenance-and-scope.md) records the durable snapshot/scope decision.

## Design

### Profile population, selection, and completion

1. The CP1 test population is every module Mix discovers by default from `test/**/*_test.exs`; helper/support/fixture and shell/Python/Node files are not ExUnit modules. `FootballMarket.TestProfileAudit` creates sorted, unique relative file/module IDs with strict AST or conservative direct-attribute parsing, rejecting ambiguous/unreadable input.
2. Every inventory module must have exactly one direct module tag, `:unit` or `:integration`, and may have `:performance`. Reject absent, duplicate, unknown, indirect/test-level profile tags and all skip tags. Unit covers isolated context/value/configuration behavior. HTTP/router/public-contract/browser or Ecto/PostgreSQL persistence assertions are integration. Paths do not decide membership.
3. Keep the legacy default `:performance` exclusion. `scripts/test_profile.sh unit|integration` and `mix test.unit` / `mix test.integration` audit first, pass only selected audited files to `mix test --only <profile> --include performance`, and require audit IDs/counts, selected-file discovery, one sentinel, a positive complete count, zero skips, and normal termination. Any audit, compile/discovery, assertion, interruption, missing/duplicate sentinel, parser, empty, or skip failure is nonzero. The opposite profile is selected out, never counted as skipped.
4. The integration runner preflights Node `24.x`, lock-installed `tools/openapi` packages, and usable local Playwright Chromium. README documents `npm ci --prefix tools/openapi` and browser installation. Missing/mismatched Node, package, or browser returns a fixed safe category and nonzero; the browser regression is never optional.

### Safe diagnostic boundary

1. Remove direct `cat`, forwarded stderr, raw assertion messages, and browser `IO.puts`. All audit, Mix, Node, coverage, exception, and command output enters only a private (`umask 077`), deleted-on-exit capture channel; nothing from it is printed or retained.
2. A runner-owned capture-and-release component emits only allowlisted profile/count/snapshot metadata, a fixed outcome category, and a predefined CP1 behavior ID. If capture, parsing, sanitization, or artifact safety checking cannot complete, it releases a generic safe category and exits nonzero. Child text, command args/environment, test names, diffs, stacktraces, fixture values, and raw reports are never a release channel.
3. Replace browser test output assertions with safe status/behavior assertions and test-local opaque handoff where needed. Inject sentinels through stdout, stderr, exceptions, command environment, and missing-prerequisite fixtures. Prove no receipt, coverage report, manifest, or retained diagnostic contains a password, API key, JWT, token, verification value, or sentinel.

### CP1 behavior matrix

- **Unit**: email/query/filter/cursor normalization and validation; safe account/API-key/JWT projections and verification; static configuration and runner/inventory contracts without an HTTP or persistence assertion.
- **Integration**: registration atomicity/normalized uniqueness; API-key issuance/independence/revocation persistence; login/token validity; protected-route credential forms, precedence and challenge; catalog list/detail/pagination/filter/cursor outcomes and no-provider reads; OpenAPI availability/fidelity and browser regression.
- The matrix maps every FR-008–FR-013 clause to a deterministic existing or added test, profile, success case, and applicable rejection/boundary. Add only gaps; do not redefine CP1 contracts.

### Inventory-controlled coverage and working-tree publication

1. Replace pattern-only inventory with a committed exact source-path/Elixir-module allowlist plus exclusion rationale, readable by `mix.exs` without an unavailable dependency. Derive native Mix `:test_coverage` `:ignore_modules` as a deny-all-except-inventory rule. The same inventory, not duplicated globs, controls the actual denominator. Include CP1 Accounts, Catalog, authenticated catalog/API-docs web edge, router, and auth plug; exclude support/tests/dependencies/generated files, operational Mix tasks, seed/infrastructure/Redis, endpoint/telemetry/UI scaffolding, and unrelated modules.
2. Run each audited profile once with `--cover --export-coverage unit|integration` through the same safe runner and require its receipt. In one subsequent `MIX_ENV=test mix run` VM, import/merge via `Mix.Tasks.Test.Coverage.run([])`, then use `:cover` data to publish an aggregate `report.html` and machine-readable summary. Native Mix's unit is executable lines and it supplies per-module source HTML; the aggregate publisher reports each inventory source's executed/unexecuted executable lines and aggregate `executed_lines / executable_lines`. Native Mix does not emit `index.html`; the plan does not claim it does.
3. Capture `base_head = git rev-parse HEAD` and SHA-256 of full binary `git diff --binary --full-index HEAD`, covering staged and unstaged tracked changes. Reject nonignored untracked paths outside explicit generated tool output, and known execution-affecting ignored inputs; reproducible locked dependency/build outputs are prerequisites rather than claimed source inputs. Empty diff reports are labelled `committed revision`; nonempty reports are labelled `working-tree snapshot`.
4. Build reports in private staging outside the checkout. Immediately before atomic move into ignored `cover/cp1/<base-head>-<run-id>/`, recheck HEAD, diff hash, untracked policy, inventory hash, exports, module equality/source detail, receipt/report correspondence, and artifact safety. Any failure or mismatch destroys staging and publishes no report. A clean tree or pre-QA commit is never required.

## Critic Findings and Rejected Alternatives

1. **Snapshot ambiguity**: full tracked diff plus rejected untracked inputs gives falsifiable broad provenance; mutation tests cover staged/unstaged source, test, config, lock, inventory, browser asset, and generated-output cases. Rejected: an enumerated relevant subset (can omit execution inputs) and clean HEAD (contradicts FR-017 and feedback).
2. **Secret leakage before scan**: capture-and-release prevents untrusted text reaching terminals or artifacts. Rejected: `cat` then grep/redaction, because disclosure precedes the check, and full-response assertions, because tests become a credential channel.
3. **Undefined percentage**: executable-line numerator/denominator is stated and used at aggregate/source level. Rejected: branch/function coverage or undocumented tool defaults.
4. **Unclassified tests**: exhaustive default discovery plus exact-one direct tags fails a new module before success. Rejected: directory membership and voluntary manifests, which can omit new tests.
5. **Nominal scope restriction**: inventory-derived native exclusion plus observed report equality proves denominator control. Rejected: unconsumed JSON globs (which currently miss nested sources) and default all-compiled-module scope.
6. **Baseline expansion**: profiles and coverage remain separate commands. Rejected: a fourth baseline category, coverage threshold, Sonar import, or optional browser test.

## Project Structure

### Documentation

```text
specs/014-cp1-test-coverage-profiles/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── test-profiles.md
│   ├── coverage-report.md
│   └── cp1-regression-matrix.md
└── handoffs/architecture.md
docs/adr/0009-cp1-coverage-snapshot-provenance-and-scope.md
```

### Implementation boundary

```text
mix.exs                                  # aliases and inventory-derived coverage options
config/cp1_coverage_inventory.exs        # canonical module/path allowlist and rationale
scripts/test_profile.sh                  # safe profile capture/release and prerequisites
scripts/coverage_report.sh               # snapshot capture, staging, validation, publication
test/test_helper.exs                     # profile selection only
test/support/test_profile_audit.ex        # strict discovery/classification and safe receipts
test/support/cp1_coverage_publisher.ex    # aggregate report in native coverage import VM
test/ci/                                  # runner, sentinel, scope, provenance, safety contracts
test/fixtures/                            # controlled non-secret/sentinel fixtures
test/football_market*/                    # classified CP1 behavior regressions
tools/openapi/                            # locked browser-regression prerequisites
README.md                                 # prerequisites, commands, report semantics
.gitignore                                # generated coverage remains ignored
```

**Structure Decision**: Orchestration remains at the test/Mix/script edge. Application modules, migrations, adapters, and locked baseline workflow are read-only behavioral inputs; the publisher is test tooling, not a domain service.

## Verification Strategy

1. Contract-test absent/duplicate/unknown/indirect/test-level/skip tags, unreadable files, empty membership, new unclassified modules, deterministic IDs, and cross-profile exclusivity; prove selected performance tests run only in their profile.
2. Exercise assertion, discovery/compile, no-test, skip, interruption, malformed receipt, Node/package/browser absence, and sanitizer failure. Each is nonzero without success language. Scan every released/retained artifact for controlled sentinels.
3. Run deterministic registration, API-key, login/JWT, protected credential/auth-precedence/challenge, catalog/filter/cursor/no-provider, OpenAPI, and browser matrix cases.
4. Prove actual native collector inclusion/exclusion, two-export merge, executable-line totals, source HTML, aggregate report, zero threshold, inventory hash, mutation refusal, and no publication on failure.
5. Run focused contracts, both profiles, coverage command, formatter, warning-fatal compilation, and baseline parity checks. Record only commands actually executed; QA reruns independently.

## Complexity Tracking

No constitution violation requires justification.
