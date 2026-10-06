# Independently declared expected bases. Overrides below retain stable case IDs.
# Paths are map keys / zero-based row indexes / source B's uppercase cells.
alias FootballMarket.Providers.FixtureData, as: F

case Code.ensure_compiled(F) do
  {:module, _} ->
    :ok

  {:error, _} ->
    Code.require_file(Path.expand("../../support/providers/fixture_data.ex", __DIR__))
end

catalog = %{
  facts: %{
    positions: [
      %{code: "FW", name: "Forward", ref: "FW"},
      %{code: "GK", name: "Goalkeeper", ref: "GK"}
    ],
    league: %{code: "PL", name: "Premier League", ref: "league"},
    season: %{ref: "season", start_year: 2025, end_year: 2026, league_ref: "league"},
    teams: [
      %{code: "RED", name: "Red Team", ref: "red", season_ref: "season"},
      %{code: "BLU", name: "Blue Team", ref: "blue", season_ref: "season"}
    ],
    players: [
      %{
        ref: "first",
        season_ref: "season",
        display_name: "Alex Example",
        team_ref: "red",
        position_ref: "FW"
      },
      %{
        ref: "second",
        season_ref: "season",
        display_name: "Alex Example",
        team_ref: "blue",
        position_ref: "GK"
      }
    ]
  }
}

performances = %{
  facts: %{
    matches: [
      %{
        status: :completed,
        ref: "match",
        season_ref: "season",
        kickoff_at: "2025-01-01T00:00:00.000000Z",
        home_team_ref: "red",
        away_team_ref: "blue"
      }
    ],
    positions: [
      %{code: "FW", name: "Forward", ref: "FW"},
      %{code: "GK", name: "Goalkeeper", ref: "GK"}
    ],
    league: %{code: "PL", name: "Premier League", ref: "league"},
    season: %{ref: "season", start_year: 2025, end_year: 2026, league_ref: "league"},
    performances: [
      %{
        ref: "appearance",
        team_ref: "red",
        position_ref: "FW",
        match_ref: "match",
        player_ref: "first",
        minutes_played: 91,
        counts: %{
          goals: 0,
          assists: 1,
          shots_on_target: 2,
          tackles: 3,
          interceptions: 4,
          saves: 5,
          goals_conceded: 6,
          yellow_cards: 7,
          red_cards: 8
        }
      }
    ],
    teams: [
      %{code: "RED", name: "Red Team", ref: "red", season_ref: "season"},
      %{code: "BLU", name: "Blue Team", ref: "blue", season_ref: "season"}
    ],
    players: [
      %{
        ref: "first",
        season_ref: "season",
        display_name: "Alex Example",
        team_ref: "blue",
        position_ref: "GK"
      }
    ]
  }
}

