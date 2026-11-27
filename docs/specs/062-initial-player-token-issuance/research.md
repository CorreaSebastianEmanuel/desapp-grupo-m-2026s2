# Feature-specific research — TASK-028

No unsettled stack choice warrants external research. Repository evidence resolves these concrete questions; existing decisions remain authoritative.

## Existing identities and designation

- Decision: Reuse Catalog.Player `players.id` and Accounts.User UUID; configure a trusted singleton recipient list and fix its identity with the first committed issuance.
- Rationale: lib/football_market/catalog/player.ex keeps season-specific stable identities; lib/football_market/accounts/user.ex has email/credential association, no admin role or balances. ADR-0002/0003 settle identity/credentials. A config list represents absent/ambiguous designations without a new role service.
- Alternatives considered: Add user roles (FR-014 excludes); caller-selected recipient (FR-001 excludes); seed/create an administrator (FR-010/014 exclude). Mutable persisted recipient after issuance violates market consistency.

## Quote storage and fixed rule

- Decision: Introduce one `market_quotes` table with exact numeric price and rule ID/version. Initialize with `initial_issuance`/`1`; retain quote FK in issuance; downstream performance quote work extends this store.
- Rationale: Scoped inspection of lib/football_market and priv/repo/migrations finds no durable quotes/holdings/issuance. Valuation evaluates/replays descriptors, with TASK-026 owning quote retention per ADR-0020/0023. No active strategy or imported data can gate FR-012.
- Alternatives considered: Separate initialization-only quote table (splits history); require managed valuation (changes one-credit rule); implement performance retention here (FR-014 excludes).

## Recipient and player coordination

- Decision: Seed a protected singleton initialization lock; READ COMMITTED transactions take it before existing player row locks. Database guards serialize every quote/holding writer on the player row; deferred checks enforce post-transaction supply and issuance linkage.
- Rationale: Configurations.store and migration 20261013000000 use a singleton FOR UPDATE lock and reject stale-isolation writes; Catalog ingestion locks players too. This reuses known persistence conventions, bounds changes and prevents snapshots during atomic transfers. Different-player first issuances cannot fix different recipients.
- Alternatives considered: Application-only locks (do not cover direct DML/multiple BEAMs); only player locks (do not coordinate first recipients across players); serializable retry machinery (extra retry complexity without a feature need); duplicate mutable supply counter (extra consistency state).

## Failure and consistency evidence

- Decision: Separate pre-commit rollback from post-commit response loss. Compare full canonical quote/issuance/recipient facts and valid nonnegative holdings, not just a total of 100.
- Rationale: product-challenge findings 1/2 and FR-006/008/009/011. Completed evidence survives acknowledgement loss; missing/corrupt state is never repaired. Pure validators plus isolated legacy-fixture namespaces exercise corruption that production constraints reject.
- Alternatives considered: Compensating deletion (breaks append-only); treating retry as unconditional success (FR-010/011 exclude); topping up holdings (changes supply).

## Test and checkpoint execution

- Decision: Use test_profile.sh unit/integration once each in the final manifest; service verification with infrastructure.verify; reuse private-schema/different-backend/fresh-BEAM patterns from test/support/valuation_configuration_case.ex.
- Rationale: TestProfileAudit requires exactly one profile module tag, rejects skips and audits membership. Protected append-only data cannot be cleaned by deleting committed shared fixtures. AGENT_VERIFICATION.md and current stage instructions exclude a historical CP1 report as a default CP2 gate.
- Alternatives considered: Shared sandbox tasks (not distinct committed sessions); destructive fixture cleanup (violates audit policy); coverage report plus both profiles (duplicate full execution). No HTTP route exists, so a synthetic HTTP gate is unnecessary.
