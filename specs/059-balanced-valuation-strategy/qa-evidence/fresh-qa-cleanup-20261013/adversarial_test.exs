defmodule BalancedFreshQAAdversarialTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Balanced, Definition, Request}

  defp definition(weights),
    do: %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: weights}
    }

  test "all nine configured zero weights require complete data and yield canonical zero" do
    f = fixture()
    record(f, "all-zero-rules", Map.new(Request.metrics(), &{&1, 7}))
    refs = Map.new(Request.metrics(), &{&1, 3})
    req = request(f, %{requirements: %{overall: Request.metrics()}, references: refs})

    for zero <- [0, %Decimal{sign: -1, coef: 0, exp: -17}] do
      d = definition(Map.new(Request.metrics(), &{&1, zero}))
      assert {:ok, result} = Valuation.evaluate(req, d)
      assert result.score == "0.000000"
      assert {:ok, prepared} = Valuation.prepare(req)
      assert {:ok, ^result} = Valuation.score(prepared, d)
      assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
    end
  end

  test "missing each of nine zero-weight metrics blocks the entire score without row exclusion" do
    for {metric, index} <- Enum.with_index(Request.metrics()) do
      f = fixture("PL", 2030 + index)
      values = Map.new(Request.metrics(), &{&1, 0}) |> Map.put(metric, nil)
      {_, row} = record(f, "missing-zero-#{metric}", Map.put(values, :minutes_played, 0))
      d = definition(Map.new(Request.metrics(), &{&1, 0}))

      req =
        request(f, %{
          requirements: %{overall: Request.metrics()},
          references: Map.new(Request.metrics(), &{&1, 1})
        })

      assert {:error, error} = Valuation.evaluate(req, d)
      assert error.kind == :insufficient_data
      assert error.details == [%{scope: :overall, metric: metric, performance_id: row.id}]
      refute Map.has_key?(error, :score)
    end
  end

  test "microsecond closing boundary and malformed week lengths remain exact" do
    f = fixture()
    record(f, "last-microsecond", %{goals: 1}, "2026-10-11T23:59:59.999999Z")
    record(f, "closing-instant", %{goals: 999}, "2026-10-12T00:00:00.000000Z")
    d = definition(%{goals: 2})
    assert {:ok, result} = Valuation.evaluate(request(f, %{references: %{goals: 2}}), d)
    assert result.score == "1.000000"
    assert length(result.prepared.facts) == 1

    for change <- [
          %{week_start: "2026-10-06T00:00:00Z", week_end: "2026-10-13T00:00:00Z"},
          %{week_end: "2026-10-12T00:00:00.000001Z"},
          %{week_start: "2026-10-05T00:00:00.000001Z"}
        ] do
      assert {:error, %{kind: :validation, reason: :invalid_week}} =
               Valuation.evaluate(request(f, change), d)
    end
  end
end
