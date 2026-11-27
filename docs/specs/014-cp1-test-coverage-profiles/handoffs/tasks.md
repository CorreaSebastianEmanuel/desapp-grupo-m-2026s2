# Tasks Handoff

## Resolutions

- The human-approved broad provenance policy is now explicit: hash `HEAD` plus the complete tracked binary diff; reject non-generated untracked inputs; label nonempty diffs as working-tree snapshots. No clean-tree or pre-QA commit is required.
- `config/cp1_coverage_inventory.exs` is the sole coverage-scope authority. It must derive Mix exclusions; fixture inventory data cannot create a second scope definition.
- Native Mix coverage reports executable lines and per-module HTML; the custom publisher supplies aggregate totals and source links, not a fictional native `index.html`.

## Remaining risks

- The exhaustive direct-tag audit will expose any pre-existing unclassified default-discovered test module; do not weaken it to preserve legacy behavior.
- Node 24, locked packages, and Chromium remain mandatory integration prerequisites. Capture their failures before any child text is released.
- Snapshot publication has several time-of-check/time-of-use boundaries; retain every revalidation and discard staging on any mismatch.

## Sequencing guidance

Establish exact-one classification and safe profile receipts before using them for CP1 regressions or coverage exports. Implement coverage only after both receipts are trustworthy. Preserve the byte-for-byte baseline and leave independent QA and final review for fresh sessions.
