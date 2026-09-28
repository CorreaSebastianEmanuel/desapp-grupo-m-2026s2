defmodule FootballMarketWeb.PlayerCatalogPerformanceTest do
  use FootballMarket.DataCase, async: false
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.CatalogCase
  import FootballMarket.AccountsCase
  @endpoint FootballMarketWeb.Endpoint

  @tag :performance
  @tag timeout: 300_000
  @tag ownership_timeout: 300_000
  test "reports p95 for first, continuation, and detail requests" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(user.id)
    %{team: team} = hierarchy = insert_hierarchy!()
    {:ok, position} = FootballMarket.Catalog.create_position(position_attrs())
    now = DateTime.utc_now()

    1..100_000
    |> Stream.chunk_every(2_000)
    |> Enum.each(fn range ->
      rows = Enum.map(range, &row(&1, team, hierarchy.season, position, now))
      FootballMarket.Repo.insert_all(FootballMarket.Catalog.Player, rows)
    end)

    conn = build_conn() |> put_req_header("authorization", "Bearer " <> token)
    first = conn |> get("/api/players?page_size=100") |> json_response(200)
    cursor = first["pagination"]["next_cursor"]
    player_id = hd(first["data"])["id"]

    cases = [
      first_page: "/api/players?page_size=100",
      continuation_page: "/api/players?page_size=100&cursor=#{URI.encode_www_form(cursor)}",
      detail: "/api/players/#{player_id}"
    ]

    Enum.each(cases, fn {name, path} ->
      Enum.each(1..10, fn _ -> request(conn, path) end)
      samples = Enum.map(1..100, fn _ -> timed_request(conn, path) end) |> Enum.sort()
      p95 = Enum.at(samples, 94) / 1_000_000
      IO.puts("PLAYER_CATALOG_P95 #{name}=#{Float.round(p95, 3)}ms")
      assert p95 >= 0
    end)
  end

  defp row(index, team, season, position, now) do
    %{
      id: Ecto.UUID.generate(),
      team_id: team.id,
      season_id: season.id,
      position_id: position.id,
      catalog_identity: "performance-#{index}",
      display_name: "Performance #{String.pad_leading(to_string(index), 6, "0")}",
      inserted_at: now,
      updated_at: now
    }
  end

  defp request(conn, path), do: conn |> recycle() |> get(path) |> json_response(200)

  defp timed_request(conn, path) do
    started = System.monotonic_time()
    request(conn, path)
    (System.monotonic_time() - started) |> System.convert_time_unit(:native, :nanosecond)
  end
end
