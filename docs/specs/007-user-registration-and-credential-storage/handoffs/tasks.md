# Tasks Handoff: TASK-007

## Resolutions

- The `{:error, changeset}` contract is made safe by requiring a field-error changeset built without raw password parameters. This closes the gap between returning validation feedback and the specification's non-disclosure rule.
- Normalization is both domain behavior (trim/lowercase before validation) and a PostgreSQL functional-index invariant. The index, not any duplicate pre-check, decides concurrent collisions.
- This remains an internal Accounts capability. No HTTP, LiveView, OpenAPI, login, token, API-key, or profile work is planned.

## Remaining risks

- `argon2_elixir` has a native build and deliberate memory cost; validate locked dependency compilation and confine reduced parameters to `test`.
- The rollback test must force the credential operation to fail through the Accounts transaction, not merely test an unrelated `Ecto.Multi`.
- Safe public projections do not alone prevent inspection leaks; retain the credential schema's hash redaction and test result/error/inspect shapes.

## Sequencing guidance

Build setup and persistence constraints first, then complete P1 as the MVP. Add P2 validation and P3 conflict handling after the shared registration path exists; serialize changes to `Accounts` while allowing separate test-file work in parallel. Finish with focused and full-suite verification plus the quickstart evidence.
