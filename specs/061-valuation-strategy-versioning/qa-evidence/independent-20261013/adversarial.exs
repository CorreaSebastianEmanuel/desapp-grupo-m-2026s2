defmodule Task025IndependentQA do
  use FootballMarket.DataCase, async: false
  alias FootballMarket.{Valuation, ValuationCase}
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.{Rules, Codec}
  @groups [:goalkeeper, :defender, :midfielder, :forward]

  defp rules(position, strategy, weights, references) do
    %{strategy_id: strategy, formula_version: "1", config: %{weights: weights}, references: references, position_mapping: [{position, :defender}]}
  end

  defp subject(f), do: Map.take(ValuationCase.request(f), [:player_id, :season_id, :week_start, :week_end])
  defp format_score(value) do
    sign = if value < 0, do: "-", else: ""
    n = abs(value)
    sign <> Integer.to_string(div(n, 1_000_000)) <> "." <> String.pad_leading(Integer.to_string(rem(n, 1_000_000)), 6, "0")
  end

  test "independent integer oracle covers signed/all-zero saved rules, caps, fractional features, both formulas and every allowed group" do
    count = for strategy <- ["balanced", "position_aware"], goals <- [0, 1, 2, 4, 7], weight <- [-3, 0, 7], ref <- [2, 3] do
      f = ValuationCase.fixture()
      ValuationCase.record(f, "qa-oracle", %{goals: goals})
      w = if strategy == "balanced", do: %{goals: weight}, else: Map.new(@groups, &{&1, %{goals: weight}})
      assert {:ok, v} = Configurations.create(rules(f.position.id, strategy, w, %{goals: ref}))
      assert {:ok, result} = Valuation.evaluate_managed(subject(f), {:version, v.id})
      # Integer half-up normalization; no production arithmetic/scoring helper is used.
      feature = min(1_000_000, div(2 * goals * 1_000_000 + ref, 2 * ref))
      assert result.score == format_score(feature * weight)
      assert result.configuration_version_id == v.id
      assert {:ok, ^result} = Valuation.replay_managed(result.descriptor)
      1
    end
    assert Enum.sum(count) == 90
    IO.puts("QA_INTEGER_ORACLE vectors=90 formulas=2 PASS")
    f = ValuationCase.fixture()
    ValuationCase.record(f, "qa-roles", %{goals: 1})
    for group <- @groups do
      w = Map.new(@groups, &{&1, %{goals: 2}})
      r = %{rules(f.position.id, "position_aware", w, %{goals: 2}) | position_mapping: [{f.position.id, group}]}
      assert {:ok, v} = Configurations.create(r)
      assert {:ok, %{score: "1.000000"}} = Valuation.evaluate_managed(subject(f), {:version, v.id})
    end
    IO.puts("QA_ALL_HISTORICAL_GROUPS groups=4 PASS")
  end

  test "all nine metrics accept zero requirements; malformed structures and references leave state unchanged" do
    f = ValuationCase.fixture()
    metrics = [:goals, :assists, :shots_on_target, :tackles, :interceptions, :saves, :goals_conceded, :yellow_cards, :red_cards]
    refs = Map.new(metrics, &{&1, Decimal.new("0.125")})
    zero = Map.new(metrics, &{&1, 0})
    for strategy <- ["balanced", "position_aware"] do
      weights = if strategy == "balanced", do: zero, else: Map.new(@groups, &{&1, zero})
      assert {:ok, v} = Configurations.create(rules(f.position.id, strategy, weights, refs))
      assert Enum.all?(v.requirements, fn {_, required} -> Enum.sort(required) == Enum.sort(metrics) end)
      assert {:ok, %{version: ^v}} = Configurations.get(v.id)
    end
    good = rules(f.position.id, "balanced", %{goals: 2}, %{goals: 2})
    invalid = [
      %{good | config: %{weights: [goals: 2, goals: 3]}},
      %{good | config: %{weights: %{goals: 2}, extra: true}},
      %{good | references: [goals: 2, goals: 2]},
      %{good | position_mapping: [{f.position.id, :defender}, {f.position.id, :defender}]},
      %{good | position_mapping: [{f.position.id, :overall}]},
      %{good | references: %{goals: Decimal.new("-0.0")}},
      %{good | references: %{goals: false}},
      %{good | config: %{weights: %{goals: %Decimal{sign: 1, coef: -1, exp: 0}}}},
      Map.put(good, "strategy_id", "balanced")
    ]
    assert {:ok, before} = Configurations.list()
    for input <- invalid do
      assert {:error, %{kind: :validation}} = Configurations.create(input)
      assert {:ok, ^before} = Configurations.list()
      assert {:ok, []} = Configurations.history()
    end
    assert {:ok, valid} = Rules.validate(good)
    encoded = Codec.encode(valid)
    corrupt = [
      put_in(encoded, ["config", "weights"], [["goals", %{"type" => "integer", "value" => "02"}]]),
      put_in(encoded, ["references"], [["goals", %{"type" => "decimal", "sign" => "1", "coefficient" => "1", "exponent" => "0", "extra" => "bad"}]]),
      put_in(encoded, ["requirements"], [["overall", ["goals", "goals"]]]),
      put_in(encoded, ["position_mapping"], [[f.position.id, "defender"], [f.position.id, "forward"]])
    ]
    for data <- corrupt, do: assert({:error, :invalid_stored_rules} = Codec.decode(data))
    IO.puts("QA_ADVERSARIAL malformed_rules=9 codec_corruption=4 metrics=9 PASS")
  end
end
