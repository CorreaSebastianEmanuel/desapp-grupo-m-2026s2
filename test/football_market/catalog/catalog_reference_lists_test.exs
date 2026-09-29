defmodule FootballMarket.Catalog.ReferenceListsTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration

  alias FootballMarket.Catalog

  test "leagues and positions are listed by name" do
    {:ok, serie_a} = Catalog.create_league(%{code: "SA", name: "Serie A"})
    {:ok, bundesliga} = Catalog.create_league(%{code: "BL1", name: "Bundesliga"})
    {:ok, midfielder} = Catalog.create_position(%{code: "MID", name: "Midfielder"})
    {:ok, defender} = Catalog.create_position(%{code: "DEF", name: "Defender"})

    assert Enum.map(Catalog.list_leagues(), & &1.id) == [bundesliga.id, serie_a.id]
    assert Enum.map(Catalog.list_positions(), & &1.id) == [defender.id, midfielder.id]
  end

  test "teams preload their season and league and can be narrowed by league" do
    {:ok, premier_league} = Catalog.create_league(%{code: "PL", name: "Premier League"})
    {:ok, ligue_1} = Catalog.create_league(%{code: "FL1", name: "Ligue 1"})

    {:ok, pl_2025} =
      Catalog.create_season(%{league_id: premier_league.id, start_year: 2025, end_year: 2026})

    {:ok, pl_2026} =
      Catalog.create_season(%{league_id: premier_league.id, start_year: 2026, end_year: 2027})

    {:ok, fl1_2026} =
      Catalog.create_season(%{league_id: ligue_1.id, start_year: 2026, end_year: 2027})

    {:ok, arsenal_2025} =
      Catalog.create_team(%{season_id: pl_2025.id, code: "ARS", name: "Arsenal"})

    {:ok, arsenal_2026} =
      Catalog.create_team(%{season_id: pl_2026.id, code: "ARS", name: "Arsenal"})

    {:ok, burnley_2026} =
      Catalog.create_team(%{season_id: pl_2026.id, code: "BUR", name: " burnley "})

    {:ok, lyon} = Catalog.create_team(%{season_id: fl1_2026.id, code: "OL", name: "Lyon"})

    assert Enum.map(Catalog.list_teams(), & &1.id) ==
             [lyon.id, arsenal_2026.id, burnley_2026.id, arsenal_2025.id]

    assert [first | _] = Catalog.list_teams(%{league_id: premier_league.id})
    assert first.season.league.code == "PL"

    assert Enum.map(Catalog.list_teams(%{league_id: premier_league.id}), & &1.id) ==
             [arsenal_2026.id, burnley_2026.id, arsenal_2025.id]

    assert Catalog.list_teams(%{league_id: Ecto.UUID.generate()}) == []
  end
end
