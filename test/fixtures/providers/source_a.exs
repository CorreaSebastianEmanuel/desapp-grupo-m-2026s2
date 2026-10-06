# Independently declared source_a bases. Overrides below retain stable case IDs.
# Paths are map keys / zero-based row indexes / source B's uppercase cells.
alias FootballMarket.Providers.FixtureData, as: F

case Code.ensure_compiled(F) do
  {:module, _} ->
    :ok

  {:error, _} ->
    Code.require_file(Path.expand("../../support/providers/fixture_data.ex", __DIR__))
end

catalog = %{
  "document" => %{
    "candidate" => %{
      "bindings" => [
        %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
        %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
        %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
        %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
        %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
        %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
      ],
      "facts" => %{
        "league" => %{"code" => "PL", "name" => "Premier League", "ref" => "a/league"},
        "players" => [
          %{
            "display_name" => " Alex Example ",
            "position_ref" => "FW",
            "ref" => "a/first",
            "season_ref" => "a/season",
            "team_ref" => "a/red"
          },
          %{
            "display_name" => "Alex Example",
            "position_ref" => "GK",
            "ref" => "a/second",
            "season_ref" => "a/season",
            "team_ref" => "a/blue"
          }
        ],
        "positions" => [
          %{"code" => "FW", "name" => "Forward", "ref" => "FW"},
          %{"code" => "GK", "name" => "Goalkeeper", "ref" => "GK"}
        ],
        "season" => %{
          "end_year" => 2026,
          "league_ref" => "a/league",
          "ref" => "a/season",
          "start_year" => 2025
        },
        "teams" => [
          %{
            "code" => " RED ",
            "name" => " Red Team ",
            "ref" => "a/red",
            "season_ref" => "a/season"
          },
          %{"code" => "BLU", "name" => "Blue Team", "ref" => "a/blue", "season_ref" => "a/season"}
        ]
      },
      "fixture_id" => "F-C01-PL-2025-2026-A",
      "operation" => :catalog,
      "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025}
    },
    "elapsed_us" => 0,
    "portions" => []
  },
  "ignored_attempted_tackles" => 888,
  "ignored_team_goals" => 999,
  "ignored_vendor_rating" => 9876
}

performances = %{
  "document" => %{
    "candidate" => %{
      "bindings" => [
        %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
        %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
        %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
        %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
        %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
        %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
        %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
      ],
      "facts" => %{
        "league" => %{"code" => "PL", "name" => "Premier League", "ref" => "a/league"},
        "matches" => [
          %{
            "away_team_ref" => "a/blue",
            "home_team_ref" => "a/red",
            "kickoff_at" => "2025-01-01T00:00:00.000000Z",
            "ref" => "a/match",
            "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
            "season_ref" => "a/season",
            "status" => :completed
          }
        ],
        "performances" => [
          %{
            "counts" => %{
              "assists" => 1,
              "goals" => 0,
              "goals_conceded" => 6,
              "interceptions" => 4,
              "red_cards" => 8,
              "saves" => 5,
              "shots_on_target" => 2,
              "tackles" => 3,
              "yellow_cards" => 7
            },
            "match_ref" => "a/match",
            "minutes_played" => 91,
            "player_ref" => "a/first",
            "position_ref" => "FW",
            "ref" => "a/appearance",
            "team_ref" => "a/red"
          }
        ],
        "players" => [
          %{
            "display_name" => " Alex Example ",
            "position_ref" => "GK",
            "ref" => "a/first",
            "season_ref" => "a/season",
            "team_ref" => "a/blue"
          },
          %{
            "display_name" => "Alex Example",
            "position_ref" => "GK",
            "ref" => "a/second",
            "season_ref" => "a/season",
            "team_ref" => "a/blue"
          }
        ],
        "positions" => [
          %{"code" => "FW", "name" => "Forward", "ref" => "FW"},
          %{"code" => "GK", "name" => "Goalkeeper", "ref" => "GK"}
        ],
        "season" => %{
          "end_year" => 2026,
          "league_ref" => "a/league",
          "ref" => "a/season",
          "start_year" => 2025
        },
        "teams" => [
          %{
            "code" => " RED ",
            "name" => " Red Team ",
            "ref" => "a/red",
            "season_ref" => "a/season"
          },
          %{"code" => "BLU", "name" => "Blue Team", "ref" => "a/blue", "season_ref" => "a/season"}
        ]
      },
      "fixture_id" => "F-P01-PL-2025-2026-A",
      "operation" => :performances,
      "scope" => %{
        "end_year" => 2026,
        "from" => nil,
        "league_code" => "PL",
        "start_year" => 2025,
        "to" => nil
      }
    },
    "elapsed_us" => 0,
    "portions" => []
  },
  "ignored_attempted_tackles" => 888,
  "ignored_team_goals" => 999,
  "ignored_vendor_rating" => 9876
}

