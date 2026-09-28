defmodule FootballMarketWeb.PlayerDetailControllerTest do
  use FootballMarket.DataCase, async: false
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.CatalogCase
  import FootballMarket.AccountsCase
  @endpoint FootballMarketWeb.Endpoint

  test "JWT detail lookup returns the authoritative hierarchy" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(user.id)
    %{players: [player], league: league} = insert_catalog!()

    body =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> token)
      |> get("/api/players/#{player.id}")
      |> json_response(200)

    assert body["data"]["league"]["id"] == league.id
    assert body["data"]["season"]["id"] == player.team.season.id
  end

  test "API-key lookup and malformed/absent identities use the shared contract" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)
    %{players: [player]} = insert_catalog!()
    conn = build_conn() |> put_req_header("x-api-key", key.secret)

    assert %{"data" => %{"id" => id}} =
             conn |> get("/api/players/#{player.id}") |> json_response(200)

    assert id == player.id
    expected = %{"error" => %{"code" => "player_not_found"}}
    assert conn |> get("/api/players/not-a-uuid") |> json_response(404) == expected
    assert conn |> get("/api/players/#{Ecto.UUID.generate()}") |> json_response(404) == expected
  end
end
