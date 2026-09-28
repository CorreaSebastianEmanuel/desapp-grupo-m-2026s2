defmodule FootballMarketWeb.PlayerCatalogPerformanceTest do
  use FootballMarket.DataCase, async: false
  import Ecto.Query
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.AccountsCase

  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}
  alias FootballMarket.Repo

  @endpoint FootballMarketWeb.Endpoint
  @seed 12_012

  @tag :performance
  @tag timeout: :infinity
  @tag ownership_timeout: :infinity
  test "all twelve filtered page cases meet the two-second p95 gate" do
    fixture = seed_catalog!()
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(user.id)
    conn = build_conn() |> put_req_header("authorization", "Bearer " <> token)

    assert Repo.aggregate(Player, :count) == 100_000
    assert Repo.aggregate(League, :count) == 5
    assert Repo.aggregate(Season, :count) == 10
    assert Repo.aggregate(Team, :count) == 100
    assert Repo.aggregate(Position, :count) == 4

    IO.puts(
      "PLAYER_CATALOG_FIXTURE seed=#{@seed} leagues=5 seasons=10 teams=100 positions=4 players=100000"
    )

    league_id = hd(fixture.leagues).id
    team_id = hd(fixture.teams).id
    position_id = hd(fixture.positions).id

    cases = [
      {:league, %{league_id: league_id}, 20_000},
      {:position, %{position_id: position_id}, 25_000},
      {:team, %{team_id: team_id}, 1_000},
      {:league_position, %{league_id: league_id, position_id: position_id}, 5_000},
      {:team_position, %{team_id: team_id, position_id: position_id}, 250},
      {:league_team_position, %{league_id: league_id, team_id: team_id, position_id: position_id},
       250}
    ]

    for {name, filters, expected_count} <- cases do
      assert count_matches(filters) == expected_count
      query = Enum.map_join(filters, "&", fn {key, value} -> "#{key}=#{value}" end)
      first_path = "/api/players?page_size=100&#{query}"
      first = request(conn, first_path)
      assert length(first["data"]) == 100
      cursor = first["pagination"]["next_cursor"]
      assert is_binary(cursor)
      continuation_path = first_path <> "&cursor=#{URI.encode_www_form(cursor)}"

      for {page, path} <- [{:first, first_path}, {:continuation, continuation_path}] do
        Enum.each(1..10, fn _ -> request(conn, path) end)
        samples = Enum.map(1..100, fn _ -> timed_request(conn, path) end) |> Enum.sort()
        p95 = Enum.at(samples, 94) / 1_000_000

        IO.puts(
          "PLAYER_CATALOG_P95 #{name}_#{page}=#{Float.round(p95, 3)}ms matches=#{expected_count}"
        )

        if p95 > 2_000 do
          query_plan(filters, if(page == :first, do: nil, else: cursor))
        end

        assert p95 <= 2_000, "#{name} #{page} p95 was #{p95}ms"
      end
    end
  end

  defp seed_catalog! do
    now = DateTime.utc_now()

    leagues =
      FootballMarket.Catalog.supported_leagues()
      |> Enum.with_index(1)
      |> Enum.map(fn {{code, name}, index} ->
        %{id: uuid(index), code: code, name: name, inserted_at: now, updated_at: now}
      end)

    positions =
      ["GK", "DEF", "MID", "FWD"]
      |> Enum.with_index(11)
      |> Enum.map(fn {code, index} ->
        %{id: uuid(index), code: code, name: code, inserted_at: now, updated_at: now}
      end)

    seasons =
      for {league, league_index} <- Enum.with_index(leagues), season_index <- 0..1 do
        year = 2024 + season_index

        %{
          id: uuid(21 + league_index * 2 + season_index),
          league_id: league.id,
          start_year: year,
          end_year: year + 1,
          inserted_at: now,
          updated_at: now
        }
      end

    teams =
      for {season, season_index} <- Enum.with_index(seasons), team_index <- 0..9 do
        %{
          id: uuid(100 + season_index * 10 + team_index),
          season_id: season.id,
          code: "T#{team_index}",
          name: "Team #{team_index}",
          inserted_at: now,
          updated_at: now
        }
      end

    Repo.insert_all(League, leagues)
    Repo.insert_all(Position, positions)
    Repo.insert_all(Season, seasons)
    Repo.insert_all(Team, teams)

    teams
    |> Enum.with_index()
    |> Stream.flat_map(fn {team, team_index} ->
      season = Enum.find(seasons, &(&1.id == team.season_id))

      for player_index <- 0..999 do
        index = team_index * 1_000 + player_index

        %{
          id: uuid(1_000 + index),
          team_id: team.id,
          season_id: season.id,
          position_id: Enum.at(positions, rem(player_index, 4)).id,
          catalog_identity: "seed-#{@seed}-#{index}",
          display_name: "Player #{String.pad_leading(to_string(index), 6, "0")}",
          inserted_at: now,
          updated_at: now
        }
      end
    end)
    |> Stream.chunk_every(2_000)
    |> Enum.each(&Repo.insert_all(Player, &1))

    %{leagues: leagues, seasons: seasons, teams: teams, positions: positions}
  end

  defp count_matches(filters) do
    query =
      from player in Player,
        join: team in Team,
        on: team.id == player.team_id,
        join: season in Season,
        on: season.id == team.season_id

    query =
      Enum.reduce(filters, query, fn
        {:league_id, id}, query ->
          from [player, team, season] in query, where: season.league_id == ^id

        {:team_id, id}, query ->
          from [player, team, season] in query, where: team.id == ^id

        {:position_id, id}, query ->
          from [player, team, season] in query, where: player.position_id == ^id
      end)

    Repo.aggregate(query, :count)
  end

  defp query_plan(filters, cursor) do
    anchor =
      if cursor,
        do: elem(FootballMarket.Catalog.PlayerCursor.decode(cursor, filters), 1),
        else: nil

    query = FootballMarket.Catalog.Query.player_page(anchor, 101, filters)
    {sql, params} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
    %{rows: rows} = Ecto.Adapters.SQL.query!(Repo, "EXPLAIN (ANALYZE, BUFFERS) " <> sql, params)
    IO.puts("PLAYER_CATALOG_SLOW_PLAN\n" <> (rows |> List.flatten() |> Enum.join("\n")))
  end

  defp uuid(index) do
    "00000000-0000-4000-8000-" <> (index |> Integer.to_string(16) |> String.pad_leading(12, "0"))
  end

  defp request(conn, path), do: conn |> recycle() |> get(path) |> json_response(200)

  defp timed_request(conn, path) do
    started = System.monotonic_time()
    request(conn, path)
    (System.monotonic_time() - started) |> System.convert_time_unit(:native, :nanosecond)
  end
end
