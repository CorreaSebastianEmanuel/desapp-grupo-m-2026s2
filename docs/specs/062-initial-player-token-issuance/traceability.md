# Acceptance alignment — TASK-028

The authoritative behavior is spec.md. The named test files now contain executable assertions. Passing execution is established separately by current helper receipts. Every test file executes through `unit_profile` or `integration_profile` in verification.json. The audited runner checks profile membership/skips; adding files without asserted cases is insufficient. No AC identifiers are defined in spec.md, so numbered scenarios are mapped here without inventing canonical IDs.

## Requirement → assertion → tasks

All paths below abbreviate `test/football_market/market/`.

| Requirement | Concrete asserted coverage | Check(s) | Owner tasks |
|---|---|---|---|
| FR-001 | input_test validates singleton; issuance_test validates existing original user; rejection_test and concurrency_test reject cross-player/captured-recipient conflict; scope_test ensures no ordinary HTTP initializer | unit_profile, integration_profile | T002–T003, T004, T012, T016, T019–T021 |
| FR-002 | input_test rejects noncanonical quantity; issuance_test verifies per-player sum=100 and original holder=100, others=0; storage_test DB canonical guard and first-commit wrong-owner rejection | unit_profile, integration_profile | T002–T010 |
| FR-003 | input_test canonical price; issuance_test/durability_test retain exact one-credit quote, original link, DB time/rule version without performance date | unit_profile, integration_profile | T002–T010 |
| FR-004 | input/consistency unit cases reject fractions/floats; issuance_test exact Decimal unit/value and integer quantities; storage_test rejects fractional/negative rows | unit_profile, integration_profile | T002–T010, T013, T017–T018 |
| FR-005 | issuance/retry/rollback/rejection compare all account and balance-sentinel snapshots; scope_test traces no account/balance/Trading writes/calls and no purchase/sale records | integration_profile | T004, T009, T011, T013, T016, T020–T021 |
| FR-006 | storage_test explicit-prefix seed regression preserves source state; rollback_test injects pre-commit failures after each write and deferred validation; zero new recipient/quote/holding/issuance or balance changes and retry once | integration_profile, prefix_regression | T005, T007, T013–T015 |
| FR-007 | storage_test unique issuance; concurrency_test same-player/different-invocation duplicates, conserved final sum; retry_test never replenishes 0-owned original; DB deferred inflation test | integration_profile | T005, T007, T011–T015 |
| FR-008 | consistency_test validates before success; retry_test later fixture 80/20 and 0/100 + quotes preserved; rejection_test invalid designation/corruption overrides duplicate success | unit_profile, integration_profile | T011–T019 |
| FR-009 | consistency_test complete/agreed evidence; storage_test mutation/truncate guards; durability_test fresh-runtime retrieval exact original IDs/owner/value/dates | unit_profile, integration_profile | T005–T010, T017–T019 |
| FR-010 | input_test all assertion failures; rejection_test first/retry missing/ambiguous/nonexistent prerequisites and market conflict with unchanged snapshots; concurrency_test conflicting designation | unit_profile, integration_profile | T002–T003, T012, T016–T019 |
| FR-011 | consistency_test negative offsets/missing or wrong linked facts; rejection_test orphan holdings/quote, bad issuance totals and no repair; concurrency_test coherent retry and first-quote race | unit_profile, integration_profile | T012, T015–T019 |
| FR-012 | issuance/durability/scope tests initialize with no provider/statistics/active configuration and trace no external/valuation dependency; only local existing identities | integration_profile | T004, T006, T009–T010, T020 |
| FR-013 | input/consistency unit matrices plus all named integration scenarios/edges below; audited profiles assert membership/no skips; scope_test retains exact inventory of test files | unit_profile, integration_profile, prefix_regression, scope_regression, committed_scope_regression, ci_unit_tests | T001–T023 |
| FR-014 | scope_test exact file/dependency/table inventory and inherited allowlist unknown-path negative controls; no roles/accounts/routes/trades/funding/provider/valuation/portfolio/job/conditional orders | integration_profile, scope_regression, committed_scope_regression, ci_unit_tests | T020–T023 |
| SC-001 | issuance_test all valid first cases: each sum=100, original holder=100, exact unit=1/value=100, same recipient across players | integration_profile | T004–T010 |
| SC-002 | retry/concurrency/storage tests one issuance/initial quote after repeats and concurrent commits, same successful identity | integration_profile | T005, T011–T015 |
| SC-003 | rejection/rollback tests unchanged snapshots/no effects on every rejected or incomplete case; fixed recipient rolls back with failed first transaction; valid retry once | integration_profile | T013–T019 |
| SC-004 | retry/concurrency tests preserve representative later ownership/balance/all-quote snapshots and original evidence | integration_profile | T011–T015 |
| SC-005 | issuance/durability/storage assert exact retained original facts, correct quote linkage/version/date and fresh-runtime readability | integration_profile | T004–T010 |
| SC-006 | rejection tests distinguish safe applicable failures from both issued/already_completed; storage guards and legacy snapshots show no repair | integration_profile | T016–T019 |

## Numbered acceptance scenarios

