# Outcome specification: Required Sobelow security analysis for Elixir PRs

**Feature Branch**: `074-required-sobelow-security-analysis-for-elixir-prs`

**Task**: `TASK-074`

## Outcome

TASK-074 adds pinned Sobelow security analysis to the existing quality workflow and required aggregate, preserving application behavior.

## Acceptance

- [ ] Verify the exact locked analyzer on Elixir 1.20.3 / OTP 29.0.6 with the current Phoenix dependencies; document real checks, metadata and exit semantics.
- [ ] Analyze the application and document every existing finding and any individually justified exception by rule and location.
- [ ] Block all confidence levels of unaccepted findings, malformed/incomplete analyzer output, execution errors and invalid configuration. Preserve file, line and rule diagnostics.
- [ ] Exercise the real analyzer through the CI control on isolated unsafe and corrected fixtures, proving detection, failure propagation and recovery without adding vulnerable application code.
- [ ] Preserve existing tests, Credo, coverage, SonarCloud, workflow permissions and secret protections; retain bounded, non-sensitive revision-bound evidence.

## Scope

Pinned dependency, a small CI control, focused tests, existing quality workflow integration, and scope/policy/triage documentation. Resolve only findings that fit security-analysis scope.

## Non-goals

Broader TASK-050 API/UI hardening, new pipelines or frameworks, blanket suppressions, product refactors, full regression execution during development, commits, pushes, PR creation or merge.

## Risk

High: dependency and required CI control changes. ThinFlow path classification remains authoritative. Static findings indicate confidence, not business severity or proof of exploitability.

## Decisions

- All reported confidence levels block unless an exact reviewed rule/location exception matches. Never choose a finding-count allowance.
- Run offline/private with strict parsing, no project suppression configuration and no skipped findings. Document scope and remaining static-analysis limits.

