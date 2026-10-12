# Internal ingestion contract

No new or changed HTTP interface. Reuse the merged TASK-016 `Providers.catalog/2` and TASK-055 Scraping adapter; source adapters never receive database IDs/instructions or publish catalog data.

## Entry point

`FootballMarket.Catalog.Ingestion.import_catalog(request, options \ [])` returns `{:ok, %Outcome{}}` for accepted-with-changes, accepted-unchanged or replay, and `{:error, %Outcome{}}` for safe failures.

Request has only TASK-016 catalog request keys (`league_code`, `start_year`, `end_year`, optional positive `timeout_ms`); use its normalizer. Options supply explicit provider selection, existing test runtime injection and trusted reconciliation instructions. Persisted configured positions are loaded internally and passed to Providers; a caller cannot expand vocabulary. No fallback/default switch to TASK-017. Invalid internal inputs fail before retrieval when possible and always before writes.

Instruction maps are lists to preserve duplicate detection: mappings contain provider, league_code, start_year, end_year, kind, source_id, target_id; new declarations contain the same qualification, kind=player and source_id, without target_id. Reject mixed mapping/new declarations for one key and instruction entries outside incoming validated facts. Established binding wins; a conflicting instruction fails rather than retargeting it. Mapping does not authorize updating a player in another season.

## Outcomes

| Status | Evidence / applied counts | Recovery |
|---|---|---|
| accepted_with_changes | New acceptance; actual created/updated/unchanged incoming counts | none |
| accepted_unchanged | New acceptance; zero created/updated football rows, unchanged incoming counts | none |
| replay | Original acceptance and historical original counts; zero applied counts | none |
| provider_failure | Original TASK-016 safe category/retryability/valid delay, scope | obey supplied guidance; caller decides retry |
| reconciliation_conflict | Safe reason code, no partial success | correct facts/instructions |
| stale_observation | Safe reason, no writes | new retrieval; trusted future clock limitation visible |
| concurrent_change | Safe reason, no writes | retry as new attempt with fresh revision |
| persistence_failure | Safe generic reason, no SQL/exception text | caller may retry |

Outcome `counts_historical` explicitly labels replay evidence; `new_bindings_count` reports original binding additions and `applied_new_bindings_count` is zero on replay. Both remain separate from football entity counts.

Per-kind count keys are league, season, team, player, each with created/updated/unchanged; positions resolve preconfigured vocabulary and are excluded. Omitted entities and binding/observation writes never inflate counts. Failure diagnostics use allowlisted reason templates only. Fixture_id stays explicit on success and on safe failures when validated provenance is available; do not invent lineage before provider validation. A blocked live provider remains provider failure, never live-ready/statistically fresh.

## Equality and precedence

Canonical delivery v1: operation, normalized scope, provider, UTC retrieval instant, fixture_id, supplied resolved facts and complete qualified bindings. References become qualified keys; arrays sort by keys; IDs stay case-sensitive. Different retrieval/fixture/provider is a different delivery. Digest locates evidence, full canonical equality proves replay. Persisted football comparison instead determines changed/unchanged rows.

Validate trusted instructions, then exact accepted replay, captured-revision check, stale/equal-time check, final candidate reconciliation, atomic persistence. Exact replay after later observations cannot revert current facts. Different concurrent deliveries cannot both publish against captured revision 0 or n. Equal-time attribution change is conflict. A later identical observation may advance revision while updating zero entities. Valid final team key swaps are accepted; genuine collisions with retained omitted teams fail.

No retry/backoff, asynchronous job interface, raw evidence store or automatic clock correction. Provider timeout encloses source work only; late completion never calls publication.
