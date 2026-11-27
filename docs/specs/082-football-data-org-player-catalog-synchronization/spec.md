# Football-Data.org player catalog synchronization

## Outcome

Refresh each searchable league catalog from Football-Data.org v4 current-season competition teams and their squads through the existing durable synchronization and atomic catalog-ingestion path. Support PL, BL1, PD, SA, and FL1. Daily schedules and operator-triggered initial/manual runs are per league. Failed or incomplete snapshots preserve the last accepted league catalog. No quotes, statistics, or financial records are changed.

## Acceptance

- [ ] Runtime configuration reads a valid credential only from `FOOTBALL_DATA_ORG_TOKEN`. Missing or invalid credentials fail closed before admission. The credential is absent from durable inputs, Oban arguments, logs, and inspection; local catalog reads remain available.
- [ ] Each accepted snapshot has the requested competition and season, a nonempty unique team list whose count matches the provider count, valid team codes/names, and a valid nonempty squad for every team. Every player has a stable provider ID, name, and recognized position. Provider IDs become source bindings.
- [ ] A failed/incomplete snapshot records a failed durable outcome and leaves the previous accepted league snapshot unchanged. Existing reconciliation rules resolve identity; unresolved conflicts remain unpublished until explicitly instructed. Omitted entities remain stored and searchable.
- [ ] Replaying or updating a complete snapshot is idempotent, affects only the requested league catalog, and preserves quotes, issuance, balances, orders, transactions, matches, and statistics.
- [ ] Daily and operator-triggered requests use existing durable admission, Oban execution, retry, publication, and inspection. Provider errors, including team-resource 429, 503, and timeouts, retain retry classification and delay through translation.
- [ ] Requests sharing the same credential are paced durably across workers, application restarts, adjacent runs, and retries so the credential never exceeds 10 requests in a rolling 60-second window. Provider reset intervals are retained even when they exceed an attempt deadline. The adapter makes no immediate HTTP retry; durable synchronization policy owns retries.
- [ ] Tests exercise runtime configuration, admission, worker execution, validation, atomic publication/replay/update, inspection, credential non-persistence, preservation on failure, reconciliation conflicts, omission retention, and unchanged unrelated/financial/statistics state.

## Scope

Add the Football-Data.org catalog adapter, bounded HTTPS/JSON transport, runtime-only credential configuration, current-season daily schedules for the five leagues, operator invocation documentation, focused tests, and durable credential-scoped request pacing backed by PostgreSQL.

## Non-goals

Historical seasons, performance/statistics imports, quote calculation, token issuance, trading, accounts, provider discovery, arbitrary name scraping, new public endpoints, retirement/deletion of omitted teams or players, and changes to the shared synchronization framework's retry/publication semantics.

## Risk

High: authenticated external data changes catalog identities. Validate the whole snapshot before atomic publication, restrict HTTPS to the fixed Football-Data.org API origin, and never expose the credential in durable or inspectable state.

## Decisions

- Resolve the current season from UTC calendar time at runtime startup: July–December uses the current year as start; January–June uses the prior year. Restart at the season boundary. Each league is an independent atomic publication scope.
- Use the v4 competition team list followed by one team resource per team. Enforce the documented 10 requests/minute ceiling with durable shared PostgreSQL state keyed by a one-way credential digest; honor longer provider reset intervals without truncating them to the current attempt deadline.
- An empty squad is incomplete. Existing source bindings and exact catalog reconciliation rules govern identity; ambiguous player identities require explicit operator mappings or new-player instructions. Omission never deletes or unbinds retained entities.
