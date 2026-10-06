defmodule FootballMarket.Providers.FootballData.CatalogTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.FootballData.{FixtureData, ContractCase}

  for c <- FixtureData.cases(),
      String.starts_with?(c.id, ["FD-C01", "FD-C02", "FD-C03", "FD-C04"]) do
    @case c
    test @case.id, do: ContractCase.run(@case)
  end
end
