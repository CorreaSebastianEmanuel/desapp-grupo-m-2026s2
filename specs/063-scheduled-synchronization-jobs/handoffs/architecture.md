# Architecture delta — TASK-019

ADR-0025 resolves critic findings without changing product scope. Lost completion uses a neutral fenced receipt committed inside existing ingestion publication/replay; recovery can confirm the final attempt without a fourth retrieval. Prepared deliveries and numbered begun attempts are distinct. Oban jobs are one-shot transport; the PostgreSQL ledger owns domain budgets and waits.

A dedicated execution-guard connection owns scope/global-slot session locks. Cleanup must terminate that connection on worker death; never use pooled session locks. Recovery takes the same locks and revokes orphan fences, preventing a delayed old worker from publishing after recovery. Test the receipt-row ordering against guard loss, not just ordinary task exceptions.

Busy and downtime scheduling use a latest pending candidate and compressed supersession audit. Already-associated occurrences stay handled even if their run fails. Enablement generations survive restart but change on disable/re-enable; test the exact boundary.

Persist full non-secret canonical inputs plus fixture digest, compare after resolving references at each execution, and revalidate current access. No saved authorization or source fallback.

Existing scope tests inspect the working tree. Implementation must add exact active-feature allowances with negative cases in the three named scope tests. Preserve config/config.exs byte-for-byte because issuance pins its approved hash; use dedicated synchronization config loaded by runtime/test config. Scope and inventory details belong to plan.md, not this handoff.

No TASK-019 feedback exists. Relevant TASK-018 toolchain and TASK-055 efficiency/access feedback remain authoritative. Do not run historical CP1 coverage or duplicate full profiles. The manifest's dedicated runtime probe runs separately from ExUnit profile discovery. Architecture validation is structural; implementation, independent QA and final review remain pending.
