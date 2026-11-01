defmodule FootballMarketWeb.PlayerFreshnessTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  alias FootballMarket.{Accounts, FreshnessCase, Repo}
  alias FootballMarket.Synchronization.Run
  @endpoint FootballMarketWeb.Endpoint

  setup do
    fixture = FreshnessCase.fixture()
    {:ok, user} = Accounts.register_user(FootballMarket.AccountsCase.registration_attrs())
    {:ok, jwt} = Accounts.Authentication.issue(user.id)
    {:ok, key} = Accounts.issue_api_key(user.id)
    {:ok, Map.merge(fixture, %{jwt: jwt, key: key.secret})}
  end

  test "authenticated detail appends status while list reads never enqueue", f do
    conn = build_conn() |> put_req_header("authorization", "Bearer " <> f.jwt)
    list = conn |> get("/api/players") |> json_response(200)
    assert Map.keys(list) |> Enum.sort() == ~w(data pagination)
    assert Repo.aggregate(Run, :count) == 0

    shown =
      conn
      |> get(
        "/api/players/#{f.player.id}?source_ref=attacker&ttl_seconds=1&policy[attempt_limit]=100"
      )
      |> json_response(200)

    assert Map.keys(shown) |> Enum.sort() == ~w(data statistics statistics_status)
    assert shown["data"] == hd(list["data"])
    assert shown["statistics_status"]["refresh"]["state"] == "queued"
    assert shown["statistics_status"]["valuation"]["last_quoted_at"] == nil
    assert shown["statistics_status"]["valuation"]["current_quote"] == nil
    assert shown["statistics_status"]["last_checked_at"] == nil
    assert shown["statistics_status"]["ttl_seconds"] == 86_400
    assert Repo.one!(Run).source_ref == "freshness-fixture"
    assert Repo.one!(Run).policy["attempt_limit"] == 3

    key_result =
      build_conn()
      |> put_req_header("x-api-key", f.key)
      |> get("/api/players/#{f.player.id}")
      |> json_response(200)

    assert key_result == shown
    assert Repo.aggregate(Run, :count) == 1
    refute Jason.encode!(shown) =~ "source_identity"
    refute Jason.encode!(shown) =~ "freshness-fixture"
  end

  test "player freshness includes the latest persisted quote timestamp", f do
    effective_at = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    Repo.insert!(%FootballMarket.Market.Quote{
      player_id: f.player.id,
      unit_price: Decimal.new("1"),
      effective_at: effective_at,
      inserted_at: effective_at,
      rule_id: "initial_issuance",
      rule_version: "1"
    })

    body =
      build_conn()
      |> put_req_header("x-api-key", f.key)
      |> get("/api/players/#{f.player.id}")
      |> json_response(200)

    assert body["statistics_status"]["valuation"]["last_quoted_at"] ==
             DateTime.to_iso8601(effective_at)

    assert body["statistics_status"]["valuation"]["current_quote"] == "1.00"
  end

  test "authentication and player lookup reject before freshness admission", f do
    assert build_conn() |> get("/api/players/#{f.player.id}") |> json_response(401)

    Repo.insert!(%FootballMarket.Catalog.Player{
      id: Ecto.UUID.cast!("abcdefghijklmnop"),
      team_id: f.player.team_id,
      season_id: f.player.season_id,
      position_id: f.player.position_id,
      catalog_identity: "binary-identity-probe",
      display_name: "Binary Identity Probe"
    })

    for id <- ["bad", Ecto.UUID.generate(), "abcdefghijklmnop"] do
      assert build_conn()
             |> put_req_header("x-api-key", f.key)
             |> get("/api/players/#{id}")
             |> json_response(404) ==
               %{"error" => %{"code" => "player_not_found"}}
    end

    assert Repo.aggregate(Run, :count) == 0
  end

  test "catalog storage failure maps to 503 without replacing it with a missing player", f do
    previous = Repo.put_dynamic_repo(:MissingFreshnessRepo)

    try do
      result =
        FootballMarketWeb.PlayerController.show(build_conn(), %{"player_id" => f.player.id})

      assert json_response(result, 503) == %{"error" => %{"code" => "temporarily_unavailable"}}
    after
      Repo.put_dynamic_repo(previous)
    end
  end

  test "missing source configuration returns local data and explicit unavailable refresh", f do
    FreshnessCase.config(:refresh_options_by_scope, %{})

    body =
      build_conn()
      |> put_req_header("x-api-key", f.key)
      |> get("/api/players/#{f.player.id}")
      |> json_response(200)

    assert body["data"]["id"] == f.player.id
    assert body["statistics_status"]["refresh"]["state"] == "unconfigured"
    assert Repo.aggregate(Run, :count) == 0
  end
end
