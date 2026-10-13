defmodule FootballMarket.Valuation.CanonicalTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  test "typed canonical configuration distinguishes integers, decimals and key types" do
    alias FootballMarket.Valuation.Evidence

    assert Evidence.canonical(%{"b" => [1, nil], a: Decimal.new("1.00")}) ==
             Evidence.canonical(%{"b" => [1, nil], a: Decimal.new("1")})

    assert {:integer, 1} = Evidence.canonical(1)
    assert {:decimal, 1, 1} = Evidence.canonical(Decimal.new(1))
  end

  test "24 fact permutations, tied byte identities, mappings and nested config order" do
    import FootballMarket.ValuationCase
    alias FootballMarket.Valuation.{Request, Preparation, Scoring, Definition, Evidence}
    midfield = "00000000-0000-0000-0000-000000000905"

    rows =
      for {n, identity} <- [{1, "Zulu"}, {2, "alpha"}, {3, "Beta"}, {4, "beta"}],
          do:
            fact(n, %{
              position_id: if(rem(n, 2) == 0, do: midfield, else: fact(1).position_id),
              match_identity: identity,
              metrics: %{fact(n).metrics | goals: n}
            })

    {:ok, req} =
      Request.validate(
        pure_request(%{
          references: %{goals: 20},
          position_mapping: [{fact(1).position_id, :defender}, {midfield, :midfielder}]
        })
      )

    d = %Definition{
      module: FootballMarket.ValuationScorers.Weighted,
      strategy_id: "illustrative",
      version: "1",
      config: %{policy: :require_all, weights: %{overall: %{goals: 2}}}
    }

    permutations = permute(rows)
    assert length(permutations) == 24
    assert {:ok, base} = Preparation.build(req, rows)
    assert Enum.map(base.facts, & &1.match_identity) == ["Beta", "Zulu", "alpha", "beta"]
    assert {:ok, definition} = Scoring.definition(d)
    assert {:ok, score} = Scoring.calculate(base, definition)
    assert score.score == "1.000000"

    for permutation <- permutations do
      assert {:ok, ^base} = Preparation.build(req, permutation)
      assert {:ok, ^score} = Scoring.calculate(base, definition)
    end

    unused = "00000000-0000-0000-0000-000000000999"

    input =
      pure_request(%{
        requirements: %{overall: [:assists, :goals], defender: [:goals]},
        references: %{goals: 20, assists: 1},
        position_mapping: [{unused, :forward}, {fact(1).position_id, :defender}]
      })

    assert {:ok, r1} = Request.validate(input)

    assert {:ok, ^r1} =
             Request.validate(%{
               input
               | position_mapping: Enum.reverse(input.position_mapping),
                 requirements: %{defender: [:goals], overall: [:goals, :assists]}
             })

    assert Evidence.canonical(%{x: [%{"z" => Decimal.new("2.00"), a: 1}]}) ==
             Evidence.canonical(%{x: [Map.new([{:a, 1}, {"z", Decimal.new(2)}])]})
  end

  defp permute([]), do: [[]]

  defp permute(rows),
    do: for(row <- rows, rest <- permute(List.delete(rows, row)), do: [row | rest])
end
