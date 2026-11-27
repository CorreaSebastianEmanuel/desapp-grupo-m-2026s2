# Tasks Handoff

## Resolutions

- Normal application startup supervises `FootballMarket.Repo`, but `mix infrastructure.verify` must declare no automatic application start. It loads compiled configuration and starts temporary Repo and Redis clients independently, ensuring PostgreSQL failure cannot hide the Redis result.
- Test database identity is a pre-mutation safety boundary, not ordinary validation. The same pure rule must run during test configuration and before every preparation, migration, verification, or direct Repo startup entry point.
- Story ordering is intentionally sequential: reproducible services enable database preparation, which enables application-owned connectivity. Parallelism is limited to test authorship and file-isolated components inside each phase.
- The migration probe is infrastructure-only. It may support migration and acceptance evidence but must never enter a domain context.

## Remaining Risks

- Official image digests must be verified as valid multi-architecture manifests at implementation time; a readable tag alone is insufficient.
- Shell failure injection can damage a contributor’s existing local state if project scoping or cleanup traps are wrong. Tests must use explicit disposable project identities and refuse broad volume targets.
- Driver exceptions may contain credentials even when application formatting is safe. Tests must exercise real authentication failures and redact before rendering.
- The ten-minute criterion remains a manual clean-checkout trial because image-pull time is environment-dependent.

## Sequencing Guidance

At each story checkpoint, run its newly failing tests before implementation and its whole suite afterward. Do not begin final acceptance until occupied-port, unsafe-test-database, independent dependency failure, persistence, reset, and TASK-001 regression cases all pass. Keep transcripts untracked and hand independent QA command references rather than workflow logs.
