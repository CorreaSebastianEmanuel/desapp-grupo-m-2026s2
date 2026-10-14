# ADR-0023: Immutable Valuation Configurations and Serialized Selection History

**Status**: Accepted for TASK-025 architecture under approved specification and AGENTS rule 9
**Date**: 2026-10-13

## Context

The independent challenge finds integer/Decimal evidence loss, identity activation's ABA limit, application-only immutability gaps and restart tests potentially expanding into quote retention. ADR-0010 establishes ordinary-database-write protection; ADR-0020/21/22 settle exact evidence, reviewed formulas and group summation. No approved preset or public management permission exists.

## Decision

Store complete immutable versions with UUID identities/UTC creation times. Schema-versioned JSONB uses whitelisted structural keys and typed numeric leaves: integers as signed decimal strings; Decimals as normalized sign/coefficient/exponent strings. Preserve integer/Decimal tags, canonical equivalent Decimals and normalized zero. No fixed-scale numeric ceiling, floats, term deserialization, arbitrary atom interning or persisted executable modules. Resolve reviewed formula pairs through code-only clauses; inspect unsupported saved formulas without executing them.

Named UPDATE/DELETE and statement TRUNCATE guards protect versions/history, including unused versions and metadata. Restrictive foreign keys and constraints preserve integrity. Database owners disabling guards or destructive DDL are outside the trusted application boundary. Check mapping positions under key-share locks when saving; retain original identities without adding lifetime restrictions on unused catalog positions.

Derive active selection from greatest committed append-only change order. Seed one protected serialization row, with no rules/selection preset. Activation locks it, checks expected **configuration identity**, validates supported target and appends one change or returns a matching no-op. A volatile change insertion guard serializes/verifies predecessors too; require READ COMMITTED and reject other write isolation rather than accepting a stale pre-lock snapshot. Assign order after the lock. Consistent read-only snapshots may use REPEATABLE READ without inserting history. This enforcement is inferred from PostgreSQL’s documented [snapshot isolation](https://www.postgresql.org/docs/18/transaction-iso.html) and [volatile function visibility](https://www.postgresql.org/docs/18/xfunc-volatility.html), with direct-write regressions required. DB-sampled UTC effective time becomes visible on commit; order handles ties without claiming an exact commit-clock timestamp. This avoids a redundant mutable pointer.

Identity comparison deliberately allows delayed A expectations after A→B→A. Competing different targets from one uninterrupted state permit one change; this is not revision-based detection of all intervening changes. Introduce no caller revision token.

Managed evaluation fixes a version before football reads and returns its UUID alongside formula identity/version and existing evidence. A strategy-independent envelope binds the unchanged common descriptor. Managed replay compares all effective rules before authoritative original-membership replay. Pure scoring APIs remain compatible building blocks; production market paths use managed calls. TASK-026 owns descriptor retention/protection and conversion into dated quotes. Restart tests hold descriptors outside separate fresh BEAM application instances and do not implement quote storage.

## Consequences and alternatives

Test exact canonical round-trips across client restart/Decimal contexts, DB mutation guards, first/competing activation commits, matching no-op versus stale expectation, A→B→A, controlled in-flight fixation and original replay after late facts. Committed fixtures use isolated guarded test namespaces; never disable guards to delete protected fixtures.

Fixed-scale numeric/untyped JSON loses precision or tags. Context-only guards leave direct writes unprotected. A pointer adds consistency enforcement; caller revisions change approved rejection behavior. Deduplication contradicts distinct identity per save. A second scoring engine/public administration/quote retention expands scope. Intentional production calibration and full CP2 delivery remain downstream obligations.
