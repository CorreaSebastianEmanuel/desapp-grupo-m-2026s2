# Implementation Evidence: Phoenix Project Foundation

**Task**: TASK-001  
**Date**: 2026-09-13  
**Owner**: Development (sole implementation owner)

## Environment

- macOS, x86_64
- Elixir 1.20.3
- Erlang/OTP 29.0.3, ERTS 17.0.6
- Mix 1.20.3
- Phoenix/phx_new 1.8.13; resolved Phoenix runtime 1.8.13
- Task-local Mix and Hex homes under `/private/tmp`; these are execution fixtures and are not referenced by repository source or contributor commands.

`./scripts/check_toolchain.sh` exited 0 and printed:

```text
toolchain ok: Elixir 1.20.3, Erlang/OTP 29.0.3 (ERTS 17.0.6), Mix 1.20.3 (compiled with Erlang/OTP 29)
```

The system default was Elixir 1.20.4. The checker rejected relying on that default; validation selected the exact pinned binaries instead of broadening the claimed baseline.

## Build and automated checks

All commands below used the exact environment above.

| Command | Exit | Result |
|---|---:|---|
| `mix deps.get --locked` | 0 | Lock resolved unchanged; all dependencies fetched. |
| `mix assets.setup` | 0 | Phoenix-managed Tailwind and esbuild binaries installed. |
| `mix assets.build` | 0 | Tailwind and esbuild outputs generated under ignored `priv/static/assets/`. |
| `mix format --check-formatted` | 0 | All Elixir and HEEx files formatted. |
| `mix compile --warnings-as-errors` (first) | 0 | Application and locked dependencies compiled. Dependency compiler diagnostics were printed by upstream packages but did not fail the application compile. |
| `mix compile --warnings-as-errors` (second) | 0 | Repeat compilation succeeded without source changes or downloads. |
| `mix test` | 0 | `Result: 5 passed`; includes endpoint status/marker contract. |
| `test/scripts/verify_foundation_test.sh` | 0 | 5 cases passed: readiness, bad status, missing marker/occupied unrelated service, stopped connection, and bounded timeout. |
| `git diff --check` | 0 | No whitespace errors. |

## Regression-detection proof

A disposable project under `/private/tmp` changed only the endpoint test expectation from `Football Player Market` to `Definitely Missing Marker`. The implementation worktree was not modified. `mix test` reported `4/5 passed`, one `Assertion with =~ failed`, and exited 2. The normal worktree suite was rerun successfully.

## Real HTTP lifecycle

The lifecycle ran without starting or contacting PostgreSQL or Redis:

1. `mix phx.server` bound Bandit to `127.0.0.1:4000`.
2. `./scripts/verify_foundation.sh` exited 0 in 0 seconds.
3. A direct curl recorded HTTP 200 and found `Football Player Market`.
4. Foreground interrupt stopped the VM; the post-stop curl failed as required and `lsof` found no listener. Observed shutdown/release time was under 1 second, below the 10-second limit.
5. A second `mix phx.server` start and oracle invocation exited successfully; the second foreground stop also released the port.

## Isolated clean-copy verification

An isolated source copy at `/private/tmp/task001-clean.u9pozv` was created without `.git`, `_build/`, `deps/`, or `priv/static/assets/`. It then executed the documented preparation, asset build, two compilation passes, `mix test`, shell verification tests, start/probe/stop, restart/probe/stop, and post-stop connection check. Every required command exited 0; both runtime probes reported status 200 and the marker in 0 seconds. Source hashes before and after preparation/build/test matched exactly:

```text
05da3e43397e0f922f31abdc01cf4a2a1f36efe6
```

This isolated copy was used because the implementation is intentionally uncommitted; the user expressly prohibited a commit, push, or PR during development.

## Security, scope, and architecture review

- Development and test endpoints bind to IPv4 loopback. The production release template retains Phoenix's production runtime configuration and is outside the local TASK-001 oracle.
- No application-specific credentials or machine-specific paths are present. Generated `postgres` values are inactive development/test placeholders; Repo is not supervised and no database alias runs.
- `.gitignore` excludes Mix outputs, dependencies, generated assets, environment files, editor files, logs, and credential-bearing local configuration.
- `mix.lock` is present and `mix deps.get --locked` succeeds.
- `FootballMarket.Repo` remains as the TASK-002 contract, but `FootballMarket.Application` does not supervise it. Tests do not start SQL Sandbox, and no migrations or persistent entities exist.
- Searches found no Oban, Redis, OpenAPI, JWT/authentication, provider, catalog, valuation, trading, audit, mailer, or LiveDashboard implementation.
- The only public application route is the presentation-owned `GET /`; no speculative domain, worker, cache, or adapter namespaces were created.
- TASK-001 contributes the compiling/testable application baseline to CP1. CI, SonarCloud, authentication, OpenAPI, API keys, and catalog remain assigned to later tasks.

## Remaining gate

T021 remains unchecked. The constitution requires QA and final review in fresh independent sessions, and existing reports describe the pre-feedback non-implementation state and end in `Verdict: FAIL`. Development cannot truthfully replace those independent verdicts. QA must now rerun the commands and lifecycle below against this implementation; final review follows only after QA passes.

## Feedback-cycle 2 verification

Development removed the incomplete `ecto.setup` and `ecto.reset` aliases from `mix.exs` and changed the specification lifecycle status to `Review Ready`. The full direct suite was rerun on 2026-09-13 under the exact pinned toolchain: locked dependency preparation, asset setup/build, formatting, two warning-as-error compiles, five ExUnit tests, five shell-oracle tests, and `git diff --check` all exited 0.

For clean-checkout acceptance, development created `/private/tmp/task001-pending-diff.YE1r7s/source` from the NUL-delimited output of `git ls-files --cached --others --exclude-standard`. This included the complete pending feature diff and excluded ignored `_build/`, `deps/`, and `priv/static/assets/`. Fresh preparation, asset build, formatting, two compilation passes, `mix test`, shell-oracle tests, and `mix precommit` all passed in that snapshot.

The isolated wrong-marker mutation exited 2 with one `Assertion with =~ failed` and `Result: 4/5 passed`. The restored snapshot then completed two real HTTP lifecycle cycles: readiness in 5s and 4s respectively, HTTP 200 plus the marker, shutdown in 1s each, post-stop curl exit 7, and no remaining port-4000 listener. The final lifecycle result was `ISOLATED_PENDING_DIFF_LIFECYCLE=PASS`.

This snapshot is the required pre-publication acceptance fixture. A clone containing only current `HEAD` is deliberately not the fixture because the user prohibits development from committing and assigns Git publication to Agentflow only after independent QA and final review pass.

After updating the required development handoff, a final complete snapshot was created at `/private/tmp/task001-final-pending-diff.zc9mMf/source` by the same tracked-plus-nonignored procedure. It contained 186 source files with ignored build artifacts absent. Fresh locked preparation, asset setup/build, two warning-as-error compiles, and `mix precommit` passed; ExUnit again reported 5 passed. This final snapshot confirms that the handoff-bearing pending diff is self-contained.
