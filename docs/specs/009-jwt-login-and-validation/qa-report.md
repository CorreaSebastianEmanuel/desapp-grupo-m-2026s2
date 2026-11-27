# QA Report — TASK-009 JWT Login and Validation

Date: 2026-09-24  
Scope: independent acceptance of the current working-tree diff against `spec.md`, `plan.md`, `tasks.md`, architecture/development handoffs, and current human feedback.

## Evidence matrix

| Acceptance area | Direct evidence | Result |
|---|---|---|
| US1 / FR-001–004: successful credential login, normalized email, exact password, generic failures, no token on failure | `MIX_ENV=test mix test test/football_market/accounts/authentication_test.exs test/football_market/accounts/authentication_security_test.exs test/football_market/accounts/password_credential_test.exs` → 16 passed. Tests exercise case/whitespace normalization, untrimmed password semantics, unknown/wrong/blank/whitespace/malformed/non-text inputs, and configuration failure with the same `{:error, :authentication_failed}` result. | PASS |
| US1 / FR-003,005–007: one signed token, required identity/time/issuer/audience claims, exact 900-second lifetime, unique JTI | Focused suite verifies the sole success shape `%{access_token: token}`, all six claims and UUID formats. A fixed-clock loop performs 1,000 successful logins and asserts 1,000 distinct production-generated JTIs. | PASS |
| US2 / FR-008–010: validated identity only after complete trust checks | Focused suite accepts an unchanged issued token and returns only account/JTI. It rejects non-binary, empty, malformed, altered, unsigned, wrong-key, HS512, wrong issuer/audience, malformed UUID/time, and future `nbf` inputs with `{:error, :invalid_token}`. Each required claim (`sub`, `jti`, `iat`, `exp`, `iss`, `aud`) is independently deleted and rejected. | PASS |
| US3 / FR-006,011: time boundaries | Controlled-clock assertions accept at `exp - 1`, reject exactly at `exp`, reject future `iat`, and reject future optional `nbf`; issuance asserts `exp - iat == 900`. Zero skew is required by configuration validation. | PASS |
| FR-012–014 and human feedback: non-disclosure, safe configuration/provider failures, complete regression coverage | Sentinel test covers password/hash, email/account, signing key in raw/Base64 form, issued/forged complete tokens, verified/unverified account IDs and JTIs across captured logs, success/failure telemetry, credential/authentication inspection, safe failure results, and configuration/provider exception paths. Only the specified successful login token and successful validation identity projection are allowed. Credential inspection redacts hash and owner ID. | PASS |
| Validation independence | Telemetry query probe observes no repository query during successful standalone validation. Source inspection confirms verification stays in `Accounts.Authentication`; no account-state lookup is performed. | PASS |
| SC-005 performance | `MIX_ENV=test mix test --include performance test/football_market/accounts/authentication_performance_test.exs` → 1 passed; warm nearest-rank p95: login 3,167 µs, validation 63 µs (Darwin, OTP 29, 8 schedulers, 100/1,000 samples). Both are below one second. | PASS |
| FR-015 / SC-007 scope boundary | Working-tree diff and targeted search of `lib/football_market_web/router.ex` and `priv/repo/migrations/` show no login/JWT controller, route, plug, migration, UI, authorization, refresh, logout, revocation, lockout, or throttling addition. The only matching migration term is the pre-existing API-key `revoked_at`. | PASS |
| Build and regression quality | `mix format --check-formatted` → exit 0; `git diff --check` → exit 0; `MIX_ENV=test mix compile --warnings-as-errors` → exit 0; `MIX_ENV=test mix test` → 82 passed, 2 performance-tagged tests excluded, 0 failures. | PASS |

## Runtime endpoint decision

No HTTP exercise was applicable. The plan defines an internal Accounts context contract and explicitly excludes HTTP routes; diff inspection confirms that TASK-009 neither exposes nor changes an endpoint. Starting Phoenix and curling unrelated routes would not test this feature.

## Residual risk

Tasks T008, T014, and T019 request historical red-phase executions and remain unchecked. That history cannot be recreated after implementation; this is a process-evidence limitation, not a current behavioral failure. Current focused, adversarial, full-suite, leak, boundary, uniqueness, and performance evidence all pass.

Verdict: PASS
