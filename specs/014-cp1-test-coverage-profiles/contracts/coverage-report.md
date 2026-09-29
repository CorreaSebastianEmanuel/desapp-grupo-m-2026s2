# Contract: CP1 Coverage Report

```text
mix test.cp1_coverage
```

The command runs complete safe unit and integration profiles in coverage mode. It needs valid local prerequisites, inventory, HEAD, and no untracked non-generated input; it never requires a clean worktree or pre-QA commit.

The committed exact path/module inventory derives Mix `:ignore_modules`. Native Mix executable-line coverage produces source HTML; the aggregate report provides executed/total executable lines, percentage, and executed/unexecuted detail for every included source. Test, generated, dependency, third-party, and inventory-excluded modules contribute zero lines. Threshold is `0` and informational.

Manifest fields: base HEAD, complete binary-diff SHA-256, inventory SHA-256, tool versions, profile receipts/counts, line totals, and report paths. The binary diff includes every tracked execution input, with only the active feature's generated post-execution QA/review artifacts (`qa-report.md`, `review-report.md`, and `handoffs/`) excluded. Empty diff is `committed revision`; nonempty diff is `working-tree snapshot`. Artifacts are staged outside the checkout and fingerprint/scope/safety-validated before atomic ignored publication. Any failure or changed execution snapshot publishes nothing.
