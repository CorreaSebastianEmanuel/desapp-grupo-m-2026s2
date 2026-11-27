# Data Model: Development Seed Data

This feature adds no database table or persisted seed flag. It reconciles transient definitions against the existing League, Season, Team, Position, and Player schemas described by TASK-005.

## Seed Definition

An immutable in-code manifest containing:

- `leagues`: exact supported code/name pairs;
- one `season` per league with `start_year: 2026`, `end_year: 2027`;
- two teams per season with stable code/name pairs;
- four shared position code/name pairs;
- four players per season with display name, catalog identity, team code, and position code.

Validation occurs before database writes and requires the exact counts, supported leagues, years, unique identities within TASK-005 scopes, resolvable manifest relationships, two players per team, and one GK/DEF/MID/FWD per league.

## Canonical positions

| Code | Name |
|---|---|
| `GK` | Goalkeeper |
| `DEF` | Defender |
| `MID` | Midfielder |
| `FWD` | Forward |

## Canonical league manifests

Every league uses one 2026–2027 season. Alpha has GK and DEF; Beta has MID and FWD.

| League | Team code | Team name | Position | Player display name | Catalog identity |
|---|---|---|---|---|---|
| `PL` / Premier League | `DEMO-PL-A` | Demo PL Alpha FC | `GK` | Demo PL Goalkeeper | `demo-2026-27-pl-gk` |
| `PL` | `DEMO-PL-A` | Demo PL Alpha FC | `DEF` | Demo PL Defender | `demo-2026-27-pl-def` |
| `PL` | `DEMO-PL-B` | Demo PL Beta FC | `MID` | Demo PL Midfielder | `demo-2026-27-pl-mid` |
| `PL` | `DEMO-PL-B` | Demo PL Beta FC | `FWD` | Demo PL Forward | `demo-2026-27-pl-fwd` |
| `BL1` / Bundesliga | `DEMO-BL1-A` | Demo BL1 Alpha FC | `GK` | Demo BL1 Goalkeeper | `demo-2026-27-bl1-gk` |
| `BL1` | `DEMO-BL1-A` | Demo BL1 Alpha FC | `DEF` | Demo BL1 Defender | `demo-2026-27-bl1-def` |
| `BL1` | `DEMO-BL1-B` | Demo BL1 Beta FC | `MID` | Demo BL1 Midfielder | `demo-2026-27-bl1-mid` |
| `BL1` | `DEMO-BL1-B` | Demo BL1 Beta FC | `FWD` | Demo BL1 Forward | `demo-2026-27-bl1-fwd` |
| `PD` / La Liga | `DEMO-PD-A` | Demo PD Alpha FC | `GK` | Demo PD Goalkeeper | `demo-2026-27-pd-gk` |
| `PD` | `DEMO-PD-A` | Demo PD Alpha FC | `DEF` | Demo PD Defender | `demo-2026-27-pd-def` |
| `PD` | `DEMO-PD-B` | Demo PD Beta FC | `MID` | Demo PD Midfielder | `demo-2026-27-pd-mid` |
| `PD` | `DEMO-PD-B` | Demo PD Beta FC | `FWD` | Demo PD Forward | `demo-2026-27-pd-fwd` |
| `SA` / Serie A | `DEMO-SA-A` | Demo SA Alpha FC | `GK` | Demo SA Goalkeeper | `demo-2026-27-sa-gk` |
| `SA` | `DEMO-SA-A` | Demo SA Alpha FC | `DEF` | Demo SA Defender | `demo-2026-27-sa-def` |
| `SA` | `DEMO-SA-B` | Demo SA Beta FC | `MID` | Demo SA Midfielder | `demo-2026-27-sa-mid` |
| `SA` | `DEMO-SA-B` | Demo SA Beta FC | `FWD` | Demo SA Forward | `demo-2026-27-sa-fwd` |
| `FL1` / Ligue 1 | `DEMO-FL1-A` | Demo FL1 Alpha FC | `GK` | Demo FL1 Goalkeeper | `demo-2026-27-fl1-gk` |
| `FL1` | `DEMO-FL1-A` | Demo FL1 Alpha FC | `DEF` | Demo FL1 Defender | `demo-2026-27-fl1-def` |
| `FL1` | `DEMO-FL1-B` | Demo FL1 Beta FC | `MID` | Demo FL1 Midfielder | `demo-2026-27-fl1-mid` |
| `FL1` | `DEMO-FL1-B` | Demo FL1 Beta FC | `FWD` | Demo FL1 Forward | `demo-2026-27-fl1-fwd` |

## Seed Run

Transient result of one invocation:

- environment capability;
- status: `validating -> reconciling -> committed` or `validating/reconciling -> rolled_back`;
- counters: created and reused per entity and total;
- fixed target totals: 5 leagues, 5 seasons, 10 teams, 4 positions, 20 players.

Only a committed run exposes success. A repeated unchanged run reports 0 created and 44 reused.

## Seed Conflict

Typed transient failure with:

- kind: forbidden environment, conflict, validation, relationship, concurrent write, database unavailable, or persistence failure;
- entity type;
- manifest business identity;
- safe field/cause when applicable.

It never contains credentials, connection details, raw exceptions, or arbitrary stored values.

## Reconciliation transitions

- **Absent -> created**: all business-key lookups are absent and insertion succeeds.
- **Matching -> reused**: all alternate keys resolve coherently and canonical attributes/relationships match.
- **Matching -> unchanged**: reuse preserves UUID, timestamps, literal identity spelling, attributes, and relationships.
- **Candidate -> conflict**: split/partial alternate identity, exact attribute mismatch, or relationship mismatch aborts the run.
- **Any failure -> rolled back**: no creation from that invocation remains; all pre-existing data is unchanged.

Records outside the manifest identities have no transition and are never written.
