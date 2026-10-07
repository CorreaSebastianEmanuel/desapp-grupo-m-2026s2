defmodule FootballMarket.Providers.ScrapingMatrixTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.Providers.ScrapingFixtureData, as: Data

  test "fingerprints and scenario inventory are closed and traceable" do
    cases = Data.cases()
    assert length(cases) == 170
    assert length(Enum.uniq_by(cases, & &1["id"])) == 170

    assert Enum.sort(Enum.map(cases, & &1["id"])) ==
             Enum.sort(Enum.map(Data.inventory(), & &1["id"]))

    assert Enum.sort(Enum.uniq(Enum.map(cases, & &1["scenario"]))) ==
             ~w(US1.1 US1.2 US1.3 US1.4 US2.1 US2.2 US2.3 US3.1 US3.2 US3.3 US3.4 US3.5 US3.6 US4.1 US4.2 US4.3 US4.4)

    for i <- Data.inventory() do
      assert i["created"] == "2026-10-07"
      assert i["origin"] =~ "synthetic"

      for {key, body} <- Data.documents(i["id"]) do
        assert Base.encode16(:crypto.hash(:sha256, body), case: :lower) == i["sha256"][key]
        refute body =~ "https://"
        refute body =~ "Bearer "
      end
    end

    for league <- ~w(PL BL1 PD SA FL1), year <- [2024, 2025], prefix <- ~w(catalog performance) do
      Data.assert_case!(Data.case!("#{prefix}-#{league}-#{year}"))
    end
  end

  test "two complete controlled runs compare facts/errors/provenance without app startup" do
    baseline = FootballMarket.Providers.Scraping.Assessment.actual()
    first = Enum.map(Data.cases(), &Data.assert_case!/1)
    second = Enum.map(Data.cases(), &Data.assert_case!/1)
    assert first == second
    assert FootballMarket.Providers.Scraping.Assessment.actual() == baseline
  end
end
