%{
  default_attempts: 3,
  retry_seconds: [60, 300],
  initial_counts: %{
    "league" => %{"created" => 1, "updated" => 0, "unchanged" => 0},
    "season" => %{"created" => 1, "updated" => 0, "unchanged" => 0},
    "team" => %{"created" => 2, "updated" => 0, "unchanged" => 0},
    "player" => %{"created" => 1, "updated" => 0, "unchanged" => 0}
  },
  player_names: ["Alex"],
  latest_daily: ~U[2026-10-20 00:00:00.000000Z]
}
