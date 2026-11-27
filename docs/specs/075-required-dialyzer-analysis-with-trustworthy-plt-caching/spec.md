# Outcome specification: Required Dialyzer analysis with trustworthy PLT caching

**Feature Branch**: `075-required-dialyzer-analysis-with-trustworthy-plt-caching`

**Task**: `TASK-075`

## Outcome

TASK-075 adds pinned Dialyxir to the existing required quality gate with a trustworthy dependency model, explicit production/test-support analysis and reusable, correctly invalidated PLTs.

## Acceptance

- [ ] Verify locked Dialyxir and exact Elixir 1.20.3 / OTP 29.0.6 / Dialyzer versions against TASK-068 observations.
- [ ] Analyze production application and test-support builds separately. Retain unknown-function/type warnings. Resolve or individually explain optional/native dependency types, Ecto.Multi opaque findings, test compile hooks and deliberately invalid fixtures. No broad suppression or hidden baseline.
- [ ] Cache PLTs by runner/platform, exact toolchain, locked dependencies and analyzer configuration/scope. Focused tests prove invalidation without cold rebuilds.
- [ ] Existing Quality baseline and ThinFlow required fail on unaccepted findings and analyzer/configuration failures. Any temporarily informative result is explicitly incomplete; mandatory adoption is required for acceptance.
- [ ] An isolated real-analyzer contract-error sample fails with file/line/warning-kind evidence and its correction passes through the same control. Application behavior stays unchanged.
- [ ] Record one cold and one warm/cache-hit timing, environment, cache identity and bounded evidence. Preserve existing tests, Credo, Sobelow, coverage accounting and SonarCloud. Report larger remediation as a concrete blocker.

## Scope

Dependencies, analyzer configuration/control, existing CI integration, focused tooling tests and evidence documentation. Reuse TASK-068 assessment; do not rerun unrelated regression profiles.

## Non-goals

Application feature changes, broad refactoring, new quality pipelines, suppressing unknown warnings, changing workflow policy, commits or publication in this development stage.

## Risk

Quality infrastructure: a stale PLT or hidden dependency warning could provide false assurance. Fail closed and retain analyzer errors separately from findings. Deterministic diff classification remains authoritative.

## Decisions

