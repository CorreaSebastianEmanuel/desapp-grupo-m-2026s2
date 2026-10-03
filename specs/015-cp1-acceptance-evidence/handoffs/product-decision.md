human_check_required: true

## Decision needed

What exact SonarCloud population counts toward CP1's “fewer than 10 issues” threshold?

This changes the observable checkpoint verdict: the same candidate revision may pass under a new-code or PR-only count and fail under the total unresolved count. The governing documents specify neither branch scope nor whether accepted/won't-fix items count.

## Options

1. **Total unresolved issues on the candidate revision's governing branch analysis.** Broadest, fail-closed interpretation; strongest quality signal, but inherited issues can block CP1.
2. **Unresolved issues introduced on new code for the candidate analysis.** Aligns with common quality-gate practice, but can pass while the project has 10 or more unresolved issues overall.
3. **Unresolved issues on the feature/PR analysis.** Most attributable to this task, but acceptance can differ after merge and it weakly represents repository-wide CP1 quality.

## Recommendation

Choose option 1 because it most directly matches the unqualified checkpoint wording. Record the Sonar project, governing branch, analysis identifier, included issue statuses/types, and timestamp so the result is reproducible. If course staff supplied a narrower rubric, that authoritative interpretation should replace this recommendation verbatim.