| Spec scenario | Executable file / assertions |
|---|---|
| US1.1 | issuance_test.exs: first outcome after commit, nested initialization rejection before writes, original owner 100/all others zero, exact price 1. |
| US1.2 | issuance_test.exs, durability_test.exs: persisted original facts/value 100/date/version and fresh read. |
| US1.3 | issuance_test.exs: multiple player and season IDs each independently total 100, same recipient. |
| US1.4 | issuance_test.exs, scope_test.exs: account and balance-sentinel snapshots unchanged/no financial account writes. |
| US2.1 | retry_test.exs: unambiguous already_completed/same ID, identical entire market snapshots. |
| US2.2 | concurrency_test.exs: distinct committed backends; at most one issued; every success same evidence. |
| US2.3 | rollback_test.exs: failure before commit leaves no rows; resolved retry issues once. |
| US2.4 | retry_test.exs: controlled 80/20 transfer, same balances/current holdings and original evidence. |
| US2.5 | retry_test.exs: extra dated fixture quotes/current value preserved with original quote still linked. |
| US3.1 | rejection_test.exs: nonexistent player yields player_not_found with zero effects. |
| US3.2 | input_test.exs, rejection_test.exs: empty/multiple/nonexistent designation, no account creation. |
| US3.3 | input_test.exs, rejection_test.exs: wrong asserted recipient/quantity/price rejected unchanged. |
| US3.4 | consistency_test.exs, rejection_test.exs: orphan rows and bad/missing original facts or totals; no repair. |
| US3.5 | rejection_test.exs: existing player's different recipient rejected with no reassignment. |
| US3.6 | rejection_test.exs, concurrency_test.exs: sequential and concurrent different-player global recipient conflicts. |
| US3.7 | rejection_test.exs: invalid designation and inconsistent retained state fail before duplicate success. |

## Edge cases and critic regressions

| Edge / finding | Executable assertion |
|---|---|
| No statistics/strategy/provider availability | issuance_test + scope_test: first call succeeds, no forbidden calls or facts read. |
| Unissued player not zero-supply initialized | issuance_test: getter not_initialized and no quote/holding/issuance. |
| Original recipient owns zero after trading | retry_test + consistency_test: 0/100 or absent original holding accepted, no replenishment. |
| Stable identity after rename/catalog refresh; distinct seasons | issuance_test: rename existing display record then retry same issuance; independent season IDs each 100. |
| Conflicting same-player designations | concurrency_test: recipient_conflict/invalid designation without second issuance. |
| Conflicting different-player first designations | concurrency_test: only recipient-consistent issuance commits, other player untouched. |
| Failure creating recipient/quote/holding/issuance | rollback_test: namespace-local trigger rejection before commit, with a nontransactional fixture sequence proving each reached write boundary; zero new rows, successful explicit retry. |
| Later quote different value/date | retry_test + durability_test: original rule/value/date/evidence unchanged; later quote preserved. |
| Incomplete/contradictory prior records | rejection_test + consistency_test: safe inconsistent_state, full state snapshots unchanged. |
| Commit then lost response (critic 1) | rollback_test: commit durable issuance, discard response, new client/retry returns retained ID without mutation; no compensating delete. |
| Negative offsets/wrong quote player/value/rule/date (critic 2) | consistency_test adversarial maps + rejection_test legacy namespace: 120/-20 cannot pass aggregate shortcut; required linked evidence agrees. |
| Retry concurrently with transfer (critic 3) | concurrency_test: distinct backends and pg_blocking_pids prove both lock orders; post-lock validation sees complete 100 aggregate, unchanged original evidence. |
| First issuance concurrently with quote (critic 3) | concurrency_test: quote-first produces unissued-history failure; issuance-first permits later fixture quote while preserving initial. |
| Explicit migration prefix differs from search_path (current Feedback 1, R1/P2) | storage_test tagged prefix_regression: target singleton is exactly [[1]], migration succeeds, source search_path/lock rows/account and market snapshots remain unchanged; targeted helper check plus integration_profile. |
| Initialization before performance valuation (critic 4) | rejection_test orphan quote failure + issuance_test fresh-player success; quickstart documents demo ordering; scope_test excludes backfill/auto-hooks/duplicate store. |
| Configuration boundary after commit (current Feedback 2/3) | scope_test hashes the entire approved config independently of Git; six negative assertions reject changed/absent/duplicate designation, seed, Argon2 and unrelated settings. committed_scope_regression clones the existing commit at depth 1, asserts committed approved config and clean checkout, overlays only the corrected scope test and executes its assertions. ci_unit_tests executes the real Quality baseline script including complete-discovery sentinel. No commit or remote reference is needed by the boundary assertion. |

## Checkpoint and invariant coverage

Supply, exact money, atomic/idempotent initialization and immutable audit/quotes are directly asserted above. Provider-independent local behavior is asserted without enabling an adapter. Initialization rule ID/version plus retained original quote make this fixed rule reproducible; later managed scoring evidence remains TASK-026. This feature supplies CP2 initial inventory; audited unit/integration profiles preserve regressions and existing browser smoke. Charts, portfolio/trading browser E2E and conditional orders remain downstream checkpoint obligations. Existing CI/CP1 coverage infrastructure is preserved, with no duplicate local historical coverage report gate.

## Implementation evidence details

Full row snapshots use SHA-256 per row before equality comparison, including users, credentials, API keys and exact test-only balance sentinels; assertions cannot expose credential material. Guarded schemas exercise ordinary DML and committed 80/20 or 0/100 transfers. Unconstrained legacy copies are separate owned schemas; production guards remain enabled. Missing or orphan market-recipient fixation fails for a fresh player as well as a retry. Null required facts and the cross-player quote FK have dedicated storage assertions.

Concurrency tests verify distinct PostgreSQL backend IDs and actual blocking, including facade designation capture while a competing call observes a changed setting. Rollback tests cover rejection before quote, holding and issuance inserts, plus rejection after all four rows exist before commit. A fixture-only sequence proves the intended fault boundary was reached. Durability tests stop/reconnect the owned Repo and assert retained IDs, dates, exact values and rule in a new BEAM process. No HTTP method or route is introduced; internal DB runtime assertions execute in integration_profile.