# Each edit states only this case's differences from its named base.
%{
  "F-C01-PL-2024-2025-A" =>
    F.patch(catalog, [
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-PL-2024-2025-B" =>
    F.patch(catalog, [
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-PL-2025-2026-A" => F.patch(catalog, []),
  "F-C01-PL-2025-2026-B" => F.patch(catalog, []),
  "F-C01-BL1-2024-2025-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-BL1-2024-2025-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-BL1-2025-2026-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"}
    ]),
  "F-C01-BL1-2025-2026-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"}
    ]),
  "F-C01-PD-2024-2025-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-PD-2024-2025-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-PD-2025-2026-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"}
    ]),
  "F-C01-PD-2025-2026-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"}
    ]),
  "F-C01-SA-2024-2025-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-SA-2024-2025-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-SA-2025-2026-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"}
    ]),
  "F-C01-SA-2025-2026-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"}
    ]),
  "F-C01-FL1-2024-2025-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-FL1-2024-2025-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-C01-FL1-2025-2026-A" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"}
    ]),
  "F-C01-FL1-2025-2026-B" =>
    F.patch(catalog, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"}
    ]),
  "F-C02-empty" =>
    F.patch(catalog, [
      {:put, [:facts, :players], []},
      {:put, [:facts, :positions], []},
      {:put, [:facts, :teams], []}
    ]),
  "F-C03-unknown-season" => %{category: :not_found},
  "F-C03-unsupported" => %{category: :unsupported_capability},
  "F-C04-missing-fact" => %{category: :invalid_response},
  "F-C04-blank-label" => %{category: :invalid_response},
  "F-C04-duplicate-ref-identical" => %{category: :invalid_response},
  "F-C04-duplicate-ref-conflicting" => %{category: :invalid_response},
  "F-C04-duplicate-source" => %{category: :invalid_response},
  "F-C04-duplicate-name" => %{category: :invalid_response},
  "F-C04-duplicate-code" => %{category: :invalid_response},
  "F-C04-duplicate-position-name" => %{category: :invalid_response},
  "F-C04-duplicate-position-code" => %{category: :invalid_response},
  "F-C04-cross-season" => %{category: :invalid_response},
  "F-C04-dangling" => %{category: :invalid_response},
  "F-C04-unmapped-position" => %{category: :invalid_response},
  "F-C04-extra-normalized-field" => %{category: :invalid_response},
  "F-C04-binding-missing" => %{category: :invalid_response},
  "F-C04-binding-dangling" => %{category: :invalid_response},
  "F-C04-binding-duplicate" => %{category: :invalid_response},
  "F-C04-league-mismatch" => %{category: :invalid_response},
  "F-C04-season-mismatch" => %{category: :invalid_response},
  "F-C05-same-id-other-kind" => F.patch(catalog, []),
  "F-C05-same-id-other-scope" => F.patch(catalog, []),
  "F-C05-same-id-other-provider" => F.patch(catalog, []),
  "F-P01-PL-2024-2025-A" =>
    F.patch(performances, [
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-PL-2024-2025-B" =>
    F.patch(performances, [
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-PL-2025-2026-A" => F.patch(performances, []),
  "F-P01-PL-2025-2026-B" => F.patch(performances, []),
  "F-P01-BL1-2024-2025-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-BL1-2024-2025-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-BL1-2025-2026-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"}
    ]),
  "F-P01-BL1-2025-2026-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "BL1"},
      {:put, [:facts, :league, :name], "Bundesliga"}
    ]),
  "F-P01-PD-2024-2025-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-PD-2024-2025-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-PD-2025-2026-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"}
    ]),
  "F-P01-PD-2025-2026-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "PD"},
      {:put, [:facts, :league, :name], "La Liga"}
    ]),
  "F-P01-SA-2024-2025-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-SA-2024-2025-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-SA-2025-2026-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"}
    ]),
  "F-P01-SA-2025-2026-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "SA"},
      {:put, [:facts, :league, :name], "Serie A"}
    ]),
  "F-P01-FL1-2024-2025-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-FL1-2024-2025-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"},
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ]),
  "F-P01-FL1-2025-2026-A" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"}
    ]),
  "F-P01-FL1-2025-2026-B" =>
    F.patch(performances, [
      {:put, [:facts, :league, :code], "FL1"},
      {:put, [:facts, :league, :name], "Ligue 1"}
    ]),
  "F-P02-before" =>
    F.patch(catalog, [
      {:put, [:facts, :matches], []},
      {:put, [:facts, :performances], []},
      {:put, [:facts, :players], []},
      {:put, [:facts, :positions], []},
      {:put, [:facts, :teams], []}
    ]),
  "F-P02-lower" => F.patch(performances, []),
  "F-P02-equal-offset" => F.patch(performances, []),
  "F-P02-upper" =>
    F.patch(performances, [
      {:put, [:facts, :matches, 0, :kickoff_at], "2025-01-01T00:00:00.000001Z"}
    ]),
  "F-P02-after" =>
    F.patch(catalog, [
      {:put, [:facts, :matches], []},
      {:put, [:facts, :performances], []},
      {:put, [:facts, :players], []},
      {:put, [:facts, :positions], []},
      {:put, [:facts, :teams], []}
    ]),
  "F-P03-zero" =>
    F.patch(performances, [
      {:put, [:facts, :performances, 0, :counts, :assists], 0},
      {:put, [:facts, :performances, 0, :counts, :goals_conceded], 0},
      {:put, [:facts, :performances, 0, :counts, :interceptions], 0},
      {:put, [:facts, :performances, 0, :counts, :red_cards], 0},
      {:put, [:facts, :performances, 0, :counts, :saves], 0},
      {:put, [:facts, :performances, 0, :counts, :shots_on_target], 0},
      {:put, [:facts, :performances, 0, :counts, :tackles], 0},
      {:put, [:facts, :performances, 0, :counts, :yellow_cards], 0}
    ]),
  "F-P03-nil" =>
    F.patch(performances, [
      {:put, [:facts, :performances, 0, :counts, :assists], nil},
      {:put, [:facts, :performances, 0, :counts, :goals], nil},
      {:put, [:facts, :performances, 0, :counts, :goals_conceded], nil},
      {:put, [:facts, :performances, 0, :counts, :interceptions], nil},
      {:put, [:facts, :performances, 0, :counts, :red_cards], nil},
      {:put, [:facts, :performances, 0, :counts, :saves], nil},
      {:put, [:facts, :performances, 0, :counts, :shots_on_target], nil},
      {:put, [:facts, :performances, 0, :counts, :tackles], nil},
      {:put, [:facts, :performances, 0, :counts, :yellow_cards], nil}
    ]),
  "F-P03-omitted" =>
    F.patch(performances, [
      {:put, [:facts, :performances, 0, :counts, :assists], nil},
      {:put, [:facts, :performances, 0, :counts, :goals], nil},
      {:put, [:facts, :performances, 0, :counts, :goals_conceded], nil},
      {:put, [:facts, :performances, 0, :counts, :interceptions], nil},
      {:put, [:facts, :performances, 0, :counts, :red_cards], nil},
      {:put, [:facts, :performances, 0, :counts, :saves], nil},
      {:put, [:facts, :performances, 0, :counts, :shots_on_target], nil},
      {:put, [:facts, :performances, 0, :counts, :tackles], nil},
      {:put, [:facts, :performances, 0, :counts, :yellow_cards], nil}
    ]),
  "F-P03-zero-minutes-positive-count" =>
    F.patch(performances, [{:put, [:facts, :performances, 0, :minutes_played], 0}]),
  "F-P03-minutes-over-120" =>
    F.patch(performances, [{:put, [:facts, :performances, 0, :minutes_played], 121}]),
  "F-P03-match-no-performance" =>
    F.patch(performances, [
      {:put, [:facts, :performances], []},
      {:put, [:facts, :players], []},
      {:put, [:facts, :positions], []}
    ]),
  "F-P03-empty" =>
    F.patch(catalog, [
      {:put, [:facts, :matches], []},
      {:put, [:facts, :performances], []},
      {:put, [:facts, :players], []},
      {:put, [:facts, :positions], []},
      {:put, [:facts, :teams], []}
    ]),
  "F-P04-filter-mixed" => F.patch(performances, []),
  "F-P05-bad-scope" => %{category: :invalid_response},
  "F-P05-bad-status" => %{category: :invalid_response},
  "F-P05-bad-kickoff" => %{category: :invalid_response},
  "F-P06-eligible-bad-metric" => %{category: :invalid_response},
  "F-P06-eligible-duplicate" => %{category: :invalid_response},
  "F-P06-cross-season-edge" => %{category: :invalid_response},
  "F-P06-dangling-performance-match" => %{category: :invalid_response},
  "F-P06-duplicate-eligible-ref-with-scheduled-copy" => %{category: :invalid_response},
  "F-P07-excluded-only-directory" => F.patch(performances, []),
  "F-P07-retained-player-current-team" =>
    F.patch(performances, [
      {:put, [:facts, :players, 0, :team_ref], "green"},
      {:put, [:facts, :teams],
       [
         %{code: "RED", name: "Red Team", ref: "red", season_ref: "season"},
         %{code: "BLU", name: "Blue Team", ref: "blue", season_ref: "season"},
         %{code: "GRN", name: "Green Team", ref: "green", season_ref: "season"}
       ]}
    ]),
  "F-P08-transfer" => F.patch(performances, []),
  "F-P09-no-capability" => %{category: :unsupported_capability},
  "F-P10-goals-negative" => %{category: :invalid_response},
  "F-P10-goals-fraction" => %{category: :invalid_response},
  "F-P10-goals-boolean" => %{category: :invalid_response},
  "F-P10-goals-text" => %{category: :invalid_response},
  "F-P10-assists-negative" => %{category: :invalid_response},
  "F-P10-assists-fraction" => %{category: :invalid_response},
  "F-P10-assists-boolean" => %{category: :invalid_response},
  "F-P10-assists-text" => %{category: :invalid_response},
  "F-P10-shots_on_target-negative" => %{category: :invalid_response},
  "F-P10-shots_on_target-fraction" => %{category: :invalid_response},
  "F-P10-shots_on_target-boolean" => %{category: :invalid_response},
  "F-P10-shots_on_target-text" => %{category: :invalid_response},
  "F-P10-tackles-negative" => %{category: :invalid_response},
  "F-P10-tackles-fraction" => %{category: :invalid_response},
  "F-P10-tackles-boolean" => %{category: :invalid_response},
  "F-P10-tackles-text" => %{category: :invalid_response},
  "F-P10-interceptions-negative" => %{category: :invalid_response},
  "F-P10-interceptions-fraction" => %{category: :invalid_response},
  "F-P10-interceptions-boolean" => %{category: :invalid_response},
  "F-P10-interceptions-text" => %{category: :invalid_response},
  "F-P10-saves-negative" => %{category: :invalid_response},
  "F-P10-saves-fraction" => %{category: :invalid_response},
  "F-P10-saves-boolean" => %{category: :invalid_response},
  "F-P10-saves-text" => %{category: :invalid_response},
  "F-P10-goals_conceded-negative" => %{category: :invalid_response},
  "F-P10-goals_conceded-fraction" => %{category: :invalid_response},
  "F-P10-goals_conceded-boolean" => %{category: :invalid_response},
  "F-P10-goals_conceded-text" => %{category: :invalid_response},
  "F-P10-yellow_cards-negative" => %{category: :invalid_response},
  "F-P10-yellow_cards-fraction" => %{category: :invalid_response},
  "F-P10-yellow_cards-boolean" => %{category: :invalid_response},
  "F-P10-yellow_cards-text" => %{category: :invalid_response},
  "F-P10-red_cards-negative" => %{category: :invalid_response},
  "F-P10-red_cards-fraction" => %{category: :invalid_response},
  "F-P10-red_cards-boolean" => %{category: :invalid_response},
  "F-P10-red_cards-text" => %{category: :invalid_response},
  "F-P10-minutes_played-negative" => %{category: :invalid_response},
  "F-P10-minutes_played-fraction" => %{category: :invalid_response},
  "F-P10-minutes_played-boolean" => %{category: :invalid_response},
  "F-P10-minutes_played-text" => %{category: :invalid_response},
  "F-P10-unsupported-count" => %{category: :invalid_response},
  "F-P10-missing-minutes" => %{category: :invalid_response},
  "F-P10-missing-kickoff" => %{category: :invalid_response},
  "F-P10-missing-position" => %{category: :invalid_response},
  "F-P10-unknown-league" => %{category: :invalid_response},
  "F-P10-missing-participant" => %{category: :invalid_response},
  "F-P10-same-home-away" => %{category: :invalid_response},
  "F-P10-nonparticipating-team" => %{category: :invalid_response},
  "F-P10-repeat-player-match" => %{category: :invalid_response},
  "F-P10-duplicate-identical" => %{category: :invalid_response},
  "F-P10-duplicate-conflicting" => %{category: :invalid_response},
  "F-P10-rating-substitute" => %{category: :invalid_response},
  "F-P10-team-total-substitute" => %{category: :invalid_response},
  "F-R01-case" => F.patch(catalog, []),
  "F-R01-whitespace" => F.patch(catalog, []),
  "F-R01-string-keys" => F.patch(catalog, []),
  "F-R02-missing" => %{category: :invalid_request},
  "F-R02-unknown-field" => %{category: :invalid_request},
  "F-R02-mixed-keys" => %{category: :invalid_request},
  "F-R02-non-map" => %{category: :invalid_request},
  "F-R02-league" => %{category: :invalid_request},
  "F-R02-year-type" => %{category: :invalid_request},
  "F-R02-year-bool" => %{category: :invalid_request},
  "F-R02-year-gap" => %{category: :invalid_request},
  "F-R02-catalog-bound" => %{category: :invalid_request},
  "F-R02-timeout-type" => %{category: :invalid_request},
  "F-R02-timeout-zero" => %{category: :invalid_request},
  "F-R02-timeout-negative" => %{category: :invalid_request},
  "F-R02-timeout-bool" => %{category: :invalid_request},
  "F-R03-same-year" => F.patch(catalog, [{:put, [:facts, :season, :end_year], 2025}]),
  "F-R03-lower-only" => F.patch(performances, []),
  "F-R03-upper-only" => F.patch(performances, []),
  "F-R03-unbounded" => F.patch(performances, []),
  "F-R03-offset-equal" => F.patch(performances, []),
  "F-R04-naive" => %{category: :invalid_request},
  "F-R04-bad-instant" => %{category: :invalid_request},
  "F-R04-overprecision" => %{category: :invalid_request},
  "F-R04-reversed" => %{category: :invalid_request},
  "F-E01-invalid_request" => %{category: :invalid_request},
  "F-I01-invalid_request" => %{category: :invalid_request},
  "F-E01-unsupported_capability" => %{category: :unsupported_capability},
  "F-I01-unsupported_capability" => %{category: :unsupported_capability},
  "F-E01-not_found" => %{category: :not_found},
  "F-I01-not_found" => %{category: :not_found},
  "F-E01-authentication_failed" => %{category: :authentication_failed},
  "F-I01-authentication_failed" => %{category: :authentication_failed},
  "F-E01-rate_limited" => %{category: :rate_limited},
  "F-I01-rate_limited" => %{category: :rate_limited},
  "F-E01-unavailable" => %{category: :unavailable},
  "F-I01-unavailable" => %{category: :unavailable},
  "F-E01-timeout" => %{category: :timeout},
  "F-I01-timeout" => %{category: :timeout},
  "F-E01-invalid_response" => %{category: :invalid_response},
  "F-I01-invalid_response" => %{category: :invalid_response},
  "F-E02-known-delay" => %{category: :rate_limited, retry_after_ms: 17},
  "F-E02-unknown-delay" => %{category: :rate_limited},
  "F-E02-bad-delay" => %{category: :invalid_response},
  "F-E03-url" => %{category: :invalid_response},
  "F-E03-userinfo" => %{category: :invalid_response},
  "F-E03-token-query" => %{category: :invalid_response},
  "F-E03-header" => %{category: :invalid_response},
  "F-E03-source-ref" => %{category: :invalid_response},
  "F-E03-source-id" => %{category: :invalid_response},
  "F-E03-fixture-id" => %{category: :invalid_response},
  "F-E03-exception" => %{category: :unavailable},
  "F-E03-unknown-key" => %{category: :invalid_request},
  "F-E03-provider-label" => %{category: :invalid_response},
  "F-D01-default-before" => F.patch(catalog, []),
  "F-D01-default-at" => %{category: :timeout},
  "F-D01-default-after" => %{category: :timeout},
  "F-D01-default-never" => %{category: :timeout},
  "F-D02-custom-before" => F.patch(catalog, []),
  "F-D02-custom-at" => %{category: :timeout},
  "F-D02-custom-after" => %{category: :timeout},
  "F-D02-custom-validation-delay" => %{category: :timeout},
  "F-D02-custom-error-at-boundary" => %{category: :timeout},
  "F-D03-pages-complete" => F.patch(catalog, []),
  "F-D04-later-page-error" => %{category: :unavailable},
  "F-D04-later-page-timeout" => %{category: :timeout},
  "F-D04-cumulative-page-delay" => %{category: :timeout},
  "F-D05-late-result" => %{category: :timeout},
  "F-D05-next-call" => %{category: :timeout},
  "F-D05-caller-exit" => %{category: :timeout},
  "F-D05-crash" => %{category: :unavailable},
  "F-O01-repeat" => F.patch(catalog, []),
  "F-O02-bijection-negative" => F.patch(catalog, []),
  "F-O03-traceability" => F.patch(catalog, []),
  "F-C05-same-id-other-scope-2024" =>
    F.patch(catalog, [
      {:put, [:facts, :season, :end_year], 2025},
      {:put, [:facts, :season, :start_year], 2024}
    ])
}
