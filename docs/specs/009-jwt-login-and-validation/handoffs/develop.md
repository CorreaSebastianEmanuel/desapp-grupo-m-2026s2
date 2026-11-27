# Development Handoff: JWT Login and Validation

## Changes

- Completed the current human-feedback regression coverage in `test/football_market/accounts/authentication_security_test.exs`: distinct sentinels now cover passwords, hashes, signing material, complete issued/forged tokens, verified/unverified account IDs and JTIs, and email/account data across logs, successful and failed telemetry, failure results, configuration/provider errors, and inspected internal structures. Successful login and validation projections retain only their explicitly allowed disclosures.
- Added generic-failure cases for blank email, blank password, whitespace-only values, and malformed email.
- Expanded `test/football_market/accounts/authentication_test.exs` to delete and reject each required claim (`sub`, `jti`, `iat`, `exp`, `iss`, `aud`) independently.
- Redacted `user_id` as well as `password_hash` from `PasswordCredential` inspection and covered it in `test/football_market/accounts/password_credential_test.exs`.

## Decisions

- Credential ownership is internal authentication data, so inspected credential structs no longer reveal it. Persistence and successful public account/token projections are unchanged.
- T008, T014, and T019 remain unchecked in `tasks.md`: they require historical pre-implementation failing-test evidence that cannot be recreated honestly after implementation. Every checked task was reconciled against its named files.

## Command outcomes

- Focused authentication/credential tests: 16 passed.
- `mix format --check-formatted`: passed.
- `MIX_ENV=test mix compile --warnings-as-errors`: passed.
- `MIX_ENV=test mix test`: 82 passed, 2 excluded.
- Tagged benchmark: 1 passed; login p95 2,544 µs, validation p95 94 µs (Darwin, OTP 29, 8 schedulers, test Argon2 t1/m8/p1).
- `git diff --check`: passed. Targeted router/migration search found no JWT/login scope additions; matches were limited to the pre-existing API-key migration.

## Residual risks and QA guidance

- Historical red-phase evidence remains unavailable; assess T008/T014/T019 as process evidence, not current behavior.
- Re-run the two focused authentication files, credential tests, the full suite, and tagged benchmark. Specifically verify every sentinel surface, per-claim deletion, exact expiry boundaries, no validation query, and that no route/migration was introduced.
