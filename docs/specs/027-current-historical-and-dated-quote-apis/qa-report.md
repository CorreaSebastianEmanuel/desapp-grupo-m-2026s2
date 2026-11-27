# Independent retrospective QA — TASK-027

Executed 2026-10-26 by an independent QA session after the reconciliation
artifacts were frozen. This verifies the current merged implementation and its
backfilled contract. It does not assert that an original Agentflow run or its
product/design/development stages occurred.

Baseline: `0e417ebe752d0d23d840e6ac48c1326b330e7ee6`, branch
`repair-agentflow-task-history`. No application, test, configuration, migration,
asset or CI code differs from that baseline. TASK-029, TASK-033 and TASK-055's
existing scraping artifacts are unchanged. Canonical artifact hashes and the
test inventory were checked again after execution and remained unchanged.

## Executed evidence

Both retrospective manifests declare the same commands. They were executed
manually once against this shared frozen code, without reusing development or
historical receipts. Environment:

```sh
PATH=/tmp/task027-elixir/bin:$PATH
ERL_FLAGS='+S 4:4'
POSTGRES_PORT=55427
REDIS_PORT=6379
MIX_ENV=test
MIX_TEST_PARTITION=agentflow_backfill_qa_20261026
```

Prerequisite: run `mix test.prepare` before profile discovery on a new partition.
The first unit attempt exited 1 after 6.71 seconds with
`inventory-or-service-prerequisite`; its new database did not yet exist. Database
preparation then created and migrated the isolated partition through
`20261026000000`, exit 0. The corrected attempts below passed without code changes.

| Command | Result | Seconds |
|---|---|---:|
| `mix format --check-formatted` | exit 0 | 0.58 |
| `mix compile --warnings-as-errors` | exit 0 | 0.39 |
| `node tools/openapi/validate.mjs priv/static/openapi.json` | exit 0 | 0.17 |
| `sh scripts/test_profile.sh unit` | 570 expected/discovered/executed/passed | 106.11 |
| `sh scripts/test_profile.sh integration` | 531 expected/discovered/executed/passed | 376.41 |
| `sh scripts/test_profile.sh e2e` | 2 expected/discovered/executed/passed | 24.19 |

The 1,103-case total comprises unit: 232 ExUnit, 313 Python, 8 Node, 17 shell;
integration: 522 ExUnit, 9 shell; E2E: 2 ExUnit browser/worker journeys. Integration
also exercised its invocation-owned service lifecycle and committed-race
partitions. Actual profile receipts bind inventory SHA-256
`a1aa58ed9efa709aba82a0093b60f0a1dd0621ec782dcc6784e71eb5dbe06c06`.

Local command logs, exit/duration records, fresh native profile receipts, and the
frozen-artifact snapshot are in `/tmp/agentflow-backfill-qa-20261026/`. The initial
failed attempt remains in `unit-initial-unprepared.log` and its result record.
These are current local evidence, not historical or Agentflow stage receipts.

## Acceptance assessment

- FR-001 and FR-005: the seven quote HTTP cases exercise JWT/API-key access,
  rejection of missing/invalid/mixed credentials before validation, strict
  malformed/duplicate/nested date handling, UUID rejection, explicit missing
  player/quote outcomes and storage-unavailable responses.
- FR-002 and FR-003: the five reader cases cover initial issuance, immutable
  distinct records, authoritative sequence ordering even across timestamp
  differences, inclusive UTC day, leap days, gap carry-forward and date bounds.
- FR-004: HTTP assertions check the exact field set, decimal-string precision,
  preserved strategy/configuration/mapping/calculation metadata, timestamps and
  nullable issuance fields.
- FR-006: integration includes six shared OpenAPI contract cases and browser
  documentation checks. The protected-state snapshot assertion and source
  inspection confirm these local reads introduce no provider, job, calculation
  or financial write. Full profiles supply regression evidence for retained
  baseline behavior; the two E2E journeys are not claimed as quote-specific tests.

Source review confirms the web/domain/persistence boundary in the retrospective
plan. Provenance accurately distinguishes direct-main commit `689d917` from
merged maintenance PR #54 and avoids inventing an original implementation PR,
branch execution or run identifier. Canonical ownership is explicit and does not
alter the historical delivery record. No unresolved QA obligation remains for
this retrospective contract. Final review and completion remain separate gates.

Verdict: PASS
