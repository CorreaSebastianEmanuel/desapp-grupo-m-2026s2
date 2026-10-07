defmodule FootballMarket.Providers.ScrapingPerformancesTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data

  test "literal dated facts, tri-state metrics, affiliation and required-field failures" do
    for c <- Data.cases(),
        c["operation"] == "performances",
        not String.starts_with?(c["id"], ["deadline-", "source-equivalence-"]) do
      Data.assert_case!(c)
    end
  end

  test "unrelated duplicate rating and aggregate labels do not become football counts" do
    c = Data.case!("performance-PL-2024")
    state = Data.state(c)
    match = Jason.decode!(state.portions["match:m1"].body)
    stats = get_in(match, ["content", "playerStats", "p1", "stats"])
    rating = %{"key" => "rating", "stat" => %{"value" => "FAKE_SENTINEL"}}

    match =
      put_in(
        match,
        ["content", "playerStats", "p1", "stats"],
        stats ++ [%{"stats" => [rating, rating]}]
      )

    portions = put_in(state.portions, ["match:m1", :body], Jason.encode!(match))
    assert {:ok, result} = Data.assert_case!(c, %{portions: portions})
    refute inspect(result) =~ "FAKE_SENTINEL"
  end
end
