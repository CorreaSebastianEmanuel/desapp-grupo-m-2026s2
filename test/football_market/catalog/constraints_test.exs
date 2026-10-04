defmodule FootballMarket.CatalogConstraintsTest do
  use FootballMarket.DataCase, async: true

  @moduletag :integration

  alias FootballMarket.Catalog
  alias FootballMarket.Repo
  import FootballMarket.CatalogCase

  test "migration installs UUID tables, named constraints, and lookup indexes" do
    tables = ~w(leagues seasons teams positions players)

    %{rows: table_rows} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = ANY($1) ORDER BY table_name",
        [tables]
      )

    assert Enum.map(table_rows, &hd/1) == Enum.sort(tables)

    %{rows: id_rows} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT data_type FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'id' AND table_name = ANY($1)",
        [tables]
      )

    assert length(id_rows) == 5
    assert Enum.all?(id_rows, fn [type] -> type == "uuid" end)

    constraints =
      ~w(leagues_code_not_blank leagues_name_not_blank leagues_supported_code seasons_valid_year_span players_team_season_fkey)

    %{rows: constraint_rows} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT conname FROM pg_constraint WHERE conname = ANY($1)",
        [constraints]
      )

    assert constraint_rows |> Enum.map(&hd/1) |> Enum.sort() == Enum.sort(constraints)

    indexes =
      ~w(leagues_normalized_code_index seasons_league_years_index teams_season_normalized_code_index positions_normalized_code_index players_season_normalized_identity_index players_team_position_id_index)

    %{rows: index_rows} =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT indexname FROM pg_indexes WHERE schemaname = 'public' AND indexname = ANY($1)",
        [indexes]
      )

    assert index_rows |> Enum.map(&hd/1) |> Enum.sort() == Enum.sort(indexes)
  end

  test "exact, case, and whitespace variants cannot bypass any normalized identity scope" do
    {:ok, league} = Catalog.create_league(%{code: "PL", name: "Premier League"})
    assert_normalized_league_duplicates_rejected()

    {:ok, season} = Catalog.create_season(season_attrs(league))
    assert {:error, season_duplicate} = Catalog.create_season(season_attrs(league))
    assert %{league_id: [_ | _]} = errors_on(season_duplicate)

    {:ok, team} = Catalog.create_team(%{season_id: season.id, code: "ARS", name: "Arsenal"})

    assert_normalized_duplicates(
      ["ARS", "ars", " ARS "],
      fn code ->
        Catalog.create_team(%{
          season_id: season.id,
          code: code,
          name: unique_code("Other Team ")
        })
      end,
      :code
    )

    assert_normalized_duplicates(
      ["Arsenal", "arsenal", " Arsenal "],
      fn name ->
        Catalog.create_team(%{
          season_id: season.id,
          code: unique_code("OT"),
          name: name
        })
      end,
      :name
    )

    {:ok, position} = Catalog.create_position(%{code: "GK", name: "Goalkeeper"})

    assert_normalized_duplicates(
      ["GK", "gk", " GK "],
      &Catalog.create_position(%{code: &1, name: unique_code("Position ")}),
      :code
    )

    assert_normalized_duplicates(
      ["Goalkeeper", "goalkeeper", " Goalkeeper "],
      &Catalog.create_position(%{code: unique_code("P"), name: &1}),
      :name
    )

    {:ok, original} =
      Catalog.create_player(player_attrs(team, position, %{catalog_identity: "player-1"}))

    assert_normalized_duplicates(
      ["player-1", "PLAYER-1", " player-1 "],
      &Catalog.create_player(player_attrs(team, position, %{catalog_identity: &1})),
      :catalog_identity
    )

    assert Repo.aggregate(FootballMarket.Catalog.League, :count) == 1
    assert Repo.aggregate(FootballMarket.Catalog.Season, :count) == 1
    assert Repo.aggregate(FootballMarket.Catalog.Team, :count) == 1
    assert Repo.aggregate(FootballMarket.Catalog.Position, :count) == 1
    assert Enum.map(Repo.all(FootballMarket.Catalog.Player), & &1.id) == [original.id]
  end

  test "database rejects an inconsistent player team and season pair" do
    %{season: first_season, team: first_team} = insert_hierarchy!()

    {:ok, second_season} =
      Catalog.create_season(
        season_attrs(first_season.league_id |> Catalog.fetch_league!(), %{
          start_year: 2026,
          end_year: 2027
        })
      )

    {:ok, position} = Catalog.create_position(position_attrs())

    assert_raise Postgrex.Error, fn ->
      Ecto.Adapters.SQL.query!(
        Repo,
        "INSERT INTO players (id, team_id, season_id, position_id, catalog_identity, display_name, inserted_at, updated_at) VALUES ($1,$2,$3,$4,$5,$6,NOW(),NOW())",
        [
          Ecto.UUID.dump!(Ecto.UUID.generate()),
          Ecto.UUID.dump!(first_team.id),
          Ecto.UUID.dump!(second_season.id),
          Ecto.UUID.dump!(position.id),
          unique_code("bad-"),
          "Bad"
        ]
      )
    end
  end

  test "dependent players protect their team and position" do
    %{team: team} = insert_hierarchy!()
    {:ok, position} = Catalog.create_position(position_attrs())
    {:ok, _player} = Catalog.create_player(player_attrs(team, position))

    assert {:error, team_changeset} = Catalog.delete_team(team)
    assert %{players: [_ | _]} = errors_on(team_changeset)
    assert {:error, position_changeset} = Catalog.delete_position(position)
    assert %{players: [_ | _]} = errors_on(position_changeset)
  end

  defp assert_normalized_league_duplicates_rejected do
    for attrs <- [
          %{code: "PL", name: "Premier League"},
          %{code: "pl", name: "premier league"},
          %{code: " PL ", name: " Premier League "}
        ] do
      assert {:error, changeset} = Catalog.create_league(attrs)
      assert errors_on(changeset) != %{}
    end
  end

  defp assert_normalized_duplicates(values, create, field) do
    for value <- values do
      assert {:error, changeset} = create.(value)
      assert %{^field => [_ | _]} = errors_on(changeset)
    end
  end
