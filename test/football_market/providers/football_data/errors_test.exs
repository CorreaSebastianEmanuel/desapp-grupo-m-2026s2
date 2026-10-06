defmodule FootballMarket.Providers.FootballData.ErrorsTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.FootballData.{FixtureData, ContractCase}

  for c <- FixtureData.cases(), String.starts_with?(c.id, "FD-E") do
    @case c
    test @case.id, do: ContractCase.run(@case)
  end

  test "delay expires during processing, ambiguous headers and malformed bodies preserve the category" do
    alias FootballMarket.Providers.{FixtureRuntime, FootballData.Errors}
    headers = [{"rEtRy-AfTeR", "3"}]

    for {elapsed, expected} <- [
          {0, 3000},
          {1_000_000, 2000},
          {1_000_001, 1999},
          {2_999_999, nil},
          {3_000_000, nil},
          {4_000_000, nil}
        ] do
      Process.put(:fixture_elapsed, elapsed)

      assert Errors.delay(headers, %{runtime: {FixtureRuntime, %{}}}, %{
               received_us: 0,
               received_utc: ~U[2026-10-06 12:00:00Z]
             }) ==
               expected
    end

    for body <- [nil, "not-json", "FD_SYNTHETIC_SENTINEL", <<255>>],
        {status, category} <- [
          {403, :authentication_failed},
          {404, :not_found},
          {429, :rate_limited},
          {503, :unavailable}
        ] do
      assert %{category: ^category} =
               Errors.response(%{status: status, headers: [], body: body}, %{
                 runtime: {FixtureRuntime, %{}}
               })
    end
  end
end
