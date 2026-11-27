# Product Handoff: User Registration and Credential Storage

## Decisions

- Registration creates one durable market-user identity from an email address and password. It is the prerequisite for later authentication, API-key, portfolio, and trading work, but does not itself authenticate anyone.
- Email identity is trimmed before validation and compared case-insensitively. One normalized email maps to exactly one user; exact, case-only, and surrounding-whitespace variants are duplicates.
- The initial password policy accepts values from 12 through 128 characters inclusive, provided the value is not whitespace-only. Passwords are otherwise evaluated exactly as supplied: they are never trimmed or normalized.
- A password is not retained, displayed, logged, returned, or otherwise exposed. Only non-recoverable credential-verification material is retained, and a later authentication feature may verify a submitted password through the defined verification boundary.
- A rejected, conflicting, or unsuccessful creation request leaves neither a user nor credential record behind. Feedback identifies the affected field or duplicate condition without exposing credential material.
- This feature ends at account creation, durable identity/credential storage, and credential verification. Login, sessions or tokens, authorization, email confirmation, password recovery or changes, profiles, API keys, and trading remain out of scope.

## Unresolved Assumptions

- Planning must select the concrete credential-protection method and its operational parameters. The selection must satisfy the specified non-recoverability, verification, and non-disclosure outcomes; its technical implementation is not a product-policy decision.
- Planning must ensure normalized-email uniqueness is enforced safely when registrations race, rather than relying only on a pre-check. This implements FR-009 and FR-011 without defining a new user-visible policy.
- Email syntax validation covers a non-blank address with a valid local part and domain. Internationalized-address support and canonical display casing are deferred; neither should be added incidentally.

## Guidance

- Treat the User and Password Credential as separate domain concepts with a one-to-one relationship. Keep web input/output, domain validation, authoritative persistence, and later authentication adapters separated under the project architecture.
- Make every validation rule, uniqueness variant, credential non-disclosure boundary, successful verification, failed verification, and rollback/no-partial-state behavior independently testable.
- Do not make credential material observable through ordinary user reads, errors, audit output, or logs. Later authentication work should consume verification outcomes rather than credential data.
- TASK-002 supplies the authoritative persistence prerequisite. Preserve its authority and do not introduce cache, provider, worker, UI, or external account-registration scope in this task.
