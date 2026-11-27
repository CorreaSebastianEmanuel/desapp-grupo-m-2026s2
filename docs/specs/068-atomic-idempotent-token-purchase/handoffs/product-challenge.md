# Product Challenge — TASK-029

## Material findings

- **Self-purchase has no defined outcome.** The spec says the authenticated buyer purchases from the designated initial recipient (User Scenarios; FR-001/002/005), but does not exclude that recipient as buyer. If they are the same account, FR-005 requires a debit and credit to one balance while FR-006 requires a token transfer between the same owner; a successful “purchase” could be a no-op or could have inconsistent ledger/holding semantics. **Recommendation:** ask for a product decision; default to rejecting self-purchases before mutation with a distinct safe outcome. Alternative: explicitly define them as permitted no-op operations, including ledger semantics. Evidence: `spec.md` FR-001, FR-002, FR-005, FR-006; `docs/PRODUCT.md` identifies the designated initial recipient as superuser.

- **Quote-race acceptance needs a testable ordering.** FR-003/007 and scenario 1.4 require one authoritative quote when quote publication overlaps a purchase, but do not identify the ordering point or define whether an already-started purchase may commit against the prior quote. **Recommendation:** architect documents the serialized decision point and produces a deterministic interleaving test showing either quote wins according to that order, with the operation retaining the same quote used for charge. This is an implementation contract, not a reason to reopen settled product scope. Evidence: `spec.md` FR-003, FR-007, scenario 1.4; `handoffs/product.md` already asks for demonstrable ordering.

Funding scope is settled by current human feedback: balances are provisioned setup, with no funding or credit grants in TASK-029. Do not reopen it absent new evidence.