# Each edit states only this case's differences from its named base.
%{
  "F-C01-PL-2024-2025-A" =>
    F.source_a("F-C01-PL-2024-2025-A", catalog, [
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-PL-2024-2025-B" =>
    F.source_a("F-C01-PL-2024-2025-B", catalog, [
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-PL-2025-2026-A" => F.source_a("F-C01-PL-2025-2026-A", catalog, []),
  "F-C01-PL-2025-2026-B" => F.source_a("F-C01-PL-2025-2026-B", catalog, []),
  "F-C01-BL1-2024-2025-A" =>
    F.source_a("F-C01-BL1-2024-2025-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-BL1-2024-2025-B" =>
    F.source_a("F-C01-BL1-2024-2025-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-BL1-2025-2026-A" =>
    F.source_a("F-C01-BL1-2025-2026-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"}
    ]),
  "F-C01-BL1-2025-2026-B" =>
    F.source_a("F-C01-BL1-2025-2026-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"}
    ]),
  "F-C01-PD-2024-2025-A" =>
    F.source_a("F-C01-PD-2024-2025-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-PD-2024-2025-B" =>
    F.source_a("F-C01-PD-2024-2025-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-PD-2025-2026-A" =>
    F.source_a("F-C01-PD-2025-2026-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"}
    ]),
  "F-C01-PD-2025-2026-B" =>
    F.source_a("F-C01-PD-2025-2026-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"}
    ]),
  "F-C01-SA-2024-2025-A" =>
    F.source_a("F-C01-SA-2024-2025-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-SA-2024-2025-B" =>
    F.source_a("F-C01-SA-2024-2025-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-SA-2025-2026-A" =>
    F.source_a("F-C01-SA-2025-2026-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"}
    ]),
  "F-C01-SA-2025-2026-B" =>
    F.source_a("F-C01-SA-2025-2026-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"}
    ]),
  "F-C01-FL1-2024-2025-A" =>
    F.source_a("F-C01-FL1-2024-2025-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-FL1-2024-2025-B" =>
    F.source_a("F-C01-FL1-2024-2025-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-C01-FL1-2025-2026-A" =>
    F.source_a("F-C01-FL1-2025-2026-A", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"}
    ]),
  "F-C01-FL1-2025-2026-B" =>
    F.source_a("F-C01-FL1-2025-2026-B", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"}
    ]),
  "F-C02-empty" =>
    F.source_a("F-C02-empty", catalog, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"}
       ]},
      {:put, ["document", "candidate", "facts", "players"], []},
      {:put, ["document", "candidate", "facts", "positions"], []},
      {:put, ["document", "candidate", "facts", "teams"], []}
    ]),
  "F-C03-unknown-season" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :not_found}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-C03-unsupported" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-C04-missing-fact" =>
    F.source_a("F-C04-missing-fact", catalog,
      drop: ["document", "candidate", "facts", "players", 0, "display_name"]
    ),
  "F-C04-blank-label" =>
    F.source_a("F-C04-blank-label", catalog, [
      {:put, ["document", "candidate", "facts", "teams", 0, "name"], " "}
    ]),
  "F-C04-duplicate-ref-identical" =>
    F.source_a("F-C04-duplicate-ref-identical", catalog, [
      {:put, ["document", "candidate", "facts", "players"],
       [
         %{
           "display_name" => " Alex Example ",
           "position_ref" => "FW",
           "ref" => "a/first",
           "season_ref" => "a/season",
           "team_ref" => "a/red"
         },
         %{
           "display_name" => "Alex Example",
           "position_ref" => "GK",
           "ref" => "a/second",
           "season_ref" => "a/season",
           "team_ref" => "a/blue"
         },
         %{
           "display_name" => " Alex Example ",
           "position_ref" => "FW",
           "ref" => "a/first",
           "season_ref" => "a/season",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-C04-duplicate-ref-conflicting" =>
    F.source_a("F-C04-duplicate-ref-conflicting", catalog, [
      {:put, ["document", "candidate", "facts", "players"],
       [
         %{
           "display_name" => " Alex Example ",
           "position_ref" => "FW",
           "ref" => "a/first",
           "season_ref" => "a/season",
           "team_ref" => "a/red"
         },
         %{
           "display_name" => "Alex Example",
           "position_ref" => "GK",
           "ref" => "a/second",
           "season_ref" => "a/season",
           "team_ref" => "a/blue"
         },
         %{
           "display_name" => "Other",
           "position_ref" => "FW",
           "ref" => "a/first",
           "season_ref" => "a/season",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-C04-duplicate-source" =>
    F.source_a("F-C04-duplicate-source", catalog, [
      {:put, ["document", "candidate", "bindings", 5, "source_id"], "A-source-a/first"}
    ]),
  "F-C04-duplicate-name" =>
    F.source_a("F-C04-duplicate-name", catalog, [
      {:put, ["document", "candidate", "facts", "teams", 1, "name"], " red team "}
    ]),
  "F-C04-duplicate-code" =>
    F.source_a("F-C04-duplicate-code", catalog, [
      {:put, ["document", "candidate", "facts", "teams", 1, "code"], " red "}
    ]),
  "F-C04-duplicate-position-name" =>
    F.source_a("F-C04-duplicate-position-name", catalog, [
      {:put, ["document", "candidate", "facts", "positions", 1, "name"], " forward "}
    ]),
  "F-C04-duplicate-position-code" =>
    F.source_a("F-C04-duplicate-position-code", catalog, [
      {:put, ["document", "candidate", "facts", "positions", 1, "code"], "FW"}
    ]),
  "F-C04-cross-season" =>
    F.source_a("F-C04-cross-season", catalog, [
      {:put, ["document", "candidate", "facts", "players", 0, "season_ref"], "other-season"}
    ]),
  "F-C04-dangling" =>
    F.source_a("F-C04-dangling", catalog, [
      {:put, ["document", "candidate", "facts", "players", 0, "team_ref"], "missing"}
    ]),
  "F-C04-unmapped-position" =>
    F.source_a("F-C04-unmapped-position", catalog, [
      {:put, ["document", "candidate", "facts", "players", 0, "position_ref"], "UNKNOWN"}
    ]),
  "F-C04-extra-normalized-field" =>
    F.source_a("F-C04-extra-normalized-field", catalog, [
      {:put, ["document", "candidate", "facts", "players", 0, "rating"], 87}
    ]),
  "F-C04-binding-missing" =>
    F.source_a("F-C04-binding-missing", catalog, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
         %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
         %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
         %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"}
       ]}
    ]),
  "F-C04-binding-dangling" =>
    F.source_a("F-C04-binding-dangling", catalog, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
         %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
         %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
         %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
         %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
         %{"kind" => :team, "ref" => "missing", "source_id" => "safe"}
       ]}
    ]),
  "F-C04-binding-duplicate" =>
    F.source_a("F-C04-binding-duplicate", catalog, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
         %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
         %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
         %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
         %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"}
       ]}
    ]),
  "F-C04-league-mismatch" =>
    F.source_a("F-C04-league-mismatch", catalog, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"}
    ]),
  "F-C04-season-mismatch" =>
    F.source_a("F-C04-season-mismatch", catalog, [
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2027}
    ]),
  "F-C05-same-id-other-kind" =>
    F.source_a("F-C05-same-id-other-kind", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"], "shared-public-id"},
      {:put, ["document", "candidate", "bindings", 1, "source_id"], "shared-public-id"}
    ]),
  "F-C05-same-id-other-scope" =>
    F.source_a("F-C05-same-id-other-scope", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"], "shared-public-id"},
      {:put, ["document", "candidate", "bindings", 1, "source_id"], "shared-public-id"}
    ]),
  "F-C05-same-id-other-provider" =>
    F.source_a("F-C05-same-id-other-provider", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"], "shared-public-id"},
      {:put, ["document", "candidate", "bindings", 1, "source_id"], "shared-public-id"}
    ]),
  "F-P01-PL-2024-2025-A" =>
    F.source_a("F-P01-PL-2024-2025-A", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-PL-2024-2025-B" =>
    F.source_a("F-P01-PL-2024-2025-B", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-PL-2025-2026-A" => F.source_a("F-P01-PL-2025-2026-A", performances, []),
  "F-P01-PL-2025-2026-B" => F.source_a("F-P01-PL-2025-2026-B", performances, []),
  "F-P01-BL1-2024-2025-A" =>
    F.source_a("F-P01-BL1-2024-2025-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-BL1-2024-2025-B" =>
    F.source_a("F-P01-BL1-2024-2025-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-BL1-2025-2026-A" =>
    F.source_a("F-P01-BL1-2025-2026-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"}
    ]),
  "F-P01-BL1-2025-2026-B" =>
    F.source_a("F-P01-BL1-2025-2026-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "BL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Bundesliga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "BL1"},
      {:put, ["document", "candidate", "scope", "league_code"], "BL1"}
    ]),
  "F-P01-PD-2024-2025-A" =>
    F.source_a("F-P01-PD-2024-2025-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-PD-2024-2025-B" =>
    F.source_a("F-P01-PD-2024-2025-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-PD-2025-2026-A" =>
    F.source_a("F-P01-PD-2025-2026-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"}
    ]),
  "F-P01-PD-2025-2026-B" =>
    F.source_a("F-P01-PD-2025-2026-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "PD"},
      {:put, ["document", "candidate", "facts", "league", "name"], "La Liga"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "PD"},
      {:put, ["document", "candidate", "scope", "league_code"], "PD"}
    ]),
  "F-P01-SA-2024-2025-A" =>
    F.source_a("F-P01-SA-2024-2025-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-SA-2024-2025-B" =>
    F.source_a("F-P01-SA-2024-2025-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-SA-2025-2026-A" =>
    F.source_a("F-P01-SA-2025-2026-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"}
    ]),
  "F-P01-SA-2025-2026-B" =>
    F.source_a("F-P01-SA-2025-2026-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "SA"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Serie A"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "SA"},
      {:put, ["document", "candidate", "scope", "league_code"], "SA"}
    ]),
  "F-P01-FL1-2024-2025-A" =>
    F.source_a("F-P01-FL1-2024-2025-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-FL1-2024-2025-B" =>
    F.source_a("F-P01-FL1-2024-2025-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "start_year"], 2024},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ]),
  "F-P01-FL1-2025-2026-A" =>
    F.source_a("F-P01-FL1-2025-2026-A", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"}
    ]),
  "F-P01-FL1-2025-2026-B" =>
    F.source_a("F-P01-FL1-2025-2026-B", performances, [
      {:put, ["document", "candidate", "facts", "league", "code"], "FL1"},
      {:put, ["document", "candidate", "facts", "league", "name"], "Ligue 1"},
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "FL1"},
      {:put, ["document", "candidate", "scope", "league_code"], "FL1"}
    ]),
  "F-P02-before" =>
    F.source_a("F-P02-before", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "kickoff_at"],
       "2024-12-31T23:59:59.999999Z"}
    ]),
  "F-P02-lower" => F.source_a("F-P02-lower", performances, []),
  "F-P02-equal-offset" =>
    F.source_a("F-P02-equal-offset", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "kickoff_at"],
       "2025-01-01T01:00:00.000000+01:00"}
    ]),
  "F-P02-upper" =>
    F.source_a("F-P02-upper", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "kickoff_at"],
       "2025-01-01T00:00:00.000001Z"}
    ]),
  "F-P02-after" =>
    F.source_a("F-P02-after", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "kickoff_at"],
       "2025-01-01T00:00:00.000002Z"}
    ]),
  "F-P03-zero" =>
    F.source_a("F-P03-zero", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "assists"], 0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
       0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"], 0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"], 0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "saves"], 0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
       0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"], 0},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"], 0}
    ]),
  "F-P03-nil" =>
    F.source_a("F-P03-nil", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "assists"], nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals"], nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
       nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"],
       nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"], nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "saves"], nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
       nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"], nil},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"], nil}
    ]),
  "F-P03-omitted" =>
    F.source_a("F-P03-omitted", performances,
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "assists"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "goals"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "saves"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "tackles"],
      drop: ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"]
    ),
  "F-P03-zero-minutes-positive-count" =>
    F.source_a("F-P03-zero-minutes-positive-count", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "minutes_played"], 0}
    ]),
  "F-P03-minutes-over-120" =>
    F.source_a("F-P03-minutes-over-120", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "minutes_played"], 121}
    ]),
  "F-P03-match-no-performance" =>
    F.source_a("F-P03-match-no-performance", performances, [
      {:put, ["document", "candidate", "facts", "performances"], []}
    ]),
  "F-P03-empty" =>
    F.source_a("F-P03-empty", catalog, [
      {:put, ["document", "candidate", "facts", "matches"], []},
      {:put, ["document", "candidate", "facts", "performances"], []},
      {:put, ["document", "candidate", "facts", "players", 0, "position_ref"], "GK"},
      {:put, ["document", "candidate", "facts", "players", 0, "team_ref"], "a/blue"},
      {:put, ["document", "candidate", "operation"], :performances},
      {:put, ["document", "candidate", "scope", "from"], nil},
      {:put, ["document", "candidate", "scope", "to"], nil}
    ]),
  "F-P04-filter-mixed" =>
    F.source_a("F-P04-filter-mixed", performances, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
         %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
         %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
         %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
         %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
         %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"},
         %{
           "kind" => :match,
           "ref" => "a/excluded-scheduled",
           "source_id" => "A-excluded-scheduled"
         },
         %{"kind" => :match, "ref" => "a/excluded-live", "source_id" => "A-excluded-live"},
         %{
           "kind" => :match,
           "ref" => "a/excluded-postponed",
           "source_id" => "A-excluded-postponed"
         },
         %{
           "kind" => :match,
           "ref" => "a/excluded-abandoned",
           "source_id" => "A-excluded-abandoned"
         },
         %{"kind" => :match, "ref" => "a/old", "source_id" => "A-old"},
         %{"kind" => :match, "ref" => "a/different-scope", "source_id" => "A-different-scope"}
       ]},
      {:put, ["document", "candidate", "facts", "matches"],
       [
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "kickoff_at" => "2025-01-01T00:00:00.000000Z",
           "ref" => "a/match",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :completed
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "ref" => "a/excluded-scheduled",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :scheduled
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "ref" => "a/excluded-live",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :live
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "ref" => "a/excluded-postponed",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :postponed
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "ref" => "a/excluded-abandoned",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :abandoned
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "kickoff_at" => "2024-01-01T00:00:00.000000Z",
           "ref" => "a/old",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :completed
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "kickoff_at" => "invalid-unused",
           "ref" => "a/different-scope",
           "scope" => %{"end_year" => 2025, "league_code" => "SA", "start_year" => 2024},
           "season_ref" => "a/season",
           "status" => :completed
         }
       ]},
      {:put, ["document", "candidate", "facts", "performances"],
       [
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{"goals" => -1},
           "match_ref" => "a/excluded-scheduled",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/excluded-performance-scheduled",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{"goals" => -1},
           "match_ref" => "a/excluded-live",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/excluded-performance-live",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{"goals" => -1},
           "match_ref" => "a/excluded-postponed",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/excluded-performance-postponed",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{"goals" => -1},
           "match_ref" => "a/excluded-abandoned",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/excluded-performance-abandoned",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{"goals" => -10},
           "match_ref" => "a/old",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/old-perf",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{"goals" => -1},
           "match_ref" => "a/different-scope",
           "minutes_played" => 91,
           "player_ref" => "unused-dangling",
           "position_ref" => "FW",
           "ref" => "a/different-scope-perf",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-P05-bad-scope" =>
    F.source_a("F-P05-bad-scope", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "ZZ"}
    ]),
  "F-P05-bad-status" =>
    F.source_a("F-P05-bad-status", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "status"], :unknown}
    ]),
  "F-P05-bad-kickoff" =>
    F.source_a("F-P05-bad-kickoff", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "kickoff_at"], "2025-01-01"}
    ]),
  "F-P06-eligible-bad-metric" =>
    F.source_a("F-P06-eligible-bad-metric", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals"], -1}
    ]),
  "F-P06-eligible-duplicate" =>
    F.source_a("F-P06-eligible-duplicate", performances, [
      {:put, ["document", "candidate", "facts", "performances"],
       [
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-P06-cross-season-edge" =>
    F.source_a("F-P06-cross-season-edge", performances, [
      {:put, ["document", "candidate", "facts", "players", 0, "season_ref"], "different"}
    ]),
  "F-P06-dangling-performance-match" =>
    F.source_a("F-P06-dangling-performance-match", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "match_ref"], "undeclared"}
    ]),
  "F-P06-duplicate-eligible-ref-with-scheduled-copy" =>
    F.source_a("F-P06-duplicate-eligible-ref-with-scheduled-copy", performances, [
      {:put, ["document", "candidate", "facts", "matches"],
       [
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "kickoff_at" => "2025-01-01T00:00:00.000000Z",
           "ref" => "a/match",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :completed
         },
         %{
           "away_team_ref" => "a/blue",
           "home_team_ref" => "a/red",
           "kickoff_at" => "2025-01-01T00:00:00.000000Z",
           "ref" => "a/match",
           "scope" => %{"end_year" => 2026, "league_code" => "PL", "start_year" => 2025},
           "season_ref" => "a/season",
           "status" => :scheduled
         }
       ]}
    ]),
  "F-P07-excluded-only-directory" =>
    F.source_a("F-P07-excluded-only-directory", performances, [
      {:put, ["document", "candidate", "facts", "players", 1, "display_name"], nil},
      {:put, ["document", "candidate", "facts", "players", 1, "team_ref"], "unused-dangling"}
    ]),
  "F-P07-retained-player-current-team" =>
    F.source_a("F-P07-retained-player-current-team", performances, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
         %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
         %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
         %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
         %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
         %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"},
         %{"kind" => :team, "ref" => "a/green", "source_id" => "A-source-a/green"}
       ]},
      {:put, ["document", "candidate", "facts", "players", 0, "team_ref"], "a/green"},
      {:put, ["document", "candidate", "facts", "teams"],
       [
         %{
           "code" => " RED ",
           "name" => " Red Team ",
           "ref" => "a/red",
           "season_ref" => "a/season"
         },
         %{"code" => "BLU", "name" => "Blue Team", "ref" => "a/blue", "season_ref" => "a/season"},
         %{
           "code" => "GRN",
           "name" => "Green Team",
           "ref" => "a/green",
           "season_ref" => "a/season"
         }
       ]}
    ]),
  "F-P08-transfer" => F.source_a("F-P08-transfer", performances, []),
  "F-P09-no-capability" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-P10-goals-negative" =>
    F.source_a("F-P10-goals-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals"], -1}
    ]),
  "F-P10-goals-fraction" =>
    F.source_a("F-P10-goals-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals"], 0.5}
    ]),
  "F-P10-goals-boolean" =>
    F.source_a("F-P10-goals-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals"], true}
    ]),
  "F-P10-goals-text" =>
    F.source_a("F-P10-goals-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals"], "1"}
    ]),
  "F-P10-assists-negative" =>
    F.source_a("F-P10-assists-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "assists"], -1}
    ]),
  "F-P10-assists-fraction" =>
    F.source_a("F-P10-assists-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "assists"], 0.5}
    ]),
  "F-P10-assists-boolean" =>
    F.source_a("F-P10-assists-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "assists"], true}
    ]),
  "F-P10-assists-text" =>
    F.source_a("F-P10-assists-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "assists"], "1"}
    ]),
  "F-P10-shots_on_target-negative" =>
    F.source_a("F-P10-shots_on_target-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
       -1}
    ]),
  "F-P10-shots_on_target-fraction" =>
    F.source_a("F-P10-shots_on_target-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
       0.5}
    ]),
  "F-P10-shots_on_target-boolean" =>
    F.source_a("F-P10-shots_on_target-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
       true}
    ]),
  "F-P10-shots_on_target-text" =>
    F.source_a("F-P10-shots_on_target-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"],
       "1"}
    ]),
  "F-P10-tackles-negative" =>
    F.source_a("F-P10-tackles-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"], -1}
    ]),
  "F-P10-tackles-fraction" =>
    F.source_a("F-P10-tackles-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"], 0.5}
    ]),
  "F-P10-tackles-boolean" =>
    F.source_a("F-P10-tackles-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"], true}
    ]),
  "F-P10-tackles-text" =>
    F.source_a("F-P10-tackles-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"], "1"}
    ]),
  "F-P10-interceptions-negative" =>
    F.source_a("F-P10-interceptions-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"], -1}
    ]),
  "F-P10-interceptions-fraction" =>
    F.source_a("F-P10-interceptions-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"],
       0.5}
    ]),
  "F-P10-interceptions-boolean" =>
    F.source_a("F-P10-interceptions-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"],
       true}
    ]),
  "F-P10-interceptions-text" =>
    F.source_a("F-P10-interceptions-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"],
       "1"}
    ]),
  "F-P10-saves-negative" =>
    F.source_a("F-P10-saves-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "saves"], -1}
    ]),
  "F-P10-saves-fraction" =>
    F.source_a("F-P10-saves-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "saves"], 0.5}
    ]),
  "F-P10-saves-boolean" =>
    F.source_a("F-P10-saves-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "saves"], true}
    ]),
  "F-P10-saves-text" =>
    F.source_a("F-P10-saves-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "saves"], "1"}
    ]),
  "F-P10-goals_conceded-negative" =>
    F.source_a("F-P10-goals_conceded-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
       -1}
    ]),
  "F-P10-goals_conceded-fraction" =>
    F.source_a("F-P10-goals_conceded-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
       0.5}
    ]),
  "F-P10-goals_conceded-boolean" =>
    F.source_a("F-P10-goals_conceded-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
       true}
    ]),
  "F-P10-goals_conceded-text" =>
    F.source_a("F-P10-goals_conceded-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"],
       "1"}
    ]),
  "F-P10-yellow_cards-negative" =>
    F.source_a("F-P10-yellow_cards-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"], -1}
    ]),
  "F-P10-yellow_cards-fraction" =>
    F.source_a("F-P10-yellow_cards-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"], 0.5}
    ]),
  "F-P10-yellow_cards-boolean" =>
    F.source_a("F-P10-yellow_cards-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"],
       true}
    ]),
  "F-P10-yellow_cards-text" =>
    F.source_a("F-P10-yellow_cards-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"], "1"}
    ]),
  "F-P10-red_cards-negative" =>
    F.source_a("F-P10-red_cards-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"], -1}
    ]),
  "F-P10-red_cards-fraction" =>
    F.source_a("F-P10-red_cards-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"], 0.5}
    ]),
  "F-P10-red_cards-boolean" =>
    F.source_a("F-P10-red_cards-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"], true}
    ]),
  "F-P10-red_cards-text" =>
    F.source_a("F-P10-red_cards-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"], "1"}
    ]),
  "F-P10-minutes_played-negative" =>
    F.source_a("F-P10-minutes_played-negative", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "minutes_played"], -1}
    ]),
  "F-P10-minutes_played-fraction" =>
    F.source_a("F-P10-minutes_played-fraction", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "minutes_played"], 0.5}
    ]),
  "F-P10-minutes_played-boolean" =>
    F.source_a("F-P10-minutes_played-boolean", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "minutes_played"], true}
    ]),
  "F-P10-minutes_played-text" =>
    F.source_a("F-P10-minutes_played-text", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "minutes_played"], "1"}
    ]),
  "F-P10-unsupported-count" =>
    F.source_a("F-P10-unsupported-count", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "rating"], 10}
    ]),
  "F-P10-missing-minutes" =>
    F.source_a("F-P10-missing-minutes", performances,
      drop: ["document", "candidate", "facts", "performances", 0, "minutes_played"]
    ),
  "F-P10-missing-kickoff" =>
    F.source_a("F-P10-missing-kickoff", performances,
      drop: ["document", "candidate", "facts", "matches", 0, "kickoff_at"]
    ),
  "F-P10-missing-position" =>
    F.source_a("F-P10-missing-position", performances, [
      {:put, ["document", "candidate", "facts", "performances", 0, "position_ref"], "unmapped"}
    ]),
  "F-P10-unknown-league" =>
    F.source_a("F-P10-unknown-league", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "scope", "league_code"], "ZZ"}
    ]),
  "F-P10-missing-participant" =>
    F.source_a("F-P10-missing-participant", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "home_team_ref"], "absent"}
    ]),
  "F-P10-same-home-away" =>
    F.source_a("F-P10-same-home-away", performances, [
      {:put, ["document", "candidate", "facts", "matches", 0, "away_team_ref"], "a/red"}
    ]),
  "F-P10-nonparticipating-team" =>
    F.source_a("F-P10-nonparticipating-team", performances, [
      {:put, ["document", "candidate", "bindings"],
       [
         %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
         %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
         %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
         %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
         %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
         %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
         %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"},
         %{"kind" => :team, "ref" => "a/green", "source_id" => "A-source-a/green"}
       ]},
      {:put, ["document", "candidate", "facts", "performances", 0, "team_ref"], "a/green"},
      {:put, ["document", "candidate", "facts", "players", 0, "team_ref"], "a/green"},
      {:put, ["document", "candidate", "facts", "teams"],
       [
         %{
           "code" => " RED ",
           "name" => " Red Team ",
           "ref" => "a/red",
           "season_ref" => "a/season"
         },
         %{"code" => "BLU", "name" => "Blue Team", "ref" => "a/blue", "season_ref" => "a/season"},
         %{
           "code" => "GRN",
           "name" => "Green Team",
           "ref" => "a/green",
           "season_ref" => "a/season"
         }
       ]}
    ]),
  "F-P10-repeat-player-match" =>
    F.source_a("F-P10-repeat-player-match", performances, [
      {:put, ["document", "candidate", "facts", "performances"],
       [
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "another",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-P10-duplicate-identical" =>
    F.source_a("F-P10-duplicate-identical", performances, [
      {:put, ["document", "candidate", "facts", "performances"],
       [
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-P10-duplicate-conflicting" =>
    F.source_a("F-P10-duplicate-conflicting", performances, [
      {:put, ["document", "candidate", "facts", "performances"],
       [
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 91,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         },
         %{
           "counts" => %{
             "assists" => 1,
             "goals" => 0,
             "goals_conceded" => 6,
             "interceptions" => 4,
             "red_cards" => 8,
             "saves" => 5,
             "shots_on_target" => 2,
             "tackles" => 3,
             "yellow_cards" => 7
           },
           "match_ref" => "a/match",
           "minutes_played" => 20,
           "player_ref" => "a/first",
           "position_ref" => "FW",
           "ref" => "a/appearance",
           "team_ref" => "a/red"
         }
       ]}
    ]),
  "F-P10-rating-substitute" =>
    F.source_a("F-P10-rating-substitute", performances, [
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "assists"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "goals"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "saves"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"]},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "rating"], 10}
    ]),
  "F-P10-team-total-substitute" =>
    F.source_a("F-P10-team-total-substitute", performances, [
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "assists"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "goals"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "goals_conceded"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "interceptions"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "red_cards"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "saves"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "shots_on_target"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "tackles"]},
      {:drop, ["document", "candidate", "facts", "performances", 0, "counts", "yellow_cards"]},
      {:put, ["document", "candidate", "facts", "performances", 0, "counts", "team_goals"], 10}
    ]),
  "F-R01-case" => F.source_a("F-R01-case", catalog, []),
  "F-R01-whitespace" => F.source_a("F-R01-whitespace", catalog, []),
  "F-R01-string-keys" => F.source_a("F-R01-string-keys", catalog, []),
  "F-R02-missing" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-unknown-field" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-mixed-keys" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-non-map" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-league" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-year-type" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-year-bool" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-year-gap" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-catalog-bound" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-timeout-type" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-timeout-zero" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-timeout-negative" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R02-timeout-bool" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R03-same-year" =>
    F.source_a("F-R03-same-year", catalog, [
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "end_year"], 2025}
    ]),
  "F-R03-lower-only" => F.source_a("F-R03-lower-only", performances, []),
  "F-R03-upper-only" => F.source_a("F-R03-upper-only", performances, []),
  "F-R03-unbounded" => F.source_a("F-R03-unbounded", performances, []),
  "F-R03-offset-equal" => F.source_a("F-R03-offset-equal", performances, []),
  "F-R04-naive" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R04-bad-instant" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R04-overprecision" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-R04-reversed" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-invalid_request" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-invalid_request" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-unsupported_capability" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-unsupported_capability" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-not_found" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :not_found}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-not_found" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :not_found}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-authentication_failed" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :authentication_failed}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-authentication_failed" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :authentication_failed}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-rate_limited" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-rate_limited" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-unavailable" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unavailable}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-unavailable" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unavailable}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-timeout" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-timeout" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E01-invalid_response" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_response}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-I01-invalid_response" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_response}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E02-known-delay" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited, "retry_after_ms" => 17}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E02-unknown-delay" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited, "retry_after_ms" => nil}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E02-bad-delay" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited, "retry_after_ms" => -1}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E03-url" =>
    F.source_a("F-E03-url", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"],
       "https://FAKE_SENTINEL.invalid/a"}
    ]),
  "F-E03-userinfo" =>
    F.source_a("F-E03-userinfo", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"],
       "https://FAKE_SENTINEL:pw@invalid/a"}
    ]),
  "F-E03-token-query" =>
    F.source_a("F-E03-token-query", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"],
       "https://invalid/?token=FAKE_SENTINEL"}
    ]),
  "F-E03-header" =>
    F.source_a("F-E03-header", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"],
       "Authorization: Bearer FAKE_SENTINEL"}
    ]),
  "F-E03-source-ref" =>
    F.source_a("F-E03-source-ref", catalog, [
      {:put, ["document", "candidate", "facts", "players", 0, "ref"], "Bearer FAKE_SENTINEL"}
    ]),
  "F-E03-source-id" =>
    F.source_a("F-E03-source-id", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"], "token=FAKE_SENTINEL"}
    ]),
  "F-E03-fixture-id" =>
    F.source_a("F-E03-fixture-id", catalog, [
      {:put, ["document", "candidate", "fixture_id"], "password: FAKE_SENTINEL"}
    ]),
  "F-E03-exception" => %{
    "document" => %{"candidate" => %{"throw" => true}, "elapsed_us" => 0, "portions" => []},
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E03-unknown-key" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-E03-provider-label" =>
    F.source_a("F-E03-provider-label", catalog, [
      {:put, ["document", "candidate", "fixture_id"], "Authorization: FAKE_SENTINEL"}
    ]),
  "F-D01-default-before" =>
    F.source_a("F-D01-default-before", catalog, [{:put, ["document", "elapsed_us"], 4_999_999}]),
  "F-D01-default-at" =>
    F.source_a("F-D01-default-at", catalog, [{:put, ["document", "elapsed_us"], 5_000_000}]),
  "F-D01-default-after" =>
    F.source_a("F-D01-default-after", catalog, [{:put, ["document", "elapsed_us"], 5_000_001}]),
  "F-D01-default-never" =>
    F.source_a("F-D01-default-never", catalog, [{:put, ["document", "elapsed_us"], 10_000_000}]),
  "F-D02-custom-before" =>
    F.source_a("F-D02-custom-before", catalog, [{:put, ["document", "elapsed_us"], 6999}]),
  "F-D02-custom-at" =>
    F.source_a("F-D02-custom-at", catalog, [{:put, ["document", "elapsed_us"], 7000}]),
  "F-D02-custom-after" =>
    F.source_a("F-D02-custom-after", catalog, [{:put, ["document", "elapsed_us"], 7001}]),
  "F-D02-custom-validation-delay" =>
    F.source_a("F-D02-custom-validation-delay", catalog, [
      {:put, ["document", "elapsed_us"], 6999}
    ]),
  "F-D02-custom-error-at-boundary" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 7000,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-D03-pages-complete" =>
    F.source_a("F-D03-pages-complete", catalog, [
      {:put, ["document", "candidate", "facts", "players"], []},
      {:put, ["document", "portions"],
       [
         %{
           "delay_us" => 1000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => " Alex Example ",
                 "position_ref" => "FW",
                 "ref" => "a/first",
                 "season_ref" => "a/season",
                 "team_ref" => "a/red"
               }
             ]
           }
         },
         %{
           "delay_us" => 2000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => "Alex Example",
                 "position_ref" => "GK",
                 "ref" => "a/second",
                 "season_ref" => "a/season",
                 "team_ref" => "a/blue"
               }
             ]
           }
         }
       ]}
    ]),
  "F-D04-later-page-error" =>
    F.source_a("F-D04-later-page-error", catalog, [
      {:put, ["document", "candidate", "facts", "players"], []},
      {:put, ["document", "portions"],
       [
         %{
           "delay_us" => 1000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => " Alex Example ",
                 "position_ref" => "FW",
                 "ref" => "a/first",
                 "season_ref" => "a/season",
                 "team_ref" => "a/red"
               }
             ]
           }
         },
         %{"delay_us" => 1000, "failure" => %{"category" => :unavailable}}
       ]}
    ]),
  "F-D04-later-page-timeout" =>
    F.source_a("F-D04-later-page-timeout", catalog, [
      {:put, ["document", "candidate", "facts", "players"], []},
      {:put, ["document", "portions"],
       [
         %{
           "delay_us" => 2000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => " Alex Example ",
                 "position_ref" => "FW",
                 "ref" => "a/first",
                 "season_ref" => "a/season",
                 "team_ref" => "a/red"
               }
             ]
           }
         },
         %{
           "delay_us" => 5000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => "Alex Example",
                 "position_ref" => "GK",
                 "ref" => "a/second",
                 "season_ref" => "a/season",
                 "team_ref" => "a/blue"
               }
             ]
           }
         }
       ]}
    ]),
  "F-D04-cumulative-page-delay" =>
    F.source_a("F-D04-cumulative-page-delay", catalog, [
      {:put, ["document", "candidate", "facts", "players"], []},
      {:put, ["document", "portions"],
       [
         %{
           "delay_us" => 4000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => " Alex Example ",
                 "position_ref" => "FW",
                 "ref" => "a/first",
                 "season_ref" => "a/season",
                 "team_ref" => "a/red"
               }
             ]
           }
         },
         %{
           "delay_us" => 4000,
           "facts" => %{
             "players" => [
               %{
                 "display_name" => "Alex Example",
                 "position_ref" => "GK",
                 "ref" => "a/second",
                 "season_ref" => "a/season",
                 "team_ref" => "a/blue"
               }
             ]
           }
         }
       ]}
    ]),
  "F-D05-late-result" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-D05-next-call" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-D05-caller-exit" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-D05-crash" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unavailable}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_attempted_tackles" => 888,
    "ignored_team_goals" => 999,
    "ignored_vendor_rating" => 9876
  },
  "F-O01-repeat" => F.source_a("F-O01-repeat", catalog, []),
  "F-O02-bijection-negative" => F.source_a("F-O02-bijection-negative", catalog, []),
  "F-O03-traceability" => F.source_a("F-O03-traceability", catalog, []),
  "F-C05-same-id-other-scope-2024" =>
    F.source_a("F-C05-same-id-other-scope-2024", catalog, [
      {:put, ["document", "candidate", "bindings", 0, "source_id"], "shared-public-id"},
      {:put, ["document", "candidate", "bindings", 1, "source_id"], "shared-public-id"},
      {:put, ["document", "candidate", "facts", "season", "end_year"], 2025},
      {:put, ["document", "candidate", "facts", "season", "start_year"], 2024},
      {:put, ["document", "candidate", "scope", "end_year"], 2025},
      {:put, ["document", "candidate", "scope", "start_year"], 2024}
    ])
}
