defmodule FootballMarket.Catalog.Ingestion.ReconciliationTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog.Ingestion

  test "catalog requests normalize the canonical league-season" do
    assert {:ok, request} =
             FootballMarket.Providers.Request.normalize(:catalog, %{
               league_code: " pl ",
               start_year: 2025,
               end_year: 2026
             })

    assert request.scope == %{league_code: "PL", start_year: 2025, end_year: 2026}
  end

  test "malformed relationships duplicates and unconfigured positions reject the complete result" do
    positions!()
    c = candidate()

    malformed = [
      %{c | facts: %{c.facts | teams: c.facts.teams ++ [hd(c.facts.teams)]}},
      %{c | bindings: c.bindings ++ [hd(c.bindings)]},
      %{c | facts: %{c.facts | positions: [%{ref: "NEW", code: "NEW", name: "New"}]}},
      %{c | facts: %{c.facts | players: [%{hd(c.facts.players) | season_ref: "other"}]}},
      Map.delete(c, :facts)
    ]

    for input <- malformed do
      before = {snapshot(), acceptance_snapshot()}
      assert {:error, o} = Ingestion.import_catalog(request(), options(input))
      assert o.status == :provider_failure
      assert o.provider_error.category == :invalid_response
      assert {snapshot(), acceptance_snapshot()} == before
    end
  end

  test "adoption requires both team keys and compatible canonical names" do
    positions!()
    {:ok, l} = FootballMarket.Catalog.create_league(%{code: "PL", name: "Premier League"})

    {:ok, season} =
      FootballMarket.Catalog.create_season(%{league_id: l.id, start_year: 2025, end_year: 2026})

    {:ok, _} =
      FootballMarket.Catalog.create_team(%{season_id: season.id, code: "ALP", name: "Different"})

    before = {snapshot(), acceptance_snapshot()}
    assert {:error, o} = Ingestion.import_catalog(request(), options())
    assert o.status == :reconciliation_conflict
    assert {snapshot(), acceptance_snapshot()} == before
  end
end
