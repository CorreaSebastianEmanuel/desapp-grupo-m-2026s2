# Tasks Handoff: CP1 Acceptance Evidence

## Resolutions

- The ten FR-003 obligations remain the only top-level CP1 gates. Coverage, integration execution, pagination/filter combinations, and revocation are nested regressions whose failure invalidates their owning gate; they are not additional gates.
- The manifest is editable source; generated JSON is the authoritative verdict and Markdown is a deterministic projection. Neither prose nor a committed self-SHA may override evaluation.
- Local and PR runs are preflight. A working-tree snapshot is always `NOT PASSING`; final PASS can exist only after the integrated `main` SHA has matching completed GitHub and Sonar evidence.
- Tests precede implementation in every story. Security tests cover prevention at capture boundaries plus scanning before atomic publication; post-disclosure redaction is not accepted.
- The repeatability boundary is an explicit disposable database, exact 44-record invariants asserted twice, fresh demo users, private transient credentials, and no live provider dependency.

## Remaining risks

- Artifact retention may not satisfy an unstated permanence requirement. Use the maximum repository-supported retention and stable navigation; request a product decision before adding external storage.
- Hosted evidence can be unavailable despite correct local behavior. This must remain visible as non-passing, not be replaced by an older run.
- Shell, Phoenix, SQL, browser, or failure output can leak secrets. Keep child streams private; a scanner is only the final guard.

## Sequencing guidance

Build US1 and US2 after the shared manifest/fixtures, then integrate both through US3. Complete local verification before independent QA and final review. Run the authoritative evidence step only after merge; do not block implementation completion by pretending post-merge evidence already exists.
