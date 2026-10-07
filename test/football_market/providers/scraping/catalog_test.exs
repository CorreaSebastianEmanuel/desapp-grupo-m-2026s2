defmodule FootballMarket.Providers.ScrapingCatalogTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data

  test "complete ten-scope catalogs and every integrity/empty outcome" do
    for c <- Data.cases(), String.starts_with?(c["id"], "catalog-") do
      Data.assert_case!(c)
    end
  end
end
