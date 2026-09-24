defmodule FootballMarket.CatalogQueryTest do
  # This module creates the fixed supported-league catalog, which is shared by
  # other catalog tests. Run it serially to avoid PostgreSQL lock cycles while
  # those tests insert into the same hierarchy.
  use FootballMarket.DataCase, async: false

  alias FootballMarket.Catalog
  import FootballMarket.CatalogCase

  test "singular fetches support stable and normalized business identities" do
    %{league: league, season: season, team: team} = insert_hierarchy!()
    {:ok, position} = Catalog.create_position(%{code: "GK", name: "Goalkeeper"})

    {:ok, player} =
      Catalog.create_player(player_attrs(team, position, %{catalog_identity: " Player-1 "}))

    assert {:ok, ^league} = Catalog.get_league(league.id)
    assert {:ok, ^league} = Catalog.get_league_by_code(" pl ")
    assert {:ok, ^season} = Catalog.get_season(season.id)
    assert {:ok, ^season} = Catalog.get_season(league.id, 2025, 2026)
    assert {:ok, ^team} = Catalog.get_team_by_code(season.id, String.downcase(team.code))
    assert {:ok, ^position} = Catalog.get_position_by_name(" goalkeeper ")
    assert {:ok, found} = Catalog.get_player(season.id, "player-1")
    assert found.id == player.id
    assert {:ok, found_by_id} = Catalog.get_player(player.id)
    assert found_by_id.id == player.id
    assert found_by_id.team.season.league.id == league.id
    assert {:error, :not_found} = Catalog.get_league(Ecto.UUID.generate())
    assert {:error, :not_found} = Catalog.get_season(Ecto.UUID.generate())
    assert {:error, :not_found} = Catalog.get_player(Ecto.UUID.generate())
  end

  test "player filters compose with AND and preload the hierarchy in UUID order" do
    %{league: league, season: season, team: team} = insert_hierarchy!()
    {:ok, other_team} = Catalog.create_team(team_attrs(season))
    {:ok, position} = Catalog.create_position(position_attrs())
    {:ok, other_position} = Catalog.create_position(position_attrs())
    {:ok, first} = Catalog.create_player(player_attrs(team, position))
    {:ok, second} = Catalog.create_player(player_attrs(other_team, other_position))

    assert Enum.map(Catalog.list_players(), & &1.id) == Enum.sort([first.id, second.id])

    assert [%{id: id, team: %{season: %{league: %{id: league_id}}}, position: %{}}] =
             Catalog.list_players(%{
               league_id: league.id,
               team_id: team.id,
               position_id: position.id
             })

    assert id == first.id
    assert league_id == league.id
    assert [] == Catalog.list_players(%{team_id: Ecto.UUID.generate()})
    assert {:error, {:unknown_filters, [:bogus]}} = Catalog.list_players(%{bogus: "x"})
  end

  test "representative catalog filters correctly across every league and multiple seasons" do
    positions =
      for {code, name} <- [{"GK", "Goalkeeper"}, {"DF", "Defender"}, {"FW", "Forward"}] do
        {:ok, position} = Catalog.create_position(%{code: code, name: name})
        position
      end

    records =
      for {{code, name}, league_index} <- Enum.with_index(Catalog.supported_leagues()),
          {start_year, season_index} <- [{2024, 0}, {2025, 1}],
          team_index <- 0..1,
          position <- positions do
        {:ok, league} =
          case Catalog.get_league_by_code(code) do
            {:ok, league} -> {:ok, league}
            {:error, :not_found} -> Catalog.create_league(%{code: code, name: name})
          end

        {:ok, season} =
          case Catalog.get_season(league.id, start_year, start_year + 1) do
            {:ok, season} ->
              {:ok, season}

            {:error, :not_found} ->
              Catalog.create_season(%{
                league_id: league.id,
                start_year: start_year,
                end_year: start_year + 1
              })
          end

        team_code = "L#{league_index}S#{season_index}T#{team_index}"

        {:ok, team} =
          case Catalog.get_team_by_code(season.id, team_code) do
            {:ok, team} ->
              {:ok, team}

            {:error, :not_found} ->
              Catalog.create_team(%{
                season_id: season.id,
                code: team_code,
                name: "Team #{team_code}"
              })
          end

        {:ok, player} =
          Catalog.create_player(%{
            team_id: team.id,
            position_id: position.id,
            catalog_identity: "#{team_code}-#{position.code}",
            display_name: "#{team_code} #{position.name}"
          })

        %{league: league, season: season, team: team, position: position, player: player}
      end

    assert records |> Enum.map(& &1.league.id) |> Enum.uniq() |> length() == 5
    assert records |> Enum.map(& &1.season.id) |> Enum.uniq() |> length() == 10
    assert records |> Enum.map(& &1.team.id) |> Enum.uniq() |> length() == 20

    target = Enum.at(records, 17)

    for {filter, key} <- [
          {%{league_id: target.league.id}, :league},
          {%{season_id: target.season.id}, :season},
          {%{team_id: target.team.id}, :team},
          {%{position_id: target.position.id}, :position}
        ] do
      results = Catalog.list_players(filter)
      assert results != []

      assert Enum.all?(results, fn player ->
               case key do
                 :league -> player.team.season.league.id == target.league.id
                 :season -> player.season_id == target.season.id
                 :team -> player.team_id == target.team.id
                 :position -> player.position_id == target.position.id
               end
             end)
    end

    assert [combined] =
             Catalog.list_players(%{
               league_id: target.league.id,
               season_id: target.season.id,
               team_id: target.team.id,
               position_id: target.position.id
             })

    assert combined.id == target.player.id
  end

  @tag :query_plan
  test "selective lookup plans are index capable at representative cardinality" do
    %{league: target_league, season: target_season, team: target_team} = insert_hierarchy!()
    {:ok, target_position} = Catalog.create_position(position_attrs())
    {:ok, other_position} = Catalog.create_position(position_attrs())
    {:ok, _} = Catalog.create_player(player_attrs(target_team, target_position))

    {:ok, target_league_other_season} =
      Catalog.create_season(season_attrs(target_league, %{start_year: 2026, end_year: 2027}))

    {:ok, target_season_other_team} = Catalog.create_team(team_attrs(target_season))

    {:ok, target_league_other_team} =
      Catalog.create_team(team_attrs(target_league_other_season))

    {:ok, other_league} = Catalog.create_league(%{code: "BL1", name: "Bundesliga"})
    {:ok, other_season} = Catalog.create_season(season_attrs(other_league))
    {:ok, other_team} = Catalog.create_team(team_attrs(other_season))

    Ecto.Adapters.SQL.query!(
      FootballMarket.Repo,
      """
      INSERT INTO players
        (id, team_id, season_id, position_id, catalog_identity, display_name, inserted_at, updated_at)
      SELECT gen_random_uuid(), team_id, season_id, position_id,
             'representative-' || value, 'Representative Player', NOW(), NOW()
      FROM (
        SELECT value, $1::uuid AS team_id, $2::uuid AS season_id, $3::uuid AS position_id
          FROM generate_series(1, 99) AS value
        UNION ALL
        SELECT value, $4::uuid, $2::uuid, $5::uuid
          FROM generate_series(100, 499) AS value
        UNION ALL
        SELECT value, $6::uuid, $7::uuid, $5::uuid
          FROM generate_series(500, 999) AS value
        UNION ALL
        SELECT value, $8::uuid, $9::uuid, $5::uuid
          FROM generate_series(1000, 99999) AS value
      ) AS representative_players
      """,
      [
        Ecto.UUID.dump!(target_team.id),
        Ecto.UUID.dump!(target_season.id),
        Ecto.UUID.dump!(target_position.id),
        Ecto.UUID.dump!(target_season_other_team.id),
        Ecto.UUID.dump!(other_position.id),
        Ecto.UUID.dump!(target_league_other_team.id),
        Ecto.UUID.dump!(target_league_other_season.id),
        Ecto.UUID.dump!(other_team.id),
        Ecto.UUID.dump!(other_season.id)
      ]
    )

    Ecto.Adapters.SQL.query!(FootballMarket.Repo, "ANALYZE players", [])

    plans = %{
      league: Catalog.explain_player_lookup(%{league_id: target_league.id}),
      season: Catalog.explain_player_lookup(%{season_id: target_season.id}),
      team: Catalog.explain_player_lookup(%{team_id: target_team.id}),
      position: Catalog.explain_player_lookup(%{position_id: target_position.id}),
      combined:
        Catalog.explain_player_lookup(%{
          league_id: target_league.id,
          season_id: target_season.id,
          team_id: target_team.id,
          position_id: target_position.id
        })
    }

    for {lookup, plan} <- plans do
      assert plan =~ ~r/(Index|Bitmap)/, "#{lookup} lookup was not index capable:\n#{plan}"
    end
  end
end
