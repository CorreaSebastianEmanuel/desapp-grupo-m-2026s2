defmodule FootballMarketWeb.TransactionControllerTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  alias FootballMarket.Market.ConditionalOrders

  alias FootballMarket.{
    Accounts,
    ConditionalOrdersCase,
    PurchasesCase,
    Repo,
    SalesCase
  }

  @endpoint FootballMarketWeb.Endpoint

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "10")

    {:ok, {:ok, key}} =
      FootballMarket.Repo.transaction(fn -> Accounts.issue_api_key(f.buyer.id) end)

    {:ok, {:ok, owner_key}} =
      FootballMarket.Repo.transaction(fn -> Accounts.issue_api_key(f.owner.id) end)

    f |> Map.put(:secret, key.secret) |> Map.put(:owner_secret, owner_key.secret)
  end

  test "authenticated history combines purchase and sale evidence in anchored cursor pages", f do
    assert {:ok, purchase} = PurchasesCase.purchase(f)
    assert {:ok, sale} = SalesCase.sale(f, "history-sale", 1)
    before = SalesCase.snapshot()

    first = request(f, "/api/transactions?page_size=1") |> json_response(200)

    assert first["pagination"] == %{
             "page_size" => 1,
             "returned_count" => 1,
             "has_more" => true,
             "next_cursor" => first["pagination"]["next_cursor"]
           }

    assert is_binary(first["pagination"]["next_cursor"])
    [head] = first["data"]
    assert head["id"] == sale.id
    assert head["type"] == "sale"
    assert head["unit_price"] == "1.00"
    assert head["total"] == "1.00"
    assert before == SalesCase.snapshot()

    # A newer operation appended after the first page must not shift the
    # anchored continuation page: it stays out of the anchored traversal.
    assert {:ok, appended_sale} = SalesCase.sale(f, "history-sale-appended", 1)
    assert appended_sale.id != sale.id
    after_appended = SalesCase.snapshot()

    next =
      request(
        f,
        "/api/transactions?page_size=1&cursor=#{URI.encode_www_form(first["pagination"]["next_cursor"])}"
      )
      |> json_response(200)

    assert [%{"id" => purchase_id, "type" => "purchase", "total" => "3.00"}] = next["data"]
    assert purchase_id == purchase.id
    assert purchase_id != appended_sale.id
    assert next["pagination"]["has_more"] == false
    assert next["pagination"]["next_cursor"] == nil
    assert after_appended == SalesCase.snapshot()

    fresh = request(f, "/api/transactions?page_size=25") |> json_response(200)
    assert hd(fresh["data"])["id"] == appended_sale.id
    assert Enum.count(fresh["data"]) == 3
  end

  test "history is actor-scoped, empty pages are complete, and malformed pagination rejects", f do
    assert {:ok, _} = PurchasesCase.purchase(f)
    assert {:ok, _} = SalesCase.sale(f, "scope-sale", 1)

    conn =
      build_conn()
      |> put_req_header("x-api-key", f.secret)
      |> get("/api/transactions?page_size=1")

    body = json_response(conn, 200)
    assert [%{"type" => "sale", "id" => _}] = body["data"]

    owner_body =
      build_conn()
      |> Plug.Conn.put_req_header("x-api-key", f.owner_secret)
      |> get("/api/transactions")
      |> json_response(200)

    assert owner_body["data"] == []

    assert owner_body["pagination"] == %{
             "page_size" => 25,
             "returned_count" => 0,
             "has_more" => false,
             "next_cursor" => nil
           }

    cursor = body["pagination"]["next_cursor"]

    assert build_conn()
           |> put_req_header("x-api-key", f.owner_secret)
           |> get("/api/transactions?cursor=#{URI.encode_www_form(cursor)}")
           |> json_response(400) == %{"error" => %{"code" => "invalid_cursor"}}

    assert json_response(build_conn() |> get("/api/transactions"), 401)["error"]["code"] ==
             "unauthenticated"

    assert request(f, "/api/transactions?page_size=101") |> json_response(400) == %{
             "error" => %{"code" => "invalid_page_size"}
           }

    assert request(f, "/api/transactions?page_size=1&page_size=2") |> json_response(400) == %{
             "error" => %{"code" => "invalid_page_size"}
           }

    assert request(f, "/api/transactions?cursor=bad") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }
  end

  test "conditional-order purchases appear exactly once with complete row evidence", f do
    order = ConditionalOrdersCase.order!(f)

    assert {:ok, %{status: "executed", execution: execution}} =
             ConditionalOrders.evaluate(order.id)

    body = request(f, "/api/transactions") |> json_response(200)

    assert [%{"id" => row_id, "type" => "purchase"}] = body["data"]
    assert row_id == execution.purchase_id
    player_id = f.player.id
    completed_at = DateTime.to_iso8601(execution.completed_at)
    quote_id = execution.quote_id
    assert is_binary(quote_id) and is_binary(completed_at)

    assert %{
             "id" => ^row_id,
             "type" => "purchase",
             "player_id" => ^player_id,
             "quantity" => 3,
             "unit_price" => "1.00",
             "total" => "3.00",
             "quote_id" => ^quote_id,
             "completed_at" => ^completed_at
           } = hd(body["data"])

    assert is_binary(completed_at) and is_binary(quote_id)
    assert SalesCase.snapshot() |> Map.get("market_sales") == []
  end

  test "same-instant operations keep deterministic type and id order across pages", f do
    assert {:ok, _} = PurchasesCase.purchase(f, "tie-purchase-one")
    assert {:ok, sale} = SalesCase.sale(f, "tie-sale", 1)
    assert {:ok, _} = PurchasesCase.purchase(f, "tie-purchase-two")
    instant = ~U[2026-10-27 10:00:00Z]

    Repo.query!("ALTER TABLE market_purchases DISABLE TRIGGER ALL")
    Repo.query!("ALTER TABLE market_sales DISABLE TRIGGER ALL")

    Repo.query!("UPDATE market_purchases SET completed_at=$1", [instant])
    Repo.query!("UPDATE market_sales SET completed_at=$1", [instant])

    # One row per page: the two equal-time purchases split at a page boundary
    # (same-type ID tie), then the sale follows by type order. Assert the exact
    # whole traversal with no omissions, duplicates or order shuffle.
    first_page = request(f, "/api/transactions?page_size=1") |> json_response(200)
    assert Enum.map(first_page["data"], & &1["type"]) == ["purchase"]
    assert is_binary(first_page["pagination"]["next_cursor"])

    second_page =
      request(
        f,
        "/api/transactions?page_size=1&cursor=#{URI.encode_www_form(first_page["pagination"]["next_cursor"])}"
      )
      |> json_response(200)

    assert Enum.map(second_page["data"], & &1["type"]) == ["purchase"]
    assert [a, b] = [hd(first_page["data"])["id"], hd(second_page["data"])["id"]]
    assert a < b

    third_page =
      request(
        f,
        "/api/transactions?page_size=1&cursor=#{URI.encode_www_form(second_page["pagination"]["next_cursor"])}"
      )
      |> json_response(200)

    assert Enum.map(third_page["data"], & &1["id"]) == [sale.id]
    assert Enum.map(third_page["data"], & &1["type"]) == ["sale"]
    assert third_page["pagination"]["has_more"] == false
    assert third_page["pagination"]["next_cursor"] == nil

    all_ids =
      for page <- [first_page, second_page, third_page], row <- page["data"] do
        row["id"] <> ":" <> row["type"]
      end

    assert all_ids == [a <> ":purchase", b <> ":purchase", sale.id <> ":sale"]
    assert a < b
  end

  test "structured, repeated and blank pagination inputs reject before any history access", f do
    assert {:ok, _} = PurchasesCase.purchase(f)

    for query <-
          ~w(page_size[]=5 cursor[]=x cursor=a&cursor=b cursor= page_size= page_size=abc page_size=0) do
      body = request(f, "/api/transactions?" <> query) |> json_response(400)

      assert body in [
               %{"error" => %{"code" => "invalid_page_size"}},
               %{"error" => %{"code" => "invalid_cursor"}}
             ]
    end

    assert request(f, "/api/transactions?page_size=1&page_size=2") |> json_response(400) == %{
             "error" => %{"code" => "invalid_page_size"}
           }

    response = request(f, "/api/transactions?page_size=100") |> json_response(200)
    assert response["pagination"]["page_size"] == 100
  end

  test "published OpenAPI includes protected history contract" do
    api = File.read!("priv/static/openapi.json") |> Jason.decode!()
    operation = api["paths"]["/api/transactions"]["get"]
    assert operation["security"] != []
    assert Map.has_key?(operation["responses"], "200")
    assert Map.has_key?(operation["responses"], "400")
  end

  defp request(f, path),
    do: build_conn() |> put_req_header("x-api-key", f.secret) |> get(path)
end
