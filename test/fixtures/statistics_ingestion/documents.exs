%{
  complete: %{
    scope: "PL-2025",
    matches: ["m-1", "m-2"],
    completeness: :complete,
    retrieval: "2026-10-16T00:00:00Z"
  },
  empty: %{scope: "BL1-2025", matches: [], completeness: :explicit_empty},
  incomplete: %{scope: "PD-2025", matches: ["m-3"], completeness: :missing_detail},
  unchanged: %{
    source_material: :complete,
    retrieval: "2026-10-17T00:00:00Z",
    same_facts: true
  },
  replay: %{source_material: :complete, prior_acceptance: true, same_facts: true},
  conflict: %{
    source_material: :complete,
    prior_acceptance: true,
    changed_immutable_field: {:performance, "p-1", :goals, 1}
  },
  substitute: %{
    player: "p-1",
    season: "s-1",
    match: "m-4",
    kickoff: ~U[2026-03-01 12:00:00Z],
    participation: :substitute_entered,
    direct_position: nil
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
  },
  position_history: %{
    window: :same_season_prior_matches,
    excludes: [:current_match, :equal_kickoff, :later_kickoff, :proposed_batch],
    votes: %{
      unique_mode: [
        %{match: "prior-1", position: "position-midfielder"},
        %{match: "prior-2", position: "position-midfielder"}
      ],
      tie: [
        %{match: "prior-3", position: "position-midfielder"},
        %{match: "prior-4", position: "position-forward"}
      ],
      insufficient: []
    }
  }
}
