# Review contract

Review the change against its stated outcome and the repository, not against a
generic ideal. Optimize for production correctness and high signal.

- A **blocking** finding is introduced by this change and has concrete evidence
  that acceptance is unmet, required evidence is invalid, behavior is wrong, or
  security/data integrity can regress.
- An **advisory** finding is a nit, style preference, speculative cleanup,
  missing optional improvement, or pre-existing problem. It never fails the
  evaluation of this change.
- Every blocking finding cites a file and line plus a reproducible scenario or
  check. Validate surprising findings against the implementation before filing.
- Group every instance of the same root-cause class in one finding. Do not make
  the builder repair one occurrence per round.
- On re-review, inspect the repair delta and affected surfaces. Do not repeat a
  resolved or previously reported finding.
- Say plainly when there are no blocking findings. The person who requested the
  change remains accountable for deciding whether and when it merges.
