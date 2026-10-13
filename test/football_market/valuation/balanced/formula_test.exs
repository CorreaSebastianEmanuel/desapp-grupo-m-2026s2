defmodule FootballMarket.Valuation.Balanced.FormulaTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Catalog}
  alias FootballMarket.Valuation.{Balanced, Definition, Request}

  defp definition(weights),
    do: %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: weights}
    }

  defp calculate(f, refs, weights) do
    req = request(f, %{requirements: %{overall: Map.keys(weights)}, references: refs})
    assert {:ok, prepared} = Valuation.prepare(req)
    assert {:ok, result} = Valuation.evaluate(req, definition(weights))
    assert {:ok, ^result} = Valuation.score(prepared, definition(weights))
    assert {:ok, ^result} = Valuation.replay(result.descriptor, definition(weights))
    result
  end

  test "every metric is explicit, including penalties; zero and scores above one" do
    f = fixture()
    record(f, "all", Map.new(Request.metrics(), &{&1, 1}))

    for metric <- Request.metrics() do
      assert calculate(f, %{metric => 2}, %{metric => 2}).score == "1.000000"
    end

    assert calculate(f, %{red_cards: 2}, %{red_cards: -2}).score == "-1.000000"
    assert calculate(f, %{goals: 1, assists: 1}, %{goals: 2, assists: 2}).score == "4.000000"
    assert calculate(f, %{goals: 1}, %{goals: 0}).score == "0.000000"
    record(f, "zero", %{goals: 0, player_id: List.last(f.players).id, team_id: f.away.id})

    assert {:ok, zero} =
             Valuation.evaluate(
               request(f, %{player_id: List.last(f.players).id}),
               definition(%{goals: 2})
             )

    assert zero.score == "0.000000"
  end

  test "main example retains exact totals, references, rounded features and weights" do
    f = fixture()
    record(f, "main", %{goals: 3, assists: 1, goals_conceded: 2})

    r =
      calculate(f, %{goals: 4, assists: 2, goals_conceded: 4}, %{
        goals: 2,
        assists: 1,
        goals_conceded: -1
      })

    assert r.score == "1.500000"
    assert r.prepared.scopes.overall.totals == %{goals: 3, assists: 1, goals_conceded: 2}

    assert r.prepared.scopes.overall.features == %{
             goals: "0.750000",
             assists: "0.500000",
             goals_conceded: "0.500000"
           }

    assert r.descriptor.strategy.strategy_id == "balanced"
  end

  test "roles, minutes and current affiliations affect evidence, not overall formula" do
    f = fixture()
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    record(f, "defender", %{goals: 2, minutes_played: 0})
    record(f, "forward", %{goals: 2, minutes_played: 0, position_id: position.id})

    req =
      request(f, %{
        references: %{goals: 2},
        position_mapping: [{f.position.id, :defender}, {position.id, :forward}]
      })

    d = definition(%{goals: 2})
    assert {:ok, a} = Valuation.evaluate(req, d)
    assert a.score == "2.000000"
    assert a.prepared.scopes.overall.features.goals == "1.000000"

    {:ok, _} =
      Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: position.id})

    assert {:ok, ^a} = Valuation.evaluate(req, d)

    record(f, "other-history", %{
      goals: 4,
      minutes_played: 123,
      player_id: List.last(f.players).id,
      team_id: f.away.id
    })

    assert {:ok, b} =
             Valuation.evaluate(
               %{
                 req
                 | player_id: List.last(f.players).id,
                   position_mapping: [{f.position.id, :goalkeeper}]
               },
               d
             )

    assert b.score == a.score
    refute b.descriptor == a.descriptor
  end
end
