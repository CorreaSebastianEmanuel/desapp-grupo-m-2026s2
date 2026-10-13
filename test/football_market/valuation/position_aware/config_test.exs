defmodule FootballMarket.Valuation.PositionAware.ConfigTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  import FootballMarket.PositionAwareCase
  alias FootballMarket.Valuation.{PositionAware, Request, Scoring, Definition, FeatureView}

  test "identity, explicit signed exact weights and ordered four-group membership including zero" do
    assert PositionAware.identity() == {"position_aware", "1"}

    for weights <- [
          %{goals: 2},
          %{saves: 0, goals: -2, assists: Decimal.new("0.125")},
          Map.new(Request.metrics(), &{&1, 0})
        ] do
      config = %{weights: rules(weights)}
      assert {:ok, ^config} = PositionAware.validate_config(config)
      assert {:ok, requirements} = PositionAware.requirements(config)
      assert Map.keys(requirements) |> Enum.sort() == Enum.sort(groups())

      for group <- groups(),
          do:
            assert(
              requirements[group] == Enum.filter(Request.metrics(), &Map.has_key?(weights, &1))
            )
    end
  end

  test "malformed shapes and numbers are ordinary failures before traversal" do
    decimal = Decimal.new(1)

    invalid = [
      nil,
      %{weights: Map.delete(rules(%{goals: 1}), :forward)},
      %{weights: Map.put(rules(%{goals: 1}), :forward, %{})},
      %{weights: Map.put(rules(%{goals: 1}), :defender, decimal)},
      %{weights: Map.put(rules(%{goals: 1}), :overall, %{goals: 1})},
      %{weights: Map.put(rules(%{goals: 1}), :unknown, %{goals: 1})},
      %{weights: Map.put(rules(%{goals: 1}), :defender, %{unknown: 1})},
      %{weights: Map.put(rules(%{goals: 1}), :defender, %{"goals" => 1})},
      %{weights: Map.put(rules(%{goals: 1}), :defender, goals: 1, goals: 2)},
      %{weights: [defender: %{goals: 1}, defender: %{goals: 2}]},
      %{weights: Map.put(rules(%{goals: 1}), :defender, [{:goals, 1} | :tail])},
      %{weights: rules(%{goals: 1}), policy: :require_all},
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

    for config <- invalid ++ Enum.map(values, &%{weights: rules(%{goals: &1})}) do
      assert {:error, _} = PositionAware.validate_config(config)
      assert {:error, _} = PositionAware.requirements(config)

      assert {:error, %{kind: :validation, reason: reason}} =
               Scoring.definition(%Definition{
                 module: PositionAware,
                 strategy_id: "position_aware",
                 version: "1",
                 config: config
               })

      refute reason == :callback_exception
    end
  end

  test "equivalent decimals normalize while missing features never become zero" do
    definition = fn weight ->
      %Definition{
        module: PositionAware,
        strategy_id: "position_aware",
        version: "1",
        config: %{weights: rules(%{goals: weight})}
      }
    end

    assert {:ok, a} = Scoring.definition(definition.(Decimal.new("2.00")))
    assert {:ok, b} = Scoring.definition(definition.(Decimal.new("2")))
    assert a == b
    assert {:error, _} = PositionAware.score(%FeatureView{features: %{defender: %{}}}, a.config)
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

    for config <- configs ++ Enum.map(numbers, &%{weights: rules(%{goals: &1})}) do
      assert {:error, _} = PositionAware.validate_config(config)
      assert {:error, _} = PositionAware.requirements(config)
      assert {:error, _} = PositionAware.requirements(config)

      assert {:error, %{kind: :validation, reason: reason}} =
               Scoring.definition(%Definition{
                 module: PositionAware,
                 strategy_id: "position_aware",
                 version: "1",
                 config: config
               })

      refute reason == :callback_exception
    end
  end

  test "direct feature views reject unknown scopes, missing metrics and malformed values without exceptions" do
    config = %{weights: rules(%{goals: 2})}

    for features <- [
          nil,
          [],
          %{},
          %{overall: %{goals: Decimal.new(1)}},
          %{unknown: %{goals: Decimal.new(1)}},
          %{defender: []},
          %{defender: Decimal.new(1)},
          %{defender: %{}},
          %{defender: %{goals: 0.5}},
          %{defender: %{goals: nil}},
          %{defender: %{goals: Decimal.new("NaN")}},
          %{defender: %{goals: Decimal.new(1), saves: Decimal.new(1)}}
        ] do
      assert {:error, _} = PositionAware.score(%FeatureView{features: features}, config)
    end

    assert {:error, _} = PositionAware.score(%{}, config)

    assert {:error, _} =
             PositionAware.score(
               Map.put(
                 %FeatureView{features: %{defender: %{goals: Decimal.new(1)}}},
                 :extra,
                 :untrusted
               ),
               config
             )

    assert {:ok, score} =
             PositionAware.score(
               %FeatureView{features: %{defender: %{goals: Decimal.new("0.5")}}},
               config
             )

    assert Decimal.equal?(score, 1)
  end
end
