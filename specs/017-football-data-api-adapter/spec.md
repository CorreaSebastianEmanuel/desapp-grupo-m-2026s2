# Feature Specification: Football Data API Adapter

**Feature Branch**: `017-football-data-api-adapter`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "TASK-017 — Integrate Football-Data.org behind the provider contract with safe configuration and fixtures. Checkpoint CP2; depends on TASK-016."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Obtain a Season Catalog from the Configured Source (Priority: P1)

As an internal catalog ingestion consumer, I can select Football-Data.org through trusted configuration and request football facts through the existing provider contract, so future imports can use a real source without interpreting vendor data.

**Why this priority**: A usable source adapter is this task's outcome; reconciliation remains separate.

**Independent Test**: Exercise the actual adapter through the provider boundary against synthetic vendor-shaped responses for all five leagues, comparing explicit expected facts/provenance without importing anything.

**Acceptance Scenarios**:

1. **Given** enabled valid configuration and complete coverage of a requested current league season, **When** its catalog is requested, **Then** one complete normalized catalog contains that season's teams, supplied squad players, canonical positions and separate source provenance, with no vendor payload in football facts.
2. **Given** supported examples for `PL`, `BL1`, `PD`, `SA` and `FL1`, **When** each is requested, **Then** each retains its canonical league and exact start/end years using the same consumer request/result interpretation as other providers.
3. **Given** an existing covered scope with explicitly empty published teams or squads, **When** all required portions complete, **Then** a valid empty collection succeeds; omitted, inaccessible or malformed collections are never converted to empty ones.
4. **Given** several required team/squad portions, **When** all complete and validate before the shared deadline, **Then** the complete catalog succeeds; a failed later portion produces one error with no earlier records exposed.
5. **Given** same-name players with distinct source identities, **When** the catalog is returned, **Then** both remain distinct; duplicate identities, conflicting affiliations or missing required positions fail the whole request as invalid-response.

---

### User Story 2 - Enable External Access Safely (Priority: P1)

As an operator, I can enable the source and supply its credential outside checked-in artifacts, while developers and market users can use the application without a live subscription.

**Why this priority**: Introducing an adapter must neither expose credentials nor make local application use depend on external work.

**Independent Test**: Exercise disabled, valid and invalid configuration with a synthetic credential sentinel; count outbound attempts and inspect outcomes and captured diagnostics.

**Acceptance Scenarios**:

1. **Given** default development, test or production configuration without explicit enablement, **When** the application starts or local catalog/statistics are read, **Then** no external retrieval starts and no provider credential is required; a provider request without a selected source retains unsupported-capability.
2. **Given** source enablement with a missing or blank credential, **When** a valid request is made, **Then** authentication-failed is returned before any outbound attempt and local application use remains available.
3. **Given** valid credentials and supported catalog retrieval, **When** source work occurs, **Then** credentials reach only the approved Football-Data.org destination and appear in no public request context, result, error or log; fixtures and documentation contain only synthetic credentials or placeholders.
4. **Given** malformed non-secret configuration or an unsafe destination, **When** a valid request would use it, **Then** safe invalid-request occurs before external work; a source redirect is not followed and produces unavailable without forwarding credentials.
5. **Given** invalid consumer input under any configuration, **When** it is submitted, **Then** the existing contract's invalid-request behavior wins and no source work begins.

---

### User Story 3 - Report Coverage and Failure Honestly (Priority: P1)

As an ingestion operator, I can distinguish unavailable data, missing access and transient failure, so incomplete coverage never becomes misleading valuation inputs.

**Why this priority**: Wrong season attribution and invented statistics undermine downstream integrity.

**Independent Test**: Supply scope discovery, unavailable historical squads, unsupported performance and failure fixtures; verify categories, retry guidance and unchanged local reads.

**Acceptance Scenarios**:

1. **Given** a recognized competition whose accessible season discovery excludes the requested years, **When** its catalog is requested, **Then** not-found is returned without selecting the latest season; denied discovery/access instead remains authentication-failed.
2. **Given** an existing historical season with available teams but only current-season squads, **When** its catalog is requested, **Then** unsupported-capability is returned without relabelling current players as historical facts.
3. **Given** valid enabled configuration and a valid performance request, **When** Football-Data.org is selected, **Then** unsupported-capability is returned before outbound work; no minutes or per-match performances are derived from lineups, substitutions, scores, scorer tables or team statistics.
4. **Given** access refusal, quota exhaustion, connectivity failure or a malformed successful response, **When** retrieval ends before the deadline, **Then** FR-010's corresponding safe category/retry guidance is returned without source messages, bodies or credentials.
5. **Given** default/custom timeout and several portions, **When** a complete validated outcome is ready before, exactly at or after the deadline, **Then** only readiness before the deadline permits that outcome; the others time out, cancel owned source work and expose no late result.
6. **Given** persisted local catalog/statistics, **When** an adapter request succeeds, fails or is cancelled, **Then** records remain unchanged and subsequent local reads initiate zero provider requests.

