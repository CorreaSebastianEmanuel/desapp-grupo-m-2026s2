defmodule FootballMarket.Valuation.Balanced.ConfigTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Valuation.{Balanced, Request, Scoring, Definition, FeatureView}

  test "identity, explicit signed exact weights and ordered overall membership including zero" do
    assert Balanced.identity() == {"balanced", "1"}

    for weights <- [
          %{goals: 2},
          %{saves: 0, goals: -2, assists: Decimal.new("0.125")},
          Map.new(Request.metrics(), &{&1, 0})
        ] do
      config = %{weights: weights}
      assert {:ok, ^config} = Balanced.validate_config(config)
      assert {:ok, %{overall: metrics}} = Balanced.requirements(config)
      assert metrics == Enum.filter(Request.metrics(), &Map.has_key?(weights, &1))
    end
  end

  test "malformed shapes and numbers are ordinary failures before traversal" do
    decimal = Decimal.new(1)

    invalid = [
      nil,
      %{},
      %{weights: %{}},
      %{weights: []},
      %{weights: [{:goals, 1} | :tail]},
      %{weights: decimal},
      %{weights: %{overall: %{goals: 1}}},
      %{weights: %{minutes: 1}},
      %{weights: %{"untrusted_metric" => 1}},
      %{weights: %{goals: 1}, extra: [1 | :tail]}
    ]

    values = [
      nil,
      true,
      false,
      "1",
      1.0,
      [1 | :tail],
      %{forward: 1},
      Decimal.new("NaN"),
      Decimal.new("Infinity"),
      %{decimal | sign: 0},
      %{decimal | coef: -1},
      %{decimal | coef: 1.0},
      %{decimal | exp: "0"},
      Map.put(decimal, :extra, 1),
      Map.delete(decimal, :coef)
    ]

    for config <- invalid ++ Enum.map(values, &%{weights: %{goals: &1}}) do
      assert {:error, _} = Balanced.validate_config(config)

      assert {:error, %{kind: :validation}} =
               Scoring.definition(%Definition{
                 module: Balanced,
                 strategy_id: "balanced",
                 version: "1",
                 config: config
               })
    end
  end

  test "equivalent decimals normalize while missing features never become zero" do
    definition = fn weight ->
      %Definition{
        module: Balanced,
        strategy_id: "balanced",
        version: "1",
        config: %{weights: %{goals: weight}}
      }
    end

    assert {:ok, a} = Scoring.definition(definition.(Decimal.new("2.00")))
    assert {:ok, b} = Scoring.definition(definition.(Decimal.new("2")))
    assert a == b
    assert {:error, _} = Balanced.score(%FeatureView{features: %{overall: %{}}}, a.config)
  end

  test "every malformed Decimal field, container and nested tail fails without callbacks throwing" do
    decimal = Decimal.new(1)

    configs = [
      decimal,
      %{weights: %{goals: [[:value | :tail]]}},
      %{weights: %{goals: 1}, policy: :require_all},
      %{weights: %{defender: %{goals: 1}}},
      %{"weights" => %{goals: 1}},
      %{weights: %{goals: 1}, extra: %{nested: [[1 | :tail]]}}
    ]

    numbers =
      [
        %{decimal | sign: nil},
        %{decimal | sign: 1.0},
        %{decimal | coef: nil},
        %{decimal | exp: 0.0}
      ] ++ Enum.map([:sign, :coef, :exp], &Map.delete(decimal, &1))

    for config <- configs ++ Enum.map(numbers, &%{weights: %{goals: &1}}) do
      assert {:error, _} = Balanced.validate_config(config)
      assert {:error, _} = Balanced.requirements(config)

      assert {:error, %{kind: :validation}} =
               Scoring.definition(%Definition{
                 module: Balanced,
                 strategy_id: "balanced",
                 version: "1",
                 config: config
               })
    end
  end
end
