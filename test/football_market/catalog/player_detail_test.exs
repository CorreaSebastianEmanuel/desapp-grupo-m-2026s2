defmodule FootballMarket.Catalog.PlayerDetailTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  import FootballMarket.CatalogCase

  test "loads authoritative hierarchy and collapses malformed and absent identities" do
    %{players: [player], league: league} = insert_catalog!()
    assert {:ok, loaded} = FootballMarket.Catalog.get_player_detail(player.id)
    assert loaded.team.season.league.id == league.id
    assert {:error, :not_found} = FootballMarket.Catalog.get_player_detail("malformed")
    assert {:error, :not_found} = FootballMarket.Catalog.get_player_detail(Ecto.UUID.generate())
  end
end
