defmodule FootballMarket.Valuation.PositionAware.OutcomesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase, only: [fixture: 0, record: 3]
  import FootballMarket.PositionAwareCase
  alias FootballMarket.Valuation

  defp request(f, overrides \\ %{}) do
    position_request(f, definition(rules(%{goals: 2})), %{goals: 4}, overrides)
  end

  test "omitted unknown metrics succeed, zero weights still require every selected row" do
    f = fixture()
    record(f, "known", %{goals: 1, saves: 0})
    {_, missing} = record(f, "missing", %{goals: 1, saves: nil, minutes_played: 0})
    assert {:ok, result} = Valuation.evaluate(request(f), definition(rules(%{goals: 2})))
    assert result.score == "1.000000"
    assert Enum.any?(result.prepared.facts, &is_nil(&1.metrics.saves))

    for weight <- [0, 2] do
      req =
        request(f, %{
          requirements: Map.new(groups(), &{&1, [:goals, :saves]}),
          references: %{goals: 4, saves: 2}
        })

      assert {:error, error} =
               Valuation.evaluate(req, definition(rules(%{goals: 2, saves: weight})))

      assert error.kind == :insufficient_data
      assert error.message == "datos insuficientes"
      assert error.details == [%{scope: :defender, metric: :saves, performance_id: missing.id}]
      refute Map.has_key?(error, :score)
    end

    assert {:ok, zero} = Valuation.evaluate(request(f), definition(rules(%{goals: 0})))
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

    for config <- configs ++ Enum.map(values, &%{weights: rules(%{goals: &1})}) do
      d = %{definition(rules(%{goals: 2})) | config: config}
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
          %{requirements: %{overall: [:goals]}},
          %{requirements: %{overall: [:goals, :goals]}},
          %{requirements: %{overall: [:goals | :tail]}},
          %{requirements: %{overall: [[:goals | :tail]]}},
          %{references: %{}},
          %{references: [goals: 2, goals: 4]},
          %{references: %{goals: 4, saves: 2}},
          %{position_mapping: [{f.position.id, :defender} | :tail]},
          %{position_mapping: [[{f.position.id, :defender} | :tail]]},
          %{position_mapping: [{f.position.id, [:defender | :tail]}]}
        ] do
      req = request(f, change)

      assert {:error, %{kind: :validation}} =
               Valuation.evaluate(req, definition(rules(%{goals: 2})))

      case Valuation.prepare(req) do
        {:ok, p} ->
          assert {:error, %{kind: :validation, reason: :definition_requirements_mismatch}} =
                   Valuation.score(p, definition(rules(%{goals: 2})))

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
               Valuation.evaluate(
                 request(f, %{references: %{goals: reference}}),
                 definition(rules(%{goals: 2}))
               )
    end
  end

  test "empty, unknown, malformed week and unmapped historical role remain distinct" do
    f = fixture()

    assert {:error, %{kind: :no_recorded_performances, message: "sin actuaciones registradas"}} =
             Valuation.evaluate(request(f), definition(rules(%{goals: 2})))

    assert {:error, %{kind: :not_found}} =
             Valuation.evaluate(
               request(f, %{player_id: Ecto.UUID.generate()}),
               definition(rules(%{goals: 2}))
             )

    assert {:error, %{kind: :validation}} =
             Valuation.evaluate(
               request(f, %{week_start: "invalid"}),
               definition(rules(%{goals: 2}))
             )

    record(f, "zero-minute", %{goals: 1, minutes_played: 0})

    assert {:error, %{kind: :validation}} =
             Valuation.evaluate(
               request(f, %{position_mapping: []}),
               definition(rules(%{goals: 2}))
             )

    assert {:ok, r} = Valuation.evaluate(request(f), definition(rules(%{goals: 2})))
    assert r.score == "0.500000"
  end

  test "US3.1 role-specific nil metrics have no overall completeness requirement" do
    f = fixture()
    keeper = position()
    record(f, "keeper", %{saves: 1, tackles: nil, position_id: keeper.id})
    record(f, "defender", %{tackles: 1, saves: nil})

    d =
      definition(%{
        goalkeeper: %{saves: 2},
        defender: %{tackles: 2},
        midfielder: %{saves: 0},
        forward: %{tackles: 0}
      })

    r =
      calculate(f, d, %{saves: 2, tackles: 2}, %{
        position_mapping: [{f.position.id, :defender}, {keeper.id, :goalkeeper}]
      })

    assert r.score == "2.000000"
    assert r.prepared.scopes.overall.features == %{}
    refute Map.has_key?(r.prepared.request.requirements, :overall)
    assert r.prepared.scopes.goalkeeper.totals == %{saves: 1}
    assert r.prepared.scopes.defender.totals == %{tackles: 1}
    assert Enum.any?(r.prepared.facts, &is_nil(&1.metrics.saves))
    assert Enum.any?(r.prepared.facts, &is_nil(&1.metrics.tackles))
  end

  test "US3.2 ordered group metric row details and no partial score including zero weights" do
    f = fixture()
    keeper = position()
    {_, a} = record(f, "a", %{saves: nil, goals: nil, minutes_played: 0, position_id: keeper.id})
    {_, b} = record(f, "b", %{saves: nil, goals: nil, minutes_played: 0, position_id: keeper.id})
    {_, c} = record(f, "c", %{tackles: nil})

    d =
      definition(%{
        goalkeeper: %{saves: 0, goals: 0},
        defender: %{tackles: 1},
        midfielder: %{goals: 0},
        forward: %{goals: 0}
      })

    req =
      position_request(f, d, %{saves: 2, tackles: 2, goals: 2}, %{
        position_mapping: [{f.position.id, :defender}, {keeper.id, :goalkeeper}]
      })

    assert {:error, e} = Valuation.evaluate(req, d)
    assert e.kind == :insufficient_data

    assert e.details == [
             %{scope: :goalkeeper, metric: :goals, performance_id: a.id},
             %{scope: :goalkeeper, metric: :goals, performance_id: b.id},
             %{scope: :goalkeeper, metric: :saves, performance_id: a.id},
             %{scope: :goalkeeper, metric: :saves, performance_id: b.id},
             %{scope: :defender, metric: :tackles, performance_id: c.id}
           ]

    refute Map.has_key?(e, :score)
  end

  test "US3.3 removing zero-weight entry affects only its group; absent references remain required" do
    f = fixture()
    record(f, "unknown-saves", %{goals: 1, saves: nil})

    weights =
      rules(%{goals: 2})
      |> Map.put(:defender, %{goals: 2, saves: 0})
      |> Map.put(:goalkeeper, %{saves: 0})

    d = definition(weights)

    assert {:error, %{kind: :insufficient_data}} =
             Valuation.evaluate(position_request(f, d, %{goals: 2, saves: 2}), d)

    removed = definition(put_in(weights, [:defender], %{goals: 2}))
    r = calculate(f, removed, %{goals: 2, saves: 2})
    assert r.score == "1.000000"
    assert r.prepared.request.requirements.goalkeeper == [:saves]
    assert r.prepared.request.requirements.defender == [:goals]

    assert {:error, %{kind: :validation, reason: :invalid_references}} =
             Valuation.evaluate(position_request(f, removed, %{goals: 2}), removed)
  end

  test "US3.4 known zero and nonempty all-zero rules differ from empty history" do
    f = fixture()
    record(f, "zero", %{goals: 0, minutes_played: 0})

    for weights <- [rules(%{goals: 0}), rules(%{goals: 2})] do
      r = calculate(f, definition(weights), %{goals: 2})
      assert r.score == "0.000000"
      assert r.prepared.scopes.defender.features.goals == "0.000000"
    end

    assert {:error, %{kind: :no_recorded_performances}} =
             Valuation.evaluate(
               request(f, %{player_id: List.last(f.players).id}),
               definition(rules(%{goals: 0}))
             )
  end

  test "US3.6 every group requirement set and shared reference union must exactly match" do
    f = fixture()
    record(f, "valid", %{goals: 1, saves: 0})
    d = definition(rules(%{goals: 2}))

    for g <- groups(),
        metrics <- [[:saves], [:goals, :saves], [:goals, :goals], [:goals | :tail], []] do
      requirements = Map.put(Map.new(groups(), &{&1, [:goals]}), g, metrics)

      req =
        request(f, %{
          requirements: requirements,
          references:
            if(metrics in [[:saves], [:goals, :saves]],
              do: %{goals: 4, saves: 2},
              else: %{goals: 4}
            )
        })

      assert {:error, %{kind: :validation}} = Valuation.evaluate(req, d)
    end

    for pairs <- [
          [{f.position.id, :defender}, {f.position.id, :defender}],
          [{f.position.id, :defender}, {f.position.id, :forward}]
        ] do
      assert {:error, %{kind: :validation, reason: :invalid_mapping}} =
               Valuation.evaluate(request(f, %{position_mapping: pairs}), d)
    end
  end
end
