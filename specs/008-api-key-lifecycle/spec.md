# Feature Specification: API Key Lifecycle

**Feature Branch**: `008-api-key-lifecycle`

**Created**: 2026-09-23

**Status**: Draft

**Input**: TASK-008: "Issue, hash, identify, revoke, and test API keys without exposing stored secrets."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Issue a Key for an Existing Account (Priority: P1)

As a market account owner, I can receive a new API key through a trusted account operation so that a later authentication feature can recognize requests made with that key.

**Why this priority**: A key must be safely issued and bound to an account before it can be identified or revoked.

**Independent Test**: Create an account, issue two keys, and verify that each result contains a distinct secret and key identifier while durable records contain no usable secret.

**Acceptance Scenarios**:

1. **Given** an existing account, **When** a trusted account operation issues a key for it, **Then** exactly one active key belongs to that account and its secret is returned only in the successful issuance result.
2. **Given** an account with an active key, **When** another key is issued, **Then** the new identifier and secret are distinct and the earlier key remains active.
3. **Given** a nonexistent account, **When** issuance is attempted, **Then** it fails without returning a secret or creating a key.

---

### User Story 2 - Identify an Active Key (Priority: P2)

As a later authentication capability, I can present an API key and learn which account and key it represents so that requests can be attributed to the correct actor.

**Why this priority**: Account attribution is the purpose of a key, and invalid keys must never identify an actor.

**Independent Test**: Present each issued secret and verify its owner and identifier; present altered, unknown, malformed, and revoked values and verify that none identifies an actor.

**Acceptance Scenarios**:

1. **Given** two active keys for an account, **When** either complete secret is presented, **Then** identification returns that account and the particular key identifier without returning credential material.
2. **Given** an altered, unknown, or empty secret, **When** it is presented, **Then** identification fails without identifying an account.
3. **Given** a revoked key, **When** its former secret is presented, **Then** identification fails in the same externally observable way as an unknown key.

---

### User Story 3 - Revoke an Owned Key (Priority: P3)

As a market account owner, I can revoke one of my keys through a trusted account operation so that it stops identifying my account while my other keys remain usable.

**Why this priority**: An owner needs a reliable way to withdraw a credential without disrupting other credentials.

**Independent Test**: Issue two keys, revoke one by identifier and owner, verify that only the other still identifies the account, then repeat revocation and attempt revocation under another account.

**Acceptance Scenarios**:

1. **Given** an account with two active keys, **When** it revokes one, **Then** that key immediately stops identifying the account and the other remains active.
2. **Given** a key already revoked by its owner, **When** revocation is repeated, **Then** the key remains revoked and no credential material is revealed.
3. **Given** another account's key or an unknown identifier, **When** revocation is requested for an account, **Then** no key changes and the outcome does not disclose whether another account owns the identifier.

### Edge Cases

- Failed issuance leaves no active key and returns no secret. Successful issuance returns a secret only after the key is durable and identifiable.
- Key identifiers are management references; they cannot substitute for secrets during identification.
- Incorrect, incomplete, empty, or non-text presented values never identify an actor.
- Revoked keys cannot be reactivated. Issuing a replacement cannot make an old revoked secret valid again.
- Secret values, stored hashes, and other verification material are absent from ordinary reads, errors, logs, and audit output. A raw secret appears only in the successful issuance result and transiently when presented for identification.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST issue keys only for existing user accounts through a trusted internal account operation; this feature MUST NOT expose a public key-management endpoint or user interface.
- **FR-002**: Each key MUST have a stable, opaque identifier, exactly one owner, a creation time, and an active or revoked state. An account MUST be able to own multiple keys.
- **FR-003**: Each secret MUST be generated independently with at least 128 bits of unpredictable randomness. A new key MUST NOT reuse an existing or previously revoked secret.
- **FR-004**: A raw secret MUST be disclosed only once, in its successful issuance result. That result MUST include the key identifier and MUST NOT include a stored hash or verification material.
- **FR-005**: The system MUST retain a one-way hash for identification and MUST NOT persist the raw secret or a reversibly encrypted equivalent.
- **FR-006**: Identification MUST accept a complete presented secret and return only the owning account identity and particular key identifier when active. An identifier alone MUST NOT identify an actor.
- **FR-007**: Identification MUST reject unknown, altered, malformed, empty, non-text, and revoked secrets without identifying an actor or revealing whether a record exists.
- **FR-008**: Revocation by key identifier MUST be allowed only when the key belongs to the account specified by the trusted operation. It MUST affect only that key, take effect for subsequent identification, and be irreversible.
- **FR-009**: Repeated revocation by the owner MUST succeed without changing the revoked state or disclosing credentials. Unknown and other-account identifiers MUST produce the same non-disclosing failure and change no key.
- **FR-010**: Issuance MUST fail without a returned secret or partial key record when the account is absent or the operation cannot finish. A secret collision MUST NOT produce two keys sharing a usable secret.
- **FR-011**: Ordinary account/key reads, inspection, errors, logs, and audit output MUST NOT contain raw secrets, stored hashes, or verification material. Identification and revocation results MUST NOT return them.
- **FR-012**: Automated tests MUST cover issuance, multiple keys, owner/key identification, invalid and revoked-key rejection, owned and other-account revocation, repeated revocation, failed issuance, collision handling, and non-disclosure at every stated boundary.
- **FR-013**: Caller authentication, public key-management routes, JWT login, API-request authorization, key expiration or rotation policies, and key-management UI are outside this feature.

### Key Entities

- **User Account**: The existing market-user identity established by TASK-007; one account can own multiple keys.
- **API Key**: An account-bound credential with an opaque identifier, creation time, private one-way verification material, and active or revoked state. Its raw secret is available only at issuance or when presented by a caller.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In automated verification, 100% of successful issuances for existing accounts produce distinct, immediately identifiable keys, and 0% of failed issuances return a secret or leave a key.
- **SC-002**: In automated verification, 100% of valid active secrets identify the correct account and key; 0% of tested altered, unknown, malformed, empty, non-text, or revoked values identify an actor.
- **SC-003**: Revoking one of two keys prevents it from identifying the account on the next attempt while the other key continues to work in 100% of automated cases.
- **SC-004**: Inspection of ordinary results, errors, and recorded output in lifecycle tests finds 0 raw secrets or stored hashes beyond the one successful issuance result per key.
- **SC-005**: Under normal local conditions, at least 95% of successful key issuances and identifications complete within one second each.
- **SC-006**: Review finds no public key-management route, JWT-login behavior, API-request authorization, expiration policy, or key-management UI introduced by this feature.

## Assumptions

- TASK-007 supplies durable accounts and stable identifiers. Only trusted application code invokes issuance and revocation for a specified account until TASK-010 establishes an authenticated public request boundary.
- Keys remain active until explicitly revoked. Expiration, renewal, and automatic rotation are later policy decisions.
- An opaque key identifier grants neither identification nor authority to revoke a key owned by another account.
- An owner may hold multiple keys so a replacement can be issued before revoking an old key.
- A later API authentication task defines how external callers present a key; this task defines no external credential transport format.
