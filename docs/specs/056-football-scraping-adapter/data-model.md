# In-memory design

All returned DTOs, constraints, errors, provenance and identity semantics are existing TASK-016 types in `lib/football_market/providers/types.ex`. No schema, migration or persistent state is added.

| Internal value | Fields and relationships | Validation |
|---|---|---|
| Assessment | revision, source label, reviewed_at, evidence references, permission status, valid_from, expires_at/revalidate_at, withdrawn flag, operations, allowed destinations, mandatory conditions, attribution/retention, cadence/volume/concurrency evidence, admission capability | Missing/unresolved mandatory evidence denies actual access; fixture evidence cannot change live state |
| Scope coverage | operation, canonical league, start/end years, existence/capability state, required-fact mappings, nine metric entries, position map, discovery/collection/detail witness policies | Exact operation/season; fact state verified/unavailable/unverified; evidence and meaning required for verified entries; incomplete required coverage blocks |
| Source observation | document bytes/map, requested portion key, identity/scope observations, next/terminal observation, collection-presence evidence, assessment revision, transport outcome | Foreign kind/scope/ID, repeated portion or missing witness fails; never exposed in DTO/error |
| Fixture inventory entry | stable id, origin/classification, synthetic creation date, shape evidence reference, SHA-256 of exact safe document bytes, operation/request, scenario aliases, expected-term reference, observation witnesses | All entries indexed uniquely; literal independent expected outcomes; no credentials/raw retained capture without permission |
| Adapter state | transport module/state, assessment reader, fixture id when applicable | No provider-level mutable football data; no local persistence identity |

Assessment readiness has states blocked / simulated-eligible / live-eligible. The actual deployed assessment stays blocked. simulated-eligible is only fixture state and can never transition a live assessment. Missing, expired, revoked, inapplicable or changed assessment invalidates admission and publication. Invalid caller inputs precede all these checks via existing Request.normalize.

One retrieval progresses request-validated → assessment-checked → discovery → required portions → translate → existing validate → terminal outcome. Recheck time/revision/admission before each portion and revision before publication. Any failure/cancellation discards accumulated facts; no partial state update. Runner decides terminal deadline precedence.

Catalog players retain current team/position. Performance directories describe referenced players; performances retain independent event-time team/position. No name uniqueness for players. Lists survive until duplicate validation, including identical duplicates. Only qualified provider/kind/league-season IDs bind refs; no local IDs or cross-request promise.

Minutes/counts use existing non-negative integer rules excluding booleans, with minutes above 120 accepted. Nine optional normalized keys are goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards. Unknown is nil; verified zero is integer zero. Invalid claimed verified values fail. Source event aggregates never fabricate optional values or required facts.