- TASK-068 and TASK-074 are done; current branch descends from the merged TASK-074 revision.
- Use dev for production-source analysis (lib only) and test for lib plus compiled test/support; dependencies supply the PLT model, not first-party warning scope. Exact exceptions require individual rationale and finding identity.
- Rollout: diagnose locally, review each current finding, then enable blocking analysis in the existing Quality baseline job. There is no informative hosted bypass. The existing aggregate gate and all other checks remain required.
- `python3 scripts/dialyzer_ci.py` prepares profile-specific PLTs through locked Dialyxir, then uses native Dialyzer with unknown warnings and PLT validation enabled. Application analysis covers every compiled first-party BEAM, including Mix tasks and consolidated protocols. The separate model pass analyzes dependency BEAMs for unresolved functions/types/behaviors; dependency-internal style/dead-code/type findings are outside first-party remediation scope.
- PLTs live in ignored `tmp/dialyzer/`. Cache identity includes OS, architecture, runner image, exact tool versions, lockfile, Mix project, build configuration and the analyzer/scope/exception control. No fallback restore prefix is allowed; even an exact hit still validates PLT BEAM checksums. Evidence in `tmp/dialyzer-ci/` distinguishes preparation errors, execution errors, accepted findings and blocking findings for each profile/phase.
- Native return 0 means no findings, 2 means findings, and 1 means analyzer/configuration failure. Only individually reviewed exact exceptions can turn a findings result into control success. Exceptions bind profile, phase, path, line, warning kind, warning bytes, available source bytes and locked dependency bytes, and carry an explicit rationale in `scripts/dialyzer_exceptions.json`.
- Production-source analysis uses `dev` (257 first-party BEAMs); `test` adds compiled support (335 BEAMs). Both PLTs also include Mix, ExUnit, Dialyzer, tools/cover, inets/httpc, IEx and compile-time analyzer dependencies. The native boundary restores tools/inets/IEx code paths pruned by Mix, then verifies actual tool versions. It audits only dependency BEAMs represented in the PLT, excluding stale build directories.
- Current reviewed first-party findings: dev 8, test 15. The two Ecto.Multi warnings concern the default nested MapSet empty-map representation versus opaque `sets:set()`, despite unmodified `Multi.new()` construction. Three defensive fallback/comparison sites are redundant under current callers. Dev has three unreachable synchronization failpoint branches; test has five compile-time hook specializations, one deliberate crash probe and four deliberately invalid scorer callbacks. Each has an exact scoped exception; no application code was changed.
- Current dependency-model references: dev 144, test 123. Optional MySQL/Tds and Cowboy/Ranch adapters are unused by the configured Postgres/Bandit application. JOSE's absent JSON/native crypto/RSA-generation alternatives are capability-probed; application JWT uses HS256 with installed OTP crypto. Dev lacks test-only LazyHTML types used by packaged LiveView test helpers; test lacks the optional FileSystem watcher used only by Credo watch mode. Credo's nonexistent `Map.t/0` and Postgrex's undeclared `TextQuery.t/0` remain individually identified upstream limitations: the tooling callback and raw text-query union arm remain imprecise. This is a reviewed-policy pass, not a claim that every dependency type is complete or that the analyzer proves runtime correctness. The 290 exact records retain individual reasons and bind available dependency source bytes plus `mix.lock`; first-party unknown references remain blocking.
- Real isolated controls passed: `probe.ex:2` with `@spec value() :: integer()` and a string return produced `invalid_contract`, native exit 2 and control failure; changing the return to `1` produced native/control exit 0. Calling an absent module produced `unknown_function` and failure; malformed syntax produced native exit 1 and a distinct execution-error record. Bounded evidence is retained in `tmp/dialyzer-ci/probe-evidence.json`; samples never enter application sources.
- Focused development validation: five new Python controls passed; 18 existing quality-contract/inventory tests passed; native test-profile inventory reconciled 1,382 cases; focused formatting and baseline Credo passed. The effective Credo inventory also passed with a disposable index including the new script (the real index remains unchanged). A separate strict-Credo diagnostic enabled checks beyond repository policy and reported existing findings; no policy or unrelated source was changed.
- Timing environment: 2026-10-30, base revision `27d697a6bb2670b6f341c8219ffa9daff3105641` plus this development diff, Linux/WSL2 x86_64 (`6.18.54.1-microsoft-standard-WSL2`, glibc 2.43), pinned tool versions above, locked dependencies already compiled. This measures PLT preparation plus both model/application analyses, not dependency fetching or clean hosted-machine provisioning. TASK-068 remains historical context; no hosted timing/cache hit is claimed.
- Cold run: zero PLTs initially, all four analyses passed the reviewed policy, 315.09 s total, 2,340,380 KiB peak RSS. Dev/test PLT preparation took 129.37/116.79 s; model analysis took 24.35/24.80 s and application analysis 9.15/10.62 s. Cache identity: `dialyzer-72ae3d4f177c4783fd2ffd796b0ff72034f57cd7bd35f23e21903a3f5f55772f`. Retained local summary: `tmp/task075-cold-summary.json`.
- Warm local reuse: all four analyses passed again, 69.86 s total, 1,120,948 KiB peak RSS, four PLTs present beforehand, dev/test preparation 0.77/0.77 s. Current cache identity: `dialyzer-28040801e88f910569c9c5d4eed6d1f9dfb6a9e3b5a6bd1d57eb8869f90ec169`. The identity changed after the cold run solely because the wrapper was corrected to fail on a missing preparation receipt even after native exit zero; a fifth focused test proves that refusal. BEAMs, PLT model/scope, pinned versions and reviewed findings did not change. This is validated local warm reuse, not an assertion that the changed hosted cache key would hit. Retained summary: `tmp/task075-warm-summary.json`.
- Development leaves the required hosted job wired and blocking, with no informative bypass. Deterministically selected ThinFlow checks, independent evaluation, exact-head hosted CI and human merge remain subsequent delivery gates; this development stage does not claim them passed.
- Feedback 1 repair: reviewed the existing workflow additions and refreshed only its matching SHA-256 byte oracle (`ef45f6b915217301fee281bbb509a665edee0da0c17eb82eb4ca331381f73476`). TASK-075 now permits exactly the 17 actual tracked/untracked changed paths; focused assertions permit each and reject unrelated application, workflow, script, config, feedback and feature paths. The full four-file ThinFlow CI contract set plus workflow-scope and application-coverage inventory controls passed (37 tests); test/helper inventory discovery reconciled all 1,382 cases, including all five Dialyzer cases assigned to unit. Credo source/effective inventories reconciled and baseline Credo passed using a disposable index/object directory that includes the new analyzer script, leaving the real index unchanged. Analyzer code, exceptions, cache inputs, workflow policy and application behavior were unchanged in this repair; existing cold/warm and real-analyzer controls were reused.
