# Feature-specific research decisions

No unsettled stack choice requires remote research. Existing architecture/ADR-0013/0016/0017 and merged Providers are reused. No source was contacted in this stage.

## Source evidence versus synthetic coverage

- Decision: Offline-only FotMob-shaped translation; actual transport denies access. Source assessment records five leagues/two illustrative seasons separately without extrapolation.
- Rationale: spec.md's dated terms/robots assessment and preliminary seven-match observations establish neither permission nor complete coverage. Local exploratory report/prototype confirms `__NEXT_DATA__.props.pageProps`, `fixtures.allMatches`, `details.selectedSeason`, match `general` and `content.playerStats` shapes. These paths are recorded in contracts/source-mapping.md; temporary files are not test prerequisites. 62/216 sampled performances lacked position. No permitted raw retained data or complete roster schema exists.
- Alternatives considered: Unrestricted scraping, another provider, copied captured payloads and invented position fields rejected; each conflicts with approved scope/evidence.

## Complete collection versus missing data

- Decision: Explicit scope/terminal/detail witnesses supplied by a transport observation and referenced by assessed scope evidence. Synthetic witnesses prove handling, not source capability. Missing/wrong-season/duplicate portions fail whole request.
- Rationale: Current code validates normalized facts but cannot infer whether source retrieval was complete; source layer must check before producing candidates. Explicit empty appearances remain valid.
- Alternatives considered: Expected 18/20 teams, successful status or an empty array as completeness proof rejected. Actual witness absent means blocked live scope, not a guessed schema.

## Limits and cancellation

- Decision: Deny-only actual transport now; future live port requires atomic shared admission across requests and reassessment before every portion/publication. Fixture transport simulates revisions, rejection and redirect limits. All source work is synchronous inside existing Runner worker and one monotonic deadline.
- Rationale: There is no established permission/cadence/limit to configure, and existing Runner already handles cancellation and arbitrary positive integer timeouts. Scheduler retries cannot guarantee permission across concurrent calls.
- Alternatives considered: Per-request counters and guessed rate defaults rejected. No distributed infrastructure added. Durable extension recorded in ADR-0018.

## Metric semantics and CP2 ownership

- Decision: Explicit external-position-to-configured-vocabulary mapping; no profile fallback or derived frequency. Direct optional counts require metric evidence; event-only tackles, conceded goals and card/shot reconstruction remain unknown when semantics/completeness unverified.
- Rationale: TASK-021 feedback is authoritative; own goals/keeper changes expose unsafe team/event inference. Fixture evidence can model verified direct statistics without claiming real semantic coverage.
- Alternatives considered: usualPosition and team totals rejected. CP2 ingestion/quotes/charts/orders remain separate tasks under ADR-0017.
