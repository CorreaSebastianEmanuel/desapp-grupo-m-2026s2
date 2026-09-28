defmodule FootballMarketWeb.PlayerCatalogSecurityTest do
  use FootballMarket.DataCase, async: false
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
    Logger.configure(level: :debug)
    on_exit(fn -> Logger.configure(level: previous_level) end)

    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)

    anchor_name = "private-cursor-anchor-#{System.unique_integer([:positive])}"
    %{players: [anchor, _later]} = insert_catalog!([anchor_name, "zzzz-later-player"])
    conn = build_conn() |> put_req_header("x-api-key", key.secret)

    first = conn |> get("/api/players?page_size=1") |> json_response(200)
    cursor = first["pagination"]["next_cursor"]

    log =
      capture_log([level: :debug], fn ->
        assert conn
               |> recycle()
               |> put_req_header("x-api-key", key.secret)
               |> get("/api/players?page_size=1&cursor=#{URI.encode_www_form(cursor)}")
               |> json_response(200)
      end)

    refute log =~ cursor
    refute log =~ anchor_name
    refute log =~ anchor.id
  end
end
