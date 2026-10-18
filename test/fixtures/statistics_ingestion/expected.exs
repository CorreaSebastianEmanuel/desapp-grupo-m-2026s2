%{
  complete: %{accepted_matches: 2, accepted_performances: 2, outcome: :accepted_changes},
  empty: %{accepted_matches: 0, accepted_performances: 0, outcome: :accepted_empty},
  incomplete: %{accepted_matches: 0, accepted_performances: 0, outcome: :invalid_incomplete},
  unchanged: %{accepted_matches: 2, accepted_performances: 2, outcome: :accepted_unchanged},
  replay: %{accepted_matches: 2, accepted_performances: 2, outcome: :replay, duplicate_facts: 0},
  conflict: %{outcome: :immutable_conflict, new_facts: 0, successful_check_advanced: false},
  unique_mode: %{
    position_id: "position-midfielder",
    reason: nil,
    frequencies: %{"position-midfielder" => 2},
    basis_match_ids: ["prior-1", "prior-2"]
  },
  tie: %{
    position_id: nil,
    reason: :tie,
    frequencies: %{"position-midfielder" => 1, "position-forward" => 1},
    basis_match_ids: ["prior-3", "prior-4"]
  },
  insufficient: %{
    position_id: nil,
    reason: :insufficient_history,
    frequencies: %{},
    basis_match_ids: []
  },
  metric_unknown_and_zero: %{
    goals: nil,
    assists: 0,
    shots_on_target: nil,
    tackles: nil,
    interceptions: nil,
    saves: nil,
    goals_conceded: nil,
    yellow_cards: nil,
    red_cards: nil
  }
}
