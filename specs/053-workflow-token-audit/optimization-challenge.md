# Independent challenge: authorized delivery optimizations

Scope: acceptance 10–16 and the authorized optimization boundary. The six-session design preserves independent criticism, QA and review. No unresolved product decision requires a human check; the following conservative implementation rules fit the authorized scope.

1. **Readiness must prove current inputs.** A command's zero exit status alone cannot establish readiness. Define the fingerprint over the complete relevant source/configuration set, the specification, planning artifacts, manifest and implementation-task state. Include untracked source files and detect deletions. Validate receipt structure, command identity, evidence-file existence and matching hashes. Changes during execution invalidate the receipt. Hashing only tracked files or timestamps risks false readiness.

2. **Coverage needs semantic enforcement.** Parse FR/AC/SC identifiers conservatively, reject duplicate or unknown mappings, and require every identifier to map to an executable command. Reject empty argument arrays and malformed records. Deferred tags must apply only to explicitly identified QA/review work; a deferred implementation task must still block readiness. Detect HTTP obligations independently of a manifest author's classification, including planned contracts, and require a runtime check with a concrete expected result.

3. **Receipts preserve failure.** Remove or supersede older success evidence before re-execution; a failed or interrupted attempt cannot reuse a previous passing receipt. Runtime/service failures remain failures even when a wrapper exits successfully. Independent QA must exercise real HTTP and rerun its own scoped checks rather than treating readiness as acceptance.

4. **Console usability includes byte fragments.** Test prompts split across writes without newlines, ANSI sequences, stdout/stderr interleaving, EOF, cancellation and nonzero exits. Keep human gates outside filtered sections, forward stdin promptly, and expose failures and heartbeats without leaking JSON prompts/tool payloads.

5. **Usage is attempt-local and conservative.** Define whether supported CLI counters are cumulative before deriving deltas. Keep baselines per private session hash and counter dimension; unavailable baselines, decreases and inconsistent duplicate events yield unknown rather than zero. Public metrics expose neither identifiers nor hashes permitting cross-run linkage. Test resumed sessions and partial dimensions explicitly.

6. **Frozen feedback preserves approval applicability.** Use snapshot step order and retain historical approvals, but invalidate the active approval when its reviewed artifacts change. Preserve unaffected approvals/artifacts. Test both legacy separate planning and combined planning with matching gate artifacts; never rewrite TASK-015 or silently upgrade its snapshot.
