# Independent QA — TASK-013

Reviewed the current specification, plan, contract design, implementation, tests, TASK-013 feedback, and working tree. This verification used the current checkout, including the four pending CI/browser-tool changes. No implementation file was edited.

## Acceptance evidence

| Gate | Evidence |
| --- | --- |
| Public publication and contract scope (FR-001–003, FR-014) | The pinned OpenAPI parser accepted `priv/static/openapi.json` as OpenAPI 3.0.3. Endpoint tests verify public `/docs` and `/openapi.json`; the contract and router expose exactly the two protected catalog GET operations. The document declares the five list parameters, required detail UUID, response statuses, exact public schemas, and no future product operation. |
| Interactive discovery and authorization (FR-002, FR-004–005, SC-001–002, SC-005) | The isolated Chromium test discovered both operations, parameters, statuses, and examples in 616 ms. It executed JWT list → API-key detail → JWT list against a live loopback server, compared response bodies with endpoint results, and asserted only the selected credential header. An empty credential returned 401; broken contract and UI asset loads produced visible errors. It checked request URLs, browser storage, rendered text, and off-origin requests for credential exposure. |
| Catalog and failure fidelity (FR-006–013, SC-003–004) | Contract tests compare route metadata, security alternatives, parameters, response codes, required fields, nullability, examples, and live response shapes. They cover populated and empty pages, detail, all five list error codes, error priority, authentication before catalog access, the exact 401 body/challenge, malformed and absent player 404, repeated/mixed credentials, and filter-bound cursor rejection. Disposable contract mutations demonstrate drift detection. The two 200 examples use matching fictional Premier League data, resolving recorded TASK-013 feedback. |
| Asset and CI readiness (FR-015–016) | All five vendored asset SHA-256 values match `ASSETS.md`. The current workflow installs Node, OpenAPI dependencies, and Playwright's Chromium shell before the unit test step; its fixture checksum and seven workflow-probe tests pass. The Playwright shell install command accepts `--only-shell chromium` in a dry run. Production changes remain at the web/static publication boundary; existing catalog and authentication implementation was not modified. |

## Commands run

- `./scripts/check_toolchain.sh` — passed: Elixir 1.20.3, OTP 29.0.6.
- `npm ci --prefix tools/openapi`; `node tools/openapi/validate.mjs priv/static/openapi.json`; `npm test --prefix tools/openapi` — passed, 2 Node tests.
- `mix format --check-formatted`; `MIX_ENV=test mix compile --warnings-as-errors` — passed.
- `MIX_ENV=test mix test test/football_market_web/openapi_contract_test.exs test/football_market_web/openapi_browser_test.exs` — 7 passed.
- `MIX_ENV=test mix test` — 176 passed, 4 excluded.
- `sha256sum -c test/ci/fixtures/quality-baseline.sha256`; `python3 -m unittest test/scripts/workflow_artifact_probe_test.py`; `git diff --check` — passed, including 7 Python tests.

Mix's first sandboxed attempt could not acquire its local TCP filesystem lock (`:eperm`); the required commands passed when rerun with that permission. GitHub Actions itself was not run here. The pending CI/browser-tool changes must be included in the feature commit for the passing browser gate to be reproducible on the runner.

Verdict: PASS
