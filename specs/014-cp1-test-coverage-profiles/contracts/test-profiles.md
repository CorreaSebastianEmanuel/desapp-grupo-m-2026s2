# Contract: CP1 Test Profiles

```text
mix test.unit
mix test.integration
```

Both commands independently audit and run their complete selected classification.

| Item | Contract |
|---|---|
| Population | Default-discovered `test/**/*_test.exs` ExUnit modules. |
| Membership | One direct module `:unit` or `:integration` tag, never both. `:performance` is allowed only as an additional tag. |
| Unit | Isolated behavior; no HTTP/router/public-contract/browser or Ecto/PostgreSQL assertion. |
| Integration | Any HTTP, public-contract/browser, or persistence-boundary assertion. |
| Rejections | Missing/duplicate/unknown/indirect/test-level profile tag, skip, unreadable file, unstable identity, or empty scope. |

Success emits only allowlisted profile/count metadata. Failure is nonzero and emits only a fixed safe category (`audit`, `node-runtime`, `browser-prerequisite`, `discovery`, `test-failure`, `skipped`, `incomplete`, or `safe-capture-failure`) and optional predefined behavior ID. Raw child output, test names, stacktraces, arguments/environment, secrets, tokens, and verification material are never emitted or retained.

Integration validates Node 24, packages, and Chromium before execution. An absent prerequisite fails rather than skipping the browser regression.
