# TASK-013 validation quickstart

Use the pinned Elixir/OTP toolchain, PostgreSQL test service, Node 24/npm, and `/usr/bin/chromium` (or set `CHROMIUM_PATH`). In this workspace, Elixir 1.20.3/OTP 29 is installed at `/tmp/task13-elixir-v1.20.3-otp-29/bin`; put it first on `PATH` before running Mix. Prepare the repository's existing Hex dependencies and test database as described in `README.md`. The UI bundle is tracked locally; the browser needs no CDN.

## Machine contract and focused acceptance

Run from the repository root:

```bash
export PATH=/tmp/task13-elixir-v1.20.3-otp-29/bin:$PATH
./scripts/check_toolchain.sh
npm ci --prefix tools/openapi
node tools/openapi/validate.mjs priv/static/openapi.json
npm test --prefix tools/openapi
MIX_ENV=test mix test test/football_market_web/openapi_contract_test.exs test/football_market_web/openapi_browser_test.exs
```

The Node tests validate OpenAPI 3 and reject malformed/incomplete disposable copies. ExUnit compares `/openapi.json` with the tracked file, CP1 router methods and metadata, exact security alternatives, parameters, responses, schema fields, examples, and live status/body behavior. Its isolated browser test creates temporary Accounts credentials and catalog fixtures in the SQL sandbox, starts a loopback Bandit server, opens `/docs` in Chromium, and times discovery under three minutes. It exercises JWT → API key → JWT and empty-credential 401, inspects only credential-header presence, checks visible panels and browser storage for accidental exposure, and simulates broken contract and UI asset loads. `try`/`after` in ExUnit and `finally` in Node close the server/browser on failure. No credential file or screenshot is created.

## Full regression

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test
```

## Public walkthrough

Start `mix phx.server`, open the README's `/docs` address, and within three minutes find the two player GET operations, the Bearer JWT and API-key choices, five list parameters, success/error responses, and response examples. Open `/openapi.json` without a credential. With a valid local test or development credential, try one operation per method; the selected method alone should be sent. Leave the input empty and execute a catalog request: expect 401, `{"error":{"code":"unauthenticated"}}`, and `WWW-Authenticate: Bearer realm="api"`. Stop the development server afterward. The focused browser test performs the same credential-path check on an isolated running server without printing credential values.
