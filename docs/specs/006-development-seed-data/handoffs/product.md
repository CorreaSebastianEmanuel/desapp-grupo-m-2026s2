# Product Handoff: Development Seed Data

## Decisions

- Treat the concrete seed manifest as reviewable product data, not incidental implementation detail. Its readability and coherence directly affect demonstrations.
- “Seed-owned” denotes membership in that manifest; it does not require a new public catalog attribute or a parallel identity model.

## Unresolved Assumptions

- No unresolved product assumption changes observable behavior. Planning still needs to supply the concrete manifest values permitted by the specification.

## Guidance

- Review proposed names and codes for accidental resemblance to real clubs or players before they become stable development data.
- If atomic reconciliation cannot be expressed through the TASK-005 catalog boundary, resolve that as an architecture concern; do not weaken the all-or-nothing behavior.
- Do not repurpose this seed action as a migration or cleanup mechanism for developer-created data.
