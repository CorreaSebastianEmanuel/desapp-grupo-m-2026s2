defmodule FootballMarket.Valuation.Balanced.OutcomesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Balanced, Definition}

  defp definition(weights \\ %{goals: 2}),
    do: %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: weights}
    }

  test "omitted unknown metrics succeed, zero weights still require every selected row" do
    f = fixture()
    record(f, "known", %{goals: 1, saves: 0})
    {_, missing} = record(f, "missing", %{goals: 1, saves: nil, minutes_played: 0})
    assert {:ok, result} = Valuation.evaluate(request(f), definition())
    assert result.score == "1.000000"
    assert Enum.any?(result.prepared.facts, &is_nil(&1.metrics.saves))

    for weight <- [0, 2] do
      req =
        request(f, %{
          requirements: %{overall: [:goals, :saves]},
          references: %{goals: 4, saves: 2}
        })

      assert {:error, error} = Valuation.evaluate(req, definition(%{goals: 2, saves: weight}))
      assert error.kind == :insufficient_data
      assert error.message == "datos insuficientes"
      assert error.details == [%{scope: :overall, metric: :saves, performance_id: missing.id}]
      refute Map.has_key?(error, :score)
    end

    assert {:ok, zero} = Valuation.evaluate(request(f), definition(%{goals: 0}))
    assert zero.score == "0.000000"
  end

  test "invalid config fails through evaluate and authenticated score even in an empty week" do
    f = fixture()
    empty = request(f)
    record(f, "valid", %{goals: 1})
    assert {:ok, p} = Valuation.prepare(empty)
    req = %{empty | player_id: List.last(f.players).id}
    decimal = Decimal.new(1)

    configs = [
      %{},
      %{weights: %{}},
      %{weights: [{:goals, 1} | :tail]},
      %{weights: %{goals: [1 | :tail]}},
      %{weights: %{goals: 1}, extra: %{nested: [[1 | :tail]]}},
      %{weights: %{minutes: 1}},
      %{weights: %{"unknown" => 1}},
      %{weights: decimal},
      %{weights: %{goals: %{forward: 1}}}
    ]

    values = [
      nil,
      true,
      false,
      "1",
      1.0,
      Decimal.new("NaN"),
      Decimal.new("Infinity"),
      %{decimal | sign: 0},
      %{decimal | coef: -1},
      %{decimal | exp: nil},
      Map.put(decimal, :extra, 1),
      Map.delete(decimal, :coef)
    ]

    for config <- configs ++ Enum.map(values, &%{weights: %{goals: &1}}) do
      d = %{definition() | config: config}
      assert {:error, %{kind: :validation}} = Valuation.evaluate(req, d)
      assert {:error, %{kind: :validation}} = Valuation.score(p, d)
    end
  end

  test "requirements and references must exactly match the explicit definition" do
    f = fixture()
    record(f, "valid", %{goals: 1, assists: 1})

    for change <- [
          %{requirements: %{overall: [:assists]}, references: %{assists: 2}},
          %{requirements: %{overall: [:goals, :assists]}, references: %{goals: 4, assists: 2}},
          %{requirements: %{defender: [:goals]}},
          %{requirements: %{overall: [:goals, :goals]}},
          %{requirements: %{overall: [:goals | :tail]}},
          %{requirements: %{overall: [[:goals | :tail]]}},
          %{references: %{}},
          %{references: %{goals: 4, saves: 2}},
          %{position_mapping: [{f.position.id, :defender} | :tail]},
          %{position_mapping: [[{f.position.id, :defender} | :tail]]},
          %{position_mapping: [{f.position.id, [:defender | :tail]}]}
        ] do
      req = request(f, change)
      assert {:error, %{kind: :validation}} = Valuation.evaluate(req, definition())

      case Valuation.prepare(req) do
        {:ok, p} ->
          assert {:error, %{kind: :validation, reason: :definition_requirements_mismatch}} =
                   Valuation.score(p, definition())

        {:error, %{kind: :validation}} ->
          :ok
      end
    end

    for reference <- [
          0,
          -1,
          true,
          "2",
          2.0,
          Decimal.new("NaN"),
          Decimal.new("Infinity"),
          Map.delete(Decimal.new(2), :exp)
        ] do
      assert {:error, %{kind: :validation, reason: :invalid_references}} =
               Valuation.evaluate(request(f, %{references: %{goals: reference}}), definition())
    end
  end

  test "empty, unknown, malformed week and unmapped historical role remain distinct" do
    f = fixture()

    assert {:error, %{kind: :no_recorded_performances, message: "sin actuaciones registradas"}} =
             Valuation.evaluate(request(f), definition())

    assert {:error, %{kind: :not_found}} =
             Valuation.evaluate(request(f, %{player_id: Ecto.UUID.generate()}), definition())

    assert {:error, %{kind: :validation}} =
             Valuation.evaluate(request(f, %{week_start: "invalid"}), definition())

    record(f, "zero-minute", %{goals: 1, minutes_played: 0})

    assert {:error, %{kind: :validation}} =
             Valuation.evaluate(request(f, %{position_mapping: []}), definition())

    assert {:ok, r} = Valuation.evaluate(request(f), definition())
    assert r.score == "0.500000"
  end

  test "weekly half-open selection, offsets, player and season isolation" do
    f = fixture()
    record(f, "before", %{goals: 99}, "2026-10-04T23:59:59Z")
    {_, opening} = record(f, "opening", %{goals: 1}, "2026-10-05T00:00:00Z")
    {_, ending} = record(f, "ending", %{goals: 1}, "2026-10-11T23:59:59Z")
    record(f, "closed", %{goals: 99}, "2026-10-12T00:00:00Z")

    record(f, "other-player", %{goals: 99, player_id: List.last(f.players).id, team_id: f.away.id})

    other = fixture("PD", 2024)
    record(other, "other-season", %{goals: 99})
    assert {:ok, a} = Valuation.evaluate(request(f), definition())
    assert a.score == "1.000000"
    assert a.prepared.scopes.overall.membership == [opening.id, ending.id]

    assert {:ok, ^a} =
             Valuation.evaluate(
               request(f, %{
                 week_start: "2026-10-05T02:00:00+02:00",
                 week_end: "2026-10-12T02:00:00+02:00"
               }),
               definition()
             )

    assert {:error, %{kind: :validation, reason: :season_mismatch}} =
             Valuation.evaluate(request(f, %{season_id: other.season.id}), definition())
  end
end
