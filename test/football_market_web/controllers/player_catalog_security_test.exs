defmodule FootballMarketWeb.PlayerCatalogSecurityTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  import ExUnit.CaptureLog
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.CatalogCase
  import FootballMarket.AccountsCase
  @endpoint FootballMarketWeb.Endpoint

  test "all list and detail outcomes are satisfied by local persistence" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)
    %{players: [player, _second]} = insert_catalog!(["Alpha", "Beta"])
    conn = build_conn() |> put_req_header("x-api-key", key.secret)

    first = conn |> get("/api/players?page_size=1") |> json_response(200)
    assert first["data"] != []

    assert conn
           |> get(
             "/api/players?page_size=1&cursor=#{URI.encode_www_form(first["pagination"]["next_cursor"])}"
           )
           |> json_response(200)
           |> get_in(["pagination", "has_more"]) == false

    assert conn |> get("/api/players/#{player.id}") |> json_response(200) |> Map.has_key?("data")

    assert conn |> get("/api/players/#{Ecto.UUID.generate()}") |> json_response(404) == %{
             "error" => %{"code" => "player_not_found"}
           }
  end

  test "an empty local catalog succeeds without fallback" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)

    body =
      build_conn()
      |> put_req_header("x-api-key", key.secret)
      |> get("/api/players")
      |> json_response(200)

    assert body == %{
             "data" => [],
             "pagination" => %{
               "page_size" => 25,
               "returned_count" => 0,
               "has_more" => false,
               "next_cursor" => nil
             }
           }
  end

  test "continuation requests redact the cursor and decoded anchor from logs" do
    previous_level = Logger.level()

    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)

    anchor_name = "private-cursor-anchor-#{System.unique_integer([:positive])}"
    %{players: [anchor, _later]} = insert_catalog!([anchor_name, "zzzz-later-player"])
    conn = build_conn() |> put_req_header("x-api-key", key.secret)

    first = conn |> get("/api/players?page_size=1") |> json_response(200)
    cursor = first["pagination"]["next_cursor"]

    log =
      capture_debug_log(fn ->
        assert conn
               |> recycle()
               |> put_req_header("x-api-key", key.secret)
               |> get("/api/players?page_size=1&cursor=#{URI.encode_www_form(cursor)}")
               |> json_response(200)
      end)

    refute log =~ cursor
    refute log =~ anchor_name
    refute log =~ anchor.id
    assert Logger.level() == previous_level
  end

  test "filtered continuation keeps cursor and anchor out of logs" do
    previous_level = Logger.level()

    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)
    name = "filtered-private-anchor-#{System.unique_integer([:positive])}"
    %{team: team, players: [anchor, _]} = insert_catalog!([name, "zzzz-filtered-later"])
    conn = build_conn() |> put_req_header("x-api-key", key.secret)
    first = conn |> get("/api/players?team_id=#{team.id}&page_size=1") |> json_response(200)
    cursor = first["pagination"]["next_cursor"]

    log =
      capture_debug_log(fn ->
        assert conn
               |> recycle()
               |> put_req_header("x-api-key", key.secret)
               |> get(
                 "/api/players?team_id=#{team.id}&page_size=1&cursor=#{URI.encode_www_form(cursor)}"
               )
               |> json_response(200)
      end)

    refute log =~ cursor
    refute log =~ name
    refute log =~ anchor.id
    assert Logger.level() == previous_level
  end

  test "filtered pages never call the Redis cache adapter" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)
    %{team: team} = insert_catalog!()
    conn = build_conn() |> put_req_header("x-api-key", key.secret)

    :erlang.trace_pattern({Redix, :command, :_}, true, [])
    :erlang.trace_pattern({Redix, :command!, :_}, true, [])
    :erlang.trace(self(), true, [:call])

    on_exit(fn ->
      :erlang.trace(self(), false, [:call])
      :erlang.trace_pattern({Redix, :command, :_}, false, [])
      :erlang.trace_pattern({Redix, :command!, :_}, false, [])
    end)

    assert conn
           |> get("/api/players?team_id=#{team.id}")
           |> json_response(200)
           |> get_in(["pagination", "returned_count"]) == 1

    refute_receive {:trace, _, :call, {Redix, _, _}}
  end

  defp capture_debug_log(fun) do
    previous_level = Logger.level()

    capture_log([level: :debug], fn ->
      Logger.configure(level: :debug)

      try do
        fun.()
      after
        Logger.configure(level: previous_level)
      end
    end)
  end
end
