defmodule FootballMarket.Valuation.Configurations.RulesTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  import FootballMarket.ValuationConfigurationCase
  alias FootballMarket.Valuation.Configurations.Rules
  @position "00000000-0000-0000-0000-000000000001"

  test "both allowlisted formulas derive all configured requirements without defaults" do
    for strategy <- ["balanced", "position_aware"], weight <- [0, -2, Decimal.new("0.125")] do
      assert {:ok, valid} = Rules.validate(rules(@position, strategy, %{goals: weight}))

      scopes =
        if strategy == "balanced",
          do: [:overall],
          else: [:goalkeeper, :defender, :midfielder, :forward]

      assert valid.requirements == Map.new(scopes, &{&1, [:goals]})
      assert valid.config.weights == rules(@position, strategy, %{goals: weight}).config.weights
    end
  end

  test "malformed, extra, duplicate, empty and coercible values fail ordinarily" do
    r = rules(@position)

    invalid = [
      nil,
      [],
      Map.put(r, :requirements, %{overall: [:goals]}),
      Map.put(r, :module, Enum),
      %{r | config: %{weights: []}},
      %{r | config: %{weights: %{}}},
      %{r | references: %{}},
      %{r | references: %{goals: 0}},
      %{r | references: %{goals: -1}},
      %{r | references: %{goals: 2, assists: 1}},
      %{r | position_mapping: []},
      %{r | position_mapping: [{@position, :defender}, {@position, :forward}]},
      %{r | position_mapping: [{@position, :unknown}]},
      %{r | position_mapping: [{@position, :defender} | :bad]},
      %{r | position_mapping: %{@position => :defender}},
      %{r | position_mapping: [{"bad", :defender}]}
    ]

    for value <- invalid, do: assert({:error, %{kind: :validation}} = Rules.validate(value))

    for n <- [
          1.0,
          true,
          "2",
          Decimal.new("NaN"),
          Decimal.new("Infinity"),
          %Decimal{sign: 0, coef: 1, exp: 0}
        ] do
      assert {:error, %{kind: :validation}} =
               Rules.validate(%{r | config: %{weights: %{goals: n}}})

      assert {:error, %{kind: :validation}} = Rules.validate(%{r | references: %{goals: n}})
    end

    for group <- [:goalkeeper, :defender, :midfielder, :forward] do
      p = rules(@position, "position_aware")

      assert {:error, _} =
               Rules.validate(%{p | config: %{weights: Map.delete(p.config.weights, group)}})

      assert {:error, _} =
               Rules.validate(%{p | config: %{weights: Map.put(p.config.weights, group, %{})}})
    end

    assert {:error, %{kind: :unsupported_strategy}} = Rules.validate(%{r | formula_version: "2"})

    assert {:error, %{kind: :unsupported_strategy}} =
             Rules.validate(%{r | strategy_id: "arbitrary"})
  end

  test "each group's metric union is explicit, zero entries required and omission meaningful" do
    r = rules(@position, "position_aware", %{goals: 0})

    r = %{
      r
      | config: %{weights: Map.put(r.config.weights, :forward, %{assists: 0})},
        references: %{goals: 2, assists: 1}
    }

    assert {:ok, valid} = Rules.validate(r)
    assert valid.requirements.forward == [:assists]
    assert valid.requirements.defender == [:goals]
    refute Map.has_key?(valid.requirements, :overall)
    assert {:error, _} = Rules.validate(%{r | references: %{goals: 2}})
    b = rules(@position, "balanced", %{goals: 0, assists: 0}, %{goals: 2, assists: 1})
    assert {:ok, %{requirements: %{overall: [:goals, :assists]}}} = Rules.validate(b)

    assert {:ok, %{requirements: %{overall: [:goals]}}} =
             Rules.validate(rules(@position, "balanced", %{goals: 0}))

    assert {:error, _} = Rules.validate(%{b | config: %{weights: %{unknown: 0}}})
  end
end
