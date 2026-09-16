# Data Model: Continuous Integration Quality Baseline

This feature introduces no product entity, database table, migration, cache entry, or durable business state.

## Validation-only concepts

### Quality Run

- **Revision**: immutable Git commit SHA checked out once per job
- **Event**: pull request targeting `main`, or push to `main`
- **Toolchain**: Elixir 1.20.3 and Erlang/OTP 29.0.3
- **Setup state**: checkout, toolchain, locked dependencies, ephemeral PostgreSQL readiness
- **Categories**: formatting, warnings-as-errors compilation, unit tests
- **Conclusion**: success only if setup and all three categories succeed; failure otherwise; an older superseded run may be cancelled

### Category Result

- **Name**: exactly one of `formatting`, `warnings-as-errors`, `unit-tests`
- **Revision**: same SHA as its parent Quality Run
- **Outcome**: pass or fail
- **Diagnostics**: command output sufficient to identify the category and concrete formatter difference, warning, or failed test

## Invariants

- All category results in a run reference the same checked-out revision.
- Formatting is read-only.
- Project-owned application, test-support, and test-file warnings are fatal.
- The unit-test category uses the unfiltered default ExUnit scope and must observe the sentinel's execution marker.
- A setup or category failure prevents a successful overall conclusion.
- No state transition writes product data; the PostgreSQL service is ephemeral test infrastructure.

## State transitions

```text
queued -> running -> success
                  -> failure
                  -> cancelled (only when superseded by a newer run in its concurrency group)
```

A cancelled older run is not success evidence for the newer revision.
