# Research: JWT Login and Validation

## JWT implementation

**Decision**: Use `joken ~> 2.7` with its JOSE dependency and an explicitly constructed HS256 signer.

**Rationale**: Joken is the focused Elixir JWT library, supplies claim validation hooks, and avoids implementing compact-JWS parsing and signature verification locally. Pinning the current major/minor line keeps the plan compatible with the package available on 2026-09-23. A fixed signer prevents token header input from selecting an algorithm.

**Alternatives considered**: Phoenix.Token is signed data rather than the required JWT contract; direct JOSE usage duplicates claim validation policy; RS256 adds asymmetric key operations and distribution without a current consumer need.

## Key and trusted configuration

**Decision**: Configure one Base64-encoded random HS256 key (minimum 32 decoded bytes), issuer, and audience at runtime. Production has no defaults and fails startup on invalid/missing values. Test configuration is explicitly non-production.

**Rationale**: This is the smallest configuration satisfying trusted key, issuer, audience, and fixed-method requirements. Base64 gives an unambiguous environment representation; a 256-bit minimum matches HS256 strength.

**Alternatives considered**: Reusing `SECRET_KEY_BASE` couples independent security purposes; source defaults risk production use; caller-provided configuration breaks the trust boundary; key rings/rotation are deferred until needed.

## Time semantics

**Decision**: One injectable UTC clock yields integer Unix seconds. Issue `iat = now`, `exp = iat + 900`; choose zero skew. Reject `iat > now`, optional `nbf > now`, and `exp <= now`.

**Rationale**: Integer NumericDate values eliminate rounding disagreement, make the lifetime exactly 900 recorded seconds, and give deterministic exclusive expiration. Zero skew is allowed by FR-011 and is adequate for issuance/validation inside one application.

**Alternatives considered**: Milliseconds are non-standard for JWT NumericDate; mixed precision changes observed lifetime; positive leeway complicates boundaries and cannot apply to expiration.

## Non-enumerating credential failure

**Decision**: Expose only `{:error, :authentication_failed}` for all login failures and call `Argon2.no_user_verify/0` when normalized lookup finds no account. Keep causes internal and non-sensitive.

**Rationale**: This makes response shape and later HTTP mapping uniform and prevents the obvious fast unknown-user path while reusing the TASK-007 verifier for known users.

**Alternatives considered**: Exact constant-time guarantees are not credible across database and scheduler effects; hard timing thresholds are flaky; returning changesets or cause atoms reveals validation/account state.

## Standalone validation

**Decision**: Validate cryptography and claims only, returning verified account ID and JTI without an account lookup.

**Rationale**: The specification defines standalone identity validation, has no account-status model, and explicitly excludes revocation. Tokens therefore retain their declared meaning until expiration.

**Alternatives considered**: Fetching the account on every validation adds latency and implicit deletion/status revocation; caching adds stale-state behavior.

## Bounded security and performance evidence

**Decision**: Leak tests cover application-owned authentication results, errors, Logger output, inspected structures, and authentication telemetry using sentinels. Performance is a manual, documented warm local p95 benchmark with fixed fixtures and sample counts, not a CI correctness gate.

**Rationale**: These corpora and methods are reproducible and controlled. They meet the intent of SC-005/SC-006 without claiming control over external infrastructure or turning host variance into failure.

**Alternatives considered**: Searching every possible system sink is unbounded; CI latency gates are environment-dependent; comparing known/unknown timing numerically does not establish resistance to enumeration.
