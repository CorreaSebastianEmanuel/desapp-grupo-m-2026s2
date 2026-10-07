# Offline acceptance matrix

The implementation must create the following stable example families in test/fixtures/scraping. `USn.m` aliases identify existing numbered spec scenarios; they add no requirement. Inventory expands families to unique IDs, exact requests, safe source documents, witness observations, independently authored expected terms and literal byte fingerprints. Synthetic creation date is recorded at creation, never a claimed source capture date. All fixtures are synthetic; observations reproduce known shapes, hypothetical roster/witness/metric semantics are labelled separately.

| Stable family | Spec scenario | Explicit expected facts or error | Suite |
|---|---|---|---|
| access-default | US1.1 | Baseline and enabled-flag attempts unsupported_capability, zero fetches; labelled offline path remains usable | assessment |
| access-scoped | US1.2 | Simulated valid PL/2024–2025 catalog allowed; other operation/season rejected; concurrent simulated budget/destination admission cannot exceed assessment | assessment |
| access-invalidation | US1.3 | Missing/expired/withdrawn/coverage-unverified assessment rejects before fetch; invalid request precedes gate; revision/expiry between portions or before publication discards outcome | assessment |
| assessment-inventory | US1.4 | Five league × two season × two operation rows and nine metric meanings/states inspectable; fixture pass leaves actual baseline blocked | assessment, matrix |
| catalog-scopes | US2.1 | Ten league/season cases with complete synthetic roster witnesses, explicit canonical positions/current teams, independent bindings; no match-observation catalog | catalog |
| catalog-empty | US2.2 | Present complete empty success; absent published scope not_found; unsupported season unsupported_capability | catalog |
| catalog-integrity | US2.3 | Same-name distinct IDs both retained; wrong season, unresolved positions/rosters, identical/conflicting duplicates, missing later roster, repeated/nonterminal portion invalid_response with no facts | catalog |
| performance-eligibility | US3.1 | Ten league/season cases; completed inclusive lower/upper kickoff retained; time-zone equivalent instants equal; known irrelevant status/date records excluded before unused details; unknown eligibility invalid_response | performances |
| metrics-tristate | US3.2 | Each of nine verified direct counts: literal zero retained; missing/unverified nil; negative/fractional/boolean/string claimed verified value invalid_response | performances |
| historical-affiliation | US3.3 | Current team B versus historical A preserved; explicit event position differs from profile; literal configured map; no name-based identity | performances |
| required-facts | US3.4 | Missing minutes/position or unmapped required role invalid_response; zero minutes and >120 minutes accepted; no usualPosition fallback | performances |
| unsupported-performance | US3.5 | Known required coverage absence unsupported_capability before fetch; catalog/calendar capability never promoted | assessment, performances |
| attribution-events | US3.6 | Own goal never counted as ordinary goal/shot; keeper substitutions never get whole-match conceded totals; partial/unverified event counters nil; independently specified verified direct player counts retained | performances |
| source-equivalence | US4.1 | Catalog and performance facts equal to existing FixtureSourceA using explicit bijections; source labels/qualified bindings different, fixture IDs/retrieval instant correct | equivalence |
| source-errors | US4.2 | All eight existing categories/retry flags; positive rate delay retained, absent nil, invalid delay rejected; sentinel payload/secret/URL/exception absent; challenge refused without bypass or fallback | safety |
| shared-deadline | US4.3 | Before/default/override success; equality/after timeout; multi-portion later failure whole error; large overrides 4294968000/10000000000000 accepted; real worker cancellation ends source work/no late publication | deadline |
| offline-repeat-isolation | US4.4 | Two runs same facts/errors/provenance and zero external calls/credentials; successful and failed retrievals leave catalog/statistics snapshots and local reads unchanged, local reads initiate zero source work | repeat, isolation |

Additional mandatory cases: completed-empty-performances succeeds only with present collection/complete detail witness; missing playerStats/detail fails supported fixture; partial discovery, historical redirect to wrong ID/season, duplicate source binding, cross-season link, missing match actual kickoff and unknown completion fail. Performance reference directory is not a full roster. A source error encountered while retrieving a required portion retains its category instead of becoming a generic completeness error. Invalid claimed values are not repaired; malformed non-retained player data in provably irrelevant matches is not a new exclusion.

Equivalence fixtures may add an independent source-shaped test-only example for FixtureSourceA without changing the original 217 corpus or four fingerprints. Reuse FactOracle and FixtureRuntime; literal expected values/correspondence cannot be generated by production translator or Validator. Real source field-path omissions are failure fixtures; hypothetical success witnesses do not attest actual readiness.

## Implementation inventory

`test/fixtures/scraping/inventory.exs` indexes 170 unique cases and all 17 scenario aliases. `documents.exs` retains only authored synthetic byte strings; `expected.exs` specifies facts/error variants independently, expanded by the literal football oracle in `ScrapingFixtureData.expected_facts/2`. Each metric has verified zero, missing, unavailable, unverified and four invalid claimed-value examples. `html-schedule` exercises the observed `__NEXT_DATA__` path successfully; malformed and ambiguous scripts fail. `access-publication-revoked` invalidates assessment after the last portion before candidate submission. Source-equivalence reference inputs are literal test-only values in `cases.exs`; existing provider corpus/fingerprints remain unchanged.

The isolation suite runs every inventory case with exact populated seven-table catalog/statistics snapshots and local-read comparisons. The deadline suite also runs production Runtime cancellation/worker-death assertions and both large overrides. All checks remain in verification.json; no HTTP route was added. A case pass establishes only offline behavior, while source-assessment.md and Assessment.actual/0 remain blocked.

Final-validation admission regressions: assessment_test.exs separately checks catalog-PL-2024 and performance-PL-2024 for expiry, withdrawal and revision change caused by Validator clock advancement, plus timeout precedence for each combination. The unchanged six-case human reproduction is the publication-gate check. These extend US1.3/US4.3 without modifying fixture bytes or expected corpus outcomes.
