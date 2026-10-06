defmodule FootballMarket.Providers.EquivalenceTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.ProviderContractCase, as: Contract
  alias FootballMarket.Providers.{FactOracle, FixtureSourceA, FixtureSourceB}

  test "F-O02 bijection accepts renamed/reordered refs, rejects missing/merged same-name players and swapped edges" do
    id = "F-C01-PL-2025-2026-A"
    c = Enum.find(Contract.cases(), &(&1.id == id))
    expected = Contract.expected()[id].facts

    for adapter <- [FixtureSourceA, FixtureSourceB] do
      {:ok, result} = Contract.assert_contract!(adapter, id)
      correspondence = c.correspondence[adapter.source_key()]
      assert FactOracle.assert_facts!(result.facts, expected, correspondence) == :ok
      [first, second] = result.facts.players

      for players <- [
            [first],
            [%{first | team_ref: second.team_ref}, %{second | team_ref: first.team_ref}]
          ] do
        assert_raise ExUnit.AssertionError, fn ->
          FactOracle.assert_facts!(%{result.facts | players: players}, expected, correspondence)
        end
      end

      collapsed = put_in(correspondence, [:player, second.ref], correspondence.player[first.ref])

      assert_raise ExUnit.AssertionError, fn ->
        FactOracle.assert_facts!(result.facts, expected, collapsed)
      end
    end

    id = "F-P08-transfer"
    c = Enum.find(Contract.cases(), &(&1.id == id))
    {:ok, result} = Contract.assert_contract!(FixtureSourceA, id)
    [performance] = result.facts.performances
    player = hd(result.facts.players)

    swapped = %{
      result.facts
      | performances: [
          %{performance | team_ref: player.team_ref, position_ref: player.position_ref}
        ]
    }

    assert_raise ExUnit.AssertionError, fn ->
      FactOracle.assert_facts!(swapped, Contract.expected()[id].facts, c.correspondence.a)
    end
  end
end
