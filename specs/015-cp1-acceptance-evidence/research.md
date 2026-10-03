# Research: CP1 Acceptance Evidence

## Exact-revision record

- **Decision**: Keep a version-controlled declarative manifest and generate the authoritative acceptance JSON/Markdown inside CI for the checked-out full SHA; rerun after integration to `main`.
- **Rationale**: A commit cannot contain its own final SHA. Runtime generation binds evidence without mutating the candidate, and the post-merge run supplies the governing Sonar result.
- **Alternatives considered**: Commit generated results (circular); accept a working-tree hash (not final under the spec); reuse PR evidence after merge (stale).

## Aggregation

- **Decision**: A standard-library Python validator owns strict schema validation, revision correlation, safety checks, conjunction, and deterministic rendering.
- **Rationale**: Python already runs the Sonar gate, adds no dependency, and is convenient for adversarial fixture tests. A single evaluator prevents prose/JSON disagreement.
- **Alternatives considered**: Manual checklist (not fail-closed); shell-only parsing (fragile structured-data handling); application-domain module (wrong boundary).

## Sonar population

- **Decision**: Use `open_issues` for `CorreaSebastianEmanuel_desapp-grupo-m-2026s2` on the exact candidate's completed `main` analysis: all issue types with Open status; 0–9 passes.
- **Rationale**: This is the approved broad interpretation and matches ADR-0001 and the existing gate.
- **Alternatives considered**: New-code or PR-only issue counts; both can hide repository-wide CP1 issues.

## Hosted publication

- **Decision**: Publish one SHA-named GitHub Actions artifact and run summary; link through stable repository documentation/workflow navigation.
- **Rationale**: The workflow identity and artifact bind results to the revision without another source commit, while normal repository authorization satisfies access constraints.
- **Alternatives considered**: Local paths/private sessions (not reviewer-accessible); committing evidence after each run (changes revision); a new external evidence service (unnecessary infrastructure).

## Secret-safe execution

- **Decision**: Treat child output as private and untrusted, release only schema-checked receipts, scan staging before publication, destroy unsafe artifacts, and require affected credential rotation/revocation.
- **Rationale**: Prevention avoids the irreversible leak caused by printing before redaction.
- **Alternatives considered**: Capture full HTTP/shell transcripts and redact afterward; inspection alone cannot undo disclosure.

## Demo repeatability and timing

- **Decision**: Use an isolated disposable database, exact deterministic seed counts, fresh per-run user identities, two consecutive runs, and timing from preparation through the second invariant check; exclude dependency acquisition, first infrastructure startup, hosted latency, and teardown.
- **Rationale**: These boundaries measure the repeatable product demonstration rather than machine/network provisioning and prevent ambient data from masking faults.
- **Alternatives considered**: Reuse developer data (non-deterministic); include downloads/hosted waits (not comparable); destructive reset of an unspecified database (unsafe).
