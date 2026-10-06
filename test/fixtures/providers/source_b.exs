# Independently declared source_b bases. Overrides below retain stable case IDs.
# Paths are map keys / zero-based row indexes / source B's uppercase cells.
alias FootballMarket.Providers.FixtureData, as: F

case Code.ensure_compiled(F) do
  {:module, _} ->
    :ok

  {:error, _} ->
    Code.require_file(Path.expand("../../support/providers/fixture_data.ex", __DIR__))
end

catalog =
  {:packet,
   {:cells,
    [
      {"PORTIONS", {:rows, []}},
      {"ELAPSED_US", 0},
      {"CANDIDATE",
       {:cells,
        [
          {"FIXTURE_ID", "F-C01-PL-2025-2026-A"},
          {"BINDINGS",
           {:rows,
            [
              cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
              cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
              cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
              cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
              cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
              cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]
            ]}},
          {"FACTS",
           {:cells,
            [
              {"PLAYERS",
               {:rows,
                [
                  cells: [
                    {"POSITION_REF", "GK"},
                    {"TEAM_REF", "b#blue"},
                    {"DISPLAY_NAME", "Alex Example"},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#second"}
                  ],
                  cells: [
                    {"POSITION_REF", "FW"},
                    {"TEAM_REF", "b#red"},
                    {"DISPLAY_NAME", " Alex Example "},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#first"}
                  ]
                ]}},
              {"POSITIONS",
               {:rows,
                [
                  cells: [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}],
                  cells: [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]
                ]}},
              {"TEAMS",
               {:rows,
                [
                  cells: [
                    {"CODE", "BLU"},
                    {"NAME", "Blue Team"},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#blue"}
                  ],
                  cells: [
                    {"CODE", " RED "},
                    {"NAME", " Red Team "},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#red"}
                  ]
                ]}},
              {"SEASON",
               {:cells,
                [
                  {"END_YEAR", 2026},
                  {"START_YEAR", 2025},
                  {"LEAGUE_REF", "b#league"},
                  {"REF", "b#season"}
                ]}},
              {"LEAGUE",
               {:cells, [{"NAME", "Premier League"}, {"CODE", "PL"}, {"REF", "b#league"}]}}
            ]}},
          {"SCOPE", {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
          {"OPERATION", :catalog}
        ]}}
    ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}}

performances =
  {:packet,
   {:cells,
    [
      {"PORTIONS", {:rows, []}},
      {"ELAPSED_US", 0},
      {"CANDIDATE",
       {:cells,
        [
          {"FIXTURE_ID", "F-P01-PL-2025-2026-A"},
          {"BINDINGS",
           {:rows,
            [
              cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
              cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
              cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
              cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
              cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
              cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}],
              cells: [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]
            ]}},
          {"FACTS",
           {:cells,
            [
              {"PERFORMANCES",
               {:rows,
                [
                  cells: [
                    {"COUNTS",
                     {:cells,
                      [
                        {"RED_CARDS", 8},
                        {"YELLOW_CARDS", 7},
                        {"GOALS_CONCEDED", 6},
                        {"SAVES", 5},
                        {"INTERCEPTIONS", 4},
                        {"TACKLES", 3},
                        {"SHOTS_ON_TARGET", 2},
                        {"ASSISTS", 1},
                        {"GOALS", 0}
                      ]}},
                    {"MINUTES_PLAYED", 91},
                    {"POSITION_REF", "FW"},
                    {"TEAM_REF", "b#red"},
                    {"PLAYER_REF", "b#first"},
                    {"MATCH_REF", "b#match"},
                    {"REF", "b#appearance"}
                  ]
                ]}},
              {"MATCHES",
               {:rows,
                [
                  cells: [
                    {"SCOPE",
                     {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                    {"AWAY_TEAM_REF", "b#blue"},
                    {"HOME_TEAM_REF", "b#red"},
                    {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                    {"STATUS", :completed},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#match"}
                  ]
                ]}},
              {"PLAYERS",
               {:rows,
                [
                  cells: [
                    {"POSITION_REF", "GK"},
                    {"TEAM_REF", "b#blue"},
                    {"DISPLAY_NAME", "Alex Example"},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#second"}
                  ],
                  cells: [
                    {"POSITION_REF", "GK"},
                    {"TEAM_REF", "b#blue"},
                    {"DISPLAY_NAME", " Alex Example "},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#first"}
                  ]
                ]}},
              {"POSITIONS",
               {:rows,
                [
                  cells: [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}],
                  cells: [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]
                ]}},
              {"TEAMS",
               {:rows,
                [
                  cells: [
                    {"CODE", "BLU"},
                    {"NAME", "Blue Team"},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#blue"}
                  ],
                  cells: [
                    {"CODE", " RED "},
                    {"NAME", " Red Team "},
                    {"SEASON_REF", "b#season"},
                    {"REF", "b#red"}
                  ]
                ]}},
              {"SEASON",
               {:cells,
                [
                  {"END_YEAR", 2026},
                  {"START_YEAR", 2025},
                  {"LEAGUE_REF", "b#league"},
                  {"REF", "b#season"}
                ]}},
              {"LEAGUE",
               {:cells, [{"NAME", "Premier League"}, {"CODE", "PL"}, {"REF", "b#league"}]}}
            ]}},
          {"SCOPE",
           {:cells,
            [
              {"TO", nil},
              {"FROM", nil},
              {"END_YEAR", 2026},
              {"START_YEAR", 2025},
              {"LEAGUE_CODE", "PL"}
            ]}},
          {"OPERATION", :performances}
        ]}}
    ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}}

# Each edit states only this case's differences from its named base.
%{
  "F-C01-PL-2024-2025-A" =>
    F.source_b("F-C01-PL-2024-2025-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024}
    ]),
  "F-C01-PL-2024-2025-B" =>
    F.source_b("F-C01-PL-2024-2025-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024}
    ]),
  "F-C01-PL-2025-2026-A" => F.source_b("F-C01-PL-2025-2026-A", catalog, []),
  "F-C01-PL-2025-2026-B" => F.source_b("F-C01-PL-2025-2026-B", catalog, []),
  "F-C01-BL1-2024-2025-A" =>
    F.source_b("F-C01-BL1-2024-2025-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-C01-BL1-2024-2025-B" =>
    F.source_b("F-C01-BL1-2024-2025-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-C01-BL1-2025-2026-A" =>
    F.source_b("F-C01-BL1-2025-2026-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-C01-BL1-2025-2026-B" =>
    F.source_b("F-C01-BL1-2025-2026-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-C01-PD-2024-2025-A" =>
    F.source_b("F-C01-PD-2024-2025-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-C01-PD-2024-2025-B" =>
    F.source_b("F-C01-PD-2024-2025-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-C01-PD-2025-2026-A" =>
    F.source_b("F-C01-PD-2025-2026-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-C01-PD-2025-2026-B" =>
    F.source_b("F-C01-PD-2025-2026-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-C01-SA-2024-2025-A" =>
    F.source_b("F-C01-SA-2024-2025-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-C01-SA-2024-2025-B" =>
    F.source_b("F-C01-SA-2024-2025-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-C01-SA-2025-2026-A" =>
    F.source_b("F-C01-SA-2025-2026-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-C01-SA-2025-2026-B" =>
    F.source_b("F-C01-SA-2025-2026-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-C01-FL1-2024-2025-A" =>
    F.source_b("F-C01-FL1-2024-2025-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-C01-FL1-2024-2025-B" =>
    F.source_b("F-C01-FL1-2024-2025-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-C01-FL1-2025-2026-A" =>
    F.source_b("F-C01-FL1-2025-2026-A", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-C01-FL1-2025-2026-B" =>
    F.source_b("F-C01-FL1-2025-2026-B", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-C02-empty" =>
    F.source_b("F-C02-empty", catalog, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]
        ]}},
      {:put, ["CANDIDATE", "FACTS", "PLAYERS"], {:rows, []}},
      {:put, ["CANDIDATE", "FACTS", "POSITIONS"], {:rows, []}},
      {:put, ["CANDIDATE", "FACTS", "TEAMS"], {:rows, []}}
    ]),
  "F-C03-unknown-season" =>
    F.source_b("F-C03-unknown-season", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :not_found}]}}]}}
    ]),
  "F-C03-unsupported" =>
    F.source_b("F-C03-unsupported", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
    ]),
  "F-C04-missing-fact" =>
    F.source_b("F-C04-missing-fact", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1],
       {:cells,
        [
          {"POSITION_REF", "FW"},
          {"TEAM_REF", "b#red"},
          {"SEASON_REF", "b#season"},
          {"REF", "b#first"}
        ]}}
    ]),
  "F-C04-blank-label" =>
    F.source_b("F-C04-blank-label", catalog, [
      {:put, ["CANDIDATE", "FACTS", "TEAMS", 1, "NAME"], " "}
    ]),
  "F-C04-duplicate-ref-identical" =>
    F.source_b("F-C04-duplicate-ref-identical", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS"],
       {:rows,
        [
          cells: [
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"DISPLAY_NAME", " Alex Example "},
            {"SEASON_REF", "b#season"},
            {"REF", "b#first"}
          ],
          cells: [
            {"POSITION_REF", "GK"},
            {"TEAM_REF", "b#blue"},
            {"DISPLAY_NAME", "Alex Example"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#second"}
          ],
          cells: [
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"DISPLAY_NAME", " Alex Example "},
            {"SEASON_REF", "b#season"},
            {"REF", "b#first"}
          ]
        ]}}
    ]),
  "F-C04-duplicate-ref-conflicting" =>
    F.source_b("F-C04-duplicate-ref-conflicting", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS"],
       {:rows,
        [
          cells: [
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"DISPLAY_NAME", "Other"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#first"}
          ],
          cells: [
            {"POSITION_REF", "GK"},
            {"TEAM_REF", "b#blue"},
            {"DISPLAY_NAME", "Alex Example"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#second"}
          ],
          cells: [
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"DISPLAY_NAME", " Alex Example "},
            {"SEASON_REF", "b#season"},
            {"REF", "b#first"}
          ]
        ]}}
    ]),
  "F-C04-duplicate-source" =>
    F.source_b("F-C04-duplicate-source", catalog, [
      {:put, ["CANDIDATE", "BINDINGS", 5, "SOURCE_ID"], "B-source-b#first"}
    ]),
  "F-C04-duplicate-name" =>
    F.source_b("F-C04-duplicate-name", catalog, [
      {:put, ["CANDIDATE", "FACTS", "TEAMS", 0, "NAME"], " red team "}
    ]),
  "F-C04-duplicate-code" =>
    F.source_b("F-C04-duplicate-code", catalog, [
      {:put, ["CANDIDATE", "FACTS", "TEAMS", 0, "CODE"], " red "}
    ]),
  "F-C04-duplicate-position-name" =>
    F.source_b("F-C04-duplicate-position-name", catalog, [
      {:put, ["CANDIDATE", "FACTS", "POSITIONS", 0, "NAME"], " forward "}
    ]),
  "F-C04-duplicate-position-code" =>
    F.source_b("F-C04-duplicate-position-code", catalog, [
      {:put, ["CANDIDATE", "FACTS", "POSITIONS", 0, "CODE"], "FW"}
    ]),
  "F-C04-cross-season" =>
    F.source_b("F-C04-cross-season", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "SEASON_REF"], "other-season"}
    ]),
  "F-C04-dangling" =>
    F.source_b("F-C04-dangling", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "TEAM_REF"], "missing"}
    ]),
  "F-C04-unmapped-position" =>
    F.source_b("F-C04-unmapped-position", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "POSITION_REF"], "UNKNOWN"}
    ]),
  "F-C04-extra-normalized-field" =>
    F.source_b("F-C04-extra-normalized-field", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1],
       {:cells,
        [
          {"RATING", 87},
          {"POSITION_REF", "FW"},
          {"TEAM_REF", "b#red"},
          {"DISPLAY_NAME", " Alex Example "},
          {"SEASON_REF", "b#season"},
          {"REF", "b#first"}
        ]}}
    ]),
  "F-C04-binding-missing" =>
    F.source_b("F-C04-binding-missing", catalog, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]
        ]}}
    ]),
  "F-C04-binding-dangling" =>
    F.source_b("F-C04-binding-dangling", catalog, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "safe"}, {"REF", "missing"}, {"KIND", :team}]
        ]}}
    ]),
  "F-C04-binding-duplicate" =>
    F.source_b("F-C04-binding-duplicate", catalog, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]
        ]}}
    ]),
  "F-C04-league-mismatch" =>
    F.source_b("F-C04-league-mismatch", catalog, [
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"}
    ]),
  "F-C04-season-mismatch" =>
    F.source_b("F-C04-season-mismatch", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2027}
    ]),
  "F-C05-same-id-other-kind" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#second"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", "Alex Example"},
                      {"TEAM_REF", "b#blue"},
                      {"POSITION_REF", "GK"}
                    ],
                    cells: [
                      {"REF", "b#first"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", " Alex Example "},
                      {"TEAM_REF", "b#red"},
                      {"POSITION_REF", "FW"}
                    ]
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-kind"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-C05-same-id-other-scope" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#second"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", "Alex Example"},
                      {"TEAM_REF", "b#blue"},
                      {"POSITION_REF", "GK"}
                    ],
                    cells: [
                      {"REF", "b#first"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", " Alex Example "},
                      {"TEAM_REF", "b#red"},
                      {"POSITION_REF", "FW"}
                    ]
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-scope"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-C05-same-id-other-provider" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#second"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", "Alex Example"},
                      {"TEAM_REF", "b#blue"},
                      {"POSITION_REF", "GK"}
                    ],
                    cells: [
                      {"REF", "b#first"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", " Alex Example "},
                      {"TEAM_REF", "b#red"},
                      {"POSITION_REF", "FW"}
                    ]
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-provider"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-P01-PL-2024-2025-A" =>
    F.source_b("F-P01-PL-2024-2025-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024}
    ]),
  "F-P01-PL-2024-2025-B" =>
    F.source_b("F-P01-PL-2024-2025-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024}
    ]),
  "F-P01-PL-2025-2026-A" => F.source_b("F-P01-PL-2025-2026-A", performances, []),
  "F-P01-PL-2025-2026-B" => F.source_b("F-P01-PL-2025-2026-B", performances, []),
  "F-P01-BL1-2024-2025-A" =>
    F.source_b("F-P01-BL1-2024-2025-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "BL1"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-P01-BL1-2024-2025-B" =>
    F.source_b("F-P01-BL1-2024-2025-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "BL1"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-P01-BL1-2025-2026-A" =>
    F.source_b("F-P01-BL1-2025-2026-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "BL1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-P01-BL1-2025-2026-B" =>
    F.source_b("F-P01-BL1-2025-2026-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "BL1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Bundesliga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "BL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "BL1"}
    ]),
  "F-P01-PD-2024-2025-A" =>
    F.source_b("F-P01-PD-2024-2025-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "PD"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-P01-PD-2024-2025-B" =>
    F.source_b("F-P01-PD-2024-2025-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "PD"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-P01-PD-2025-2026-A" =>
    F.source_b("F-P01-PD-2025-2026-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "PD"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-P01-PD-2025-2026-B" =>
    F.source_b("F-P01-PD-2025-2026-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "PD"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "La Liga"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "PD"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "PD"}
    ]),
  "F-P01-SA-2024-2025-A" =>
    F.source_b("F-P01-SA-2024-2025-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "SA"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-P01-SA-2024-2025-B" =>
    F.source_b("F-P01-SA-2024-2025-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "SA"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-P01-SA-2025-2026-A" =>
    F.source_b("F-P01-SA-2025-2026-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "SA"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-P01-SA-2025-2026-B" =>
    F.source_b("F-P01-SA-2025-2026-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "SA"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Serie A"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "SA"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "SA"}
    ]),
  "F-P01-FL1-2024-2025-A" =>
    F.source_b("F-P01-FL1-2024-2025-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "FL1"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-P01-FL1-2024-2025-B" =>
    F.source_b("F-P01-FL1-2024-2025-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "FL1"},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "FACTS", "SEASON", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "START_YEAR"], 2024},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-P01-FL1-2025-2026-A" =>
    F.source_b("F-P01-FL1-2025-2026-A", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "FL1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-P01-FL1-2025-2026-B" =>
    F.source_b("F-P01-FL1-2025-2026-B", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "FL1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "NAME"], "Ligue 1"},
      {:put, ["CANDIDATE", "FACTS", "LEAGUE", "CODE"], "FL1"},
      {:put, ["CANDIDATE", "SCOPE", "LEAGUE_CODE"], "FL1"}
    ]),
  "F-P02-before" =>
    F.source_b("F-P02-before", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "KICKOFF_AT"], "2024-12-31T23:59:59.999999Z"}
    ]),
  "F-P02-lower" => F.source_b("F-P02-lower", performances, []),
  "F-P02-equal-offset" =>
    F.source_b("F-P02-equal-offset", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "KICKOFF_AT"],
       "2025-01-01T01:00:00.000000+01:00"}
    ]),
  "F-P02-upper" =>
    F.source_b("F-P02-upper", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "KICKOFF_AT"], "2025-01-01T00:00:00.000001Z"}
    ]),
  "F-P02-after" =>
    F.source_b("F-P02-after", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "KICKOFF_AT"], "2025-01-01T00:00:00.000002Z"}
    ]),
  "F-P03-zero" =>
    F.source_b("F-P03-zero", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "RED_CARDS"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "YELLOW_CARDS"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS_CONCEDED"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SAVES"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "INTERCEPTIONS"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "TACKLES"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SHOTS_ON_TARGET"], 0},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "ASSISTS"], 0}
    ]),
  "F-P03-nil" =>
    F.source_b("F-P03-nil", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "RED_CARDS"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "YELLOW_CARDS"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS_CONCEDED"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SAVES"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "INTERCEPTIONS"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "TACKLES"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SHOTS_ON_TARGET"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "ASSISTS"], nil},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS"], nil}
    ]),
  "F-P03-omitted" =>
    F.source_b("F-P03-omitted", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS"], {:cells, []}}
    ]),
  "F-P03-zero-minutes-positive-count" =>
    F.source_b("F-P03-zero-minutes-positive-count", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MINUTES_PLAYED"], 0}
    ]),
  "F-P03-minutes-over-120" =>
    F.source_b("F-P03-minutes-over-120", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MINUTES_PLAYED"], 121}
    ]),
  "F-P03-match-no-performance" =>
    F.source_b("F-P03-match-no-performance", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"], {:rows, []}}
    ]),
  "F-P03-empty" =>
    F.source_b("F-P03-empty", performances, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]
        ]}},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"], {:rows, []}},
      {:put, ["CANDIDATE", "FACTS", "MATCHES"], {:rows, []}}
    ]),
  "F-P04-filter-mixed" =>
    F.source_b("F-P04-filter-mixed", performances, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}],
          cells: [
            {"SOURCE_ID", "B-excluded-scheduled"},
            {"REF", "b#excluded-scheduled"},
            {"KIND", :match}
          ],
          cells: [{"SOURCE_ID", "B-excluded-live"}, {"REF", "b#excluded-live"}, {"KIND", :match}],
          cells: [
            {"SOURCE_ID", "B-excluded-postponed"},
            {"REF", "b#excluded-postponed"},
            {"KIND", :match}
          ],
          cells: [
            {"SOURCE_ID", "B-excluded-abandoned"},
            {"REF", "b#excluded-abandoned"},
            {"KIND", :match}
          ],
          cells: [{"SOURCE_ID", "B-old"}, {"REF", "b#old"}, {"KIND", :match}],
          cells: [
            {"SOURCE_ID", "B-different-scope"},
            {"REF", "b#different-scope"},
            {"KIND", :match}
          ]
        ]}},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"],
       {:rows,
        [
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ],
          cells: [
            {"COUNTS", {:cells, [{"GOALS", -1}]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#excluded-scheduled"},
            {"REF", "b#excluded-performance-scheduled"}
          ],
          cells: [
            {"COUNTS", {:cells, [{"GOALS", -1}]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#excluded-live"},
            {"REF", "b#excluded-performance-live"}
          ],
          cells: [
            {"COUNTS", {:cells, [{"GOALS", -1}]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#excluded-postponed"},
            {"REF", "b#excluded-performance-postponed"}
          ],
          cells: [
            {"COUNTS", {:cells, [{"GOALS", -1}]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#excluded-abandoned"},
            {"REF", "b#excluded-performance-abandoned"}
          ],
          cells: [
            {"COUNTS", {:cells, [{"GOALS", -10}]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#old"},
            {"REF", "b#old-perf"}
          ],
          cells: [
            {"COUNTS", {:cells, [{"GOALS", -1}]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "unused-dangling"},
            {"MATCH_REF", "b#different-scope"},
            {"REF", "b#different-scope-perf"}
          ]
        ]}},
      {:put, ["CANDIDATE", "FACTS", "MATCHES"],
       {:rows,
        [
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
            {"STATUS", :completed},
            {"SEASON_REF", "b#season"},
            {"REF", "b#match"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"STATUS", :scheduled},
            {"SEASON_REF", "b#season"},
            {"REF", "b#excluded-scheduled"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"STATUS", :live},
            {"SEASON_REF", "b#season"},
            {"REF", "b#excluded-live"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"STATUS", :postponed},
            {"SEASON_REF", "b#season"},
            {"REF", "b#excluded-postponed"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"STATUS", :abandoned},
            {"SEASON_REF", "b#season"},
            {"REF", "b#excluded-abandoned"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"KICKOFF_AT", "2024-01-01T00:00:00.000000Z"},
            {"STATUS", :completed},
            {"SEASON_REF", "b#season"},
            {"REF", "b#old"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "SA"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"KICKOFF_AT", "invalid-unused"},
            {"STATUS", :completed},
            {"SEASON_REF", "b#season"},
            {"REF", "b#different-scope"}
          ]
        ]}}
    ]),
  "F-P05-bad-scope" =>
    F.source_b("F-P05-bad-scope", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "ZZ"}
    ]),
  "F-P05-bad-status" =>
    F.source_b("F-P05-bad-status", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "STATUS"], :unknown}
    ]),
  "F-P05-bad-kickoff" =>
    F.source_b("F-P05-bad-kickoff", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "KICKOFF_AT"], "2025-01-01"}
    ]),
  "F-P06-eligible-bad-metric" =>
    F.source_b("F-P06-eligible-bad-metric", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS"], -1}
    ]),
  "F-P06-eligible-duplicate" =>
    F.source_b("F-P06-eligible-duplicate", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"],
       {:rows,
        [
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ],
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ]
        ]}}
    ]),
  "F-P06-cross-season-edge" =>
    F.source_b("F-P06-cross-season-edge", performances, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "SEASON_REF"], "different"}
    ]),
  "F-P06-dangling-performance-match" =>
    F.source_b("F-P06-dangling-performance-match", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MATCH_REF"], "undeclared"}
    ]),
  "F-P06-duplicate-eligible-ref-with-scheduled-copy" =>
    F.source_b("F-P06-duplicate-eligible-ref-with-scheduled-copy", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES"],
       {:rows,
        [
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
            {"STATUS", :completed},
            {"SEASON_REF", "b#season"},
            {"REF", "b#match"}
          ],
          cells: [
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"AWAY_TEAM_REF", "b#blue"},
            {"HOME_TEAM_REF", "b#red"},
            {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
            {"STATUS", :scheduled},
            {"SEASON_REF", "b#season"},
            {"REF", "b#match"}
          ]
        ]}}
    ]),
  "F-P07-excluded-only-directory" =>
    F.source_b("F-P07-excluded-only-directory", performances, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 0, "TEAM_REF"], "unused-dangling"},
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 0, "DISPLAY_NAME"], nil}
    ]),
  "F-P07-retained-player-current-team" =>
    F.source_b("F-P07-retained-player-current-team", performances, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}],
          cells: [{"SOURCE_ID", "B-source-b#green"}, {"REF", "b#green"}, {"KIND", :team}]
        ]}},
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "TEAM_REF"], "b#green"},
      {:put, ["CANDIDATE", "FACTS", "TEAMS"],
       {:rows,
        [
          cells: [
            {"CODE", "GRN"},
            {"NAME", "Green Team"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#green"}
          ],
          cells: [
            {"CODE", "BLU"},
            {"NAME", "Blue Team"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#blue"}
          ],
          cells: [
            {"CODE", " RED "},
            {"NAME", " Red Team "},
            {"SEASON_REF", "b#season"},
            {"REF", "b#red"}
          ]
        ]}}
    ]),
  "F-P08-transfer" => F.source_b("F-P08-transfer", performances, []),
  "F-P09-no-capability" =>
    F.source_b("F-P09-no-capability", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
    ]),
  "F-P10-goals-negative" =>
    F.source_b("F-P10-goals-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS"], -1}
    ]),
  "F-P10-goals-fraction" =>
    F.source_b("F-P10-goals-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS"], 0.5}
    ]),
  "F-P10-goals-boolean" =>
    F.source_b("F-P10-goals-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS"], true}
    ]),
  "F-P10-goals-text" =>
    F.source_b("F-P10-goals-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS"], "1"}
    ]),
  "F-P10-assists-negative" =>
    F.source_b("F-P10-assists-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "ASSISTS"], -1}
    ]),
  "F-P10-assists-fraction" =>
    F.source_b("F-P10-assists-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "ASSISTS"], 0.5}
    ]),
  "F-P10-assists-boolean" =>
    F.source_b("F-P10-assists-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "ASSISTS"], true}
    ]),
  "F-P10-assists-text" =>
    F.source_b("F-P10-assists-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "ASSISTS"], "1"}
    ]),
  "F-P10-shots_on_target-negative" =>
    F.source_b("F-P10-shots_on_target-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SHOTS_ON_TARGET"], -1}
    ]),
  "F-P10-shots_on_target-fraction" =>
    F.source_b("F-P10-shots_on_target-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SHOTS_ON_TARGET"], 0.5}
    ]),
  "F-P10-shots_on_target-boolean" =>
    F.source_b("F-P10-shots_on_target-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SHOTS_ON_TARGET"], true}
    ]),
  "F-P10-shots_on_target-text" =>
    F.source_b("F-P10-shots_on_target-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SHOTS_ON_TARGET"], "1"}
    ]),
  "F-P10-tackles-negative" =>
    F.source_b("F-P10-tackles-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "TACKLES"], -1}
    ]),
  "F-P10-tackles-fraction" =>
    F.source_b("F-P10-tackles-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "TACKLES"], 0.5}
    ]),
  "F-P10-tackles-boolean" =>
    F.source_b("F-P10-tackles-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "TACKLES"], true}
    ]),
  "F-P10-tackles-text" =>
    F.source_b("F-P10-tackles-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "TACKLES"], "1"}
    ]),
  "F-P10-interceptions-negative" =>
    F.source_b("F-P10-interceptions-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "INTERCEPTIONS"], -1}
    ]),
  "F-P10-interceptions-fraction" =>
    F.source_b("F-P10-interceptions-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "INTERCEPTIONS"], 0.5}
    ]),
  "F-P10-interceptions-boolean" =>
    F.source_b("F-P10-interceptions-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "INTERCEPTIONS"], true}
    ]),
  "F-P10-interceptions-text" =>
    F.source_b("F-P10-interceptions-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "INTERCEPTIONS"], "1"}
    ]),
  "F-P10-saves-negative" =>
    F.source_b("F-P10-saves-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SAVES"], -1}
    ]),
  "F-P10-saves-fraction" =>
    F.source_b("F-P10-saves-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SAVES"], 0.5}
    ]),
  "F-P10-saves-boolean" =>
    F.source_b("F-P10-saves-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SAVES"], true}
    ]),
  "F-P10-saves-text" =>
    F.source_b("F-P10-saves-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "SAVES"], "1"}
    ]),
  "F-P10-goals_conceded-negative" =>
    F.source_b("F-P10-goals_conceded-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS_CONCEDED"], -1}
    ]),
  "F-P10-goals_conceded-fraction" =>
    F.source_b("F-P10-goals_conceded-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS_CONCEDED"], 0.5}
    ]),
  "F-P10-goals_conceded-boolean" =>
    F.source_b("F-P10-goals_conceded-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS_CONCEDED"], true}
    ]),
  "F-P10-goals_conceded-text" =>
    F.source_b("F-P10-goals_conceded-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "GOALS_CONCEDED"], "1"}
    ]),
  "F-P10-yellow_cards-negative" =>
    F.source_b("F-P10-yellow_cards-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "YELLOW_CARDS"], -1}
    ]),
  "F-P10-yellow_cards-fraction" =>
    F.source_b("F-P10-yellow_cards-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "YELLOW_CARDS"], 0.5}
    ]),
  "F-P10-yellow_cards-boolean" =>
    F.source_b("F-P10-yellow_cards-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "YELLOW_CARDS"], true}
    ]),
  "F-P10-yellow_cards-text" =>
    F.source_b("F-P10-yellow_cards-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "YELLOW_CARDS"], "1"}
    ]),
  "F-P10-red_cards-negative" =>
    F.source_b("F-P10-red_cards-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "RED_CARDS"], -1}
    ]),
  "F-P10-red_cards-fraction" =>
    F.source_b("F-P10-red_cards-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "RED_CARDS"], 0.5}
    ]),
  "F-P10-red_cards-boolean" =>
    F.source_b("F-P10-red_cards-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "RED_CARDS"], true}
    ]),
  "F-P10-red_cards-text" =>
    F.source_b("F-P10-red_cards-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS", "RED_CARDS"], "1"}
    ]),
  "F-P10-minutes_played-negative" =>
    F.source_b("F-P10-minutes_played-negative", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MINUTES_PLAYED"], -1}
    ]),
  "F-P10-minutes_played-fraction" =>
    F.source_b("F-P10-minutes_played-fraction", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MINUTES_PLAYED"], 0.5}
    ]),
  "F-P10-minutes_played-boolean" =>
    F.source_b("F-P10-minutes_played-boolean", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MINUTES_PLAYED"], true}
    ]),
  "F-P10-minutes_played-text" =>
    F.source_b("F-P10-minutes_played-text", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "MINUTES_PLAYED"], "1"}
    ]),
  "F-P10-unsupported-count" =>
    F.source_b("F-P10-unsupported-count", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS"],
       {:cells,
        [
          {"RATING", 10},
          {"RED_CARDS", 8},
          {"YELLOW_CARDS", 7},
          {"GOALS_CONCEDED", 6},
          {"SAVES", 5},
          {"INTERCEPTIONS", 4},
          {"TACKLES", 3},
          {"SHOTS_ON_TARGET", 2},
          {"ASSISTS", 1},
          {"GOALS", 0}
        ]}}
    ]),
  "F-P10-missing-minutes" =>
    F.source_b("F-P10-missing-minutes", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0],
       {:cells,
        [
          {"COUNTS",
           {:cells,
            [
              {"RED_CARDS", 8},
              {"YELLOW_CARDS", 7},
              {"GOALS_CONCEDED", 6},
              {"SAVES", 5},
              {"INTERCEPTIONS", 4},
              {"TACKLES", 3},
              {"SHOTS_ON_TARGET", 2},
              {"ASSISTS", 1},
              {"GOALS", 0}
            ]}},
          {"POSITION_REF", "FW"},
          {"TEAM_REF", "b#red"},
          {"PLAYER_REF", "b#first"},
          {"MATCH_REF", "b#match"},
          {"REF", "b#appearance"}
        ]}}
    ]),
  "F-P10-missing-kickoff" =>
    F.source_b("F-P10-missing-kickoff", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0],
       {:cells,
        [
          {"SCOPE", {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
          {"AWAY_TEAM_REF", "b#blue"},
          {"HOME_TEAM_REF", "b#red"},
          {"STATUS", :completed},
          {"SEASON_REF", "b#season"},
          {"REF", "b#match"}
        ]}}
    ]),
  "F-P10-missing-position" =>
    F.source_b("F-P10-missing-position", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "POSITION_REF"], "unmapped"}
    ]),
  "F-P10-unknown-league" =>
    F.source_b("F-P10-unknown-league", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "SCOPE", "LEAGUE_CODE"], "ZZ"}
    ]),
  "F-P10-missing-participant" =>
    F.source_b("F-P10-missing-participant", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "HOME_TEAM_REF"], "absent"}
    ]),
  "F-P10-same-home-away" =>
    F.source_b("F-P10-same-home-away", performances, [
      {:put, ["CANDIDATE", "FACTS", "MATCHES", 0, "AWAY_TEAM_REF"], "b#red"}
    ]),
  "F-P10-nonparticipating-team" =>
    F.source_b("F-P10-nonparticipating-team", performances, [
      {:put, ["CANDIDATE", "BINDINGS"],
       {:rows,
        [
          cells: [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}],
          cells: [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}],
          cells: [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}],
          cells: [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}],
          cells: [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}],
          cells: [{"SOURCE_ID", "B-source-b#green"}, {"REF", "b#green"}, {"KIND", :team}]
        ]}},
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "TEAM_REF"], "b#green"},
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "TEAM_REF"], "b#green"},
      {:put, ["CANDIDATE", "FACTS", "TEAMS"],
       {:rows,
        [
          cells: [
            {"CODE", "GRN"},
            {"NAME", "Green Team"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#green"}
          ],
          cells: [
            {"CODE", "BLU"},
            {"NAME", "Blue Team"},
            {"SEASON_REF", "b#season"},
            {"REF", "b#blue"}
          ],
          cells: [
            {"CODE", " RED "},
            {"NAME", " Red Team "},
            {"SEASON_REF", "b#season"},
            {"REF", "b#red"}
          ]
        ]}}
    ]),
  "F-P10-repeat-player-match" =>
    F.source_b("F-P10-repeat-player-match", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"],
       {:rows,
        [
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ],
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "another"}
          ]
        ]}}
    ]),
  "F-P10-duplicate-identical" =>
    F.source_b("F-P10-duplicate-identical", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"],
       {:rows,
        [
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ],
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ]
        ]}}
    ]),
  "F-P10-duplicate-conflicting" =>
    F.source_b("F-P10-duplicate-conflicting", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES"],
       {:rows,
        [
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 91},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ],
          cells: [
            {"COUNTS",
             {:cells,
              [
                {"RED_CARDS", 8},
                {"YELLOW_CARDS", 7},
                {"GOALS_CONCEDED", 6},
                {"SAVES", 5},
                {"INTERCEPTIONS", 4},
                {"TACKLES", 3},
                {"SHOTS_ON_TARGET", 2},
                {"ASSISTS", 1},
                {"GOALS", 0}
              ]}},
            {"MINUTES_PLAYED", 20},
            {"POSITION_REF", "FW"},
            {"TEAM_REF", "b#red"},
            {"PLAYER_REF", "b#first"},
            {"MATCH_REF", "b#match"},
            {"REF", "b#appearance"}
          ]
        ]}}
    ]),
  "F-P10-rating-substitute" =>
    F.source_b("F-P10-rating-substitute", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS"], {:cells, [{"RATING", 10}]}}
    ]),
  "F-P10-team-total-substitute" =>
    F.source_b("F-P10-team-total-substitute", performances, [
      {:put, ["CANDIDATE", "FACTS", "PERFORMANCES", 0, "COUNTS"], {:cells, [{"TEAM_GOALS", 10}]}}
    ]),
  "F-R01-case" => F.source_b("F-R01-case", catalog, []),
  "F-R01-whitespace" => F.source_b("F-R01-whitespace", catalog, []),
  "F-R01-string-keys" => F.source_b("F-R01-string-keys", catalog, []),
  "F-R02-missing" =>
    F.source_b("F-R02-missing", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-unknown-field" =>
    F.source_b("F-R02-unknown-field", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-mixed-keys" =>
    F.source_b("F-R02-mixed-keys", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-non-map" =>
    F.source_b("F-R02-non-map", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-league" =>
    F.source_b("F-R02-league", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-year-type" =>
    F.source_b("F-R02-year-type", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-year-bool" =>
    F.source_b("F-R02-year-bool", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-year-gap" =>
    F.source_b("F-R02-year-gap", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-catalog-bound" =>
    F.source_b("F-R02-catalog-bound", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-timeout-type" =>
    F.source_b("F-R02-timeout-type", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-timeout-zero" =>
    F.source_b("F-R02-timeout-zero", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-timeout-negative" =>
    F.source_b("F-R02-timeout-negative", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R02-timeout-bool" =>
    F.source_b("F-R02-timeout-bool", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R03-same-year" =>
    F.source_b("F-R03-same-year", catalog, [
      {:put, ["CANDIDATE", "FACTS", "SEASON", "END_YEAR"], 2025},
      {:put, ["CANDIDATE", "SCOPE", "END_YEAR"], 2025}
    ]),
  "F-R03-lower-only" => F.source_b("F-R03-lower-only", performances, []),
  "F-R03-upper-only" => F.source_b("F-R03-upper-only", performances, []),
  "F-R03-unbounded" => F.source_b("F-R03-unbounded", performances, []),
  "F-R03-offset-equal" => F.source_b("F-R03-offset-equal", performances, []),
  "F-R04-naive" =>
    F.source_b("F-R04-naive", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R04-bad-instant" =>
    F.source_b("F-R04-bad-instant", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R04-overprecision" =>
    F.source_b("F-R04-overprecision", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-R04-reversed" =>
    F.source_b("F-R04-reversed", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-E01-invalid_request" =>
    F.source_b("F-E01-invalid_request", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-I01-invalid_request" =>
    F.source_b("F-I01-invalid_request", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-E01-unsupported_capability" =>
    F.source_b("F-E01-unsupported_capability", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
    ]),
  "F-I01-unsupported_capability" =>
    F.source_b("F-I01-unsupported_capability", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
    ]),
  "F-E01-not_found" =>
    F.source_b("F-E01-not_found", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :not_found}]}}]}}
    ]),
  "F-I01-not_found" =>
    F.source_b("F-I01-not_found", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :not_found}]}}]}}
    ]),
  "F-E01-authentication_failed" =>
    F.source_b("F-E01-authentication_failed", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :authentication_failed}]}}]}}
    ]),
  "F-I01-authentication_failed" =>
    F.source_b("F-I01-authentication_failed", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :authentication_failed}]}}]}}
    ]),
  "F-E01-rate_limited" =>
    F.source_b("F-E01-rate_limited", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :rate_limited}]}}]}}
    ]),
  "F-I01-rate_limited" =>
    F.source_b("F-I01-rate_limited", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :rate_limited}]}}]}}
    ]),
  "F-E01-unavailable" =>
    F.source_b("F-E01-unavailable", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}]}}
    ]),
  "F-I01-unavailable" =>
    F.source_b("F-I01-unavailable", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}]}}
    ]),
  "F-E01-timeout" =>
    F.source_b("F-E01-timeout", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
    ]),
  "F-I01-timeout" =>
    F.source_b("F-I01-timeout", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
    ]),
  "F-E01-invalid_response" =>
    F.source_b("F-E01-invalid_response", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_response}]}}]}}
    ]),
  "F-I01-invalid_response" =>
    F.source_b("F-I01-invalid_response", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_response}]}}]}}
    ]),
  "F-E02-known-delay" =>
    F.source_b("F-E02-known-delay", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"RETRY_AFTER_MS", 17}, {"CATEGORY", :rate_limited}]}}]}}
    ]),
  "F-E02-unknown-delay" =>
    F.source_b("F-E02-unknown-delay", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"RETRY_AFTER_MS", nil}, {"CATEGORY", :rate_limited}]}}]}}
    ]),
  "F-E02-bad-delay" =>
    F.source_b("F-E02-bad-delay", catalog, [
      {:put, ["CANDIDATE"],
       {:cells, [{"FAILURE", {:cells, [{"RETRY_AFTER_MS", -1}, {"CATEGORY", :rate_limited}]}}]}}
    ]),
  "F-E03-url" =>
    F.source_b("F-E03-url", catalog, [
      {:put, ["CANDIDATE", "BINDINGS", 0, "SOURCE_ID"], "https://FAKE_SENTINEL.invalid/a"}
    ]),
  "F-E03-userinfo" =>
    F.source_b("F-E03-userinfo", catalog, [
      {:put, ["CANDIDATE", "BINDINGS", 0, "SOURCE_ID"], "https://FAKE_SENTINEL:pw@invalid/a"}
    ]),
  "F-E03-token-query" =>
    F.source_b("F-E03-token-query", catalog, [
      {:put, ["CANDIDATE", "BINDINGS", 0, "SOURCE_ID"], "https://invalid/?token=FAKE_SENTINEL"}
    ]),
  "F-E03-header" =>
    F.source_b("F-E03-header", catalog, [
      {:put, ["CANDIDATE", "BINDINGS", 0, "SOURCE_ID"], "Authorization: Bearer FAKE_SENTINEL"}
    ]),
  "F-E03-source-ref" =>
    F.source_b("F-E03-source-ref", catalog, [
      {:put, ["CANDIDATE", "FACTS", "PLAYERS", 1, "REF"], "Bearer FAKE_SENTINEL"}
    ]),
  "F-E03-source-id" =>
    F.source_b("F-E03-source-id", catalog, [
      {:put, ["CANDIDATE", "BINDINGS", 0, "SOURCE_ID"], "token=FAKE_SENTINEL"}
    ]),
  "F-E03-fixture-id" =>
    F.source_b("F-E03-fixture-id", catalog, [
      {:put, ["CANDIDATE", "FIXTURE_ID"], "password: FAKE_SENTINEL"}
    ]),
  "F-E03-exception" =>
    F.source_b("F-E03-exception", catalog, [{:put, ["CANDIDATE"], {:cells, [{"THROW", true}]}}]),
  "F-E03-unknown-key" =>
    F.source_b("F-E03-unknown-key", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
    ]),
  "F-E03-provider-label" =>
    F.source_b("F-E03-provider-label", catalog, [
      {:put, ["CANDIDATE", "FIXTURE_ID"], "Authorization: FAKE_SENTINEL"}
    ]),
  "F-D01-default-before" =>
    F.source_b("F-D01-default-before", catalog, [{:put, ["ELAPSED_US"], 4_999_999}]),
  "F-D01-default-at" =>
    F.source_b("F-D01-default-at", catalog, [{:put, ["ELAPSED_US"], 5_000_000}]),
  "F-D01-default-after" =>
    F.source_b("F-D01-default-after", catalog, [{:put, ["ELAPSED_US"], 5_000_001}]),
  "F-D01-default-never" =>
    F.source_b("F-D01-default-never", catalog, [{:put, ["ELAPSED_US"], 10_000_000}]),
  "F-D02-custom-before" =>
    F.source_b("F-D02-custom-before", catalog, [{:put, ["ELAPSED_US"], 6999}]),
  "F-D02-custom-at" => F.source_b("F-D02-custom-at", catalog, [{:put, ["ELAPSED_US"], 7000}]),
  "F-D02-custom-after" =>
    F.source_b("F-D02-custom-after", catalog, [{:put, ["ELAPSED_US"], 7001}]),
  "F-D02-custom-validation-delay" =>
    F.source_b("F-D02-custom-validation-delay", catalog, [{:put, ["ELAPSED_US"], 6999}]),
  "F-D02-custom-error-at-boundary" =>
    F.source_b("F-D02-custom-error-at-boundary", catalog, [
      {:put, ["ELAPSED_US"], 7000},
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
    ]),
  "F-D03-pages-complete" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [
                  {"KIND", :league},
                  {"REF", "b#league"},
                  {"SOURCE_ID", "B-source-b#league"}
                ],
                cells: [
                  {"KIND", :season},
                  {"REF", "b#season"},
                  {"SOURCE_ID", "B-source-b#season"}
                ],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-D03-pages-complete"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "GK"},
                        {"TEAM_REF", "b#blue"},
                        {"DISPLAY_NAME", "Alex Example"},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#second"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 2000}
            ],
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "FW"},
                        {"TEAM_REF", "b#red"},
                        {"DISPLAY_NAME", " Alex Example "},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#first"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 1000}
            ]
          ]}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-D04-later-page-error" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [
                  {"KIND", :league},
                  {"REF", "b#league"},
                  {"SOURCE_ID", "B-source-b#league"}
                ],
                cells: [
                  {"KIND", :season},
                  {"REF", "b#season"},
                  {"SOURCE_ID", "B-source-b#season"}
                ],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-D04-later-page-error"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            cells: [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}, {"DELAY_US", 1000}],
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "FW"},
                        {"TEAM_REF", "b#red"},
                        {"DISPLAY_NAME", " Alex Example "},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#first"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 1000}
            ]
          ]}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-D04-later-page-timeout" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [
                  {"KIND", :league},
                  {"REF", "b#league"},
                  {"SOURCE_ID", "B-source-b#league"}
                ],
                cells: [
                  {"KIND", :season},
                  {"REF", "b#season"},
                  {"SOURCE_ID", "B-source-b#season"}
                ],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-D04-later-page-timeout"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "GK"},
                        {"TEAM_REF", "b#blue"},
                        {"DISPLAY_NAME", "Alex Example"},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#second"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 5000}
            ],
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "FW"},
                        {"TEAM_REF", "b#red"},
                        {"DISPLAY_NAME", " Alex Example "},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#first"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 2000}
            ]
          ]}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-D04-cumulative-page-delay" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2025}, {"END_YEAR", 2026}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2025},
                    {"END_YEAR", 2026}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [
                  {"KIND", :league},
                  {"REF", "b#league"},
                  {"SOURCE_ID", "B-source-b#league"}
                ],
                cells: [
                  {"KIND", :season},
                  {"REF", "b#season"},
                  {"SOURCE_ID", "B-source-b#season"}
                ],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-D04-cumulative-page-delay"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "GK"},
                        {"TEAM_REF", "b#blue"},
                        {"DISPLAY_NAME", "Alex Example"},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#second"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 4000}
            ],
            cells: [
              {"FACTS",
               {:cells,
                [
                  {"PLAYERS",
                   {:rows,
                    [
                      cells: [
                        {"POSITION_REF", "FW"},
                        {"TEAM_REF", "b#red"},
                        {"DISPLAY_NAME", " Alex Example "},
                        {"SEASON_REF", "b#season"},
                        {"REF", "b#first"}
                      ]
                    ]}}
                ]}},
              {"DELAY_US", 4000}
            ]
          ]}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}},
  "F-D05-late-result" =>
    F.source_b("F-D05-late-result", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
    ]),
  "F-D05-next-call" =>
    F.source_b("F-D05-next-call", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
    ]),
  "F-D05-caller-exit" =>
    F.source_b("F-D05-caller-exit", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
    ]),
  "F-D05-crash" =>
    F.source_b("F-D05-crash", catalog, [
      {:put, ["CANDIDATE"], {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}]}}
    ]),
  "F-O01-repeat" => F.source_b("F-O01-repeat", catalog, []),
  "F-O02-bijection-negative" => F.source_b("F-O02-bijection-negative", catalog, []),
  "F-O03-traceability" => F.source_b("F-O03-traceability", catalog, []),
  "F-C05-same-id-other-scope-2024" =>
    {:packet,
     {:cells,
      [
        {"CANDIDATE",
         {:cells,
          [
            {"OPERATION", :catalog},
            {"SCOPE",
             {:cells, [{"LEAGUE_CODE", "PL"}, {"START_YEAR", 2024}, {"END_YEAR", 2025}]}},
            {"FACTS",
             {:cells,
              [
                {"LEAGUE",
                 {:cells, [{"REF", "b#league"}, {"CODE", "PL"}, {"NAME", "Premier League"}]}},
                {"SEASON",
                 {:cells,
                  [
                    {"REF", "b#season"},
                    {"LEAGUE_REF", "b#league"},
                    {"START_YEAR", 2024},
                    {"END_YEAR", 2025}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#blue"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", "Blue Team"},
                      {"CODE", "BLU"}
                    ],
                    cells: [
                      {"REF", "b#red"},
                      {"SEASON_REF", "b#season"},
                      {"NAME", " Red Team "},
                      {"CODE", " RED "}
                    ]
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    cells: [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}],
                    cells: [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    cells: [
                      {"REF", "b#second"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", "Alex Example"},
                      {"TEAM_REF", "b#blue"},
                      {"POSITION_REF", "GK"}
                    ],
                    cells: [
                      {"REF", "b#first"},
                      {"SEASON_REF", "b#season"},
                      {"DISPLAY_NAME", " Alex Example "},
                      {"TEAM_REF", "b#red"},
                      {"POSITION_REF", "FW"}
                    ]
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                cells: [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}],
                cells: [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}],
                cells: [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}],
                cells: [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}],
                cells: [
                  {"KIND", :player},
                  {"REF", "b#second"},
                  {"SOURCE_ID", "B-source-b#second"}
                ]
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-scope-2024"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{rating: 777, team_goals: 999, attempted_tackles: 888}}
}
