# Independent evaluation — TASK-031 (fresh, post-repair)

This evaluation was produced independently by a fresh evaluator with no prior context. The
previous `evaluation.md` verdict (FAIL, blocker B1) evaluated an **older repair delta** whose
equal-completed-at tie traversal used `page_size=2` and lacked the append and blank-input
scenarios. That delta has since been **superseded**: the delivered test file now uses the
`page_size=1` whole-traversal design plus the append and pagination-input scenarios. Every
claim below was re-verified against the current code and tests; no implementation was modified
and no workflow journals beyond the named receipts were read.

## Acceptance / evidence matrix

| Acceptance (spec.md) | Evidence and assessment |
| --- | --- |
| Auth endpoint, API auth, actor-scoped to buyer/seller | `router.ex` registers `GET /api/transactions` with `authentication_policy: :api_protected`, consistent with `/api/ranking`. `TransactionHistory.list/2` accepts only `%AuthenticatedActor{account_id}` and returns `unauthenticated` otherwise; store queries filter `p.buyer_id == owner` / `s.seller_id == owner`. Test "history is actor-scoped…" asserts sale-but-no-purchase for the buyer key, empty history for the owner key, and a foreign/other-owner cursor rejected with 400 `invalid_cursor`. |
| Conditional-order purchase appears exactly once with all fields bound to executed execution evidence | Test "conditional-order purchases appear exactly once with complete row evidence" executes `ConditionalOrders.evaluate/1`, matches `row_id == execution.purchase_id`, and pattern-matches the full row including `player_id`, `quantity`, `unit_price == "1.00"`, `total == "3.00"`, `quote_id == execution.quote_id`, and `completed_at == DateTime.to_iso8601(execution.completed_at)`. Stored `purchase.buyer_id`/`sale.seller_id` confirmed in schemas. |
| Ordering `completed_at DESC, type ASC, id ASC`; tie traversal across page boundaries with no omissions/duplicates; newer appended operation does not shift a continuation | Store sorts merged rows by `{-unix_us(completed_at), type, id}` and per-side SQL orders equivalently; anchor predicates give the strict suffix of that order. Test "same-instant operations keep deterministic type and id order across pages" pins all three completed_at values to one instant and traverses three pages at `page_size=1`: purchase A, purchase B (`a < b` same-type ID tie), then sale, asserting `has_more == false` / `next_cursor == nil` at the terminal page and the exact aggregate `all_ids` sequence (order + uniqueness, no omissions/duplicates). Test "authenticated history…" performs a `SalesCase.sale` **between** first-page retrieval and continuation, asserting the anchored page returns the pre-append `purchase.id` (`!= appended_sale.id`), terminates with `next_cursor == nil`, and that a fresh full query places the appended sale first with all 3 rows. |
| `page_size` default 25, 1–100 inclusive; `data` + `pagination` shape; blank/malformed/repeated/structured/out-of-range → 400 without querying another user's history | Controller parses `query_string` directly: structured keys (`page_size[]`, `cursor[]`) rejected by prefix detection, repeated keys rejected, blank rejected, regex-gated integer 1..100, default 25. Validation completes in the `with` chain before `Market.transaction_history/2`, so no store access occurs on rejection. Tests cover `page_size=` (blank), `0`, `abc`, `101`, `1`, `100`, repeated `page_size=1&page_size=2`, `page_size[]=5`, `cursor[]=x`, repeated `cursor=a&cursor=b`, `cursor=`. Pagination metadata and default 25 empty-page shape are asserted exactly. OpenAPI documents all of this. |
| Empty history, generic 401, reads do not mutate records | Empty-page metadata asserted for the owner actor; raw (unauthenticated) request asserted `401 unauthenticated` with the generic error shape; ledger/holding/balance immutability asserted via `SalesCase.snapshot()` equality before/after reads in three tests (store does no writes; only `rescue` → 503 mapping). |
| OpenAPI/JSON contract | `priv/static/openapi.json` adds `/api/transactions` with Bearer/API-key security, param descriptions matching enforcement, exact-decimal string patterns, 200/400/401/503; `openapi_contract_test.exs` registers `listTransactions => 200,400,401,503` and includes `/api/transactions` in the route-scope check; focused test asserts the published contract. Money serialization via `Decimal.round(2) |> to_string(:normal)` in `TransactionJSON.data/1`. |

## Risk tier, architecture and security

Selection tier is **high** (`application` + delivery-harness rules), correctly overriding the spec's informal Medium label; required checks `ci-contracts`, `harness-tests`, `format`, `compile`, `unit-profile` all passed in the newest receipt (`digest 1fbf32d5…`, `result: passed`, matching the newest `attempts.json` entry — identical `unit-profile` hash `a044c198…` across the three passing attempts confirms the same suite outcome). `unit-profile.log` reports `expected=633 discovered=633 executed=633 passed=633 status=complete`. No `blocked_paths`. Coverage inventory adds the 3 domain modules and 2 web modules plus historical entries; `credo_inventory.json` and `test_profiles.json` register all five new files and all six history test cases (profile `integration`).

