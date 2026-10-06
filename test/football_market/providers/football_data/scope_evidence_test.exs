defmodule FootballMarket.Providers.FootballData.ScopeEvidenceTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.FootballData.{FixtureData, ContractCase}

  for c <- FixtureData.cases(), String.starts_with?(c.id, ["FD-C05", "FD-E01", "FD-E02"]) do
    @case c
    test @case.id, do: ContractCase.run(@case)
  end
end
