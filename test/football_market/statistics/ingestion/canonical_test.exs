defmodule FootballMarket.Statistics.Ingestion.CanonicalTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.Ingestion.Canonical

  defp result(refs, order, goals \\ 1) do
    [team_a, team_b, player, match, row] = refs

    bindings = [
      %{kind: :team, ref: team_a, source_id: "team-a"},
      %{kind: :team, ref: team_b, source_id: "team-b"},
      %{kind: :player, ref: player, source_id: "player-1"},
      %{kind: :match, ref: match, source_id: "match-1"}
    ]

    facts = %{
      teams:
        Enum.map(order, fn ref ->
          %{ref: ref, season_ref: "season-local", name: if(ref == team_a, do: "A", else: "B")}
        end),
      players: [%{ref: player, season_ref: "season-local", team_ref: team_a, position_ref: "MID"}],
      matches: [
        %{
          ref: match,
          season_ref: "season-local",
          home_team_ref: team_a,
          away_team_ref: team_b,
          kickoff_at: ~U[2026-01-01 12:00:00Z]
        }
      ],
      performances: [
        %{
          ref: row,
          match_ref: match,
          player_ref: player,
          team_ref: team_a,
          position_ref: "MID",
          minutes_played: 10,
          counts: %{goals: goals}
        }
      ]
    }

    provenance = %FootballMarket.Providers.Provenance{
      provider: "source",
      retrieved_at: ~U[2026-01-02 00:00:00Z],
      bindings: bindings
    }

    %{
      scope: %{league_code: "PL", start_year: 2025, end_year: 2026},
      facts: facts,
      provenance: provenance,
      completeness: %{version: 1, complete_empty: false}
    }
  end

  test "source result identity ignores list order, DTO references and retrieval time" do
    left = result(["ta", "tb", "p", "m", "r"], ["ta", "tb"])
    right = result(["team-x", "team-y", "player-z", "match-z", "row-z"], ["team-y", "team-x"])

    bindings =
      Enum.map(right.provenance.bindings, fn b ->
        %{
          b
          | ref:
              %{
                "team-a" => "team-x",
                "team-b" => "team-y",
                "player-1" => "player-z",
                "match-1" => "match-z"
              }[b.source_id]
        }
      end)

    right = %{
      right
      | provenance: %{
          right.provenance
          | retrieved_at: ~U[2026-01-03 00:00:00Z],
            bindings: bindings
        }
    }

    assert Canonical.encode(left).material == Canonical.encode(right).material
  end

  test "semantic content changes are retained even if source identities are stable" do
    left = result(["ta", "tb", "p", "m", "r"], ["ta", "tb"], 1)
    right = result(["ta", "tb", "p", "m", "r"], ["ta", "tb"], 2)
    assert Canonical.encode(left).digest != Canonical.encode(right).digest
  end

  test "match, position, count, and source-binding material each affect replay identity" do
    base = result(["ta", "tb", "p", "m", "r"], ["ta", "tb"], 1)

    changed_kickoff =
      put_in(base, [:facts, :matches, Access.at(0), :kickoff_at], ~U[2026-01-02 12:00:00Z])

    changed_position =
      put_in(base, [:facts, :performances, Access.at(0), :position_ref], "FW")

    changed_count = put_in(base, [:facts, :performances, Access.at(0), :counts, :goals], 2)

    changed_binding =
      update_in(base.provenance.bindings, fn bindings ->
        Enum.map(bindings, fn binding ->
          if binding.kind == :player,
            do: %{binding | source_id: "different-player"},
            else: binding
        end)
      end)

    original_digest = Canonical.encode(base).digest

    for changed <- [changed_kickoff, changed_position, changed_count, changed_binding] do
      assert Canonical.encode(changed).digest != original_digest
    end
  end
end
