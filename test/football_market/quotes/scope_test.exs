defmodule FootballMarket.Quotes.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  test "feature inventory stays explicitly bounded to quote calculation ownership" do
    paths =
      FootballMarket.WorkflowScope.paths("specs/026-quote-recalculation-and-immutable-history")

    assert "lib/football_market/quotes/" in paths
    refute "lib/football_market_web/" in paths
    refute "lib/football_market/providers/" in paths
  end
end