---

### User Story 4 - Prove Adapter Compatibility Offline (Priority: P2)

As a maintainer, I can reproduce supported behavior and limitations with stable synthetic examples, so verification requires no live account, quota or network.

**Why this priority**: The constitution requires deterministic external-source evidence.

**Independent Test**: Repeat actual-adapter fixture checks with controlled time and independently authored expectations; verify source requests, normalized results, cancellation and secret exclusion.

**Acceptance Scenarios**:

1. **Given** synthetic vendor-shaped examples with stable identifiers, **When** the suite runs twice offline, **Then** identical expected facts/errors and deterministic provenance appear, with zero live requests or real credentials.
2. **Given** shared provider acceptance rules, **When** declared adapter capabilities are checked, **Then** supported catalogs obey the unchanged contract and unsupported performance/historical cases use explicit unsupported outcomes, without fabricated success fixtures.
3. **Given** hostile source bodies, diagnostics, identifiers or redirects containing a synthetic secret sentinel, **When** they are processed, **Then** no sentinel enters consumer outputs or captured application diagnostics and no unauthorized destination receives credentials.

### Edge Cases

- An absent season differs from an existing season with unsupported squads and an access-denied season.
- Calendar-year seasons remain valid inputs; discovery must match both years, not just the starting year.
- Season changes during collection must not produce a mixed-season catalog.
- Explicitly empty squads differ from missing fields and withheld collections.
- Blank short codes, names or unmapped positions are not repaired from names, jersey numbers or guessed roles.
- Identical and conflicting duplicates across portions both fail; transfer reconciliation is excluded.
- Unrelated source addresses, contact data, market values, images and coach details are excluded from normalized facts.
- Access/quota/service failures with unreadable bodies retain their observed category; malformed successful bodies are invalid-response.
- Missing, invalid or expired retry delays remain unknown, never zero or guessed.
- Discovery, all portions, translation and validation share one deadline, even if later work has not started.
- Disabled access, unsupported operations, invalid input/configuration and cancellation trigger no detached work or fallback.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Football-Data.org MUST be selectable as an internal provider behind the unchanged [TASK-016 behavioral contract](../016-external-football-provider-contract/spec.md) and [provider interface](../016-external-football-provider-contract/contracts/provider.md). That contract governs input validation, facts, references, provenance, errors, deadlines and read-only isolation. Consumers MUST NOT supply vendor-specific request fields or interpret payloads. This task MUST NOT relax provider rules or change other adapters' behavior.
- **FR-002**: Catalog retrieval MUST support `PL`, `BL1`, `PD`, `SA` and `FL1` when accessible source data satisfies complete requested scope and required facts. The adapter MUST discover and match both season years, maintain that scope across portions and verify returned competition/season evidence. It MUST NOT default to today's data, switch seasons, infer season evidence from the request alone or broaden league coverage.
- **FR-003**: Catalog success MUST contain the requested league/season, supplied team names/short codes, supplied squad players with display names and unambiguous team/position relationships, and canonical positions, validated together under TASK-016. Same-name distinct players MUST remain distinct; coaches/non-player entries MUST NOT become players. Missing required source identity, names, codes, positions, relationships or scope evidence; duplicate identities; conflicting affiliations; and malformed successful collections MUST yield invalid-response without dropping records or manufacturing substitutes.
- **FR-004**: Positions MUST use an explicit configured mapping into the existing canonical vocabulary. The initial catalog mapping MUST cover documented broad squad roles: Goalkeeper → `GK`, Defence → `DEF`, Midfield → `MID`, Offence → `FWD`, using existing canonical names. Source labels MUST be trimmed and matched without case sensitivity. Additional labels require explicit documented mappings; unmapped, absent or blank player positions MUST produce invalid-response. Invalid mappings or absent canonical vocabulary MUST produce safe invalid-request before external work, without fetching vocabulary from persistence.
- **FR-005**: Current-season squads MUST be accepted only when source-declared current season matches the request. Non-current requests MUST yield not-found if accessible discovery proves season absence, and unsupported-capability if the season exists but this adapter cannot obtain season-correct squads. Latest-squad substitution, inferred historical membership, reconstruction and partial teams-only success are forbidden. Malformed scope evidence in an otherwise supported current-season response MUST yield invalid-response.
- **FR-006**: Performance requests MUST remain callable through the contract and return unsupported-capability under valid enabled configuration without outbound work. Initial capabilities are catalog retrieval and explicit unsupported performance reporting. The adapter MUST NOT infer minutes, fabricate empty performance success, attribute team totals to individuals or turn season scorer totals into match counts. Supported performance retrieval requires a later explicit specification change with verified source meanings.
- **FR-007**: Success MUST include one stable safe Football-Data.org label, retrieval instant and provider/kind/league-season-qualified source bindings for required entities. Source identifiers MUST stay separate from opaque result references and local identities. Fixtures MUST identify their example. Football facts and errors MUST exclude vendor envelopes, transport details and unrelated fields. This task MUST NOT persist raw responses or reconcile identity.
- **FR-008**: Enablement and credentials MUST be trusted runtime configuration outside consumer input. Checked-in development, test and production settings MUST disable live access by default and require explicit operator selection. Startup and local catalog/statistics reads MUST require no provider credential and perform no retrieval. Consumer validation occurs first; no selected source retains unsupported-capability; enabled source with absent/blank credentials yields authentication-failed; malformed non-secret configuration yields safe invalid-request; valid configuration permits capability evaluation/retrieval. All pre-retrieval refusals MUST make zero outbound attempts. Setup documentation MUST explain enablement, non-secret settings, credential injection, capabilities and safe errors using placeholders only.
- **FR-009**: Live retrieval MUST use the approved encrypted Football-Data.org service at `api.football-data.org` with server identity verification. Credentials MUST reach only that service, never appear in URLs or be forwarded to redirects/source-supplied links. Consumer input and vendor URLs MUST NOT select outbound destinations. Any test destination override MUST be trusted test configuration and permit no unrestricted live destination. Unsafe configuration MUST fail before credentials are sent; redirects MUST produce unavailable without being followed. Credentials, authorization values, raw bodies, source messages, secret-bearing URLs and raw exception text MUST be absent from consumer outputs and application logs/diagnostics. Secret-bearing identifiers MUST fail safely rather than enter provenance.
- **FR-010**: Outcomes MUST use the following categories, subject to TASK-016 deadline precedence. Errors MUST retain valid operation/scope and safe retry guidance without partial facts. Source messages MUST NOT determine categories through uncontrolled text matching.

