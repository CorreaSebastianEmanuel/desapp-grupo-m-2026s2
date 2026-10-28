# Independent evaluation — TASK-030 (Atomic idempotent token sale)

Evaluator: fresh session, did not implement the candidate. Reviewed `specs/030-atomic-idempotent-token-sale/spec.md`, the backlog task with its recorded human decision, `REVIEW.md` contract, the staged candidate diff (35 files, +1990/−140), the implementation, local tests, and the ThinFlow receipt under `.agentflow/runs/thinflow/TASK-030/`. No workflow logs outside the named receipt were inspected; nothing was modified.

## Evidence integrity (deterministic checks)

- Receipt `candidate.json` declares tier `high`, rules `delivery-harness` + `application` (+ docs/runtime), checks `ci-contracts, harness-tests, format, compile, unit-profile`; `result: passed`, no `blocked_paths`.
- Recomputed every log `evidence_sha256` — all five match (`ci-contracts` 01ddf3…, `unit-profile` a044c1…, `format`/`compile` empty-output e3b0c4… with exit 0; nonempty passing receipts exist for the run logs).
- Reproduced `material_digest` from `scripts/thinflow.py` against the current working tree: recomputed digest `1f3d18cb9bdc…` equals the recorded digest, so the receipt is fresh and covers exactly the reviewed material. `git status` confirms every changed file is staged with a clean worktree.
- `unit-profile` receipt: `profile=unit … expected=633 discovered=633 executed=633 passed=633 status=complete` including all seven new sale suites; `harness-tests`: 353/353 OK; `ci-contracts`: 25/25.

## Acceptance / evidence matrix

| Spec acceptance item | Evidence |
| --- | --- |
| Sale at the one authoritative current quote; stand debited quantity × unit quote, seller credited same amount; tokens seller → stand; holdings and 100-token supply conserved; one immutable sale record + paired debit/credit ledger + transfer | `sales/transfer_test.exs` (conservation, exact `total = unit_price × quantity` via DB numeric multiply `Settlement.exact_total!/2`, balance-sum invariants incl. 1e40 payer/payee case); a mid-sale quote race prices at the pre-decision quote (`quote_order_test.exs`, both orderings around the decision point) |
| Replay of completed sale returns original evidence with no effects; key reuse with different details → `key_conflict`; concurrent identical deliveries → exactly one sale | `sales/idempotency_test.exs` (snapshot equality, same key after balance/inventory changes, fresh-BEAM reads, seller-scoped lookup `get_for_seller` returning `:not_found` for others); `sales/duplicate_race_test.exs` (concurrent identical → one sale/2 entries; concurrent conflicting → 1 ok + 1 `key_conflict`; same `request_key` independent per seller) |
| Rejections (missing market credits, insufficient inventory, self-sale, uninitialized/missing player, unavailable quote, inconsistent supply, invalid request, unauthenticated) leave state unchanged and do not consume the request key | `sales/rejection_test.exs` (per-kind refusals with full-DB snapshot equality, refused key succeeds afterwards when the blocker is removed), `sales/input_test.exs` (strict keys, UUID, quantity bounds, key validity, authority boundary), `sale_controller_test.exs` (400/401 with correct codes, `www-authenticate`, DB snapshot unchanged) |
| Delivered tests incl. HTTP contract: `POST /api/sales`, `api_protected`, updated published OpenAPI 3 | `lib/football_market_web/router.ex` (`api_protected` metadata identical to purchases), `sale_controller.ex` mirroring `purchase_controller.ex` status mapping (401/400/404/503/409), `error_json.ex` `/api/sales` clause, `priv/static/openapi.json` `saleTokens` + `SaleRequest/SaleSuccess/SaleError` schemas, `openapi_contract_test.exs` updated (operation set, response set, auth-failure `$ref`), `tools/openapi/browser.mjs` 12-operation assertion |

## Risk tier and boundaries

- `lib/**` changes classify as `application` → tier `high`; the receipt's selection lists all 71 changed paths with zero blocked and all five required high-tier checks present and passed. Classification is sound.
- Interior boundaries hold: `sale_controller.ex` keeps no `Repo`/`Decimal` (asserted by a delivered test); validation belongs to `SaleInput`, persistence to `SaleStore`/`SaleTransaction`. The shared `Settlement` extraction reuses the exact-money primitives for both purchase and sale without changing purchase behavior (the money changesets are byte-equivalent refactorings, and purchase suites pass in `unit-profile`).
- DB integrity is defense-in-depth: unique `(seller_id, request_key)`, the `num_nonnulls(purchase_id, sale_id) = 1` ownership constraints plus per-sale uniqueness on credit entries and the transfer, DB-level `market_sale_exact` check and the replaced shared completion trigger revalidate quote coherence and paired evidence at commit; idempotency is serialized by a transactional advisory lock on `seller_id:request_key` inside a read-committed transaction, and the pre-check races are covered by the delivered concurrent tests.
- The migration widens `market_credit_entries`/`market_token_transfers` with nullable `sale_id`; the pre-existing TP-029-era trigger still validates purchase evidence (the replaced function keeps the purchase branch), and the modified `conditional_orders/storage_test.exs` compares exact financial projections before/after migrating up, proving old purchase evidence is unaffected.

## Blocking findings

None. Every acceptance item is implemented, tested, and covered by fresh, verified, all-passing deterministic evidence matching the selected high tier.

## Advisory findings

- `Market.Sales.get_for_seller/2` is internal-only (mirrors `get_for_buyer/2` from the purchase contract); it is currently exercised only by tests. Acceptable now, but delivery of the transaction-history/ranking surfaces should reuse it rather than re-scan the table.
- The 401 JSON shape is asserted against OpenAPI for `saleTokens`/`purchaseTokens` via the shared schema `$ref` branch in `openapi_contract_test.exs`; the refactored clause substitutes `SaleError`/`PurchaseError` by `when`-guard. Equivalent behavior, slightly less flat than the previous single-clause form.

## Residual risks

- The branch is stacked on the unmerged TASK-071 ThinFlow commits, so its diff vs `origin/main` includes harness changes (also covered by the passed receipt, but CI and review of the eventual PR should account for both changesets landing together or after a rebase).
- Human merge remains outstanding per the review contract; merge accountability sits with the requesting reviewer.

Verdict: PASS
