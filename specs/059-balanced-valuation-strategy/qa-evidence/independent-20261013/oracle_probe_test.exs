defmodule BalancedIndependentQAOracle do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Balanced, Definition, Request}

  defp numeric([sign, coef, exp]), do: %Decimal{sign: sign, coef: coef, exp: exp}
  defp numbers(map), do: Map.new(map, fn {key, value} -> {String.to_existing_atom(key), numeric(value)} end)

  test "all 511 nonempty metric subsets agree with independent rational expectations and original replay" do
    vectors = File.read!(Path.join(__DIR__, "oracle-vectors.json")) |> Jason.decode!()
    assert length(vectors) == 511
    f = fixture()
    record(f, "qa-oracle", Map.new(Enum.with_index(Request.metrics(), 1)) |> Map.put(:minutes_played, 0))
    original = Decimal.Context.get()
    on_exit(fn -> Decimal.Context.set(original) end)
    results = for {v, index} <- Enum.with_index(vectors) do
      Decimal.Context.set(%{original | precision: 1 + rem(index, 7), rounding: :down})
      weights = numbers(v["weights"])
      d = %Definition{module: Balanced, strategy_id: "balanced", version: "1", config: %{weights: weights}}
      req = request(f, %{requirements: %{overall: Map.keys(weights)}, references: numbers(v["references"])})
      assert {:ok, result} = Valuation.evaluate(req, d)
      assert result.score == v["score"], "subset #{index + 1} score disagrees with Python Fraction"
      features = Map.new(v["features"], fn {k, value} -> {String.to_existing_atom(k), value} end)
      assert result.prepared.scopes.overall.features == features
      assert {:ok, p} = Valuation.prepare(req)
      assert {:ok, ^result} = Valuation.score(p, d)
      {result, d}
    end
    record(f, "qa-late", Map.new(Request.metrics(), &{&1, 99}))
    for {result, d} <- results do
      assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
    end
    IO.puts("QA_ORACLE subsets=511 evaluate=511 authenticated_score=511 original_replay=511 status=complete")
  end
end