| Observed condition | Contract category | Retry guidance |
| --- | --- | --- |
| Invalid consumer input or non-secret trusted configuration | invalid-request | Correct input/configuration. |
| Valid operation/scope unsupported by this adapter | unsupported-capability | No retry with unchanged capability. |
| Requested competition/season proven absent, or required source resource explicitly missing | not-found | No retry with unchanged scope/source facts. |
| Missing/blank credentials or denied authentication/subscription access | authentication-failed | Correct access first. |
| Source quota or rate restriction | rate-limited | Retry eligible; respect a valid supplied delay. |
| Connectivity, name resolution, secure connection, upstream service failure, unexpected transport failure or refused redirect | unavailable | Retry eligible. |
| Deadline expires before a complete validated outcome is ready | timeout | Retry eligible. |
| Malformed/incomplete/inconsistent successful response; source rejects an already valid translated request for reasons other than access/quota/missing resource | invalid-response | Correct source facts or translation first. |

- **FR-011**: Rate-limit delay MUST be positive whole-number milliseconds only when source information establishes a valid future wait. Absent, malformed, non-positive or expired information MUST remain unknown while preserving rate-limited. Headers and quota counters MUST NOT leak into normalized errors. Architecture MUST document concrete translation of documented vendor statuses/delay formats without changing categories.
- **FR-012**: Discovery, all portions, translation and validation MUST share TASK-016's deadline: default 5,000 milliseconds, any positive whole-number override without a new ceiling, readiness strictly before deadline. No portion may reset the budget. On deadline/caller exit, owned source work MUST be cancelled/closed; no detached work, late success or local write is permitted. No automatic retries, backoff sleep, quota waiting or fallback is allowed; retry eligibility advises a later caller.
- **FR-013**: Each request MUST return one complete validated catalog or one error. All required portions and documented continuations MUST complete in that call; truncation, missing portions or later failure MUST NOT become partial success. Only explicit valid empty collections for existing covered scopes may succeed empty. Source ordering, pagination and transport structure MUST remain internal.
- **FR-014**: All adapter operations MUST be read-only and isolated from catalog/statistics persistence. Local records MUST remain unchanged after success, error and cancellation; local reads MUST initiate zero provider calls. Adapter concerns MUST remain outside web/domain business rules. Retrieval MUST NOT be wired into startup, local reads, seeds or public requests.
- **FR-015**: Deterministic synthetic vendor-shaped fixtures MUST exercise the actual adapter through the unchanged provider boundary with stable identifiers and independently authored expectations. They MUST cover every acceptance scenario and FR-001–FR-014, all five leagues, two season contexts including historical refusal, valid/empty catalogs, distinct same-name identities, mappings, invalid/duplicate facts, every error category, valid/missing/malformed delays, multi-portion success/failure, pre-work rejection, secret sentinels and destination safety. They MUST cover default/custom/very large valid timeouts, before/at/after readiness, caller cancellation, cleanup and unchanged local reads/state. Unsupported capabilities MUST be declared rather than represented by invented source fields.
- **FR-016**: Fixture checks MUST require no external services, real credentials or live network and repeat identically using controlled retrieval/elapsed time. Adapter-specific checks MUST verify requested scope, destination and credential handling as well as normalized outcomes. Existing TASK-016 checks MUST continue passing unchanged; reusable consumer assertions MUST remain provider-neutral. An optional live smoke procedure MAY be documented for explicitly enabled operator use, never as an automated acceptance prerequisite or startup action.
- **FR-017**: Scope MUST remain this adapter, safe configuration, translation, fixtures/tests and setup documentation. Catalog reconciliation/persistence belongs to TASK-018; statistics persistence to TASK-020; scheduled ingestion, retries and durable raw-source/provenance traceability to TASK-021. New public endpoints, roles, permissions, scoring, quotes, trading, rankings, caching, UI, paid subscriptions and infrastructure are excluded.