end

defmodule FootballMarket.CatalogConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration

  if System.get_env("MIX_TEST_PARTITION") == "catalog_concurrency" do
    alias Ecto.Adapters.SQL.Sandbox
    alias FootballMarket.{Catalog, Repo}
    alias FootballMarket.Catalog.{League, Season, Team, Position, Player}
    import Ecto.Query
    import FootballMarket.CatalogConcurrencyCase
    import FootballMarket.CatalogCase

    setup do
      setup_race()
    end

    test "normalized unique indexes arbitrate concurrent catalog writes", context do
      Sandbox.unboxed_run(Repo, fn ->
        existing = Repo.all(from l in League, select: l.code)

        {code, name} =
          Enum.find(Catalog.supported_leagues(), fn {code, _} -> code not in existing end)

        results =
          race(context, fn -> Catalog.create_league(%{code: " #{code} ", name: " #{name} "}) end)

        {:ok, league} = Enum.find(results, &match?({:ok, _}, &1))
        assert Repo.get!(League, league.id) == league

        season_results =
          race(context, fn ->
            Catalog.create_season(season_attrs(league, %{start_year: 2032, end_year: 2033}))
          end)

        {:ok, season} = Enum.find(season_results, &match?({:ok, _}, &1))
        assert Repo.aggregate(from(s in Season, where: s.league_id == ^league.id), :count) == 1
        assert Repo.get!(Season, season.id) == season

        code = unique_code("DUPE")
        name = unique_code("Duplicate Team ")

        team_results =
          race(context, fn ->
            Catalog.create_team(%{season_id: season.id, code: " #{code} ", name: " #{name} "})
          end)

        {:ok, team} = Enum.find(team_results, &match?({:ok, _}, &1))
        assert Repo.aggregate(from(t in Team, where: t.season_id == ^season.id), :count) == 1
        assert Repo.get!(Team, team.id) == team
      end)
    end

    test "concurrent player identity writes preserve one original record", context do
      Sandbox.unboxed_run(Repo, fn ->
        league =
          Repo.get_by(League, code: "PL") ||
            own(context, elem(Catalog.create_league(league_attrs()), 1))

        year =
          (Repo.one(from s in Season, where: s.league_id == ^league.id, select: max(s.end_year)) ||
             2029) + 1

        {:ok, season} =
          Catalog.create_season(season_attrs(league, %{start_year: year, end_year: year + 1}))

        own(context, season)
        {:ok, team} = Catalog.create_team(team_attrs(season))
        own(context, team)

        code = unique_code("RACE")
        name = unique_code("Race Position ")

        position_results =
          race(context, fn -> Catalog.create_position(%{code: " #{code} ", name: " #{name} "}) end)

        {:ok, position} = Enum.find(position_results, &match?({:ok, _}, &1))
        assert Repo.get!(Position, position.id) == position
        assert Repo.aggregate(from(p in Position, where: p.code == ^code), :count) == 1

        attrs =
          player_attrs(team, position, %{
            catalog_identity: "race-player",
            display_name: "Race Player"
          })

        results = race(context, fn -> Catalog.create_player(attrs) end)
        {:ok, player} = Enum.find(results, &match?({:ok, _}, &1))
        assert Repo.aggregate(from(p in Player, where: p.season_id == ^season.id), :count) == 1

        assert Repo.get!(Player, player.id) |> Repo.preload(team: [season: :league], position: []) ==
                 player

        assert player.catalog_identity == attrs.catalog_identity
        assert player.display_name == attrs.display_name
        assert player.team_id == team.id
        assert player.position_id == position.id
      end)
    end
  else
    test "default suite executes both committed Catalog races" do
      env = [
        {"MIX_TEST_PARTITION", "catalog_concurrency"},
        {"CP1_PROFILE", nil},
        {"CP1_PROFILE_COVERAGE", nil},
        {"CP1_PROFILE_RECEIPT", nil},
        {"CP1_PROFILE_SENTINEL_PATH", nil}
      ]

      {out, status} =
        System.cmd("mix", ["test", __ENV__.file, "--warnings-as-errors"],
          env: env,
          stderr_to_stdout: true
        )

      assert status == 0, String.slice(out, -4000, 4000)
      assert Regex.match?(~r/Result: 6 passed/, out), out
      refute String.contains?(out, "Failed:")
    end
  end
end
