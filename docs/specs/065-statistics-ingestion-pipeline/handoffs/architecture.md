# Architecture handoff — TASK-021

The three critic findings are resolved in ADR-0028 and plan.md: guarded provider/storage exception for evidenced substitute entrants; fixed committed-history basis for a whole batch; explicit source-owned completeness including complete-empty. Counting proposed batch rows was not adopted because spec explicitly limits history to already accepted performances. Equal kickoff is excluded. Replays reuse retained basis rather than recomputing after history grows.

Local inspection found two hidden implementation gaps: the existing durable runtime is catalog-specific, and Valuation has no durable calculation request boundary. Extend operation dispatch/fencing/recovery with catalog-compatible defaults; add durable intent plus idempotent receiving request only. Keep live transport denied and do not call scoring or create quotes. Missing downstream completion is visible requested/pending state, not import failure.

Implement additive migrations with legacy_direct defaults and guarded nil evidence; never disable immutable triggers or backfill accepted rows via update. All direct Statistics writes share the season publication lock. New source material conflicts even when an accepted unknown could now be filled.

verification.json binds all 23 FR/SC identifiers. No HTTP interface is affected, so no HTTP runtime check applies. Actual Oban/process/restart assertions and infrastructure readiness remain required. Use one execution of each audited profile, preserve coverage CI, and omit the historical CP1 report. Independent QA must challenge the frozen-history and outbox crash semantics.

No extension registry exists; before/after plan hooks are inapplicable. setup-plan.sh resolved feature 065 but reported a synthetic 065 branch; actual delivery branch is 021-statistics-ingestion-pipeline and was not changed. Do not rebind the feature or edit backlog state.
