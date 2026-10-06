defmodule FootballMarket.Providers.PerformanceContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.ProviderContractCase, as: Contract
  alias FootballMarket.Providers.{FixtureSourceA, FixtureSourceB}

  test "F-P01 through F-P10 every dated fact/eligibility/count oracle against both sources" do
    ids = Contract.ids("F-P")
    assert length(ids) >= 90

    for id <- ids,
        adapter <- [FixtureSourceA, FixtureSourceB],
        do: Contract.assert_contract!(adapter, id)
  end

  test "F-P08 historical team/position survives independently of current affiliation" do
    {:ok, result} = Contract.assert_contract!(FixtureSourceA, "F-P08-transfer")
    [performance] = result.facts.performances
    [player] = result.facts.players
    assert performance.team_ref != player.team_ref
    assert performance.position_ref != player.position_ref
    assert length(result.facts.teams) == 2
    assert result.provenance.retrieved_at != hd(result.facts.matches).kickoff_at
    assert performance.counts.goals == 0
    assert Enum.sort(Map.values(performance.counts)) == Enum.to_list(0..8)
  end
end
