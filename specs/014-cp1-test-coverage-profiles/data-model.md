# Data Model: CP1 Test and Coverage Profiles

No Ecto schema or product data changes are introduced.

| Record | Fields and rules |
|---|---|
| Test Profile | `name` is `unit` or `integration`; sorted unique discovered module IDs; positive expected/completed evidence; safe receipt only. Every module belongs exactly once. |
| Supported Environment | Pinned BEAM/PostgreSQL prerequisites; integration additionally requires Node 24, locked `tools/openapi` packages, and Chromium. |
| Coverage Source Inventory | Versioned exact `{source_path, elixir_module}` allowlist, rationalized exclusions, content SHA-256. It derives native reporting scope. |
| Working-Tree Snapshot | Base HEAD, SHA-256 of complete binary staged/unstaged diff, untracked-input policy, and `committed revision`/`working-tree snapshot` label. |
| Coverage Report | Two successful safe profile receipts; executable-line numerator/denominator, per-source executed/unexecuted detail, inventory/snapshot/tool provenance, native HTML links. |

Coverage states are `captured → profiles_succeeded → exports_merged → artifacts_validated → published`. Any failure or fingerprint change becomes `discarded`; nothing is published.
