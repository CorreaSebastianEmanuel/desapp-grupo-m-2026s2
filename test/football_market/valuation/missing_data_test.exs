defmodule FootballMarket.Valuation.MissingDataTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation.{Request, Preparation}

  test "all nine metrics: known zeros, unknown required/unrequired and zero-minute counts" do
    for metric <- Request.metrics() do
      {:ok, r} =
        Request.validate(
          pure_request(%{requirements: %{overall: [metric]}, references: %{metric => 4}})
        )

      assert {:ok, p} = Preparation.build(r, [fact(1, %{minutes: 0})])
      assert p.scopes.overall.features[metric] == "0.000000"

      assert {:error,
              %{
                kind: :insufficient_data,
                details: [%{scope: :overall, metric: ^metric, performance_id: id}]
              }} =
               Preparation.build(r, [
                 fact(1, %{minutes: 0, metrics: Map.put(fact(1).metrics, metric, nil)})
               ])

      assert id == fact(1).performance_id
    end

    {:ok, r} = Request.validate(pure_request())

    for minutes <- [0, 123] do
      rows = [
        fact(1, %{minutes: 0, metrics: %{fact(1).metrics | goals: 2, assists: nil}}),
        fact(2, %{minutes: minutes, metrics: %{fact(2).metrics | goals: 1}})
      ]

      assert {:ok, p} = Preparation.build(r, rows)
      assert p.scopes.overall.features.goals == "0.750000"
      assert hd(p.facts).metrics.assists == nil
      assert p.scopes.overall.row_count == 2
    end
  end

  test "complete missing details follow fixed scope, metric and canonical row order" do
    {:ok, r} =
      Request.validate(
        pure_request(%{
          requirements: %{overall: [:goals, :assists], defender: [:goals]},
          references: %{goals: 4, assists: 4}
        })
      )

    rows = for n <- [2, 1], do: fact(n, %{metrics: %{fact(n).metrics | goals: nil, assists: nil}})
    assert {:error, e} = Preparation.build(r, rows)
    assert e.reason == :missing_required_metric

    assert Enum.map(e.details, &{&1.scope, &1.metric, &1.performance_id}) ==
             for(
               {s, m} <- [{:overall, :goals}, {:overall, :assists}, {:defender, :goals}],
               n <- [1, 2],
               do: {s, m, fact(n).performance_id}
             )
  end
end
