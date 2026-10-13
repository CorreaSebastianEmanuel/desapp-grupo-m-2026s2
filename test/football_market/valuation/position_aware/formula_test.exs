defmodule FootballMarket.Valuation.PositionAware.FormulaTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase, only: [fixture: 0, record: 3]
  import FootballMarket.PositionAwareCase
  alias FootballMarket.{Catalog, Valuation}
  alias FootballMarket.Valuation.Request

  test "US1.1 all four historical groups have explicitly different goal weights" do
    f = fixture()
    record(f, "one-goal", %{goals: 1})

    d =
      definition(%{
        goalkeeper: %{goals: 1},
        defender: %{goals: 2},
        midfielder: %{goals: 3},
        forward: %{goals: 4}
      })

    for {g, expected} <- [
          goalkeeper: "0.500000",
          defender: "1.000000",
          midfielder: "1.500000",
          forward: "2.000000"
        ] do
      r = calculate(f, d, %{goals: 2}, %{position_mapping: [{f.position.id, g}]})
      assert r.score == expected
      assert Map.keys(Map.delete(r.prepared.scopes, :overall)) == [g]
      assert r.prepared.scopes.overall.features == %{}
      assert r.prepared.scopes[g].features.goals == "0.500000"
      assert r.descriptor.strategy.strategy_id == "position_aware"
      assert r.descriptor.strategy.version == "1"
      assert map_size(r.descriptor.strategy.requirements) == 4
    end
  end

  test "US1.2 goalkeeper saves and explicit signed conceded weights" do
    f = fixture()
    record(f, "keeper", %{saves: 3, goals_conceded: 2})

    r =
      calculate(
        f,
        definition(rules(%{saves: 2, goals_conceded: -1})),
        %{saves: 4, goals_conceded: 4},
        %{position_mapping: [{f.position.id, :goalkeeper}]}
      )

    assert r.score == "1.000000"

    assert r.prepared.scopes.goalkeeper.features == %{
             saves: "0.750000",
             goals_conceded: "0.500000"
           }
  end

  test "US1.3 center-back and fullback historical IDs ignore current affiliation" do
    f = fixture()

    {:ok, center_back} =
      Catalog.create_position(
        FootballMarket.CatalogCase.position_attrs(%{code: "CB", name: "Center-back"})
      )

    {:ok, fullback} =
      Catalog.create_position(
        FootballMarket.CatalogCase.position_attrs(%{code: "FB", name: "Fullback"})
      )

    record(f, "center-back", %{tackles: 1, position_id: center_back.id})
    record(f, "fullback", %{tackles: 2, position_id: fullback.id})
    d = definition(rules(%{tackles: 2}))
    overrides = %{position_mapping: [{center_back.id, :defender}, {fullback.id, :defender}]}
    r = calculate(f, d, %{tackles: 4}, overrides)
    assert r.score == "1.500000"
    assert r.prepared.scopes.defender.totals.tackles == 3
    assert r.prepared.scopes.defender.features.tackles == "0.750000"

    {:ok, _} =
      Catalog.update_player(hd(f.players), %{team_id: f.away.id, position_id: fullback.id})

    assert {:ok, ^r} = Valuation.evaluate(position_request(f, d, %{tackles: 4}, overrides), d)
  end

  test "US1.4 minutes zero, normal and extra-time leave the formula identical" do
    f = fixture()
    d = definition(rules(%{goals: 2}))

    results =
      for {minutes, week} <- [
            {0, {"2026-10-05", "2026-10-12"}},
            {90, {"2026-10-12", "2026-10-19"}},
            {123, {"2026-10-19", "2026-10-26"}}
          ] do
        {a, b} = week

        FootballMarket.ValuationCase.record(
          f,
          "minutes-#{minutes}",
          %{goals: 1, minutes_played: minutes},
          a <> "T12:00:00Z"
        )

        calculate(f, d, %{goals: 2}, %{week_start: a <> "T00:00:00Z", week_end: b <> "T00:00:00Z"})
      end

    assert Enum.map(results, & &1.score) == List.duplicate("1.000000", 3)

    assert Enum.map(results, & &1.prepared.scopes.defender.features) |> Enum.uniq() == [
             %{goals: "0.500000"}
           ]

    assert Enum.map(results, & &1.prepared.scopes.defender.total_minutes) == [0, 90, 123]
  end

  test "US1.5 all 36 group metric pairs have no implied restriction or sign" do
    f = fixture()
    record(f, "all-metrics", Map.new(Request.metrics(), &{&1, 1}))

    for g <- groups(), metric <- Request.metrics() do
      r =
        calculate(f, definition(rules(%{metric => 2})), %{metric => 2}, %{
          position_mapping: [{f.position.id, g}]
        })

      assert r.score == "1.000000"
      assert r.prepared.scopes[g].features == %{metric => "0.500000"}
    end
  end

  test "baseline rounded features and two-group tiny products precede the scorer" do
    f = fixture()
    p = position()
    record(f, "defender", %{goals: 1})
    record(f, "forward", %{goals: 1, position_id: p.id})
    map = %{position_mapping: [{f.position.id, :defender}, {p.id, :forward}]}
    assert calculate(f, definition(rules(%{goals: 3})), %{goals: 6}, map).score == "1.000002"

    assert calculate(f, definition(rules(%{goals: Decimal.new("0.000001")})), %{goals: 2}, map).score ==
             "0.000001"
  end
end
