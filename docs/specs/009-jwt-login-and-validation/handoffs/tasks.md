# Tasks Handoff: JWT Login and Validation

## Resolutions

- No `backlog/feedback/TASK-009.md` exists, so there is no current human correction to incorporate.
- Issuance, validation, and expiry share one authentication module. The task graph therefore sequences US1 -> US2 -> US3 while retaining an independent test checkpoint for each story; parallel implementation of those stories would create conflicting edits and ambiguous policy ownership.
- Test-first evidence is explicit: each story has a focused failing-test run before implementation. Foundational work is limited to dependency/configuration validation and deterministic seams so it does not pre-implement story behavior.
- Production configuration fails startup for missing/invalid JWT settings, while callable issuance and validation still fail closed with generic errors for tests and alternate boot paths.
- Exact expiration uses zero skew and `exp <= now` rejection. Performance remains tagged/manual so host variance cannot weaken deterministic CI checks.

## Remaining risks

- HS256 key holders can mint tokens; keep the key application-local. Rotation/asymmetric verification remains deliberately deferred.
- Dummy Argon2 work reduces the obvious unknown-user timing gap but does not prove constant time across database and scheduler behavior.
- Login throttling/lockout is out of scope, so CP1 authentication must not be described as production-hardened against online guessing.

## Sequencing guidance

Preserve the red-green evidence at T008, T014, and T019. Do not let later adapters bypass `FootballMarket.Accounts`, broaden the two stable error atoms, add persistence to validation, or move transport/authorization concerns into this task. T025-T027 are release gates, not optional cleanup.
