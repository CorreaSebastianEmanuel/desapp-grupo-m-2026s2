defmodule FootballMarket.Providers.FootballData.FixturesTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.FootballData.{FixtureData, ContractCase}

  test "FD-O01 every required inventory prefix executes twice with identical independent outcomes" do
    cases = FixtureData.cases()
    assert length(cases) == length(Enum.uniq_by(cases, & &1.id))

    for prefix <-
          ~w(FD-C01 FD-C02 FD-C03 FD-C04 FD-C05 FD-S01 FD-S02 FD-S03 FD-S04 FD-S05 FD-E01 FD-E02 FD-E03 FD-E04 FD-E05 FD-E06 FD-D01 FD-D02 FD-I01 FD-O01),
        do: assert(Enum.any?(cases, &String.starts_with?(&1.id, prefix)), prefix)

    assert Enum.sort(for c <- cases, String.starts_with?(c.id, "FD-C01"), do: c.league) ==
             ~w(BL1 FL1 PD PL SA)

    assert Enum.any?(
             cases,
             &(&1[:operation] == :performances and &1.expected == :unsupported_capability)
           )

    assert Enum.any?(cases, &(&1[:variant] == :large and &1.calls == 523))

    for c <- cases do
      assert ContractCase.run(c) == ContractCase.run(c)
    end
  end

  test "B1 full-boundary expiry matrix is tracked and included in pure selectors" do
    source = File.read!("test/football_market/providers/football_data/retry_expiry_test.exs")

    for oracle <- [
          "FD-E05-B1",
          "Retry-After",
          "X-RequestCounter-Reset",
          "received_us",
          "received_utc",
          "1_000_000, 1000",
          "2_000_000, nil",
          "3_000_000, nil",
          "legacy"
        ] do
      assert source =~ oracle
    end

    assert File.read!("test/football_data_offline.exs") =~ ~s|"retry-expiry" => ~w(retry_expiry)|
  end

  test "operator guide covers exact settings, access restrictions and safe actions" do
    guide = File.read!("docs/FOOTBALL_DATA.md")

    for required <- [
          "FOOTBALL_DATA_ENABLED=true",
          "FOOTBALL_DATA_TOKEN",
          "position_mapping",
          "3 + T + P",
          "523",
          "historical",
          "performances",
          "authentication-failed",
          "invalid-request",
          "invalid-response",
          "rate-limited",
          "unavailable",
          "timeout",
          "not-found",
          "unsupported-capability",
          "quickstart.md",
          "5,000",
          "CP2",
          "original source-header receipt",
          "normalization consume that wait"
        ],
        do: assert(String.contains?(guide, required), required)

    refute guide =~ "FD_SYNTHETIC_SENTINEL"
  end
end
