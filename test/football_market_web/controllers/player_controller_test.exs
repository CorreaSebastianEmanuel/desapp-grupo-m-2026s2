defmodule FootballMarketWeb.PlayerControllerTest do
  use FootballMarket.DataCase, async: false
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.CatalogCase
  import FootballMarket.AccountsCase

  @endpoint FootballMarketWeb.Endpoint

  setup do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(user.id)
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)
    {:ok, token: token, key: key.secret}
  end

  test "list supports both credentials and exact envelope", %{token: token, key: key} do
    insert_catalog!(["B", "a"])

    Enum.each([{"authorization", "Bearer " <> token}, {"x-api-key", key}], fn {header, value} ->
      response =
        build_conn()
        |> put_req_header(header, value)
        |> get("/api/players?page_size=1")
        |> json_response(200)

      assert Map.keys(response) |> Enum.sort() == ["data", "pagination"]
      assert response["pagination"]["page_size"] == 1
      assert response["pagination"]["returned_count"] == 1
      assert response["pagination"]["has_more"]
      assert is_binary(response["pagination"]["next_cursor"])
      assert exact_player?(hd(response["data"]))
    end)
  end

  test "strict parameters, error precedence, duplicates, and unknowns", %{token: token} do
    conn = auth(token)

    for query <- [
          "page_size=0",
          "page_size=101",
          "page_size=1.0",
          "page_size=%201",
          "page_size=%2B1",
          "page_size=",
          "page_size=1&page_size=2",
          "page_size[]=1",
          "page_size[value]=1"
        ] do
      assert conn |> get("/api/players?" <> query) |> json_response(400) == %{
               "error" => %{"code" => "invalid_page_size"}
             }
    end

    assert conn |> get("/api/players?page_size=bad&cursor=bad") |> json_response(400) == %{
             "error" => %{"code" => "invalid_page_size"}
           }

    assert conn |> get("/api/players?cursor=") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }

    assert conn |> get("/api/players?cursor[]=value") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }

    assert conn |> get("/api/players?cursor=a&cursor=b") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }

    assert conn |> get("/api/players?cursor=bad") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }

    assert conn
           |> get("/api/players?unknown=value")
           |> json_response(200)
           |> Map.keys()
           |> Enum.sort() == ["data", "pagination"]
  end

  test "default, minimum, and maximum pages traverse more than 100 rows", %{token: token} do
    %{players: players} = insert_players!(105)
    conn = auth(token)

    default = conn |> get("/api/players") |> json_response(200)
    assert default["pagination"]["page_size"] == 25
    assert length(default["data"]) == 25

    minimum = conn |> get("/api/players?page_size=1") |> json_response(200)
    assert minimum["pagination"]["returned_count"] == 1

    ids = traverse(conn, "/api/players?page_size=100", [])
    assert length(ids) == 105
    assert MapSet.new(ids) == MapSet.new(players, & &1.id)
  end

  test "detail has shared exact representation and generic not found", %{key: key} do
    %{players: [player]} = insert_catalog!()
    conn = build_conn() |> put_req_header("x-api-key", key)
    assert %{"data" => data} = conn |> get("/api/players/#{player.id}") |> json_response(200)
    assert exact_player?(data)

    expected = %{"error" => %{"code" => "player_not_found"}}
    assert conn |> get("/api/players/malformed") |> json_response(404) == expected
    assert conn |> get("/api/players/#{Ecto.UUID.generate()}") |> json_response(404) == expected
  end

  test "authentication precedes pagination and lookup" do
    assert build_conn() |> get("/api/players?page_size=bad&cursor=bad") |> json_response(401) ==
             %{"error" => %{"code" => "unauthenticated"}}

    assert build_conn() |> get("/api/players/malformed") |> json_response(401) == %{
             "error" => %{"code" => "unauthenticated"}
           }
  end

  defp auth(token), do: build_conn() |> put_req_header("authorization", "Bearer " <> token)

  defp traverse(conn, path, ids) do
    body = conn |> recycle() |> get(path) |> json_response(200)
    accumulated = ids ++ Enum.map(body["data"], & &1["id"])

    case body["pagination"]["next_cursor"] do
      nil ->
        accumulated

      cursor ->
        traverse(
          conn,
          "/api/players?page_size=100&cursor=#{URI.encode_www_form(cursor)}",
          accumulated
        )
    end
  end

  defp exact_player?(data) do
    Map.keys(data) |> Enum.sort() ==
      ~w(catalog_identity display_name id league position season team) and
      Map.keys(data["position"]) |> Enum.sort() == ~w(code id name) and
      Map.keys(data["team"]) |> Enum.sort() == ~w(id name short_code) and
      Map.keys(data["season"]) |> Enum.sort() == ~w(end_year id start_year) and
      Map.keys(data["league"]) |> Enum.sort() == ~w(code id name)
  end
end
