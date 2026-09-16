defmodule FootballMarket.QualityBaselineDiscoveryTest do
  use ExUnit.Case, async: true

  test "default ExUnit discovery reaches the CI sentinel" do
    IO.puts("\nFOOTBALL_MARKET_CI_DISCOVERY_SENTINEL")
    assert true
  end
end
