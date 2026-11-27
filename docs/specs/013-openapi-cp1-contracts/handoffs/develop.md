# Development handoff: TASK-013

## Changes and decisions

- Published the two existing protected catalog GET operations through public `/docs` and `/openapi.json`. The page uses pinned local Swagger UI assets and one memory-only credential selector. Catalog and authentication runtime behavior is unchanged. See `priv/static/openapi.json`, `priv/static/api-docs/`, and the web route/view files.
- Replaced the list and detail 200 examples with matching fictional Premier League data. Added a regression test that checks both examples against `Catalog.supported_leagues/0` and the fictional names. The test failed on the prior NWSL examples, then passed after correction.
- Updated `quickstart.md` with the pinned toolchain path used here. All 26 checked tasks were reconciled against their named files; 22 named implementation files exist. Vendored asset hashes match `priv/static/api-docs/ASSETS.md`.

## Command outcomes

With `/tmp/task13-elixir-v1.20.3-otp-29/bin` first on `PATH`: `./scripts/check_toolchain.sh` passed (Elixir 1.20.3, OTP 29.0.6); `npm ci --prefix tools/openapi`, the OpenAPI validator, and `npm test --prefix tools/openapi` passed (2 tests). Focused ExUnit contract/browser tests passed (7 tests), including JWT, API key, 401, spec/asset failures, and browser discovery in 639 ms. `mix format --check-formatted` and `MIX_ENV=test mix compile --warnings-as-errors` passed. `MIX_ENV=test mix test` passed (175 tests, 4 excluded). `git diff --check` passed.

## QA guidance and residual risk

Run the commands in `quickstart.md` with the pinned toolchain first on `PATH`. Inspect the two 200 examples for supported `PL` league data, then use the focused browser test to verify single-header credential switching and the empty-credential 401. The `/tmp` toolchain location is workspace-specific; obtain the same versions if it is unavailable. No other known implementation risk remains.
