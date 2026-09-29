# Quickstart: CP1 Test and Coverage Profiles

Use the pinned Erlang/Elixir toolchain and isolated PostgreSQL test service documented in the repository README. For integration install Node 24, then prepare browser tooling:

```bash
npm ci --prefix tools/openapi
tools/openapi/node_modules/.bin/playwright-core install --with-deps --only-shell chromium
```

Run focused checks:

```bash
mix test.unit
mix test.integration
```

Each command emits a safe receipt only after complete audited execution. Integration includes the browser regression; missing Node, packages, or Chromium is a nonzero safe prerequisite result, never a skip. See [test profile contract](contracts/test-profiles.md).

Generate coverage:

```bash
mix test.cp1_coverage
```

After both coverage-mode profiles succeed, open the published `report.html` under `cover/cp1/` for executable-line totals and source detail. `manifest.json` records base revision, diff/inventory hashes, profile receipts, and label. A nonempty diff is a working-tree snapshot; no pre-QA commit is required. See [coverage contract](contracts/coverage-report.md).

Controlled contract fixtures must prove nonzero safe failure for invalid membership, skipped/undiscovered/interrupted execution, missing browser prerequisites, unsafe capture, scope mismatch, snapshot mutation, and report-generation error—with no falsely attributed publication.
