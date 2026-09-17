defmodule FootballMarket.CatalogTest do
  use FootballMarket.DataCase, async: true

  alias FootballMarket.Catalog
  import FootballMarket.CatalogCase

  test "accepts exactly the supported league pairs and normalizes display values" do
    for {code, name} <- Catalog.supported_leagues() do
      assert {:ok, league} = Catalog.create_league(%{code: " #{code} ", name: " #{name} "})
      assert league.code == code
      assert league.name == name
    end

    assert {:error, changeset} = Catalog.create_league(%{code: "PL", name: "Bundesliga"})
    assert "is not a supported league pair" in errors_on(changeset).code

    assert {:error, unsupported_code} =
             Catalog.create_league(%{code: "EPL", name: "Premier League"})

    assert "is not a supported league pair" in errors_on(unsupported_code).code

    assert {:error, unsupported_name} =
             Catalog.create_league(%{code: "PL", name: "English Premier League"})

    assert "is not a supported league pair" in errors_on(unsupported_name).code
  end

  test "validates hierarchy and protects parents" do
    %{league: league, season: season, team: team} = insert_hierarchy!()

    assert {:error, changeset} =
             Catalog.create_season(season_attrs(league, %{start_year: 2024, end_year: 2026}))

    assert %{end_year: [_ | _]} = errors_on(changeset)

    before_counts = catalog_counts()
    assert {:error, league_changeset} = Catalog.delete_league(league)
    assert %{seasons: [_ | _]} = errors_on(league_changeset)
    assert catalog_counts() == before_counts

    assert {:error, changeset} = Catalog.delete_season(season)
    assert %{teams: [_ | _]} = errors_on(changeset)
    assert {:ok, _} = Catalog.delete_team(team)
  end

  test "creates players and permits only same-season reassignment" do
    %{season: season, team: first_team} = insert_hierarchy!()
    {:ok, second_team} = Catalog.create_team(team_attrs(season))
    {:ok, position} = Catalog.create_position(position_attrs())
    {:ok, player} = Catalog.create_player(player_attrs(first_team, position))

    assert player.season_id == season.id
    assert {:ok, moved} = Catalog.update_player(player, %{team_id: second_team.id})
    assert moved.id == player.id
    assert moved.team_id == second_team.id

    {:ok, other_season} =
      Catalog.create_season(
        season_attrs(season.league_id |> Catalog.fetch_league!(), %{
          start_year: 2026,
          end_year: 2027
        })
      )

    {:ok, other_team} = Catalog.create_team(team_attrs(other_season))
    assert {:error, changeset} = Catalog.update_player(moved, %{team_id: other_team.id})
    assert %{team_id: [_ | _]} = errors_on(changeset)
  end

  test "rejects blank fields and missing relationships" do
    assert {:error, missing_team} = Catalog.create_player(%{})
    assert %{team_id: [_ | _]} = errors_on(missing_team)

    assert {:error, changeset} = Catalog.create_position(%{code: " ", name: " "})
    assert %{code: [_], name: [_]} = errors_on(changeset)

    assert {:error, changeset} =
             Catalog.create_team(%{season_id: Ecto.UUID.generate(), code: "X", name: "X"})

    assert %{season_id: [_ | _]} = errors_on(changeset)

    %{team: team} = insert_hierarchy!()

    assert {:error, player_changeset} =
             Catalog.create_player(%{
               team_id: team.id,
               position_id: Ecto.UUID.generate(),
               catalog_identity: "missing-position",
               display_name: "Missing Position"
             })

    assert %{position_id: [_ | _]} = errors_on(player_changeset)
    assert FootballMarket.Repo.aggregate(FootballMarket.Catalog.Player, :count) == 0

    {:ok, position} = Catalog.create_position(position_attrs())
    {:ok, player} = Catalog.create_player(player_attrs(team, position))
    assert {:error, nil_team} = Catalog.update_player(player, %{team_id: nil})
    assert %{team_id: [_ | _]} = errors_on(nil_team)
  end

  defp catalog_counts do
    for schema <- [
          FootballMarket.Catalog.League,
          FootballMarket.Catalog.Season,
          FootballMarket.Catalog.Team,
          FootballMarket.Catalog.Position,
          FootballMarket.Catalog.Player
        ],
        into: %{},
        do: {schema, FootballMarket.Repo.aggregate(schema, :count)}
  end
end
