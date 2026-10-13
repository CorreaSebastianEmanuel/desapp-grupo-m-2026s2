defmodule FootballMarket.Valuation.MatrixTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.{Valuation, Catalog, StatisticsCase}
  alias FootballMarket.Valuation.{Request, Definition}

  test "five leagues, two seasons, four historical groups and every counting metric" do
    for {league, _} <- Catalog.supported_leagues(), year <- [2025, 2026] do
      f = fixture(league, year)

      positions =
        for group <- [:goalkeeper, :midfielder, :forward],
            into: %{defender: f.position},
            do:
              {group,
               elem(Catalog.create_position(FootballMarket.CatalogCase.position_attrs()), 1)}

      mapping = Enum.map(positions, fn {group, p} -> {p.id, group} end)

      rows =
        for {group, position} <- positions do
          {_, row} =
            record(
              f,
              "matrix-#{group}",
              Map.merge(Map.new(StatisticsCase.metrics(), &{&1, 2}), %{
                position_id: position.id,
                minutes_played: if(group == :defender, do: 0, else: 123)
              })
            )

          row
        end

      {_, opening} =
        record(
          f,
          "opening",
          Map.merge(Map.new(Request.metrics(), &{&1, 0}), %{minutes_played: 0}),
          "2026-10-05T00:00:00Z"
        )

      record(f, "closing", Map.new(Request.metrics(), &{&1, 99}), "2026-10-12T00:00:00Z")
      references = Map.new(Request.metrics(), &{&1, 4})
      requirements = Map.new(Request.scopes(), &{&1, Request.metrics()})

      req =
        request(f, %{
          requirements: requirements,
          references: references,
          position_mapping: mapping
        })

      assert {:ok, p} = Valuation.prepare(req)

      assert MapSet.new(Enum.map(p.facts, & &1.performance_id)) ==
               MapSet.new([opening.id | Enum.map(rows, & &1.id)])

      assert p.scopes.overall.row_count == 5
      assert p.scopes.overall.total_minutes == 369

      for metric <- Request.metrics() do
        assert p.scopes.overall.totals[metric] == 8
        assert p.scopes.overall.features[metric] == "1.000000"

        for group <- tl(Request.scopes()) do
          assert p.scopes[group].totals[metric] == 2
          assert p.scopes[group].features[metric] == "0.500000"
        end
      end

      weights = Map.new(Request.scopes(), &{&1, Map.new(Request.metrics(), fn m -> {m, 1} end)})

      d = %Definition{
        module: FootballMarket.ValuationScorers.Weighted,
        strategy_id: "illustrative",
        version: "1",
        config: %{weights: weights, policy: :require_all}
      }

      assert {:ok, result} = Valuation.evaluate(req, d)
      assert result.score == "27.000000"
      assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
      general = %{req | requirements: %{overall: Request.metrics()}}
      gd = %{d | config: %{weights: %{overall: weights.overall}, policy: :require_all}}
      assert {:ok, g} = Valuation.evaluate(general, gd)
      assert g.score == "9.000000"
      assert {:ok, ^g} = Valuation.replay(g.descriptor, gd)
      assert g.prepared.facts == result.prepared.facts
    end
  end

  test "each counting metric's unknowns are independently rejected in real local histories" do
    f = fixture()
    record(f, "unknown", %{minutes_played: 0})

    for metric <- Request.metrics() do
      assert {:error, %{kind: :insufficient_data, details: [%{metric: ^metric, scope: :overall}]}} =
               Valuation.prepare(
                 request(f, %{requirements: %{overall: [metric]}, references: %{metric => 4}})
               )
    end
  end

  test "large accepted counts and context independence survive authoritative loading" do
    f = fixture()
    large = Integer.pow(10, 60) + 123
    record(f, "large", %{goals: large, minutes_played: large})

    Decimal.Context.with(%Decimal.Context{precision: 2}, fn ->
      assert {:ok, p} = Valuation.prepare(request(f))
      assert p.scopes.overall.totals.goals == large
      assert p.scopes.overall.total_minutes == large
      assert p.scopes.overall.features.goals == "1.000000"
    end)
  end
end
