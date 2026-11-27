# Product Challenge: User Registration and Credential Storage

## Material findings

- **Credential handling is a security boundary.** The specification requires non-recoverable verification material and forbids disclosure, but deliberately leaves the concrete protection method and its operational parameters to planning. The architecture must use an established adaptive password-hashing mechanism, keep passwords out of logs and ordinary reads, and test that verification fails for a different password. This is an implementation choice constrained by FR-006 through FR-008, not a new product-policy decision.

- **Email identity must remain race-safe.** Trimming and case-insensitive identity are observable requirements. Planning must ensure concurrent registrations cannot create duplicate normalized identities and that a conflict leaves no partial user or credential state. This follows FR-003, FR-009, and FR-011.

- **The scope boundary is clear.** Login, tokens, API keys, recovery, confirmation, profiles, and trading are explicitly deferred. No HTTP contract or user interface should be added incidentally; those capabilities belong to their separately scheduled tasks.

## Recommendation

Proceed to planning. The defined 12-to-128-character, non-whitespace password policy and email identity rules make the feature testable. The remaining choices are implementation safeguards or later-task scope, so they do not require a human product decision.
