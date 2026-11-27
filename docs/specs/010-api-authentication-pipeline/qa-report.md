# QA Report: API Authentication Pipeline

Date: 2026-09-26

Scope: independent review of the working-tree diff against `spec.md`, `plan.md`, and `tasks.md`, with architecture/development handoffs and current backlog state. No `backlog/feedback/TASK-010.md` exists. Product-debate, workflow-log, and prior QA/review artifacts were not inspected.

## Evidence matrix

| Criteria | Evidence | Result |
|---|---|---|
| US1; FR-002–007, FR-009–010; SC-001–002 | Focused suite exercised valid mixed-case Bearer, missing/blank/malformed/unsupported/repeated/coalesced credentials, invalid and genuinely expired JWTs, exact actor attribution, generic `401`, `WWW-Authenticate: Bearer realm="api"`, absent actor, and protected-probe non-execution. Command result: `15 passed`. Source inspection confirms token bytes go unchanged only to `Accounts.validate_access_token/1`. | PASS |
| US2; FR-002–008; SC-001–002 | Focused suite exercised active, unknown, malformed, repeated, and coalesced API keys, dual credentials, committed revocation on the next request, and continued use of a second key. Exact account/key actor attribution and non-execution on rejection were asserted. Command result included in `15 passed`. Source inspection confirms delegation only to `Accounts.identify_api_key/1`. | PASS |
| US3; FR-001, FR-006–008, FR-011, FR-013; SC-003, SC-006 | Test router covers public/protected policy behavior, public header ignoring, and no actor/validator call. Route/source audit passed. Independent command `MIX_ENV=test mix run -e ...` returned `production_api_routes: []`; no production `/api` endpoint exists, so live HTTP requests are not applicable. `rg` found supported-header parsing only in the shared Plug and none in controllers. | PASS |
| Actor contract; FR-004–005 | `%AuthenticatedActor{}` has enforced `account_id`, `authentication_method`, and `credential_id` fields only. Exact-shape test passed for both authentication methods. | PASS |
| Failure equivalence and privacy; FR-007–010, FR-012, FR-014; SC-002, SC-004 | Security tests compare stable status/body/challenge; inspect responses, actor, captured logs, query logs, exception convergence, and complete telemetry metadata using sentinels. No credential or identity leakage was found; one event per protected decision contains only policy, outcome, method, and duration. | PASS |
| Performance; SC-005 | `MIX_ENV=test mix test --include performance ...`: JWT `40/40 below 1s, p95=96us`; API key `40/40 below 1s, p95=1188us`. | PASS |
| Scope and boundaries; FR-003, FR-013, FR-015; SC-007 | Diff inspection found one web Plug, one Accounts value, two router policies, tests, and ADR only. No schema, dependency, authorization, lifecycle, browser/LiveView, rate-limit, OpenAPI, controller parsing, direct Repo access, or JWT decoding was introduced. | PASS |
| Repository gates | `mix format --check-formatted`; `MIX_ENV=test mix compile --warnings-as-errors`; focused suite `15 passed`; default suite `128 passed, 3 excluded`; opt-in performance suite `1 passed`; `git diff --check`. The chained command exited `0`. | PASS |

## Adversarial notes

- Repeated raw header occurrences and simultaneous credential types are counted before validation and fail closed.
- Non-binary direct Plug input fails closed; malformed wire bytes rejected before Plug remain transport-level behavior per the approved plan.
- Validator exceptions/throws converge to the same response without cause rendering.
- T004, T008, T013, and T018 lack historical red-phase evidence, but this does not invalidate current acceptance behavior; final independent checks are green.

Verdict: PASS
