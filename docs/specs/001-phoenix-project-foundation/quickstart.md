# Quickstart Validation: Phoenix Project Foundation

This guide defines the validation sequence the implementation README must expose. It is not evidence that the commands already pass.

## Prerequisites

- Git
- Erlang/OTP 29.0.3
- Elixir 1.20.3 with Mix, Hex, and Rebar
- Network access for the preparation step
- Port 4000 free on loopback
- PostgreSQL and Redis stopped or unavailable to prove the TASK-001 boundary

Confirm `elixir --version` reports the supported versions before continuing. An unsupported version is a failed prerequisite check, not an implicit compatibility claim.

## Isolated fixture

Use a fresh clone of the feature branch in a temporary directory. Confirm `_build/`, `deps/`, and generated asset outputs are absent. Do not copy `.env` files, credentials, or untracked artifacts into it.

## Lifecycle

From the clone root, run the README's commands in this order:

1. **Prepare**: install Hex/Rebar if absent, fetch locked Mix dependencies, and install/build Phoenix-managed assets if required. Preparation must be the only phase that downloads packages.
2. **Compile**: run `mix compile --warnings-as-errors`. It must exit zero without fetching packages or changing source.
3. **Test**: run `mix test`. At least one endpoint test must execute and assert the contract in `contracts/foundation-http.md`.
4. **Start**: run `mix phx.server` in the foreground with the documented development environment. It must not require PostgreSQL or Redis.
5. **Verify reachability**: for no more than 30 seconds, request `http://127.0.0.1:4000/`; require status 200 and body marker `Football Player Market`. A plain error page is a failure.
6. **Stop**: send the documented foreground interrupt. Require process exit within 10 seconds, then confirm the HTTP request no longer connects.
7. **Restart**: repeat start and reachability once, then stop again.

## Regression-detection proof

In a disposable second clone or copy, change only the expected response marker in the endpoint test to a string the page does not contain. Run the same `mix test` command and require a nonzero exit with a visible failed assertion. Discard the disposable copy; the implementation worktree must remain unchanged.

## Failure cases

- Occupied port, unavailable dependency, unsupported toolchain, compilation error, test failure, or failed HTTP oracle must produce a visible non-success result.
- A server process that remains alive but never satisfies the HTTP contract is unhealthy and fails after 30 seconds.
- A stopped parent whose child retains port 4000 fails shutdown validation.
- No validation step may silently start PostgreSQL, Redis, or another external service.

## Expected evidence

Capture commands, versions, exit statuses, discovered test count, HTTP status/marker, shutdown timing, and successful restart. One complete clean lifecycle and one intentional-failure run are the minimum TASK-001 evidence; independent QA repeats the README sequence.
