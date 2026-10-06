%{
  "F-C01-PL-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PL-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Premier League"}, {"CODE", "PL"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PL-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PL-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Premier League"}, {"CODE", "PL"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PL-2025-2026-A" =>
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
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PL-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PL-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-BL1-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-BL1-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "BL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-BL1-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-BL1-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "BL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-BL1-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-BL1-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "BL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-BL1-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-BL1-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "BL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PD-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PD-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PD"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PD-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PD-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PD"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PD-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PD-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PD"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-PD-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-PD-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PD"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-SA-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-SA-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "SA"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-SA-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-SA-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "SA"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-SA-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-SA-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "SA"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-SA-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-SA-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "SA"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-FL1-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-FL1-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "FL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-FL1-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-FL1-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "FL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-FL1-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-FL1-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "FL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C01-FL1-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C01-FL1-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "FL1"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C02-empty" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C02-empty"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS", {:rows, []}},
                {"POSITIONS", {:rows, []}},
                {"TEAMS", {:rows, []}},
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C03-unknown-season" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :not_found}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C03-unsupported" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-missing-fact" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-missing-fact"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-blank-label" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-blank-label"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-ref-identical" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-ref-identical"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-ref-conflicting" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-ref-conflicting"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", "Other"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-source" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-source"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-name" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-name"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", " red team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-code" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-code"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", " red "},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-position-name" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-position-name"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", " forward "}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-duplicate-position-code" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-duplicate-position-code"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "FW"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-cross-season" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-cross-season"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "other-season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-dangling" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-dangling"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "missing"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-unmapped-position" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-unmapped-position"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "UNKNOWN"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-extra-normalized-field" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-extra-normalized-field"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"RATING", 87},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-binding-missing" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-binding-missing"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-binding-dangling" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-binding-dangling"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells, [{"SOURCE_ID", "safe"}, {"REF", "missing"}, {"KIND", :team}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-binding-duplicate" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-binding-duplicate"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-league-mismatch" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-league-mismatch"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
                 {:cells, [{"NAME", "Premier League"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-C04-season-mismatch" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-C04-season-mismatch"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2027},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Premier League"}, {"CODE", "PL"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"REF", "b#second"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"TEAM_REF", "b#blue"},
                       {"POSITION_REF", "GK"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#first"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"TEAM_REF", "b#red"},
                       {"POSITION_REF", "FW"}
                     ]}
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-kind"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"REF", "b#second"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"TEAM_REF", "b#blue"},
                       {"POSITION_REF", "GK"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#first"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"TEAM_REF", "b#red"},
                       {"POSITION_REF", "FW"}
                     ]}
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-scope"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"REF", "b#second"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"TEAM_REF", "b#blue"},
                       {"POSITION_REF", "GK"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#first"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"TEAM_REF", "b#red"},
                       {"POSITION_REF", "FW"}
                     ]}
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-provider"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PL-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PL-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
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
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "PL"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PL-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PL-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
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
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "PL"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PL-2025-2026-A" =>
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
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PL-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PL-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-BL1-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-BL1-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "BL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "BL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-BL1-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-BL1-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "BL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "BL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-BL1-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-BL1-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "BL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "BL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-BL1-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-BL1-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "BL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
                 {:cells, [{"NAME", "Bundesliga"}, {"CODE", "BL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "BL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PD-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PD-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PD"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "PD"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PD-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PD-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "PD"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "PD"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PD-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PD-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PD"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "PD"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-PD-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-PD-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PD"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "La Liga"}, {"CODE", "PD"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "PD"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-SA-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-SA-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "SA"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "SA"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-SA-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-SA-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "SA"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "SA"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-SA-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-SA-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "SA"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "SA"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-SA-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-SA-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "SA"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Serie A"}, {"CODE", "SA"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "SA"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-FL1-2024-2025-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-FL1-2024-2025-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "FL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "FL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-FL1-2024-2025-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-FL1-2024-2025-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "FL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2024},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2025},
                {"START_YEAR", 2024},
                {"LEAGUE_CODE", "FL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-FL1-2025-2026-A" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-FL1-2025-2026-A"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "FL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "FL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P01-FL1-2025-2026-B" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P01-FL1-2025-2026-B"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "FL1"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2026},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE", {:cells, [{"NAME", "Ligue 1"}, {"CODE", "FL1"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells,
              [
                {"TO", nil},
                {"FROM", nil},
                {"END_YEAR", 2026},
                {"START_YEAR", 2025},
                {"LEAGUE_CODE", "FL1"}
              ]}},
            {"OPERATION", :performances}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P02-before" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P02-before"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2024-12-31T23:59:59.999999Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P02-lower" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P02-lower"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P02-equal-offset" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P02-equal-offset"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T01:00:00.000000+01:00"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P02-upper" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P02-upper"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000001Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P02-after" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P02-after"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000002Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-zero" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-zero"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 0},
                           {"YELLOW_CARDS", 0},
                           {"GOALS_CONCEDED", 0},
                           {"SAVES", 0},
                           {"INTERCEPTIONS", 0},
                           {"TACKLES", 0},
                           {"SHOTS_ON_TARGET", 0},
                           {"ASSISTS", 0},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-nil" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-nil"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", nil},
                           {"YELLOW_CARDS", nil},
                           {"GOALS_CONCEDED", nil},
                           {"SAVES", nil},
                           {"INTERCEPTIONS", nil},
                           {"TACKLES", nil},
                           {"SHOTS_ON_TARGET", nil},
                           {"ASSISTS", nil},
                           {"GOALS", nil}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-omitted" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-omitted"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS", {:cells, []}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-zero-minutes-positive-count" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-zero-minutes-positive-count"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 0},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-minutes-over-120" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-minutes-over-120"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 121},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-match-no-performance" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-match-no-performance"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES", {:rows, []}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P03-empty" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P03-empty"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES", {:rows, []}},
                {"MATCHES", {:rows, []}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P04-filter-mixed" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P04-filter-mixed"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]},
                {:cells,
                 [
                   {"SOURCE_ID", "B-excluded-scheduled"},
                   {"REF", "b#excluded-scheduled"},
                   {"KIND", :match}
                 ]},
                {:cells,
                 [{"SOURCE_ID", "B-excluded-live"}, {"REF", "b#excluded-live"}, {"KIND", :match}]},
                {:cells,
                 [
                   {"SOURCE_ID", "B-excluded-postponed"},
                   {"REF", "b#excluded-postponed"},
                   {"KIND", :match}
                 ]},
                {:cells,
                 [
                   {"SOURCE_ID", "B-excluded-abandoned"},
                   {"REF", "b#excluded-abandoned"},
                   {"KIND", :match}
                 ]},
                {:cells, [{"SOURCE_ID", "B-old"}, {"REF", "b#old"}, {"KIND", :match}]},
                {:cells,
                 [
                   {"SOURCE_ID", "B-different-scope"},
                   {"REF", "b#different-scope"},
                   {"KIND", :match}
                 ]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]},
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"GOALS", -1}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#excluded-scheduled"},
                       {"REF", "b#excluded-performance-scheduled"}
                     ]},
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"GOALS", -1}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#excluded-live"},
                       {"REF", "b#excluded-performance-live"}
                     ]},
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"GOALS", -1}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#excluded-postponed"},
                       {"REF", "b#excluded-performance-postponed"}
                     ]},
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"GOALS", -1}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#excluded-abandoned"},
                       {"REF", "b#excluded-performance-abandoned"}
                     ]},
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"GOALS", -10}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#old"},
                       {"REF", "b#old-perf"}
                     ]},
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"GOALS", -1}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "unused-dangling"},
                       {"MATCH_REF", "b#different-scope"},
                       {"REF", "b#different-scope-perf"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"STATUS", :scheduled},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#excluded-scheduled"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"STATUS", :live},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#excluded-live"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"STATUS", :postponed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#excluded-postponed"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"STATUS", :abandoned},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#excluded-abandoned"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2024-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#old"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2025}, {"START_YEAR", 2024}, {"LEAGUE_CODE", "SA"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "invalid-unused"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#different-scope"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P05-bad-scope" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P05-bad-scope"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "ZZ"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P05-bad-status" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P05-bad-status"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :unknown},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P05-bad-kickoff" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P05-bad-kickoff"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P06-eligible-bad-metric" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P06-eligible-bad-metric"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"GOALS", -1}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P06-eligible-duplicate" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P06-eligible-duplicate"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]},
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P06-cross-season-edge" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P06-cross-season-edge"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "different"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P06-dangling-performance-match" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P06-dangling-performance-match"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "undeclared"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P06-duplicate-eligible-ref-with-scheduled-copy" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P06-duplicate-eligible-ref-with-scheduled-copy"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]},
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :scheduled},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P07-excluded-only-directory" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P07-excluded-only-directory"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "unused-dangling"},
                       {"DISPLAY_NAME", nil},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P07-retained-player-current-team" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P07-retained-player-current-team"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]},
                {:cells, [{"SOURCE_ID", "B-source-b#green"}, {"REF", "b#green"}, {"KIND", :team}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#green"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "GRN"},
                       {"NAME", "Green Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#green"}
                     ]},
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P08-transfer" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P08-transfer"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P09-no-capability" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"GOALS", -1}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"GOALS", 0.5}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"GOALS", true}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"GOALS", "1"}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-assists-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-assists-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"ASSISTS", -1},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-assists-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-assists-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"ASSISTS", 0.5},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-assists-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-assists-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"ASSISTS", true},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-assists-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-assists-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"ASSISTS", "1"},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-shots_on_target-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-shots_on_target-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"SHOTS_ON_TARGET", -1},
                           {"ASSISTS", 1},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-shots_on_target-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-shots_on_target-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"SHOTS_ON_TARGET", 0.5},
                           {"ASSISTS", 1},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-shots_on_target-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-shots_on_target-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"SHOTS_ON_TARGET", true},
                           {"ASSISTS", 1},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-shots_on_target-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-shots_on_target-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"SHOTS_ON_TARGET", "1"},
                           {"ASSISTS", 1},
                           {"GOALS", 0}
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-tackles-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-tackles-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"TACKLES", -1},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-tackles-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-tackles-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"TACKLES", 0.5},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-tackles-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-tackles-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"TACKLES", true},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-tackles-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-tackles-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                           {"TACKLES", "1"},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-interceptions-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-interceptions-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", 5},
                           {"INTERCEPTIONS", -1},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-interceptions-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-interceptions-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", 5},
                           {"INTERCEPTIONS", 0.5},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-interceptions-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-interceptions-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", 5},
                           {"INTERCEPTIONS", true},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-interceptions-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-interceptions-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", 5},
                           {"INTERCEPTIONS", "1"},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-saves-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-saves-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", -1},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-saves-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-saves-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", 0.5},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-saves-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-saves-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", true},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-saves-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-saves-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 6},
                           {"SAVES", "1"},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals_conceded-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals_conceded-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", -1},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals_conceded-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals_conceded-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", 0.5},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals_conceded-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals_conceded-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", true},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-goals_conceded-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-goals_conceded-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 7},
                           {"GOALS_CONCEDED", "1"},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-yellow_cards-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-yellow_cards-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", -1},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-yellow_cards-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-yellow_cards-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", 0.5},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-yellow_cards-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-yellow_cards-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", true},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-yellow_cards-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-yellow_cards-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 8},
                           {"YELLOW_CARDS", "1"},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-red_cards-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-red_cards-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", -1},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-red_cards-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-red_cards-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", 0.5},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-red_cards-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-red_cards-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", true},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-red_cards-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-red_cards-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
                        {:cells,
                         [
                           {"RED_CARDS", "1"},
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-minutes_played-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-minutes_played-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", -1},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-minutes_played-fraction" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-minutes_played-fraction"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 0.5},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-minutes_played-boolean" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-minutes_played-boolean"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", true},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-minutes_played-text" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-minutes_played-text"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", "1"},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-unsupported-count" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-unsupported-count"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS",
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
                         ]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-missing-minutes" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-missing-minutes"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-missing-kickoff" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-missing-kickoff"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-missing-position" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-missing-position"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "unmapped"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-unknown-league" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-unknown-league"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "ZZ"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-missing-participant" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-missing-participant"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "absent"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-same-home-away" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-same-home-away"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#red"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-nonparticipating-team" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-nonparticipating-team"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]},
                {:cells, [{"SOURCE_ID", "B-source-b#green"}, {"REF", "b#green"}, {"KIND", :team}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#green"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#green"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "GRN"},
                       {"NAME", "Green Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#green"}
                     ]},
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-repeat-player-match" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-repeat-player-match"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]},
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "another"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-duplicate-identical" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-duplicate-identical"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]},
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-duplicate-conflicting" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-duplicate-conflicting"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]},
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
                       {"MINUTES_PLAYED", 20},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-rating-substitute" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-rating-substitute"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"RATING", 10}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-P10-team-total-substitute" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-P10-team-total-substitute"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"COUNTS", {:cells, [{"TEAM_GOALS", 10}]}},
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R01-case" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R01-case"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R01-whitespace" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R01-whitespace"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R01-string-keys" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R01-string-keys"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-missing" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-unknown-field" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-mixed-keys" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-non-map" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-league" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-year-type" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-year-bool" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-year-gap" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-catalog-bound" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-timeout-type" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-timeout-zero" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-timeout-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R02-timeout-bool" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R03-same-year" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R03-same-year"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
                  ]}},
                {"SEASON",
                 {:cells,
                  [
                    {"END_YEAR", 2025},
                    {"START_YEAR", 2025},
                    {"LEAGUE_REF", "b#league"},
                    {"REF", "b#season"}
                  ]}},
                {"LEAGUE",
                 {:cells, [{"NAME", "Premier League"}, {"CODE", "PL"}, {"REF", "b#league"}]}}
              ]}},
            {"SCOPE",
             {:cells, [{"END_YEAR", 2025}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R03-lower-only" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R03-lower-only"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R03-upper-only" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R03-upper-only"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R03-unbounded" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R03-unbounded"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R03-offset-equal" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-R03-offset-equal"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#match"}, {"REF", "b#match"}, {"KIND", :match}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PERFORMANCES",
                 {:rows,
                  [
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
                       {"MINUTES_PLAYED", 91},
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"PLAYER_REF", "b#first"},
                       {"MATCH_REF", "b#match"},
                       {"REF", "b#appearance"}
                     ]}
                  ]}},
                {"MATCHES",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"SCOPE",
                        {:cells,
                         [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
                       {"AWAY_TEAM_REF", "b#blue"},
                       {"HOME_TEAM_REF", "b#red"},
                       {"KICKOFF_AT", "2025-01-01T00:00:00.000000Z"},
                       {"STATUS", :completed},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#match"}
                     ]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R04-naive" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R04-bad-instant" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R04-overprecision" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-R04-reversed" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-invalid_request" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-invalid_request" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-unsupported_capability" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-unsupported_capability" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unsupported_capability}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-not_found" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :not_found}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-not_found" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :not_found}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-authentication_failed" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :authentication_failed}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-authentication_failed" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :authentication_failed}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-rate_limited" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :rate_limited}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-rate_limited" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :rate_limited}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-unavailable" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-unavailable" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-timeout" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-timeout" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E01-invalid_response" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_response}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-I01-invalid_response" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_response}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E02-known-delay" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells, [{"FAILURE", {:cells, [{"RETRY_AFTER_MS", 17}, {"CATEGORY", :rate_limited}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E02-unknown-delay" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells, [{"FAILURE", {:cells, [{"RETRY_AFTER_MS", nil}, {"CATEGORY", :rate_limited}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E02-bad-delay" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells, [{"FAILURE", {:cells, [{"RETRY_AFTER_MS", -1}, {"CATEGORY", :rate_limited}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-url" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-E03-url"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [
                   {"SOURCE_ID", "https://FAKE_SENTINEL.invalid/a"},
                   {"REF", "b#league"},
                   {"KIND", :league}
                 ]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-userinfo" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-E03-userinfo"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [
                   {"SOURCE_ID", "https://FAKE_SENTINEL:pw@invalid/a"},
                   {"REF", "b#league"},
                   {"KIND", :league}
                 ]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-token-query" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-E03-token-query"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [
                   {"SOURCE_ID", "https://invalid/?token=FAKE_SENTINEL"},
                   {"REF", "b#league"},
                   {"KIND", :league}
                 ]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-header" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-E03-header"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [
                   {"SOURCE_ID", "Authorization: Bearer FAKE_SENTINEL"},
                   {"REF", "b#league"},
                   {"KIND", :league}
                 ]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-source-ref" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-E03-source-ref"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "Bearer FAKE_SENTINEL"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-source-id" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-E03-source-id"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "token=FAKE_SENTINEL"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-fixture-id" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "password: FAKE_SENTINEL"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-exception" =>
    {:packet,
     {:cells,
      [{"PORTIONS", {:rows, []}}, {"ELAPSED_US", 0}, {"CANDIDATE", {:cells, [{"THROW", true}]}}]},
     %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-unknown-key" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :invalid_request}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-E03-provider-label" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "Authorization: FAKE_SENTINEL"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D01-default-before" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 4_999_999},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D01-default-before"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D01-default-at" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 5_000_000},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D01-default-at"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D01-default-after" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 5_000_001},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D01-default-after"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D01-default-never" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 10_000_000},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D01-default-never"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D02-custom-before" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 6999},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D02-custom-before"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D02-custom-at" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 7000},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D02-custom-at"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D02-custom-after" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 7001},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D02-custom-after"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D02-custom-validation-delay" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 6999},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-D02-custom-validation-delay"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D02-custom-error-at-boundary" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 7000},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "B-source-b#league"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "B-source-b#season"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-D03-pages-complete"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "GK"},
                          {"TEAM_REF", "b#blue"},
                          {"DISPLAY_NAME", "Alex Example"},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#second"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 2000}
             ]},
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "FW"},
                          {"TEAM_REF", "b#red"},
                          {"DISPLAY_NAME", " Alex Example "},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#first"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 1000}
             ]}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "B-source-b#league"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "B-source-b#season"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-D04-later-page-error"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}, {"DELAY_US", 1000}]},
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "FW"},
                          {"TEAM_REF", "b#red"},
                          {"DISPLAY_NAME", " Alex Example "},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#first"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 1000}
             ]}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "B-source-b#league"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "B-source-b#season"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-D04-later-page-timeout"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "GK"},
                          {"TEAM_REF", "b#blue"},
                          {"DISPLAY_NAME", "Alex Example"},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#second"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 5000}
             ]},
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "FW"},
                          {"TEAM_REF", "b#red"},
                          {"DISPLAY_NAME", " Alex Example "},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#first"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 2000}
             ]}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS", {:rows, []}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "B-source-b#league"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "B-source-b#season"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-D04-cumulative-page-delay"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS",
         {:rows,
          [
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "GK"},
                          {"TEAM_REF", "b#blue"},
                          {"DISPLAY_NAME", "Alex Example"},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#second"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 4000}
             ]},
            {:cells,
             [
               {"FACTS",
                {:cells,
                 [
                   {"PLAYERS",
                    {:rows,
                     [
                       {:cells,
                        [
                          {"POSITION_REF", "FW"},
                          {"TEAM_REF", "b#red"},
                          {"DISPLAY_NAME", " Alex Example "},
                          {"SEASON_REF", "b#season"},
                          {"REF", "b#first"}
                        ]}
                     ]}}
                 ]}},
               {"DELAY_US", 4000}
             ]}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D05-late-result" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D05-next-call" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D05-caller-exit" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :timeout}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-D05-crash" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE", {:cells, [{"FAILURE", {:cells, [{"CATEGORY", :unavailable}]}}]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-O01-repeat" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-O01-repeat"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-O02-bijection-negative" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-O02-bijection-negative"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
  "F-O03-traceability" =>
    {:packet,
     {:cells,
      [
        {"PORTIONS", {:rows, []}},
        {"ELAPSED_US", 0},
        {"CANDIDATE",
         {:cells,
          [
            {"FIXTURE_ID", "F-O03-traceability"},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"SOURCE_ID", "B-source-b#league"}, {"REF", "b#league"}, {"KIND", :league}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#season"}, {"REF", "b#season"}, {"KIND", :season}]},
                {:cells, [{"SOURCE_ID", "B-source-b#red"}, {"REF", "b#red"}, {"KIND", :team}]},
                {:cells, [{"SOURCE_ID", "B-source-b#blue"}, {"REF", "b#blue"}, {"KIND", :team}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#first"}, {"REF", "b#first"}, {"KIND", :player}]},
                {:cells,
                 [{"SOURCE_ID", "B-source-b#second"}, {"REF", "b#second"}, {"KIND", :player}]}
              ]}},
            {"FACTS",
             {:cells,
              [
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"POSITION_REF", "GK"},
                       {"TEAM_REF", "b#blue"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#second"}
                     ]},
                    {:cells,
                     [
                       {"POSITION_REF", "FW"},
                       {"TEAM_REF", "b#red"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#first"}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"NAME", "Goalkeeper"}, {"CODE", "GK"}, {"REF", "GK"}]},
                    {:cells, [{"NAME", "Forward"}, {"CODE", "FW"}, {"REF", "FW"}]}
                  ]}},
                {"TEAMS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"CODE", "BLU"},
                       {"NAME", "Blue Team"},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#blue"}
                     ]},
                    {:cells,
                     [
                       {"CODE", " RED "},
                       {"NAME", " Red Team "},
                       {"SEASON_REF", "b#season"},
                       {"REF", "b#red"}
                     ]}
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
             {:cells, [{"END_YEAR", 2026}, {"START_YEAR", 2025}, {"LEAGUE_CODE", "PL"}]}},
            {"OPERATION", :catalog}
          ]}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}},
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
                    {:cells,
                     [
                       {"REF", "b#blue"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", "Blue Team"},
                       {"CODE", "BLU"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#red"},
                       {"SEASON_REF", "b#season"},
                       {"NAME", " Red Team "},
                       {"CODE", " RED "}
                     ]}
                  ]}},
                {"POSITIONS",
                 {:rows,
                  [
                    {:cells, [{"REF", "GK"}, {"CODE", "GK"}, {"NAME", "Goalkeeper"}]},
                    {:cells, [{"REF", "FW"}, {"CODE", "FW"}, {"NAME", "Forward"}]}
                  ]}},
                {"PLAYERS",
                 {:rows,
                  [
                    {:cells,
                     [
                       {"REF", "b#second"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", "Alex Example"},
                       {"TEAM_REF", "b#blue"},
                       {"POSITION_REF", "GK"}
                     ]},
                    {:cells,
                     [
                       {"REF", "b#first"},
                       {"SEASON_REF", "b#season"},
                       {"DISPLAY_NAME", " Alex Example "},
                       {"TEAM_REF", "b#red"},
                       {"POSITION_REF", "FW"}
                     ]}
                  ]}}
              ]}},
            {"BINDINGS",
             {:rows,
              [
                {:cells,
                 [{"KIND", :league}, {"REF", "b#league"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells,
                 [{"KIND", :season}, {"REF", "b#season"}, {"SOURCE_ID", "shared-public-id"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#red"}, {"SOURCE_ID", "B-source-b#red"}]},
                {:cells, [{"KIND", :team}, {"REF", "b#blue"}, {"SOURCE_ID", "B-source-b#blue"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#first"}, {"SOURCE_ID", "B-source-b#first"}]},
                {:cells,
                 [{"KIND", :player}, {"REF", "b#second"}, {"SOURCE_ID", "B-source-b#second"}]}
              ]}},
            {"FIXTURE_ID", "F-C05-same-id-other-scope-2024"}
          ]}},
        {"ELAPSED_US", 0},
        {"PORTIONS", {:rows, []}}
      ]}, %{:rating => 777, :team_goals => 999, :attempted_tackles => 888}}
}
