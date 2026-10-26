defmodule FootballMarketWeb.RankingControllerTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  @endpoint FootballMarketWeb.Endpoint

  test "authenticated request returns exact active configuration and ranked quote" do
    f = FootballMarket.RankingCase.fixture()
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(f.user.id)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> token)
      |> get("/api/ranking")

    assert conn.status == 200
    assert get_resp_header(conn, "cache-control") == ["no-store"]
    body = json_response(conn, 200)
    assert body["configuration"]["configuration_version_id"] == f.configuration.id
    assert [entry] = body["data"]
    assert entry["player_id"] == f.player.id
    assert entry["quote_id"] == f.quote.id
    assert entry["unit_price"] == "1.25"
    assert entry["effective_at"] == DateTime.to_iso8601(f.quote.effective_at)
    assert entry["position"] == 1
    assert get_resp_header(conn, "content-type") |> hd() =~ "application/json"
  end

  test "authentication is enforced before ranking access" do
    _f = FootballMarket.RankingCase.fixture()

    assert build_conn() |> get("/api/ranking") |> json_response(401) == %{
             "error" => %{"code" => "unauthenticated"}
           }
  end

  test "an active configuration with no eligible quotes returns the exact empty contract" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(f.user.id)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> token)
      |> get("/api/ranking")

    assert conn.status == 200
    assert get_resp_header(conn, "cache-control") == ["no-store"]

    assert json_response(conn, 200) == %{
             "configuration" => %{
               "configuration_version_id" => f.configuration.id,
               "strategy_id" => f.configuration.strategy_id,
               "formula_version" => f.configuration.formula_version
             },
             "data" => []
           }
  end

  test "an absent active configuration returns a distinct safe conflict" do
    f = FootballMarket.RankingCase.fixture(active: false, quote: false)
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(f.user.id)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> token)
      |> get("/api/ranking")

    assert conn.status == 409
    assert get_resp_header(conn, "cache-control") == ["no-store"]
    assert json_response(conn, 409) == %{"error" => %{"code" => "no_active_configuration"}}
  end

  test "invalid credentials keep the existing challenge and error contract" do
    f = FootballMarket.RankingCase.fixture(quote: false)

    {:ok, {:ok, api_key}} =
      FootballMarket.Repo.transaction(fn -> FootballMarket.Accounts.issue_api_key(f.user.id) end)

    {:ok, :ok} =
      FootballMarket.Repo.transaction(fn ->
        FootballMarket.Accounts.revoke_api_key(f.user.id, api_key.id)
      end)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer invalid-token")
      |> get("/api/ranking")

    assert conn.status == 401
    assert get_resp_header(conn, "www-authenticate") == [~s(Bearer realm="api")]
    assert json_response(conn, 401) == %{"error" => %{"code" => "unauthenticated"}}

    assert build_conn() |> get("/api/ranking") |> json_response(401) == %{
             "error" => %{"code" => "unauthenticated"}
           }

    now = System.system_time(:second)

    expired =
      FootballMarket.AuthenticationHelpers.signed_token(%{
        "sub" => f.user.id,
        "jti" => Ecto.UUID.generate(),
        "iat" => now - 20,
        "exp" => now - 10,
        "iss" => "football-market-test",
        "aud" => "football-market-test-client"
      })

    assert build_conn()
           |> put_req_header("authorization", "Bearer " <> expired)
           |> get("/api/ranking")
           |> json_response(401) == %{"error" => %{"code" => "unauthenticated"}}

    assert build_conn()
           |> put_req_header("x-api-key", api_key.secret)
           |> get("/api/ranking")
           |> json_response(401) == %{"error" => %{"code" => "unauthenticated"}}
  end

  test "a missing selection anchor returns a sanitized storage-unavailable response" do
    f = FootballMarket.RankingCase.fixture(quote: false)
    {:ok, token} = FootballMarket.Accounts.Authentication.issue(f.user.id)

    FootballMarket.Repo.query!(
      "ALTER TABLE valuation_selection_locks RENAME TO valuation_selection_locks_unavailable"
    )

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> token)
      |> get("/api/ranking")

    assert conn.status == 503
    assert get_resp_header(conn, "cache-control") == ["no-store"]
    assert json_response(conn, 503) == %{"error" => %{"code" => "storage_unavailable"}}
  end
end
