defmodule FootballMarketWeb.ConditionalOrderControllerTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  alias FootballMarket.{Accounts, Repo}
  alias FootballMarket.ConditionalOrdersCase, as: C
  @endpoint FootballMarketWeb.Endpoint
  @path "/api/conditional-orders"
  setup do
    f = C.fixture()
    {:ok, {:ok, key}} = Repo.transaction(fn -> Accounts.issue_api_key(f.buyer.id) end)
    Map.put(f, :secret, key.secret)
  end

  test "authenticated create list detail exact terms location and pure owner reads", f do
    before = FootballMarket.PurchasesCase.snapshot()
    conn = request(f, :post, @path, terms(f))
    data = json_response(conn, 201)["data"]
    assert get_resp_header(conn, "location") == [@path <> "/" <> data["id"]]
    assert data["maximum_unit_price"] == "1.00"
    assert data["status"] == "pending" and data["expiry_reached"] == false

    assert Map.keys(data) |> Enum.sort() ==
             Enum.sort(
               ~w(id player_id quantity maximum_unit_price created_at expires_at status expiry_reached completed_at rejection_reason execution)
             )

    assert before == FootballMarket.PurchasesCase.snapshot()
    snapshot = C.snapshot()
    assert json_response(request(f, :get, @path), 200)["data"] == [data]
    assert json_response(request(f, :get, @path <> "/" <> data["id"]), 200)["data"] == data
    assert snapshot == C.snapshot()
  end

  test "safe validation authentication anti enumeration and unavailable storage", f do
    before = C.snapshot()

    for bad <- [
          Map.put(terms(f), :owner_id, f.owner.id),
          Map.delete(terms(f), :expires_at),
          %{terms(f) | quantity: 0},
          %{terms(f) | maximum_unit_price: 1.0}
        ] do
      assert json_response(request(f, :post, @path, bad), 400) == %{
               "error" => %{"code" => "invalid_request"}
             }
    end

    assert json_response(request(f, :post, @path, %{terms(f) | player_id: f.other.id}), 409)[
             "error"
           ]["code"] == "not_initialized"

    assert json_response(
             request(f, :post, @path, %{terms(f) | player_id: Ecto.UUID.generate()}),
             404
           )["error"]["code"] == "player_not_found"

    conn = build_conn() |> get(@path)
    assert json_response(conn, 401)["error"]["code"] == "unauthenticated"
    assert get_resp_header(conn, "www-authenticate") == [~s(Bearer realm="api")]
    assert before == C.snapshot()
    o = C.order!(f)
    {:ok, {:ok, key}} = Repo.transaction(fn -> Accounts.issue_api_key(f.owner.id) end)
    other = %{f | secret: key.secret}

    for id <- [o.id, Ecto.UUID.generate(), "bad"] do
      assert json_response(request(other, :get, @path <> "/" <> id), 404) == %{
               "error" => %{"code" => "not_found"}
             }
    end

    assert json_response(request(f, :get, @path <> "?owner_id=x"), 400)["error"]["code"] ==
             "invalid_request"

    Repo.query!("ALTER TABLE market_conditional_buy_orders RENAME TO unavailable_orders")

    try do
      assert json_response(request(f, :get, @path), 503)["error"]["code"] ==
               "temporarily_unavailable"
    after
      Repo.query!("ALTER TABLE unavailable_orders RENAME TO market_conditional_buy_orders")
    end
  end

  test "GET terminal expiry execution and rejection retains immutable linked facts", f do
    for status <- ["expired", "executed", "rejected"] do
      o = C.order!(f)
      if status == "expired", do: C.due!(o)
      if status == "rejected", do: FootballMarket.PurchasesCase.fund(f.buyer, "0")
      assert {:ok, result} = FootballMarket.Market.ConditionalOrders.evaluate(o.id)
      assert result.status == status
      before = C.snapshot()
      data = json_response(request(f, :get, @path <> "/" <> o.id), 200)["data"]
      assert data["status"] == status
      assert data["expiry_reached"] == (status == "expired")
      if status == "executed", do: assert(data["execution"]["total"] == "3.00")
      if status == "rejected", do: assert(data["rejection_reason"] == "insufficient_funds")
      assert before == C.snapshot()
    end
  end

  test "cancel owner terminal repeat expiry ownership authentication terms and storage failure",
       f do
    o = C.order!(f)
    url = @path <> "/" <> o.id <> "/cancel"
    conn = build_conn() |> post(url, %{})
    assert json_response(conn, 401)["error"]["code"] == "unauthenticated"
    assert get_resp_header(conn, "www-authenticate") == [~s(Bearer realm="api")]
    before = C.snapshot()

    assert json_response(request(f, :post, url, %{quantity: 4}), 400)["error"]["code"] ==
             "invalid_request"

    {:ok, {:ok, key}} = Repo.transaction(fn -> Accounts.issue_api_key(f.owner.id) end)

    for id <- [o.id, "bad", Ecto.UUID.generate()] do
      assert json_response(
               request(%{f | secret: key.secret}, :post, @path <> "/" <> id <> "/cancel"),
               404
             ) == %{"error" => %{"code" => "not_found"}}
    end

    assert before == C.snapshot()
    data = json_response(request(f, :post, url), 200)["data"]
    assert data["status"] == "cancelled"
    assert json_response(request(f, :post, url), 200)["data"] == data

    for status <- ["expired", "executed", "rejected"] do
      next = C.order!(f)
      if status == "expired", do: C.due!(next)
      if status == "rejected", do: FootballMarket.PurchasesCase.fund(f.buyer, "0")
      if status != "expired", do: FootballMarket.Market.ConditionalOrders.evaluate(next.id)

      assert json_response(request(f, :post, @path <> "/" <> next.id <> "/cancel"), 200)["data"][
               "status"
             ] == status
    end

    Repo.query!("ALTER TABLE market_conditional_buy_orders RENAME TO unavailable_orders")

    try do
      assert json_response(request(f, :post, url), 503)["error"]["code"] ==
               "temporarily_unavailable"
    after
      Repo.query!("ALTER TABLE unavailable_orders RENAME TO market_conditional_buy_orders")
    end
  end

  def terms(f), do: C.terms(f) |> Map.update!(:expires_at, &DateTime.to_iso8601/1)

  def request(f, method, path, body \\ %{}) do
    conn =
      build_conn()
      |> put_req_header("x-api-key", f.secret)
      |> put_req_header("content-type", "application/json")

    dispatch(
      conn,
      @endpoint,
      method,
      path,
      if(method == :get, do: nil, else: Jason.encode!(body))
    )
  end
end
