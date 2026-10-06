defmodule FootballMarket.Providers.FootballData.DeadlineTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.FootballData.{FixtureData, ContractCase}

  for c <- FixtureData.cases(), String.starts_with?(c.id, "FD-D") do
    @case c
    test @case.id, do: ContractCase.run(@case)
  end
end
