defmodule FootballMarketWeb.SaleControllerTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  alias FootballMarket.{Accounts, Repo, SalesCase}
  @endpoint FootballMarketWeb.Endpoint

  setup do
    fixture = SalesCase.fixture()

    {:ok, {:ok, key}} =
      Repo.transaction(fn -> Accounts.issue_api_key(fixture.buyer.id) end)

    Map.put(fixture, :secret, key.secret)
  end

  test "protected exact response replay and conflict", fixture do
    original = request(fixture, SalesCase.request(fixture)) |> json_response(200)

    assert Map.keys(original["data"]) |> Enum.sort() ==
             Enum.sort(
               ~w(id seller_id recipient_id player_id quantity quote_id unit_price total request_key quote_effective_at rule_id rule_version configuration_version_id mapping_id performance_sequence completed_at)
             )

    assert original["data"]["total"] == "3.00"
    assert original["data"]["seller_id"] == fixture.buyer.id
    assert request(fixture, SalesCase.request(fixture)) |> json_response(200) == original

    assert request(fixture, SalesCase.request(fixture, "sale-key", 2)) |> json_response(409) == %{
             "error" => %{"code" => "key_conflict"}
           }
  end

  test "rejects authority overrides invalid JSON and unauthenticated calls", fixture do
    before = SalesCase.snapshot()

    for field <- [:seller_id, :recipient_id, :unit_price, :price, :total, :quote_id] do
      assert request(fixture, Map.put(SalesCase.request(fixture), field, fixture.owner.id))
             |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}
    end

    for quantity <- [0, -1, 1.0, "1", nil] do
      assert request(fixture, %{SalesCase.request(fixture) | quantity: quantity})
             |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}
    end

    assert request(fixture, %{SalesCase.request(fixture) | request_key: "nul\0key"})
           |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}

    conn = build_conn() |> post("/api/sales", SalesCase.request(fixture))
    assert json_response(conn, 401) == %{"error" => %{"code" => "unauthenticated"}}
    assert get_resp_header(conn, "www-authenticate") == [~s(Bearer realm="api")]
    assert before == SalesCase.snapshot()
  end

  test "JWT identity is the seller", fixture do
    {:ok, login} =
      Accounts.login(%{email: fixture.buyer.email, password: "market-fixture-password"})

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> login.access_token)
      |> put_req_header("content-type", "application/json")
      |> post("/api/sales", Jason.encode!(SalesCase.request(fixture)))

    assert json_response(conn, 200)["data"]["seller_id"] == fixture.buyer.id
  end

  test "adapter has no financial persistence and OpenAPI publishes the route" do
    source = File.read!("lib/football_market_web/controllers/sale_controller.ex")
    refute source =~ "Repo"
    refute source =~ "Decimal"
    api = File.read!("priv/static/openapi.json") |> Jason.decode!()
    operation = api["paths"]["/api/sales"]["post"]
    assert operation["security"] != []
    assert Map.has_key?(operation["responses"], "200")
    assert Map.has_key?(operation["responses"], "409")
  end

  defp request(fixture, input) do
    build_conn()
    |> put_req_header("x-api-key", fixture.secret)
    |> put_req_header("content-type", "application/json")
    |> post("/api/sales", Jason.encode!(input))
  end
end
