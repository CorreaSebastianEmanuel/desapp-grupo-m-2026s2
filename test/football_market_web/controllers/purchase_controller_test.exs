defmodule FootballMarketWeb.PurchaseControllerTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  alias FootballMarket.{Accounts, PurchasesCase}
  @endpoint FootballMarketWeb.Endpoint

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "10")

    {:ok, {:ok, key}} =
      FootballMarket.Repo.transaction(fn -> Accounts.issue_api_key(f.buyer.id) end)

    Map.put(f, :secret, key.secret)
  end

  test "protected exact response, replay and conflict", f do
    original = request(f, PurchasesCase.request(f)) |> json_response(200)

    assert Map.keys(original["data"]) |> Enum.sort() ==
             Enum.sort(
               ~w(id buyer_id recipient_id player_id quantity quote_id unit_price total request_key quote_effective_at rule_id rule_version configuration_version_id mapping_id performance_sequence completed_at)
             )

    assert original["data"]["total"] == "3.00"
    assert original["data"]["buyer_id"] == f.buyer.id
    assert request(f, PurchasesCase.request(f)) |> json_response(200) == original

    assert request(f, PurchasesCase.request(f, "purchase-key", 4)) |> json_response(409) == %{
             "error" => %{"code" => "key_conflict"}
           }
  end

  test "rejects authority overrides, invalid JSON quantities and unauthenticated calls", f do
    before = PurchasesCase.snapshot()

    for field <- [:buyer_id, :recipient_id, :unit_price, :price, :total, :quote_id] do
      assert request(f, Map.put(PurchasesCase.request(f), field, f.owner.id))
             |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}
    end

    for quantity <- [0, -1, 1.0, "1", nil] do
      assert request(f, %{PurchasesCase.request(f) | quantity: quantity}) |> json_response(400) ==
               %{"error" => %{"code" => "invalid_request"}}
    end

    assert request(f, %{PurchasesCase.request(f) | request_key: "nul\0key"})
           |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}

    conn = build_conn() |> post("/api/purchases", PurchasesCase.request(f))
    assert json_response(conn, 401) == %{"error" => %{"code" => "unauthenticated"}}
    assert get_resp_header(conn, "www-authenticate") == [~s(Bearer realm="api")]
    assert before == PurchasesCase.snapshot()
  end

  test "JWT identity is the buyer", f do
    {:ok, login} = Accounts.login(%{email: f.buyer.email, password: "market-fixture-password"})

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> login.access_token)
      |> put_req_header("content-type", "application/json")
      |> post("/api/purchases", Jason.encode!(PurchasesCase.request(f)))

    assert json_response(conn, 200)["data"]["buyer_id"] == f.buyer.id
  end

  test "web adapter delegates all financial persistence and OpenAPI matches contract" do
    source = File.read!("lib/football_market_web/controllers/purchase_controller.ex")
    refute source =~ "Repo"
    refute source =~ "Decimal"
    api = File.read!("priv/static/openapi.json") |> Jason.decode!()
    operation = api["paths"]["/api/purchases"]["post"]
    assert operation["security"] != []
    assert Map.has_key?(operation["responses"], "200")
    assert Map.has_key?(operation["responses"], "409")
  end

  defp request(f, input),
    do:
      build_conn()
      |> put_req_header("x-api-key", f.secret)
      |> put_req_header("content-type", "application/json")
      |> post("/api/purchases", Jason.encode!(input))
end
