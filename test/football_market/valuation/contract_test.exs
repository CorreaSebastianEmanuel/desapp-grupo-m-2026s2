defmodule FootballMarket.Valuation.ContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Definition, Descriptor, Request}
  import FootballMarket.ValuationCase

  test "explicit shapes, keys, requirements, mappings and exact numbers" do
    assert {:ok, _} = Request.validate(pure_request())

    for field <- [
          :player_id,
          :season_id,
          :week_start,
          :week_end,
          :requirements,
          :references,
          :position_mapping
        ] do
      assert {:error, %{kind: :validation}} = Request.validate(Map.delete(pure_request(), field))
    end

    for change <- [
          %{other: 1},
          %{player_id: "bad"},
          %{requirements: %{}},
          %{requirements: %{overall: []}},
          %{requirements: %{overall: [:minutes]}},
          %{requirements: %{other: [:goals]}},
          %{requirements: %{overall: [:goals, :goals]}},
          %{references: %{}},
          %{references: %{goals: 0}},
          %{references: %{goals: -1}},
          %{references: %{goals: 1.0}},
          %{references: %{goals: true}},
          %{references: %{goals: "4"}},
          %{references: %{goals: Decimal.new("NaN")}},
          %{references: %{goals: Decimal.new("Infinity")}},
          %{references: %{goals: %Decimal{sign: 0, coef: 1, exp: 0}}},
          %{references: %{goals: %Decimal{sign: 1, coef: -1, exp: 0}}},
          %{references: %{goals: %Decimal{sign: 1, coef: 1, exp: nil}}},
          %{references: %{goals: Map.put(Decimal.new(4), :unexpected, 1)}},
          %{references: %{goals: 4, assists: 1}},
          %{position_mapping: %{}},
          %{position_mapping: [1]},
          %{position_mapping: [{"bad", :defender}]},
          %{position_mapping: [{fact(1).position_id, :unknown}]},
          %{position_mapping: [{fact(1).position_id, :defender}, {fact(1).position_id, :forward}]}
        ] do
      assert {:error, %{kind: :validation}} = Request.validate(Map.merge(pure_request(), change)),
             inspect(change)
    end

    for value <- [nil, [], "bad", 1], do: assert(match?({:error, _}, Request.validate(value)))
  end

  test "public entrypoints reject improper request and nested configuration lists before reads" do
    base = pure_request()
    position = fact(1).position_id

    for requirements <- [
          %{overall: [:goals | :invalid_tail]},
          %{defender: [:goals, :assists | :invalid_tail]},
          %{overall: [[:goals | :invalid_tail]]}
        ] do
      assert {:error, %{kind: :validation, reason: :invalid_requirements}} =
               Valuation.prepare(%{base | requirements: requirements})
    end

    for mapping <- [
          [{position, :defender} | :invalid_tail],
          [{position, :defender}, {fact(2).position_id, :forward} | :invalid_tail],
          [{position, [:defender | :invalid_tail]}],
          [[{position, :defender} | :invalid_tail]]
        ] do
      assert {:error, %{kind: :validation, reason: :invalid_mapping}} =
               Valuation.prepare(%{base | position_mapping: mapping})
    end

    definition = %Definition{
      module: FootballMarket.ValuationScorers.Weighted,
      strategy_id: "illustrative",
      version: "1",
      config: %{weights: %{overall: %{goals: 1}}, policy: :require_all}
    }

    for extra <- [
          [1 | :invalid_tail],
          [[1 | :invalid_tail]],
          %{nested: [1 | :invalid_tail]},
          [%{nested: [[1 | :invalid_tail]]}]
        ] do
      invalid = %{definition | config: Map.put(definition.config, :extra, extra)}

      assert {:error, %{kind: :validation, reason: :invalid_definition}} =
               Valuation.evaluate(base, invalid)

      assert {:error, %{kind: :validation}} = Valuation.score(nil, invalid)
    end

    assert {:error, %{kind: :inconsistent_replay}} =
             Valuation.replay(%Descriptor{request: base, facts: [fact(1) | :invalid_tail]}, nil)
  end
end
