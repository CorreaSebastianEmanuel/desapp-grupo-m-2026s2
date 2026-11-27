# Product Handoff: SonarCloud Integration

## Decisions

- No additional product decisions remain outside the canonical specification.

## Unresolved Assumptions

- Planning must confirm the existing SonarCloud organization/project identity and the authorized maintainer who can configure protected repository settings.
- Planning should verify which SonarCloud issue states contribute to the available unresolved-project issue measure. If platform terminology differs, preserve the observable 0–9 versus 10+ rule.

## Guidance

- Do not introduce conditional logic for untrusted or fork-based pull requests; it would encode a repository context that product policy excludes.
- Prefer the smallest configuration that satisfies the canonical behaviors, and leave platform-specific mechanics to planning.
