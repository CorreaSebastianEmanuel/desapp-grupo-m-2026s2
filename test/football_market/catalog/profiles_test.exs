defmodule FootballMarket.Catalog.ProfilesTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  use FootballMarket.IngestionFixtures
  alias FootballMarket.Catalog.{Profiles, Player, Ingestion}
  alias FootballMarket.Catalog.Ingestion.{Scope, SourceBinding}

  test "profiles preserve public context and use only the requested player's provider bindings" do
    positions!()
    assert {:ok, _} = Ingestion.import_catalog(request(), options())
    player = Repo.get_by!(Player, display_name: "Alex")
    scope = Repo.one!(Scope)

    assert %{name: "Alex", team: "Alpha", league: "Premier League", photo: nil, crest: nil} =
             Profiles.get_many([player.id])[player.id]

    base = %{
      scope_id: scope.id,
      season_scope_id: scope.season_id,
      league_scope_id: scope.league_id
    }

    Repo.insert!(
      SourceBinding.changeset(
        %SourceBinding{},
        Map.merge(base, %{
          provider: "fotmob-public-html-v1",
          kind: "player",
          source_id: "737066",
          player_id: player.id
        })
      )
    )

    Repo.insert!(
      SourceBinding.changeset(
        %SourceBinding{},
        Map.merge(base, %{
          provider: "football-data.org-v4",
          kind: "team",
          source_id: "66",
          team_id: player.team_id
        })
      )
    )

    profiles = Profiles.get_many([player.id, player.id, Ecto.UUID.generate()])
    assert map_size(profiles) == 1

    assert profiles[player.id].photo ==
             "https://images.fotmob.com/image_resources/playerimages/737066.png"

    assert profiles[player.id].crest == "https://crests.football-data.org/66.png"
    assert Profiles.get_many([]) == %{}
    assert Profiles.get_many([Ecto.UUID.generate()]) == %{}
  end
end
