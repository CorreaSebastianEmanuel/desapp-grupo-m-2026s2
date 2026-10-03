# Contract: CP1 Acceptance Record and Demonstration

## Commands

```sh
python3 scripts/cp1_acceptance.py validate --manifest config/cp1_acceptance.json --receipts <private-directory> --output <staging-directory>
scripts/cp1_demo.sh --receipt <private-receipt-path>
```

Both commands fail closed. Success output contains only an outcome, full candidate SHA, counts, and artifact-relative paths. Failure output contains a fixed category; raw child output and secrets are never released.

## Top-level obligations

The manifest contains exactly: repository accessibility; automated quality build; SonarCloud issue threshold; JWT authentication; OpenAPI 3 publication; minimum persisted catalog model; unit tests; user creation; API-key lifecycle; authenticated player catalog. Supporting regression cases attach to one of these rows and do not create new checkpoint obligations.

## Acceptance rule

Final `PASS` requires a clean committed candidate and ten passing results whose required receipts all identify that full SHA. Missing, failed, skipped, interrupted, canceled, timed-out, undiscovered, unavailable, inaccessible, stale, unsafe, or unpublished evidence is `NON_PASS`. A working-tree snapshot always has overall `NOT PASSING`.

## Sonar receipt

It must identify project `CorreaSebastianEmanuel_desapp-grupo-m-2026s2`, branch `main`, candidate revision, completed analysis ID/link, retrieval timestamp, active profile identities, metric `open_issues`, and integer count 0–9. Any other population or revision is invalid.

## Demo receipt

The harness emits only fixed behavior IDs proving the required security, catalog, and contract journeys. It records two stable seed assertions of 5/5/10/4/20 entities (44 total) and elapsed demonstration time. Credentials exist only in private transient storage, tracing is disabled, and no raw HTTP/SQL/browser transcript is retained.

## Publication

The `main` workflow publishes one artifact named `cp1-acceptance-<full-sha>` containing authoritative `acceptance.json`, rendered `acceptance.md`, and sanitized receipts. The artifact and summary state normal authorization requirements. Unsafe staging is deleted; it is never published.

## Nested evidence and pre-publication staging

The `demo` aggregate receipt includes exactly two full `runs`, each with `schema_version`, `kind`, `status`, `candidate_sha`, `observed`, `reference`, `provider_access`, `seed_assertions`, `elapsed_seconds`, `behaviors`, `provenance`, and `snapshot_sha256`. Committed fingerprints equal SHA-256 of the full candidate SHA; dirty source fingerprints are explicit preflight evidence. Each run must satisfy all 26 behavior observations, the two 44-record invariants, the timing boundary, and provider independence.

The `tests` receipt includes ordered complete `unit` and `integration` profiles with positive audited counts, plus coverage candidate SHA, committed snapshot label, current inventory SHA-256, positive source count, and report reference. Collection additionally validates the coverage manifest, empty committed diff, complete inventory source scope, and every referenced summary page. Directory existence does not establish success.

`python3 scripts/cp1_acceptance.py stage-local --candidate-sha <full-sha> --local-evidence . --output <private-staging>` validates and scans the precise local artifact set before upload. Final validation accepts `--local-evidence <downloaded-directory>` and publishes only scanned receipts and coverage pages beside the record. Non-pass collection still generates a safe ten-row record; unsafe inputs never cross publication boundaries.

## Exact hosted and local identity

Hosted governing runs require the expected workflow name and exact `.github/workflows/quality-baseline.yml` or `.github/workflows/sonarcloud.yml` path, repository identity, full SHA, `main` head branch, `push`/`workflow_dispatch` event, completed status, and successful conclusion. The Sonar workflow name is `SonarCloud analysis`; its job label is not the workflow identity.

Any committed demo/test PASS requires `--local-evidence`, two matching full demo receipts and matching profile/coverage receipts. A missing, inaccessible, stale, or inconsistent local file invalidates acceptance. Generated rows link the published demos and coverage summary directly.

Coverage publication uses only the manifest, `report.html`, and inventory-declared `sources/*.html` line-status pages. Native Mix pages containing source code and incidental receipt/native files are excluded; this avoids mistaking source-level credential field names for runtime captures. All retained JSON is parsed and scanned recursively; all retained HTML and observations are scanned for unsafe values, including quoted JSON credential keys. Referenced evidence JSON is inspected before acceptance. The repository's public OpenAPI schema is source documentation and contains no retained credential values.
