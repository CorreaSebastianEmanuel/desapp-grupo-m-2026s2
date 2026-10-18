%{
  "complete" => %{
    origin: "Synthetic controlled provider fixture",
    created_at: ~U[2026-10-16 00:00:00.000000Z],
    digest: "223499961947814cc72770dca89f410b65e007d5d1e8c0e2618c95c76a32d3c7",
    non_live: true,
    rules: ["complete-scope", "unchanged", "replay", "immutable-conflict", "provenance"]
  },
  "empty" => %{
    origin: "Synthetic controlled provider fixture",
    created_at: ~U[2026-10-16 00:00:00.000000Z],
    digest: "223499961947814cc72770dca89f410b65e007d5d1e8c0e2618c95c76a32d3c7",
    non_live: true,
    rules: ["complete-empty"]
  },
  "incomplete" => %{
    origin: "Synthetic controlled provider fixture",
    created_at: ~U[2026-10-16 00:00:00.000000Z],
    digest: "223499961947814cc72770dca89f410b65e007d5d1e8c0e2618c95c76a32d3c7",
    non_live: true,
    rules: ["missing-detail"]
  },
  "position" => %{
    origin: "Synthetic controlled provider fixture",
    created_at: ~U[2026-10-16 00:00:00.000000Z],
    digest: "223499961947814cc72770dca89f410b65e007d5d1e8c0e2618c95c76a32d3c7",
    non_live: true,
    rules: [
      "unique-mode",
      "same-season-prior-history",
      "proposed-batch-exclusion",
      "tie-is-unknown",
      "insufficient-history-is-unknown",
      "equal-and-later-kickoff-exclusion",
      "direct-position-precedence"
    ]
  },
  "metrics" => %{
    origin: "Synthetic controlled provider fixture",
    created_at: ~U[2026-10-16 00:00:00.000000Z],
    digest: "223499961947814cc72770dca89f410b65e007d5d1e8c0e2618c95c76a32d3c7",
    non_live: true,
    rules: ["nine-independent-metrics", "unknown-nil", "explicit-zero"]
  }
}
