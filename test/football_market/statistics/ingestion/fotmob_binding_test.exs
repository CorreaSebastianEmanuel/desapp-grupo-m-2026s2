defmodule FootballMarket.Statistics.Ingestion.FotMobBindingTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  use FootballMarket.IngestionFixtures

  import Ecto.Query
  alias FootballMarket.Catalog
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Catalog.Ingestion.{Scope, SourceBinding}
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Ingestion.FotMobBinding

  test "FotMob team names bind only to the unique normalized local team" do
    positions!()

    assert {:ok, _} =
             Ingestion.import_catalog(request("PL", 2190), options(candidate("PL", 2190)))

    scope = Repo.one!(from scope in Scope, where: scope.start_year == 2190)
    team = Repo.get_by!(Catalog.Team, season_id: scope.season_id, name: "Alpha")

    result = %{
      provenance: %{provider: "fotmob-public-html-v1"},
      facts: %{teams: [%{ref: "team-a", name: "Álpha FC"}], players: []}
    }

    assert %SourceBinding{team_id: id} =
             FotMobBinding.maybe_bind(result, "team", "team-a", "fotmob-team-a", scope, [])

    assert id == team.id

    assert Repo.get_by!(SourceBinding,
             scope_id: scope.id,
             provider: "fotmob-public-html-v1",
             kind: "team",
             source_id: "fotmob-team-a"
           ).team_id == team.id
  end
end