Sobelow is locked to **0.18.1**, tested with Elixir **1.20.3**, OTP **29.0.6**, Phoenix **1.8.13**, LiveView **1.2.11** and Plug **1.20.3**. The direct dependency is dev/test only with `runtime: false`; existing locked dependencies are unchanged. Sources: [upstream documentation](https://sobelow.hexdocs.pm/0.18.1/readme.html) and the locked analyzer's `lib/sobelow.ex`, `lib/sobelow/scanner.ex`, `lib/sobelow/scan/discovery.ex`, `lib/sobelow/config.ex` and `lib/mix/tasks/sobelow.ex`.

The enabled default check families are XSS, SQL, Traversal, RCE, Misc, Config, CI (command injection), DOS, Crypto and Vuln. No family or rule is disabled. The fixed invocation is `MIX_ENV=test mix sobelow --private --no-config --strict --format json --exit low --threshold low --summary`. Private mode prevents update requests/cache writes. JSON groups findings by high/medium/low **confidence**, supplies `type`, `file`, `line`, sometimes `variable`, `key` or `pipeline`, and declares version and total. These are not Java/Sonar severity levels. `--exit low` returns 1 for any finding, including accepted exceptions; the control permits that exact exit only after validating the complete report and individually classifying findings. Exit 0 requires no findings. Any other exit/report combination fails. Missing/invalid JSON, wrong version, inconsistent totals, unexpected stderr, zero scanned files, unreadable/unparseable/pending files or changing source bytes fail. Project `.sobelow-conf` and `.sobelow-skips` files are rejected rather than honored. There is no count threshold.

Scope is the tool's standard Phoenix application scope: `lib/**/*.ex`, recognized Phoenix routers/endpoints, supported EEx/HEEx templates under `lib`, production/shared/runtime configuration and its built-in known-dependency checks. Mix tasks, scripts, migrations, tests/support, assets and dependency source are not application source analysis targets. Sobelow itself omits dev/test configuration (including dev/test secret variants); this repository's two ignored files are `config/dev.exs` and `config/test.exs`. These are tool defaults, not added suppressions. The scan records discovered/scanned/ignored/error counts. This does not prove coverage of every AST construct, arbitrary configuration shape, generated code, dynamic execution or runtime authorization. Its built-in Vuln checks cover a fixed historical set, not a current dependency vulnerability database. Hex reported advisories in existing locked packages during dependency resolution; this change does not claim those dependencies are vulnerability-free or update them outside this task.

Each following exception is a reviewed false positive on the current source, keyed by exact rule, relative file, line, confidence and SHA-256 of the entire source file in `scripts/sobelow_ci.py`. Modified bytes or a different location/rule/confidence block and require fresh individual triage. Findings remain visible in evidence; no inline skips or broad exclusions are introduced.

| Rule | File:line | Confidence | Individual rationale |
| --- | --- | --- | --- |
| Config.CSP | `lib/football_market_web/router.ex:11` | high | The plug has no custom header map, but locked Phoenix 1.8.13 `Phoenix.Controller.put_secure_browser_headers/2` supplies `content-security-policy: base-uri 'self'; frame-ancestors 'self';` by default. The rule requires an explicit map and misses that default. This accepts the missing-header false positive; it does not claim a restrictive script policy. |
| XSS.HTML | `lib/football_market_web/controllers/session_controller.ex:152` | medium | The only interpolated value is Plug's locally generated `get_csrf_token()`. Plug 1.20.3 constructs it from URL-safe Base64 bytes; it cannot inject attribute delimiters or markup. The rest is fixed HTML. |
| SQL.Query | `lib/football_market/catalog.ex:180` | low | SQL identifiers come solely from the literal `filter_columns` allowlist; indexes are generated integers. Filter values are UUID-validated and bound as SQL parameters. No input becomes SQL text. |
| DOS.StringToAtom | `lib/football_market/quotes.ex:387` | low | The immediately enclosing guard limits `reason` to exactly three literal strings: configuration_unavailable, mapping_unavailable, unsupported_strategy. It cannot create an unbounded set of atoms. |
| SQL.Query | `lib/football_market/quotes/membership.ex:194` | low | `query` is a constant SQL heredoc; IDs are passed through `$1::uuid[]` with dumped UUID values. |
| SQL.Query | `lib/football_market/quotes/membership.ex:218` | low | `query` is a constant SQL heredoc; player, season and time bounds are separate bound parameters `$1` through `$4`. |
| Traversal.FileModule | `lib/football_market/statistics/ingestion/publisher.ex:333` | low | `path` is the expansion of the literal `test/fixtures/statistics_ingestion/documents.exs`. Fixture identity selects metadata, never a filesystem path; bytes are digest-checked against the fixture inventory. |
| Traversal.FileModule | `lib/football_market/synchronization/input.ex:116` | low | The public helper hashes a configured source's fixture artifact. Normal ingestion resolves a closed source reference from trusted application configuration and allowed provider modules. Request/worker payloads cannot supply the path; execution re-resolves the source and checks its identity. This is a trusted configuration boundary, not a filesystem sandbox against malicious operators or arbitrary internal callers. |

Run `python3 scripts/sobelow_ci.py` locally for the same application control used by CI. Run `python3 -m unittest discover -s test/scripts -p sobelow_ci_test.py` for focused policy and real-analyzer controls. The existing Quality baseline job runs both commands without continue-on-error; its existing required aggregate propagates failure. No workflow permissions, secrets, SonarCloud, Credo, coverage or test profile policy changes are needed. CI always uploads `tmp/sobelow-ci/` for 14 days under a revision/attempt-specific artifact name. `evidence.json` records the source digest, HEAD, trigger revision, dirty flag, exact invocation, counts, exit and accepted/blocking finding metadata. `controls.json` retains bounded unsafe/corrected/error-control evidence. Source excerpts, secret values, environment variables and raw exception output are not uploaded.

Observed focused development controls on 2026-10-30: the application reports 8 findings (1 high, 1 medium, 6 low), all individually accepted above; raw analyzer exit 1, control exit 0. A temporary project with interpolated SQL at `lib/probe.ex:3` reports `SQL.Query: SQL injection`, raw exit 1 and control exit 1. Replacing SQL interpolation with a literal `$1` query and bound values produces zero findings, raw exit 0 and control exit 0. Invalid source and prohibited suppression configuration each produce control exit 1. The unsafe source exists only inside a temporary directory generated by the test, never in application code. Focused tests also challenge report schema/count/version, incomplete scan summaries, exact exception matching and hosted failure propagation.

Focused verification: all 4 Python control tests passed; all 33 ExUnit tests across `quality_baseline_contract_test.exs`, `credo_ci_contract_test.exs`, `sonarcloud_contract_test.exs` and `workflow_scope_test.exs` passed. The workflow byte oracle was refreshed for the explicitly added Sobelow step/artifact, and the existing scope registry lists this task’s exact files. No regression profile, independent evaluation or hosted result is claimed by this development session.

Feedback 1 repair verification: `python3 scripts/test_inventory.py update --profile unit` registered exactly the four cited native Sobelow cases; an assertion-based comparison against HEAD confirmed no existing entries or inventory metadata changed. `python3 scripts/test_inventory.py check` passed with 1,377 cases. All 9 `workflow_scope_test.exs` tests passed, including explicit repair-file allowances and unrelated-path refusals. The actual tracked/untracked workspace diff contained 14 files, all allowed by TASK-074's scope registry. Focused Elixir formatting and `git diff --check` passed. This repair changes only verification registration, directly required scope bookkeeping and this evidence; fresh required checks and independent evaluation remain ThinFlow's next gates.
