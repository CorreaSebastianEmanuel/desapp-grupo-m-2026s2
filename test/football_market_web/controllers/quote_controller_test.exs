defmodule FootballMarketWeb.QuoteControllerTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn

  alias FootballMarket.{Accounts, QuotesCase, ValuationConfigurationCase}
  @endpoint FootballMarketWeb.Endpoint
  @fields ~w(id player_id unit_price effective_at inserted_at rule_id rule_version calculation_id configuration_version_id mapping_id performance_sequence)

  setup do
    ValuationConfigurationCase.private_schema()
    fixture = QuotesCase.fixture()
    {:ok, jwt} = Accounts.Authentication.issue(fixture.user.id)
    {:ok, {:ok, key}} = Repo.transaction(fn -> Accounts.issue_api_key(fixture.user.id) end)
    {:ok, Map.merge(fixture, %{jwt: jwt, api_key: key.secret})}
  end

  test "both credentials access exact issuance and history representations", f do
    for {header, value} <- [{"authorization", "Bearer " <> f.jwt}, {"x-api-key", f.api_key}] do
      conn = build_conn() |> put_req_header(header, value)
      current = conn |> get(path(f, "current")) |> json_response(200)
      quote = current["data"]
      assert Map.keys(current) == ["data"]
      assert Enum.sort(Map.keys(quote)) == Enum.sort(@fields)
      assert quote["id"] == f.issuance.initial_quote_id
      assert quote["unit_price"] == "1.00"
      assert quote["rule_id"] == "initial_issuance"

      for field <- ~w(calculation_id configuration_version_id mapping_id performance_sequence),
          do: assert(quote[field] == nil)

      assert {:ok, _, 0} = DateTime.from_iso8601(quote["effective_at"])
      assert {:ok, _, 0} = DateTime.from_iso8601(quote["inserted_at"])
      assert conn |> get(path(f, "history")) |> json_response(200) == %{"data" => [quote]}
      date = DateTime.to_date(f.issuance.effective_at)
      assert conn |> get(path(f, "at?date=#{date}")) |> json_response(200) == current
    end
  end

  test "dated API carries forward exact quote metadata and never changes local state", f do
    first = QuotesCase.dated_quote(f, ~U[2028-02-28 23:59:59.999999Z], "12345678901234567890.12")
    second = QuotesCase.dated_quote(f, ~U[2028-03-02 00:00:00.000000Z], "2.50")
    before = QuotesCase.protected_snapshot()
    provider_env = Application.get_env(:football_market, FootballMarket.Providers)
    Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)

    on_exit(fn ->
      Application.put_env(:football_market, FootballMarket.Providers, provider_env)
    end)

    conn = auth(f)
    body = conn |> get(path(f, "at?date=2028-02-29&ignored=value")) |> json_response(200)
    assert body["data"]["id"] == first.id
    assert body["data"]["unit_price"] == "12345678901234567890.12"
    assert body["data"]["effective_at"] == "2028-02-28T23:59:59.999999Z"
    assert body["data"]["calculation_id"] == first.calculation_id
    assert body["data"]["configuration_version_id"] == f.configuration.id
    assert body["data"]["mapping_id"] == f.mapping.id
    assert body["data"]["rule_version"] == f.configuration.formula_version
    assert body["data"]["performance_sequence"] == 1

    assert conn |> get(path(f, "current")) |> json_response(200) |> get_in(["data", "id"]) ==
             second.id

    assert conn |> get(path(f, "history")) |> json_response(200) |> get_in(["data"]) |> length() ==
             3

    assert QuotesCase.protected_snapshot() == before
  end

  test "strict date parsing rejects ambiguous input before player lookup", f do
    for query <- [
          "",
          "date=",
          "date=2027-02-29",
          "date=2028-2-29",
          "date=2028-02-30",
          "date=2028-02-29T00:00:00Z",
          "date=%202028-02-29",
          "date=2028-02-29%20",
          "date=2028-02-29&date=2028-02-29",
          "date[]=2028-02-29",
          "date[x]=2028-02-29",
          "date=2028-02-29&date[]=2028-02-29",
          "date=+2028-02-29"
        ] do
      assert auth(f) |> get("/api/players/bad/quotes/at?" <> query) |> json_response(400) ==
               %{"error" => %{"code" => "invalid_date"}}
    end
  end

  test "missing players and quotes distinguish empty history from missing single results", f do
    for id <- ["bad", Ecto.UUID.generate()],
        route <- ["current", "history", "at?date=2028-02-29"] do
      assert auth(f) |> get("/api/players/#{id}/quotes/#{route}") |> json_response(404) ==
               %{"error" => %{"code" => "player_not_found"}}
    end

    other = Enum.at(f.base.players, 1)

    assert auth(f) |> get("/api/players/#{other.id}/quotes/history") |> json_response(200) == %{
             "data" => []
           }

    for url <- [
          path(f, "at?date=0000-01-01"),
          "/api/players/#{other.id}/quotes/current",
          "/api/players/#{other.id}/quotes/at?date=9999-12-31"
        ] do
      assert auth(f) |> get(url) |> json_response(404) == %{
               "error" => %{"code" => "quote_not_found"}
             }
    end
  end

  test "authentication precedes validation and refuses invalid or mixed credentials", f do
    for route <- ["current", "history", "at?date=bad"],
        conn <- [
          build_conn(),
          build_conn() |> put_req_header("authorization", "Bearer bad"),
          auth(f) |> put_req_header("x-api-key", f.api_key)
        ] do
      conn = conn |> get("/api/players/bad/quotes/#{route}")
      assert json_response(conn, 401) == %{"error" => %{"code" => "unauthenticated"}}
      assert get_resp_header(conn, "www-authenticate") == ["Bearer realm=\"api\""]
    end
  end

  test "malformed binary-compatible UUID text cannot resolve an existing player", f do
    malformed = "abcdefghijklmnop"
    {:ok, uuid} = Ecto.UUID.cast(malformed)

    Repo.insert!(%FootballMarket.Catalog.Player{
      id: uuid,
      team_id: f.player.team_id,
      season_id: f.player.season_id,
      position_id: f.player.position_id,
      catalog_identity: "ascii-id-probe",
      display_name: "ASCII ID"
    })

    assert {:ok, []} = FootballMarket.Quotes.list_history(uuid)

    for route <- ["current", "history", "at?date=9999-12-31"] do
      assert auth(f) |> get("/api/players/#{malformed}/quotes/#{route}") |> json_response(404) ==
               %{"error" => %{"code" => "player_not_found"}}
    end
  end

  test "controller maps storage failure to a documented service unavailable response", f do
    previous = Repo.put_dynamic_repo(:task027_unavailable_repo)

    try do
      for action <- [:current, :history, :at] do
        conn = %{build_conn() | query_string: "date=2028-02-29"}

        result =
          apply(FootballMarketWeb.QuoteController, action, [conn, %{"player_id" => f.player.id}])

        assert json_response(result, 503) == %{"error" => %{"code" => "temporarily_unavailable"}}
      end
    after
      Repo.put_dynamic_repo(previous)
    end
  end

  defp path(f, suffix), do: "/api/players/#{f.player.id}/quotes/#{suffix}"
  defp auth(f), do: build_conn() |> put_req_header("authorization", "Bearer " <> f.jwt)
end
