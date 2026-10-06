# Independent normalized oracle. No adapter, validator or source loader is used.
%{
  league_names: %{
    "PL" => "Premier League",
    "BL1" => "Bundesliga",
    "PD" => "La Liga",
    "SA" => "Serie A",
    "FL1" => "Ligue 1"
  },
  teams: [%{ref: "team-10", season_ref: "season", name: "Synthetic Club", code: "SYN"}],
  positions: [
    %{ref: "GK", code: "GK", name: "Goalkeeper"},
    %{ref: "DEF", code: "DEF", name: "Defender"},
    %{ref: "MID", code: "MID", name: "Midfielder"},
    %{ref: "FWD", code: "FWD", name: "Forward"}
  ],
  players: [
    %{
      ref: "player-100",
      season_ref: "season",
      display_name: "Alex Example",
      team_ref: "team-10",
      position_ref: "GK"
    },
    %{
      ref: "player-101",
      season_ref: "season",
      display_name: "Alex Example",
      team_ref: "team-10",
      position_ref: "DEF"
    },
    %{
      ref: "player-102",
      season_ref: "season",
      display_name: "Case Example",
      team_ref: "team-10",
      position_ref: "MID"
    },
    %{
      ref: "player-103",
      season_ref: "season",
      display_name: "Forward Example",
      team_ref: "team-10",
      position_ref: "FWD"
    }
  ],
  bindings: [
    {:league, "league", "2021"},
    {:season, "season", "50"},
    {:team, "team-10", "10"},
    {:player, "player-100", "100"},
    {:player, "player-101", "101"},
    {:player, "player-102", "102"},
    {:player, "player-103", "103"}
  ]
}
