# Product Handoff

- The active configuration identity is the eligibility boundary. A same-named strategy or quote from another immutable version must not leak into the ranking.
- Ranking may be sparse after activation changes until matching quotes exist. Do not trigger recalculation or show stale quotes from another configuration as a fallback.
- Product selected effective time as cross-season recency, then quote sequence for same-time ties, and player identifier for equal-price ordering. These rules make ordering total and reproducible.
- TASK-027 owns individual quote exposure/history and TASK-047 owns ranking presentation; keep this task to the ranking read contract.
