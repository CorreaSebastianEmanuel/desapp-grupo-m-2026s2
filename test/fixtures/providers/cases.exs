# Independently declared cases bases. Overrides below retain stable case IDs.
# Paths are map keys / zero-based row indexes / source B's uppercase cells.
alias FootballMarket.Providers.FixtureData, as: F

case Code.ensure_compiled(F) do
  {:module, _} ->
    :ok

  {:error, _} ->
    Code.require_file(Path.expand("../../support/providers/fixture_data.ex", __DIR__))
end

catalog = %{
  id: "F-C01-PL-2025-2026-A",
  request: %{league_code: "PL", start_year: 2025, end_year: 2026},
  sources: %{a: "F-C01-PL-2025-2026-A", b: "F-C01-PL-2025-2026-A"},
  operation: :catalog,
  positions: %{"FW" => "Forward", "GK" => "Goalkeeper"},
  correspondence: %{
    a: %{
      match: %{},
      position: %{"FW" => "FW", "GK" => "GK"},
      league: %{"a/league" => "league"},
      season: %{"a/season" => "season"},
      team: %{"a/blue" => "blue", "a/red" => "red"},
      player: %{"a/first" => "first", "a/second" => "second"},
      performance: %{}
    },
    b: %{
      match: %{},
      position: %{"FW" => "FW", "GK" => "GK"},
      league: %{"b#league" => "league"},
      season: %{"b#season" => "season"},
      team: %{"b#blue" => "blue", "b#red" => "red"},
      player: %{"b#first" => "first", "b#second" => "second"},
      performance: %{}
    }
  },
  expected_bindings: %{
    a: [
      %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
      %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
      %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
      %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
      %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
      %{kind: :player, ref: "a/second", source_id: "A-source-a/second"}
    ],
    b: [
      %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
      %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
      %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
      %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
      %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
      %{kind: :player, ref: "b#second", source_id: "B-source-b#second"}
    ]
  },
  validation_us: 0,
  scenarios: ["US1.1", "US4.2"],
  requirements: ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
  success_criteria: ["SC-001", "SC-005"],
  expected_scope: %{league_code: "PL", start_year: 2025, end_year: 2026}
}

performances = %{
  id: "F-P01-PL-2025-2026-A",
  request: %{league_code: "PL", start_year: 2025, end_year: 2026},
  sources: %{a: "F-P01-PL-2025-2026-A", b: "F-P01-PL-2025-2026-A"},
  operation: :performances,
  positions: %{"FW" => "Forward", "GK" => "Goalkeeper"},
  correspondence: %{
    a: %{
      match: %{"a/match" => "match"},
      position: %{"FW" => "FW", "GK" => "GK"},
      league: %{"a/league" => "league"},
      season: %{"a/season" => "season"},
      team: %{"a/blue" => "blue", "a/red" => "red"},
      player: %{"a/first" => "first"},
      performance: %{"a/appearance" => "appearance"}
    },
    b: %{
      match: %{"b#match" => "match"},
      position: %{"FW" => "FW", "GK" => "GK"},
      league: %{"b#league" => "league"},
      season: %{"b#season" => "season"},
      team: %{"b#blue" => "blue", "b#red" => "red"},
      player: %{"b#first" => "first"},
      performance: %{"b#appearance" => "appearance"}
    }
  },
  expected_bindings: %{
    a: [
      %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
      %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
      %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
      %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
      %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
      %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
    ],
    b: [
      %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
      %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
      %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
      %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
      %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
      %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
    ]
  },
  validation_us: 0,
  scenarios: ["US2.1", "US4.2"],
  requirements: ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
  success_criteria: ["SC-001", "SC-005"],
  expected_scope: %{league_code: "PL", start_year: 2025, end_year: 2026, from: nil, to: nil}
}

