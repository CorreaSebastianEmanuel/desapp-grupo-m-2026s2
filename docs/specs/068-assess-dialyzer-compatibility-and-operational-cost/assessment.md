# Dialyzer assessment

## Recommendation

**Defer adoption as a required CI gate.** Dialyzer 6.0.2 can analyze this application on the pinned Elixir 1.20.3 / OTP 29.0.6 toolchain once the Elixir runtime and project dependencies are represented in its PLT and the Elixir ebin directory is on its code path. The analysis produced several potentially useful dead-branch/type signals, but the default output also includes known test fixtures, compile-time test hooks, and Ecto.Multi opaque-type mismatches. No warning was confirmed as a runtime defect in this assessment.

The cold PLT setup took several minutes and peaked at 2.34 GiB RSS for the OTP base alone. Dependency and Elixir additions required additional PLT work and emitted unresolved optional-dependency functions/types. Warm first-party analysis took about 14–16 seconds. This is too much setup and warning-policy maintenance to add to the existing CI quality job without a separate, scoped integration decision. Reconsider an opt-in local workflow after defining how test fixtures, test-only hooks, Ecto.Multi types, optional native dependencies, PLT caching, and OTP/dependency invalidation are handled.

## Environment and scope

- Observation date: 2026-10-28.
- Repository revision: `3a1b0db` (working-tree documentation changes do not alter the analyzed Elixir sources).
- Toolchain: Elixir 1.20.3 compiled with Erlang/OTP 29; OTP runtime 29.0.6; Dialyzer v6.0.2.
- Dependencies: existing locked dependencies from `mix.lock`; no dependency was added. Application and dependencies were already compiled locally.
- Scope: first-party `football_market` BEAMs from the existing dev and test build profiles. Test profile also contains compiled `test/support` probes. This is not a fresh dependency-fetch or clean-machine CI measurement.
- Existing `.github/workflows/quality-baseline.yml` pins Elixir 1.20.3 / OTP 29.0.6 and runs Credo, compilation, and current quality checks; it has no Dialyzer step. Hosted CI timing and hosted PLT caching were not measured.

## Measurements

| Operation | Elapsed | Peak RSS | Result |
| --- | ---: | ---: | --- |
| `mix compile --warnings-as-errors` | 3.72 s | 166 MiB | Passed |
| Full installed OTP application PLT (`erts`, `kernel`, `stdlib`, and all other installed OTP apps) | 2m 10.33s | 2.34 GiB | Passed; PLT 7.9 MiB |
| Add Elixir and compiled dev dependencies to OTP PLT | 1m 07.89s | 1.79 GiB | PLT produced, exit 2 for unresolved optional dependency functions/types |
| Add installed Elixir runtime apps (`eex`, `elixir`, `ex_unit`, `iex`, `logger`, `mix`) | 56.09 s | 1.74 GiB | PLT produced, exit 2 for unresolved optional native dependency functions and remaining dependency types |
| Add test-only dependencies (`cc_precompiler`, `fine`, `lazy_html`) | 16.31 s | 1.64 GiB | Passed |
| Warm application analysis with prepared PLT | 13.56 s dev; 15.78 s test | 1.43 GiB dev; 1.70 GiB test | Each exited 2 because warnings were emitted |

PLTs were stored under `/tmp`; the final layered PLT was 11 MiB. An initial PLT containing only `erts`, `kernel`, and `stdlib` failed after 41.99 seconds with unresolved OTP `compile`, `crypto`, and `yecc` functions/types. A usable setup needed the installed OTP application set, Elixir BEAM support via `-pa "$ELIXIR_LIB/ebin"`, Elixir runtime applications in the PLT, and the project's compiled dependency BEAMs. This establishes compatibility with a carefully constructed local PLT, not a turnkey `mix dialyzer` workflow.

The full OTP PLT completed but printed numerous missing-specification warnings from OTP `xmerl`; dependency PLT extensions also reported unresolved optional NIF functions and dependency types. These messages are not included in first-party warning counts below.

## Finding review

The dev application analysis emitted eight warnings. Test-profile analysis emitted 14:

- Two `Ecto.Multi.insert/run` calls in `accounts.ex:216` and `statistics.ex:72` were rejected against Ecto's opaque `Multi` type even though both use the standard `Multi.new() |> Multi.operation(...)` construction. These appear to be dependency type-model false positives.
- `accounts/authentication.ex:111`, `providers/scraping/source.ex:144`, and `quotes.ex:1137` were reported as unreachable fallback or redundant nil handling. Source review found no demonstrated behavior defect; at most these identify dead/redundant code for a separate cleanup decision.
- Five test-profile compile-time branches in publisher, clock, input, store, and catalog synchronization code are specialized by `Mix.env() == :test`; Dialyzer reports the branch impossible in that specialized build. This is profile-dependent noise rather than a production finding.
- `test/support/statistics_ingestion/runtime_probe.ex` and four malformed scorer fixtures in `test/support/valuation_scorers.ex` intentionally exercise crashes and invalid callback results. Their warnings are expected test-fixture findings.

No confirmed defect was established. The unreachable-branch signals show limited usefulness for finding dead paths, while the Ecto and intentional test warnings need explicit triage rules. A zero-warning gate would require a reviewed baseline or suppressions that this task does not authorize.

## Reproduction

Run from the repository root after compiling the existing dev and test profiles. These commands use only temporary PLTs and the already locked/compiled dependencies:

```bash
ERL_LIB="$(dirname "$(dirname "$(command -v erl)")")/lib"
ELIXIR_LIB="$(elixir -e 'IO.puts(:code.lib_dir(:elixir))')"

otp_apps=()
for app_dir in "$ERL_LIB"/*-*; do
  app_name=${app_dir##*/}
  otp_apps+=("${app_name%-*}")
done
/usr/bin/time -v dialyzer --build_plt --output_plt /tmp/task068-otp.plt --apps "${otp_apps[@]}"

dev_deps=()
for dep_dir in _build/dev/lib/*/ebin; do
  [ "$dep_dir" = _build/dev/lib/football_market/ebin ] || dev_deps+=("$dep_dir")
done
/usr/bin/time -v dialyzer -pa "$ELIXIR_LIB/ebin" --add_to_plt --plt /tmp/task068-otp.plt \
  --output_plt /tmp/task068-project.plt --apps "$ELIXIR_LIB/ebin" "${dev_deps[@]}"

elixir_apps=("$(dirname "$ELIXIR_LIB")"/*/ebin)
/usr/bin/time -v dialyzer -pa "$ELIXIR_LIB/ebin" --add_to_plt --plt /tmp/task068-project.plt \
  --output_plt /tmp/task068-project-full.plt --apps "${elixir_apps[@]}"

test_only_deps=()
for dep in cc_precompiler fine lazy_html; do
  test_only_deps+=("_build/test/lib/$dep/ebin")
done
/usr/bin/time -v dialyzer -pa "$ELIXIR_LIB/ebin" --add_to_plt --plt /tmp/task068-project-full.plt \
  --output_plt /tmp/task068-test.plt --apps "${test_only_deps[@]}"

/usr/bin/time -v dialyzer -pa "$ELIXIR_LIB/ebin" --plt /tmp/task068-project-full.plt \
  _build/dev/lib/football_market/ebin
/usr/bin/time -v dialyzer -pa "$ELIXIR_LIB/ebin" --plt /tmp/task068-test.plt \
  _build/test/lib/football_market/ebin
```

PLT extension returns status 2 when it reports unresolved optional dependency functions/types; preserve that output and do not interpret it as a clean gate. The application analyses also return status 2 for their reviewed warning sets.
