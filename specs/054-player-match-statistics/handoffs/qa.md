# QA handoff — TASK-020 amended CI PostgreSQL parity

Fresh T033 verification passed all 19 manifest checks and four independent adversarial acceptance/migration cases. Full regression: 216 passed. Catalog focused races passed twice, six tests each. Profiles audited 22/36 files; informational integration coverage remains 93.17%; combined publication completed. Exact commands, declared environments and logs: qa-evidence/ci-parity/qa/results.json and supplemental-results.json. No developer receipt was overwritten.

The workflow diff changes exactly one PostgreSQL image line. Parsed CI/local parity and unchanged fingerprint enforcement pass all 13 focused contracts. The healthy local container uses the exact planned 17.6 tag/digest; SQL confirms server_version 17.6 and both statistics migrations applied. Fresh generated-column challenges reject legacy collisions/blanks without changing originals and recompute valid keys with immutable protections active.

Sources remained unchanged across all checks (195 hashed files), and the real Git index was preserved. Coverage used an isolated intent-to-add index; logs remained outside the repository until coverage completed. No implementation edits, publication or merge.

Blockers: none. T034 must review this fresh evidence and the minimal amendment before authorized publication. Green remote CI on the updated PR head remains required before delivery completion. Earlier reports are superseded by the current qa-report.md.

Reviewer guidance: preserve ADR-0010's TASK-022 requirement to capture selected input membership or equivalent immutable evidence and test late-arriving facts; immutable Statistics rows alone do not reproduce historical quote input selection.

Verdict: PASS