# Each edit states only this case's differences from its named base.
[
  F.case_entry("F-C01-PL-2024-2025-A", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-PL-2024-2025-B", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-PL-2025-2026-A", catalog, []),
  F.case_entry("F-C01-PL-2025-2026-B", catalog, []),
  F.case_entry("F-C01-BL1-2024-2025-A", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "BL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-BL1-2024-2025-B", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "BL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-BL1-2025-2026-A", catalog, [
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:request, :league_code], "BL1"}
  ]),
  F.case_entry("F-C01-BL1-2025-2026-B", catalog, [
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:request, :league_code], "BL1"}
  ]),
  F.case_entry("F-C01-PD-2024-2025-A", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "PD"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-PD-2024-2025-B", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "PD"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-PD-2025-2026-A", catalog, [
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:request, :league_code], "PD"}
  ]),
  F.case_entry("F-C01-PD-2025-2026-B", catalog, [
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:request, :league_code], "PD"}
  ]),
  F.case_entry("F-C01-SA-2024-2025-A", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "SA"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-SA-2024-2025-B", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "SA"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-SA-2025-2026-A", catalog, [
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:request, :league_code], "SA"}
  ]),
  F.case_entry("F-C01-SA-2025-2026-B", catalog, [
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:request, :league_code], "SA"}
  ]),
  F.case_entry("F-C01-FL1-2024-2025-A", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "FL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-FL1-2024-2025-B", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "FL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-C01-FL1-2025-2026-A", catalog, [
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:request, :league_code], "FL1"}
  ]),
  F.case_entry("F-C01-FL1-2025-2026-B", catalog, [
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:request, :league_code], "FL1"}
  ]),
  F.case_entry("F-C02-empty", catalog, [
    {:drop, [:correspondence, :a, :player, "a/first"]},
    {:drop, [:correspondence, :a, :player, "a/second"]},
    {:drop, [:correspondence, :a, :position, "FW"]},
    {:drop, [:correspondence, :a, :position, "GK"]},
    {:drop, [:correspondence, :a, :team, "a/blue"]},
    {:drop, [:correspondence, :a, :team, "a/red"]},
    {:drop, [:correspondence, :b, :player, "b#first"]},
    {:drop, [:correspondence, :b, :player, "b#second"]},
    {:drop, [:correspondence, :b, :position, "FW"]},
    {:drop, [:correspondence, :b, :position, "GK"]},
    {:drop, [:correspondence, :b, :team, "b#blue"]},
    {:drop, [:correspondence, :b, :team, "b#red"]},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"}
     ]},
    {:put, [:requirements], ["FR-003"]},
    {:put, [:scenarios], ["US1.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C03-unknown-season", catalog, [
    {:put, [:requirements], ["FR-003", "FR-009"]},
    {:put, [:scenarios], ["US1.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C03-unsupported", catalog, [
    {:put, [:requirements], ["FR-003", "FR-009"]},
    {:put, [:scenarios], ["US1.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-missing-fact", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-blank-label", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-ref-identical", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-ref-conflicting", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-source", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-name", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-code", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-position-name", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-duplicate-position-code", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-cross-season", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-dangling", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-unmapped-position", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-extra-normalized-field", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-binding-missing", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-binding-dangling", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-binding-duplicate", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-league-mismatch", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C04-season-mismatch", catalog, [
    {:put, [:requirements], ["FR-004", "FR-005", "FR-008"]},
    {:put, [:scenarios], ["US1.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C05-same-id-other-kind", catalog, [
    {:put, [:expected_bindings, :a, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :a, 1, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 1, :source_id], "shared-public-id"},
    {:put, [:requirements], ["FR-005"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C05-same-id-other-scope", catalog, [
    {:put, [:expected_bindings, :a, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :a, 1, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 1, :source_id], "shared-public-id"},
    {:put, [:requirements], ["FR-005"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-C05-same-id-other-provider", catalog, [
    {:put, [:expected_bindings, :a, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :a, 1, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 1, :source_id], "shared-public-id"},
    {:put, [:requirements], ["FR-005"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P01-PL-2024-2025-A", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-PL-2024-2025-B", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-PL-2025-2026-A", performances, []),
  F.case_entry("F-P01-PL-2025-2026-B", performances, []),
  F.case_entry("F-P01-BL1-2024-2025-A", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "BL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-BL1-2024-2025-B", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "BL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-BL1-2025-2026-A", performances, [
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:request, :league_code], "BL1"}
  ]),
  F.case_entry("F-P01-BL1-2025-2026-B", performances, [
    {:put, [:expected_scope, :league_code], "BL1"},
    {:put, [:request, :league_code], "BL1"}
  ]),
  F.case_entry("F-P01-PD-2024-2025-A", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "PD"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-PD-2024-2025-B", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "PD"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-PD-2025-2026-A", performances, [
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:request, :league_code], "PD"}
  ]),
  F.case_entry("F-P01-PD-2025-2026-B", performances, [
    {:put, [:expected_scope, :league_code], "PD"},
    {:put, [:request, :league_code], "PD"}
  ]),
  F.case_entry("F-P01-SA-2024-2025-A", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "SA"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-SA-2024-2025-B", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "SA"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-SA-2025-2026-A", performances, [
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:request, :league_code], "SA"}
  ]),
  F.case_entry("F-P01-SA-2025-2026-B", performances, [
    {:put, [:expected_scope, :league_code], "SA"},
    {:put, [:request, :league_code], "SA"}
  ]),
  F.case_entry("F-P01-FL1-2024-2025-A", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "FL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-FL1-2024-2025-B", performances, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :league_code], "FL1"},
    {:put, [:request, :start_year], 2024}
  ]),
  F.case_entry("F-P01-FL1-2025-2026-A", performances, [
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:request, :league_code], "FL1"}
  ]),
  F.case_entry("F-P01-FL1-2025-2026-B", performances, [
    {:put, [:expected_scope, :league_code], "FL1"},
    {:put, [:request, :league_code], "FL1"}
  ]),
  F.case_entry("F-P02-before", catalog, [
    {:drop, [:correspondence, :a, :player, "a/first"]},
    {:drop, [:correspondence, :a, :player, "a/second"]},
    {:drop, [:correspondence, :a, :position, "FW"]},
    {:drop, [:correspondence, :a, :position, "GK"]},
    {:drop, [:correspondence, :a, :team, "a/blue"]},
    {:drop, [:correspondence, :a, :team, "a/red"]},
    {:drop, [:correspondence, :b, :player, "b#first"]},
    {:drop, [:correspondence, :b, :player, "b#second"]},
    {:drop, [:correspondence, :b, :position, "FW"]},
    {:drop, [:correspondence, :b, :position, "GK"]},
    {:drop, [:correspondence, :b, :team, "b#blue"]},
    {:drop, [:correspondence, :b, :team, "b#red"]},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"}
     ]},
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:operation], :performances},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:requirements], ["FR-002", "FR-006"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P02-lower", performances, [
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:requirements], ["FR-002", "FR-006"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P02-equal-offset", performances, [
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:requirements], ["FR-002", "FR-006"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P02-upper", performances, [
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:requirements], ["FR-002", "FR-006"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P02-after", catalog, [
    {:drop, [:correspondence, :a, :player, "a/first"]},
    {:drop, [:correspondence, :a, :player, "a/second"]},
    {:drop, [:correspondence, :a, :position, "FW"]},
    {:drop, [:correspondence, :a, :position, "GK"]},
    {:drop, [:correspondence, :a, :team, "a/blue"]},
    {:drop, [:correspondence, :a, :team, "a/red"]},
    {:drop, [:correspondence, :b, :player, "b#first"]},
    {:drop, [:correspondence, :b, :player, "b#second"]},
    {:drop, [:correspondence, :b, :position, "FW"]},
    {:drop, [:correspondence, :b, :position, "GK"]},
    {:drop, [:correspondence, :b, :team, "b#blue"]},
    {:drop, [:correspondence, :b, :team, "b#red"]},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"}
     ]},
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:operation], :performances},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000001Z"},
    {:put, [:requirements], ["FR-002", "FR-006"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-zero", performances, [
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-nil", performances, [
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-omitted", performances, [
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-zero-minutes-positive-count", performances, [
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-minutes-over-120", performances, [
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-match-no-performance", performances, [
    {:drop, [:correspondence, :a, :performance, "a/appearance"]},
    {:drop, [:correspondence, :a, :player, "a/first"]},
    {:drop, [:correspondence, :a, :position, "FW"]},
    {:drop, [:correspondence, :a, :position, "GK"]},
    {:drop, [:correspondence, :b, :performance, "b#appearance"]},
    {:drop, [:correspondence, :b, :player, "b#first"]},
    {:drop, [:correspondence, :b, :position, "FW"]},
    {:drop, [:correspondence, :b, :position, "GK"]},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P03-empty", catalog, [
    {:drop, [:correspondence, :a, :player, "a/first"]},
    {:drop, [:correspondence, :a, :player, "a/second"]},
    {:drop, [:correspondence, :a, :position, "FW"]},
    {:drop, [:correspondence, :a, :position, "GK"]},
    {:drop, [:correspondence, :a, :team, "a/blue"]},
    {:drop, [:correspondence, :a, :team, "a/red"]},
    {:drop, [:correspondence, :b, :player, "b#first"]},
    {:drop, [:correspondence, :b, :player, "b#second"]},
    {:drop, [:correspondence, :b, :position, "FW"]},
    {:drop, [:correspondence, :b, :position, "GK"]},
    {:drop, [:correspondence, :b, :team, "b#blue"]},
    {:drop, [:correspondence, :b, :team, "b#red"]},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"}
     ]},
    {:put, [:expected_scope, :from], nil},
    {:put, [:expected_scope, :to], nil},
    {:put, [:operation], :performances},
    {:put, [:requirements], ["FR-003", "FR-007"]},
    {:put, [:scenarios], ["US2.2"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P04-filter-mixed", performances, [
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:requirements], ["FR-006", "FR-008"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P05-bad-scope", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-008"]},
    {:put, [:scenarios], ["US2.1", "US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P05-bad-status", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-008"]},
    {:put, [:scenarios], ["US2.1", "US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P05-bad-kickoff", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-008"]},
    {:put, [:scenarios], ["US2.1", "US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P06-eligible-bad-metric", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P06-eligible-duplicate", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P06-cross-season-edge", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P06-dangling-performance-match", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P06-duplicate-eligible-ref-with-scheduled-copy", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P07-excluded-only-directory", performances, [
    {:put, [:requirements], ["FR-004", "FR-006", "FR-008"]},
    {:put, [:scenarios], ["US2.1", "US2.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P07-retained-player-current-team", performances, [
    {:put, [:correspondence, :a, :team, "a/green"], "green"},
    {:put, [:correspondence, :b, :team, "b#green"], "green"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :team, ref: "a/green", source_id: "A-source-a/green"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :team, ref: "b#green", source_id: "B-source-b#green"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-004", "FR-006", "FR-008"]},
    {:put, [:scenarios], ["US2.1", "US2.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P08-transfer", performances, [
    {:put, [:requirements], ["FR-006"]},
    {:put, [:scenarios], ["US2.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P09-no-capability", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-009"]},
    {:put, [:scenarios], ["US2.4"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-assists-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-assists-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-assists-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-assists-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-shots_on_target-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-shots_on_target-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-shots_on_target-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-shots_on_target-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-tackles-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-tackles-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-tackles-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-tackles-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-interceptions-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-interceptions-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-interceptions-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-interceptions-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-saves-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-saves-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-saves-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-saves-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals_conceded-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals_conceded-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals_conceded-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-goals_conceded-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-yellow_cards-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-yellow_cards-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-yellow_cards-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-yellow_cards-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-red_cards-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-red_cards-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-red_cards-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-red_cards-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-minutes_played-negative", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-minutes_played-fraction", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-minutes_played-boolean", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-minutes_played-text", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-unsupported-count", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-missing-minutes", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-missing-kickoff", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-missing-position", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-unknown-league", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-missing-participant", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-same-home-away", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-nonparticipating-team", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-repeat-player-match", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-duplicate-identical", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-duplicate-conflicting", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-rating-substitute", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-P10-team-total-substitute", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:requirements], ["FR-006", "FR-007", "FR-008"]},
    {:put, [:scenarios], ["US2.5"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R01-case", catalog, [
    {:put, [:request, :league_code], "pl"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R01-whitespace", catalog, [
    {:put, [:request, :league_code], " PL "},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R01-string-keys", catalog, [
    {:drop, [:request, :end_year]},
    {:drop, [:request, :league_code]},
    {:drop, [:request, :start_year]},
    {:put, [:request, "end_year"], 2026},
    {:put, [:request, "league_code"], "PL"},
    {:put, [:request, "start_year"], 2025},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-missing", catalog, [
    {:put, [:expected_scope], nil},
    {:drop, [:request, :league_code]},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-unknown-field", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, "FAKE_SENTINEL"], "bad"},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-mixed-keys", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, "to"], nil},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-non-map", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request], true},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-league", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :league_code], "ZZ"},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-year-type", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :start_year], "2025"},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-year-bool", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :start_year], true},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-year-gap", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :end_year], 2028},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-catalog-bound", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :from], nil},
    {:put, [:requirements], ["FR-002", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-timeout-type", catalog, [
    {:put, [:request, :timeout_ms], "7"},
    {:put, [:requirements], ["FR-002", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-timeout-zero", catalog, [
    {:put, [:request, :timeout_ms], 0},
    {:put, [:requirements], ["FR-002", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-timeout-negative", catalog, [
    {:put, [:request, :timeout_ms], -1},
    {:put, [:requirements], ["FR-002", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R02-timeout-bool", catalog, [
    {:put, [:request, :timeout_ms], true},
    {:put, [:requirements], ["FR-002", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US1.3"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R03-same-year", catalog, [
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:request, :end_year], 2025},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R03-lower-only", performances, [
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R03-upper-only", performances, [
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000000Z"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R03-unbounded", performances, [
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R03-offset-equal", performances, [
    {:put, [:expected_scope, :from], "2025-01-01T00:00:00.000000Z"},
    {:put, [:expected_scope, :to], "2025-01-01T00:00:00.000000Z"},
    {:put, [:request, :from], "2025-01-01T01:00:00.000000+01:00"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000000Z"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R04-naive", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:expected_scope], nil},
    {:put, [:request, :from], "2025-01-01T00:00:00"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.3", "US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R04-bad-instant", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:expected_scope], nil},
    {:put, [:request, :from], "no"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.3", "US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R04-overprecision", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:expected_scope], nil},
    {:put, [:request, :from], "2025-01-01T00:00:00.1234567Z"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.3", "US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-R04-reversed", performances, [
    {:put, [:correspondence, :a, :player, "a/second"], "second"},
    {:put, [:correspondence, :b, :player, "b#second"], "second"},
    {:put, [:expected_bindings, :a],
     [
       %{kind: :league, ref: "a/league", source_id: "A-source-a/league"},
       %{kind: :season, ref: "a/season", source_id: "A-source-a/season"},
       %{kind: :team, ref: "a/red", source_id: "A-source-a/red"},
       %{kind: :team, ref: "a/blue", source_id: "A-source-a/blue"},
       %{kind: :player, ref: "a/first", source_id: "A-source-a/first"},
       %{kind: :player, ref: "a/second", source_id: "A-source-a/second"},
       %{kind: :match, ref: "a/match", source_id: "A-source-a/match"}
     ]},
    {:put, [:expected_bindings, :b],
     [
       %{kind: :league, ref: "b#league", source_id: "B-source-b#league"},
       %{kind: :season, ref: "b#season", source_id: "B-source-b#season"},
       %{kind: :team, ref: "b#red", source_id: "B-source-b#red"},
       %{kind: :team, ref: "b#blue", source_id: "B-source-b#blue"},
       %{kind: :player, ref: "b#first", source_id: "B-source-b#first"},
       %{kind: :player, ref: "b#second", source_id: "B-source-b#second"},
       %{kind: :match, ref: "b#match", source_id: "B-source-b#match"}
     ]},
    {:put, [:expected_scope], nil},
    {:put, [:request, :from], "2025-02-01T00:00:00Z"},
    {:put, [:request, :to], "2025-01-01T00:00:00.000000Z"},
    {:put, [:requirements], ["FR-002"]},
    {:put, [:scenarios], ["US1.3", "US2.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E01-invalid_request", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :league_code], "ZZ"},
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-invalid_request", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, :league_code], "ZZ"},
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-unsupported_capability", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-unsupported_capability", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-not_found", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-not_found", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-authentication_failed", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-authentication_failed", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-rate_limited", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-rate_limited", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-unavailable", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-unavailable", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-timeout", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-timeout", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E01-invalid_response", catalog, [
    {:put, [:requirements], ["FR-009", "FR-011"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-I01-invalid_response", catalog, [
    {:put, [:requirements], ["FR-011", "FR-013"]},
    {:put, [:scenarios], ["US3.5"]},
    {:put, [:state_check], "catalog-isolation"},
    {:put, [:state_oracle], "exact five-table/read equality"},
    {:put, [:success_criteria], ["SC-002", "SC-006"]}
  ]),
  F.case_entry("F-E02-known-delay", catalog, [
    {:put, [:requirements], ["FR-009"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E02-unknown-delay", catalog, [
    {:put, [:requirements], ["FR-009"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E02-bad-delay", catalog, [
    {:put, [:requirements], ["FR-009"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-url", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-userinfo", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-token-query", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-header", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-source-ref", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-source-id", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-fixture-id", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-exception", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-unknown-key", catalog, [
    {:put, [:expected_scope], nil},
    {:put, [:request, "FAKE_SENTINEL"], "bad"},
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-E03-provider-label", catalog, [
    {:put, [:requirements], ["FR-009", "FR-012"]},
    {:put, [:scenarios], ["US3.1"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ]),
  F.case_entry("F-D01-default-before", catalog, [
    {:put, [:requirements], ["FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D01-default-at", catalog, [
    {:put, [:requirements], ["FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D01-default-after", catalog, [
    {:put, [:requirements], ["FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D01-default-never", catalog, [
    {:put, [:requirements], ["FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D02-custom-before", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D02-custom-at", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D02-custom-after", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.2", "US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D02-custom-validation-delay", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.3"]},
    {:put, [:success_criteria], ["SC-003"]},
    {:put, [:validation_us], 1}
  ]),
  F.case_entry("F-D02-custom-error-at-boundary", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.3"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D03-pages-complete", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-003", "FR-010"]},
    {:put, [:scenarios], ["US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D04-later-page-error", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-003", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D04-later-page-timeout", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-003", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D04-cumulative-page-delay", catalog, [
    {:put, [:request, :timeout_ms], 7},
    {:put, [:requirements], ["FR-003", "FR-009", "FR-010"]},
    {:put, [:scenarios], ["US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D05-late-result", catalog, [
    {:put, [:requirements], ["FR-010", "FR-011"]},
    {:put, [:scenarios], ["US3.2", "US3.3", "US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D05-next-call", catalog, [
    {:put, [:requirements], ["FR-010", "FR-011"]},
    {:put, [:scenarios], ["US3.2", "US3.3", "US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D05-caller-exit", catalog, [
    {:put, [:requirements], ["FR-010", "FR-011"]},
    {:put, [:scenarios], ["US3.2", "US3.3", "US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-D05-crash", catalog, [
    {:put, [:requirements], ["FR-010", "FR-011"]},
    {:put, [:scenarios], ["US3.2", "US3.3", "US3.4"]},
    {:put, [:success_criteria], ["SC-003"]}
  ]),
  F.case_entry("F-O01-repeat", catalog, [
    {:put, [:requirements], ["FR-013"]},
    {:put, [:scenarios], ["US4.1", "US4.2", "US4.3"]},
    {:put, [:success_criteria], ["SC-004"]}
  ]),
  F.case_entry("F-O02-bijection-negative", catalog, [
    {:put, [:requirements], ["FR-005", "FR-013"]},
    {:put, [:scenarios], ["US4.1", "US4.2", "US4.3"]},
    {:put, [:success_criteria], ["SC-004"]}
  ]),
  F.case_entry("F-O03-traceability", catalog, [
    {:put, [:requirements], ["FR-013"]},
    {:put, [:scenarios], ["US4.1", "US4.2", "US4.3"]},
    {:put, [:success_criteria], ["SC-004"]}
  ]),
  F.case_entry("F-C05-same-id-other-scope-2024", catalog, [
    {:put, [:expected_bindings, :a, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :a, 1, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 0, :source_id], "shared-public-id"},
    {:put, [:expected_bindings, :b, 1, :source_id], "shared-public-id"},
    {:put, [:expected_scope, :end_year], 2025},
    {:put, [:expected_scope, :start_year], 2024},
    {:put, [:request, :end_year], 2025},
    {:put, [:request, :start_year], 2024},
    {:put, [:requirements], ["FR-005"]},
    {:put, [:success_criteria], ["SC-002", "SC-005"]}
  ])
]
