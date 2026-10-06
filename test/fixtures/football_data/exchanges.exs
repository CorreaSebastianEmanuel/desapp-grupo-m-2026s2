# Synthetic documented v4 fields only; squad rows deliberately have no season field.
%{
  discovery: %{
    "id" => 2021,
    "code" => "PL",
    "currentSeason" => %{"id" => 50, "startDate" => "2026-08-01", "endDate" => "2027-05-31"},
    "seasons" => [
      %{"id" => 50, "startDate" => "2026-08-01", "endDate" => "2027-05-31"},
      %{"id" => 49, "startDate" => "2025-08-01", "endDate" => "2026-05-31"}
    ]
  },
  teams: %{
    "count" => 1,
    "filters" => %{"season" => "2026"},
    "competition" => %{"id" => 2021, "code" => "PL"},
    "teams" => [%{"id" => 10, "name" => "Synthetic Club", "tla" => "SYN"}]
  },
  team: %{
    "id" => 10,
    "name" => "Synthetic Club",
    "tla" => "SYN",
    "runningCompetitions" => [%{"id" => 2021, "code" => "PL"}],
    "squad" => [
      %{"id" => 100, "name" => "Alex Example", "position" => "Goalkeeper"},
      %{"id" => 101, "name" => "Alex Example", "position" => " Defence "},
      %{"id" => 102, "name" => "Case Example", "position" => "MIDFIELD"},
      %{"id" => 103, "name" => "Forward Example", "position" => "Offence"}
    ],
    "coach" => %{"id" => 999, "name" => "Ignored Coach"},
    "address" => "Ignored address"
  },
  person: %{"id" => 100, "currentTeam" => %{"id" => 10}}
}
