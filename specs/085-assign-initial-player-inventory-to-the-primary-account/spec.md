# Assign initial player inventory to the primary account

## Outcome

The local player workflow works from five-league catalog sync and search, through player-scoped statistics scraping/import and quote calculation, to portfolio buy/sell and operator visibility. New catalog players and newly discovered players accepted through a player-scoped statistics import receive one initial inventory of 100 tokens at the initial price, assigned to the explicitly configured primary account.

## Acceptance

- [ ] Catalog synchronization and search support all five configured European leagues and keep the last accepted catalog when a provider response fails.
- [ ] Opening a player profile schedules a player-scoped scrape/import with player, league, and season context; accepted imports are idempotent and dispatch derived quote/statistics work.
- [ ] Quote closing and recovery jobs are manually runnable from the local admin; queue and execution history identify each job's work and scope.
- [ ] Portfolio purchases and sales use the existing balance, holdings, and quote rules and are covered by controller/market tests.
- [ ] A newly inserted catalog player receives one initial 100-token issuance for the configured primary account.
- [ ] A newly accepted player-scoped statistics import initializes an unissued player exactly once; retries and replays do not issue again.
- [ ] Issuance participates in the catalog publication or statistics acceptance transaction, so a failed issuance rolls back that acceptance.
- [ ] League-wide statistics imports do not issue inventory to every player in the league.
- [ ] Missing, ambiguous, or nonexistent primary-account configuration is visible and never silently selects another account.
- [ ] The operator page is local-development-only and reports database connections, jobs, queue messages, and recent quote requests.
- [ ] Browser sessions retain the configured eight-hour lifetime and browser tests cover expiry behavior.
- [ ] Automated tests cover scraping, catalog ingestion, job recovery, quotes, trading, issuance, and invalid configuration.

## Scope

This integrates catalog synchronization/search, player-scoped scraping and statistics acceptance, quote jobs, portfolio operations, the local admin page, session lifetime, and initial inventory assignment. It applies to the existing five-league local workflow and the explicitly configured primary recipient.

## Non-goals

- Adding user roles or changing access controls for the local admin page.
- Issuing inventory in bulk for existing players or league-wide imports.
- Changing the established trading rules, initial token pricing, or existing portfolio ownership.

## Risk

High: this writes ownership and token inventory during catalog/statistics acceptance. Transactions and idempotency must prevent partial acceptance, duplicate issuance, or implicit recipient selection.