Architecture boundaries are respected: router → controller (parsing only) → domain `Market.transaction_history/2` → `TransactionHistoryStore` (Ecto read-only). Cursors are AES-256-GCM encrypted with HMAC-derived key from the endpoint secret, AAD versioned, owner-bound (decode pattern-matches the owner and casting validates UUID/type/time), opaque base64url. No financial writes, no new adapters, no gateway leakage. Repo-sourced rows flow through typed `select` maps. The 503 mapping from storage errors matches the documented contract.

## Targeted check (executed once, this session)

`MIX_ENV=test mix test test/football_market_web/controllers/transaction_controller_test.exs test/football_market_web/openapi_contract_test.exs --include integration` → **12 passed, 0 failures**. There is one benign compiler style warning (redundant `is_binary/1` at line 154 after the exact `^completed_at` pattern match); assertion-safe, format/credo receipts show clean runs.

This resolves the prior execution-coverage concern: all six B1-delta scenarios run green against the current store/controller, including the exact-sequence `page_size=1` tie traversal and the between-pages append anchoring.

## Blocking findings

None.

## Advisory findings

- `test/.../transaction_controller_test.exs:154` duplicates `is_binary/1` checks already implied by the `^completed_at`/`^quote_id` pin matches; harmless noise.
- The controller `rescue _ -> {:error, :invalid_page_size}` folds any parse-time exception into a 400; acceptable for the documented parameter surface but slightly coarse.
- Sorted-merge fetch uses `size + 1` per table with in-memory merge; correctness holds at the documented maximum `page_size=100`, and the tie test exercises the same-type boundary, but very large histories remain per-request cost O(202 rows) — fine for CP2 scope.

## Residual risks

Full suite, hosted CI (`ThinFlow required` on the exact PR head) and human merge remain subsequent gates. The equal-time test relies on trigger-disabled timestamp rewrites within its disposable per-test schema, consistent with established helpers. The store rescues only Postgrex/DBConnection errors to 503; other exceptional failures would surface as 500s, which is outside the tested contract but not a defect observed here.

## Conclusion

The superseding delta delivers, and the delivered tests exercise, every Feedback-1 requirement: execution-bound conditional-order purchase evidence, same-type equal-completed-at ID ties split across `page_size=1` boundaries with the exact ordered unique sequence to the terminal page, an anchored continuation unchanged across a between-page append, and structured/repeated/blank plus boundary pagination inputs. Implementation matches the assertions.

Verdict: PASS

## Repair delta re-evaluation (2026-10-27)

After CI rejected Credo findings (function nesting too deep), one small repair commit was
delivered refining the pagination/filter predicate helpers. This fresh re-evaluation covered
only the delta between the post-CI-refactor pair of commits (8500193 and 890dea3, timestamps
23:22 and 23:36 respectively; note the extraction is the later commit 890dea3, which is HEAD
and the commit Credo's evidence revision cites):

- `lib/football_market/market/transaction_history_store.ex` — `page`/`order_key`/`continuation`
  helpers extracted from `list`'s inner closure; layout-inlined and re-extracted logic verified
  line-equivalent (same sort key, `size + 1` lookahead, `Map.take([:completed_at, :type, :id])`
  cursor fields, `nil` continuation when `has_more` is false).
- `lib/football_market_web/controllers/transaction_controller.ex` — `value`/`values`/`structured`
  helpers re-established covering the same parameter semantics: structured `?cursor[]=x` /
  `?page_size[]=5` rejected via the `key <> "["` prefix scan, repeated values (`cursor=a&cursor=b`,
  `page_size=1&page_size=2`) hit the non-exhaustive comprehension clause yielding
  `{:error, error}`, blank `?cursor=` passes `values` (empty string is a value) and is rejected by
  `valid_cursor("")`, blank `?page_size=` is rejected by the `page_size/1` regex, missing keys
  default to `nil` (25 default page size). The two evaluation orders (prefix-check-first vs
  comprehension-first) produce identical results for every pair in the input space here because
  both conditions yield the same error atom.

Verification performed: targeted test run
`MIX_ENV=test mix test test/football_market_web/controllers/transaction_controller_test.exs`
→ 6 passed, 0 failed (the delivered file contains exactly 6 test blocks; the earlier estimate of
12 was incorrect). `sh scripts/credo_ci.sh` → `CREDO_EVIDENCE status=passed complete=true`,
exit 0 at revision 890dea3. The ThinFlow receipt `.agentflow/runs/thinflow/TASK-031/candidate.json`
is current for the final attempt (digest 3c73a9a4…, all five checks passed with attached evidence
hashes); `attempts.json` records the attempt history including intermediate failures, and the
final attempt is within the attempt budget. The diff touches only the two named files with no
speculative cleanup; parsing predicates stay in the web layer and pagination/sort/cursor logic in
the persistence store — boundaries preserved.

Verdict: PASS
