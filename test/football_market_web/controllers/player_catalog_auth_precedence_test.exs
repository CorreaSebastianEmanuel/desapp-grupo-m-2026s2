defmodule FootballMarketWeb.PlayerCatalogAuthPrecedenceTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.AccountsCase
  @endpoint FootballMarketWeb.Endpoint

  test "authenticated filter validation has fixed priority for both credentials" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(user.id)
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)

    for {header, credential} <- [{"authorization", "Bearer " <> token}, {"x-api-key", key.secret}] do
      conn = build_conn() |> put_req_header(header, credential)
      uuid = Ecto.UUID.generate()

      for {filter, code} <- [
            {"league_id", "invalid_league_id"},
            {"team_id", "invalid_team_id"},
            {"position_id", "invalid_position_id"}
          ],
          invalid <- [
            "",
            "bad",
            "%20#{uuid}",
            "#{uuid}%20",
            "#{uuid}&#{filter}=#{uuid}",
            "[x]=#{uuid}",
            "[]=#{uuid}"
          ] do
        query =
          if String.starts_with?(invalid, "["),
            do: "#{filter}#{invalid}",
            else: "#{filter}=#{invalid}"

        assert conn |> get("/api/players?#{query}") |> json_response(400) == %{
                 "error" => %{"code" => code}
               }
      end

      assert conn
             |> get("/api/players?page_size=bad&league_id=bad&cursor=bad")
             |> json_response(400) == %{"error" => %{"code" => "invalid_page_size"}}

      assert conn
             |> get("/api/players?league_id=bad&team_id=bad&cursor=bad")
             |> json_response(400) == %{"error" => %{"code" => "invalid_league_id"}}

      assert conn
             |> get("/api/players?team_id=bad&position_id=bad&cursor=bad")
             |> json_response(400) == %{"error" => %{"code" => "invalid_team_id"}}

      assert conn |> get("/api/players?position_id=bad&cursor=bad") |> json_response(400) == %{
               "error" => %{"code" => "invalid_position_id"}
             }
    end
  end

  test "cursor filter mismatch is rejected before catalog reads" do
    {:ok, user} = FootballMarket.Accounts.register_user(registration_attrs())
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(user.id)
    filter = %{team_id: Ecto.UUID.generate()}

    cursor =
      FootballMarket.Catalog.PlayerCursor.encode(
        %{name: "alice", id: Ecto.UUID.generate()},
        filter
      )

    FootballMarket.PlayerCatalogProbe.attach_query_probe(self())
    conn = build_conn() |> put_req_header("authorization", "Bearer " <> token)

    assert conn |> get("/api/players?cursor=#{cursor}") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }

    refute_receive {:catalog_query, _}
  end

  test "authentication wins over malformed filters" do
    FootballMarket.PlayerCatalogProbe.attach_query_probe(self())

    assert build_conn() |> get("/api/players?league_id=bad&team_id[]=bad") |> json_response(401) ==
             %{"error" => %{"code" => "unauthenticated"}}

    refute_receive {:catalog_query, _}
  end

  test "invalid authentication halts before validation and catalog queries" do
    FootballMarket.PlayerCatalogProbe.attach_query_probe(self())

    assert build_conn() |> get("/api/players?page_size=bad&cursor=bad") |> json_response(401) ==
             %{"error" => %{"code" => "unauthenticated"}}

    assert build_conn() |> get("/api/players/malformed") |> json_response(401) == %{
             "error" => %{"code" => "unauthenticated"}
           }

    refute_receive {:catalog_query, _}
  end
end