### Key Entities

- **Configured Source**: Internal selection, explicit enablement, secret credential and trusted source/position settings, separate from football facts.
- **Source Scope Evidence**: Competition identity, available seasons and current season establishing exact coverage.
- **Season Catalog**: Complete normalized league/season, teams, positions and supplied players satisfying TASK-016.
- **Source Binding**: Qualified vendor identity associated with a result entity without promising persistent identity.
- **Source Outcome**: Complete catalog or safe error including coverage limitations and retry guidance.
- **Adapter Fixture**: Synthetic source exchange with stable identity, independent expected outcome and controlled time.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Consumers obtain correct catalog facts for 100% of supported examples across all five leagues with the same request/result interpretation as existing providers, preserving every supplied valid player and inventing zero facts.
- **SC-002**: Every inaccessible, absent, unsupported, malformed or failed-source example yields its specified category, zero partial successes and zero persisted catalog/statistics changes; operators determine the next action solely from safe outcomes.
- **SC-003**: Every pre-retrieval rejection makes zero outbound attempts; every security example exposes zero synthetic secret sentinels in outputs/diagnostics and delivers zero credentials to unauthorized destinations.
- **SC-004**: Every deadline/cancellation example terminates under existing default/custom budget rules, exposes zero late outcomes and leaves zero owned retrievals continuing after cancellation.
- **SC-005**: Two offline runs produce identical expected outcomes, cover every acceptance scenario and require zero live requests, accounts or real secrets.
- **SC-006**: Operators can identify enablement requirements, historical/performance limitations and corrective versus retryable failures from setup documentation and safe outcomes without interpreting payloads; every tested default startup/local read succeeds without credentials and initiates zero provider calls.

## Assumptions

- TASK-016 is the completed dependency and owns the provider contract. [Product](../../docs/PRODUCT.md), [architecture](../../docs/ARCHITECTURE.md), [checkpoints](../../docs/CHECKPOINTS.md) and [constitution](../../.specify/memory/constitution.md) remain authoritative; this spec authorizes no change to completed tasks or their invariants.
- The current documented Football-Data.org service is the source baseline. It lists all five target leagues; accessible seasons/fields depend on source data and granted access. Successful fixtures do not promise a subscription supplies every required fact. [Coverage](https://www.football-data.org/coverage), [competition documentation](https://docs.football-data.org/general/v4/competition.html).
- The provider documents squads as current-season data. Historical team-list access alone cannot establish historical squads; current squads provide a source snapshot only when affiliation is unambiguous under the contract. [Policies](https://docs.football-data.org/general/v4/policies.html), [team documentation](https://docs.football-data.org/general/v4/team.html).
- Documented match examples contain lineups/events/team statistics but do not establish supplied per-player minutes satisfying the contract. Initial unsupported performance coverage is a conservative inference, not a claim about every future vendor product. [Match documentation](https://docs.football-data.org/general/v4/match.html).
- Broad role mappings target existing `GK`/`DEF`/`MID`/`FWD` positions. Mapping mechanics, configuration names, transport choices, fixture layout and concrete vendor-status translation remain reversible architecture decisions within these requirements.
- Callers remain trusted internal consumers without new permissions. No subscription, credential acquisition or live call is required to finish this task.
