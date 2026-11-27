# Data Model: SonarCloud Integration

This feature adds no product entity, database table, migration, cache entry, or durable application state.

## Integration concepts

### Analysis Run

- **event**: supported pull-request event or push to `main`
- **revision**: immutable Git head SHA
- **context**: PR number/base/head, or primary branch `main`
- **compute task / analysis identity**: SonarCloud identifiers returned after upload/processing
- **states**: queued, scanning, uploaded, processing, published, failed, timed-out, or canceled-obsolete
- **native gate**: pass/fail after published processing
- **findings URL**: revision/context-specific SonarCloud view

### Checkpoint Count

- **project key**: configured non-secret SonarCloud identifier
- **branch**: exactly `main`
- **metric**: exactly `open_issues`
- **value**: one non-negative integer
- **threshold**: pass for 0–9; fail for 10+
- **observed at**: timestamp of the API observation
- **profiles**: active quality-profile name/key per analyzed language, recorded with live acceptance evidence

### Governing Result

- **revision**: GitHub check-suite SHA
- **analysis result**: completed/published native SonarCloud result for that revision
- **checkpoint result**: valid primary-branch count and threshold decision
- **conclusion**: success only when both results pass
- **diagnostic class**: issue-threshold, authentication, configuration, scan, processing, publication, timeout, API/rate-limit, or malformed-response

## Invariants

- A PR's exact-head analysis and the primary-branch checkpoint count are displayed as distinct facts.
- Only `open_issues` on `main` governs CP1; PR/new-code counts never substitute.
- Missing, stale, malformed, unpublished, or failed evidence cannot yield success.
- The latest head SHA's completed check governs a PR. Older results and canceled obsolete runs do not.
- Count/profile/revision/timestamp evidence is immutable historical evidence even if later profiles or issue triage change.
- No credential value is part of any concept, fixture, log, URL, or persisted repository file.

## State transitions

```text
queued -> scanning -> uploaded -> processing -> published -> gate-pass
       |          |           |             |           -> gate-fail
       |          |           |             -> processing-failure/timeout
       |          |           -> publication-failure
       |          -> scan/auth/configuration-failure
       -> canceled-obsolete
```

`canceled-obsolete` is never success evidence, but it does not make a newer governing run fail.
