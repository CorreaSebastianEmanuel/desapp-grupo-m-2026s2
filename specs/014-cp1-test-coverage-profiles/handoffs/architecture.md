# Architecture Handoff

## Decisions

- Approved provenance is broad: base HEAD plus complete tracked `git diff HEAD`; reject untracked non-generated inputs; label nonempty diff as working-tree snapshot. Do not restore a clean-tree rule. ADR 0009 records this.
- One exact committed source/module inventory derives native Mix coverage exclusion. Native Mix has module HTML, not aggregate `index.html`; a small test publisher creates aggregate totals/source links.
- Profile membership is exhaustive default ExUnit discovery plus one direct `:unit`/`:integration` tag. Preserve legacy baseline/performance exclusion; selected profiles include their own performance tests.
- Treat all child output as untrusted. Use private capture and runner-owned allowlisted receipts only; remove raw `cat`, assertion output, and browser `IO.puts`.

## Risks

- Broad provenance intentionally changes for unrelated tracked edits; this is the accepted truthfulness cost.
- Node 24, locked packages, and Chromium are required integration prerequisites. Fail safely before browser-command exception formatting.
- Receipt/scope parsing must use controlled evidence, never framework text released to users.

## Implementation guidance

- Begin with contracts for output sentinels, missing prerequisites, exact-one tags, actual native scope, staged/unstaged/untracked mutation, and no publication on failure.
- Remove credential-bearing browser output from ExUnit assertions/output.
- Stage outside the repository until fingerprint, scope, receipt, and artifact checks pass. Do not add CI coverage enforcement, Sonar import, provider calls, or production changes.
