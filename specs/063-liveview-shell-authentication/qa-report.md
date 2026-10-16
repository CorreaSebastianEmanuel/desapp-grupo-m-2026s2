# Independent QA — TASK-046 B1 correction

Fresh verification on 2026-10-16. Binding: `specs/063-liveview-shell-authentication`, branch `046-liveview-application-shell-and-authentication`; HEAD is integrated main `7f8d4ba50ec159fa49fb5cd802b1f12cf3cfd668`. The scheduled-synchronization directory is unrelated. Read canonical spec/plan/tasks/manifest/contracts, required repository documents, ADR-0026, architecture/development and product challenge/decision handoffs, current feedback and final-review B1 finding. Inspected affected source and tracked diffs. Historical QA PASS was not acceptance evidence. No delegation, workflow invocation, implementation edits or publication.

## Executed independent evidence

Loopback bind/listen/connect/send/receive passed before checks. Every command below was `python3 scripts/agentflow_check.py CHECK_ID --stage qa`, without reuse; DB suites ran sequentially. All checks reported unchanged source/inputs, no reuse and zero failures. No denied execution or retry occurred.

| Check | Exit | Seconds |
| --- | --- | --- |
| preflight | 0 | 4.621 |
| format | 0 | 1.265 |
| compile | 0 | 0.732 |
| openapi | 0 | 0.835 |
| unit | 0 | 27.507 |
| integration | 0 | 183.295 |
| foundation | 0 | 1.722 |
| feature | 0 | 9.289 |

Fresh receipt snapshots, identities, output hashes and evidence references: `qa-evidence/b1-independent-20261016/manifest-results.json`. Canonical receipts: `handoffs/check-*.json`. Referenced raw logs were not inspected.

Source fingerprint for every execution: `275243a46c3502b2dfd3e6fd67e34278e5d709f2ed2afc71951b110043f3018f`. Canonical input fingerprint: `9159ab6fb1941471646d0ea10dfc8af0c4e018829598ad604f1b8353dedf0ac1`. Both remained identical before/after supplemental execution.

## B1 disposition: resolved

Protected HTTP denial for missing/invalid/expired authority now appends only the existing nonsecret `notice=ended` and exact allowlisted return. Unavailable validation remains fail-closed 503. Direct public sign-in remains notice-free. No marker, authority, role, API change or retention extension was introduced. The exclusive database deadline is unchanged.

Executed controller regression covers both destinations without transport, 303, no-store, visible recovery, no email/raw handle and direct public sign-in. Executed Chromium regression explicitly calls `clearCookies` for the real session cookie while offline, after advancing server time, and asserts cookie absence before protected navigation. Thus this regression exercises removed transport rather than only a retained cookie with an advanced server clock. It asserts visible ended feedback, no private identity and successful sign-in. The separately executed retained-cookie offline expiry and exact-clock tests remain controls.

Supplemental independent probe exited 0 in 3.239s: real HTTP missing/tampered cookie responses for both destinations assert exact safe return, 303, no-store and no identity; direct sign-in has no ended notice. Real Chromium independently disconnects and removes actual transport for **each** destination, verifies absence, sees usable ended recovery without identity, signs in and verifies the requested destination. Reproduction sources and fingerprints: `qa-evidence/b1-independent-20261016/task046_b1_qa.mjs`, `task046_b1_qa_test.exs`, `task046_b1_qa_summary.json`; executed command `MIX_ENV=test mix test /tmp/task046_b1_qa_test.exs`.

## Acceptance reassessment

| Requirements | Fresh executed coverage and inspected assertions |
| --- | --- |
| FR-001/002; SC-001 | Credential normalization with exact password, generic malformed/unknown/wrong failure, cleared password, new authority/anonymous retirement, concurrent submissions and stale authenticated form isolation. Browser guard accepts cookie authority only; API requests retain separate pipelines. |
| FR-003/004; SC-002 | Deadline minus one microsecond, exact deadline and after; no renewal; callback guards for events/params/info/async; subscribe/revoke race, missed notification, missing user/outage; committed/idempotent logout, replay denial, independent browser/API authority. Real Chromium separately measures two-tab logout/expiry removal within two seconds. |
| FR-005/006; SC-004 | Both protected destinations, missing/tampered/expired/revoked authority, trusted actor despite altered account input, owned-resource denial/recovery with HTTP 403 and no foreign contents. B1 probe adds both actual removed-cookie journeys. |
| FR-007/008; SC-003 | Both headings/direct routes, one active item, shared identity, single-selection navigation, exact safe returns and hostile/unknown fallbacks; honest placeholders without financial operations. |
| FR-009/010 | Encrypted HttpOnly/SameSite cookie, Secure deployment setting; captured logs/telemetry and decoded mount payload exclude authority/password; browser DOM/storage checks. Real HTTP missing-CSRF then cross-origin sequence on fresh connections, forged websocket 403 and nonmutating GET sign-out. |
| FR-011/012; SC-005 | Generic/ended/unavailable/denied/missing/disconnected recovery, escaped text; history/account switch, changed persisted identity on reconnect, explicit queued-event sentinel never replayed, offline concealment and retained-cookie expiry recovery. |
| FR-013; SC-006 | Chromium keyboard sign-in/navigation/sign-out, labelled fields, associated errors, alert announcements, visible focus and no horizontal scrolling at 1280x800. |
| FR-014/015 | Complete independent unit/integration profiles plus foundation/feature; public pages and API policy regressions, real listener readiness and actual Chromium, two users/tabs, controlled clock and adversarial cases. |

All four product challenges remain covered: truthful failed revocation/retry, stale form and serialized retirement, exclusive authorization separate from display convergence, and actual browser lifecycle evidence. Fixed feature-specific scope allowances fail closed for unknown features/unplanned paths; config normalization accepts only the exact approved secret filter while retaining the pinned remainder hash and mutation rejection. Integrated main is preserved. Domain/web/persistence boundaries and all PRODUCT invariants remain unchanged; charts/order behavior remains outside TASK-046.

## Limits and next-stage guidance

No current blockers or failures. The previously documented unexplained integration exit 2 remains a historical reproducibility risk; this fresh independent integration passed without retry and does not explain the old failure. Transport removal is deterministic browser-cookie removal, not a fifteen-minute wall-clock browser soak. Fractional real-clock retention and exact exclusive server authorization have separate executed regressions. Accessibility evidence covers the specified automated desktop journey, not a manual assistive-reader audit. Placeholder callback/ownership probes remain test-only; future financial actions need domain transaction authorization.

Only T028 is completed. T029 requires a separate final reviewer; the old review FAIL remains historical and is not overwritten here. No commits, pushes, PRs, merges or workflow-state changes.

Verdict: PASS
