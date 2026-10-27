defmodule ConditionalOrdersHTTP do
  @moduledoc false
  import ExUnit.Assertions
  alias FootballMarket.{Accounts, Market, MarketCase, PurchasesCase, Repo}
  alias FootballMarket.ConditionalOrdersCase, as: C
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  alias FootballMarket.ConditionalOrders.RuntimeProbe
  @path "/api/conditional-orders"

  def run do
    Code.require_file("scripts/verify_conditional_orders_preflight.exs")
    {:ok, _} = Application.ensure_all_started(:inets)
    store = RuntimeProbe.owned_store!()
    original = Application.fetch_env!(:football_market, Repo)
    designation = Application.fetch_env(:football_market, :initial_issuance_recipients)

    try do
      Supervisor.terminate_child(FootballMarket.Supervisor, Repo)

      config =
        original
        |> Keyword.put(:pool, DBConnection.ConnectionPool)
        |> Keyword.put(:parameters, search_path: store.schema)

      Application.put_env(:football_market, Repo, config)
      {:ok, _} = Supervisor.restart_child(FootballMarket.Supervisor, Repo)
      assert Repo.query!("SELECT 1").rows == [[1]]
      f = MarketCase.fixture()
      {:ok, _} = Market.initialize_player(f.player.id)
      PurchasesCase.fund(f.buyer, "100")
      {:ok, {:ok, key}} = Repo.transaction(fn -> Accounts.issue_api_key(f.buyer.id) end)
      {:ok, {:ok, foreign}} = Repo.transaction(fn -> Accounts.issue_api_key(f.owner.id) end)

      {:ok, server} =
        Bandit.start_link(plug: FootballMarketWeb.Endpoint, ip: {127, 0, 0, 1}, port: 0)

      try do
        {:ok, {_, port}} = ThousandIsland.listener_info(server)
        base = "http://127.0.0.1:#{port}"

        RuntimeProbe.await(fn ->
          case :httpc.request(:get, {String.to_charlist(base <> @path), []}, [timeout: 500], []) do
            {:ok, {{_, 401, _}, _, _}} -> true
            _ -> false
          end
        end)

        journey(base, f, key.secret, foreign.secret)

        IO.puts(
          "CONDITIONAL_ORDERS_HTTP_PASS: real HTTP ownership/lifecycle/expiry and exact financial assertions"
        )
      after
        Supervisor.stop(server)
      end
    after
      Supervisor.terminate_child(FootballMarket.Supervisor, Repo)
      Application.put_env(:football_market, Repo, original)
      {:ok, _} = Supervisor.restart_child(FootballMarket.Supervisor, Repo)
      C.restore(designation)
      RuntimeProbe.destroy_store!(store)
    end
  end

  defp journey(base, f, key, foreign) do
    terms =
      C.terms(f, %{maximum_unit_price: "0.01"})
      |> Map.update!(:expires_at, &DateTime.to_iso8601/1)

    before = PurchasesCase.snapshot()
    {created, headers} = request(base, :post, @path, key, terms, 201)
    o = created["data"]
    url = @path <> "/" <> o["id"]
    assert {~c"location", String.to_charlist(url)} in headers
    assert o["status"] == "pending" and not o["expiry_reached"]
    assert o["maximum_unit_price"] == "0.01" and o["quantity"] == 3
    assert before == PurchasesCase.snapshot()
    snapshot = C.snapshot()
    assert elem(request(base, :get, url, key, nil, 200), 0) == created
    assert elem(request(base, :get, @path, key, nil, 200), 0)["data"] == [o]

    access_contract(base, f, key, foreign, terms, o, url)
    assert snapshot == C.snapshot()
    C.due!(%{id: o["id"]})
    snapshot = C.snapshot()
    {due, _} = request(base, :get, url, key, nil, 200)
    assert due["data"]["status"] == "pending" and due["data"]["expiry_reached"]
    assert elem(request(base, :get, @path, key, nil, 200), 0)["data"] == [due["data"]]
    assert snapshot == C.snapshot()
    assert {:ok, %{status: "expired"}} = Orders.evaluate(o["id"])
    snapshot = C.snapshot()
    assert elem(request(base, :get, url, key, nil, 200), 0)["data"]["status"] == "expired"
    assert snapshot == C.snapshot()
    cancel = C.order!(f)
    cancel_url = @path <> "/" <> cancel.id <> "/cancel"
    {cancelled, _} = request(base, :post, cancel_url, key, %{}, 200)
    assert cancelled["data"]["status"] == "cancelled"
    assert elem(request(base, :post, cancel_url, key, %{}, 200), 0) == cancelled
    assert {:ok, %{status: "cancelled"}} = Orders.evaluate(cancel.id)
    executed = C.order!(f)
    assert {:ok, result} = Orders.evaluate(executed.id)
    assert result.status == "executed"
    snapshot = C.snapshot()
    assert {:ok, ^result} = Orders.evaluate(executed.id)
    {read, _} = request(base, :get, @path <> "/" <> executed.id, key, nil, 200)
    assert read["data"]["execution"]["unit_price"] == "1.00"
    assert read["data"]["execution"]["total"] == "3.00"
    assert snapshot == C.snapshot()
    PurchasesCase.fund(f.buyer, "0")
    rejected = C.order!(f)
    before = PurchasesCase.snapshot()
    assert {:ok, %{status: "rejected"}} = Orders.evaluate(rejected.id)

    assert elem(request(base, :get, @path <> "/" <> rejected.id, key, nil, 200), 0)["data"][
             "rejection_reason"
           ] == "insufficient_funds"

    assert before == PurchasesCase.snapshot()
    PurchasesCase.fund(f.buyer, "1000")
    assert {:ok, _} = PurchasesCase.purchase(f, "consume-remaining", 96)
    short = C.order!(f)
    before = PurchasesCase.snapshot()

    assert {:ok, %{status: "rejected", rejection_reason: "insufficient_inventory"}} =
             Orders.evaluate(short.id)

    assert before == PurchasesCase.snapshot()
    C.invariant!()

    assert Repo.query!("SELECT count(*) FROM market_purchases WHERE conditional_order_id=$1", [
             Ecto.UUID.dump!(executed.id)
           ]).rows == [[1]]

    assert Repo.query!("SELECT amount FROM market_credit_balances WHERE user_id=$1", [
             Ecto.UUID.dump!(f.owner.id)
           ]).rows == [[Decimal.new("99")]]

    Repo.query!("ALTER TABLE market_conditional_buy_orders RENAME TO unavailable_orders")

    try do
      assert elem(request(base, :get, @path, key, nil, 503), 0)["error"]["code"] ==
               "temporarily_unavailable"
    after
      Repo.query!("ALTER TABLE unavailable_orders RENAME TO market_conditional_buy_orders")
    end
  end

  defp access_contract(base, f, key, foreign, terms, o, url) do
    for id <- [o["id"], Ecto.UUID.generate(), "bad"] do
      for {method, suffix} <- [{:get, ""}, {:post, "/cancel"}] do
        {body, _} = request(base, method, @path <> "/" <> id <> suffix, foreign, %{}, 404)
        assert body == %{"error" => %{"code" => "not_found"}}
      end
    end

    for {method, path, body} <- [
          {:get, @path, nil},
          {:get, url, nil},
          {:post, @path, terms},
          {:post, url <> "/cancel", %{}}
        ] do
      assert elem(request(base, method, path, nil, body, 401), 0)["error"]["code"] ==
               "unauthenticated"
    end

    assert elem(request(base, :post, @path, key, "{", 400), 0) == %{
             "error" => %{"code" => "invalid_request"}
           }

    for invalid <- [
          Map.put(terms, :owner_id, f.owner.id),
          Map.delete(terms, :expires_at),
          %{terms | quantity: 101},
          %{terms | maximum_unit_price: 1.0}
        ] do
      assert elem(request(base, :post, @path, key, invalid, 400), 0)["error"]["code"] ==
               "invalid_request"
    end

    for {player, code, status} <- [
          {f.other.id, "not_initialized", 409},
          {Ecto.UUID.generate(), "player_not_found", 404}
        ] do
      assert elem(request(base, :post, @path, key, %{terms | player_id: player}, status), 0)[
               "error"
             ]["code"] == code
    end

    assert elem(request(base, :post, @path, foreign, terms, 409), 0)["error"]["code"] ==
             "self_purchase"

    assert elem(request(base, :get, @path <> "?owner_id=x", key, nil, 400), 0)["error"]["code"] ==
             "invalid_request"

    assert elem(request(base, :post, url <> "/cancel", key, %{quantity: 4}, 400), 0)["error"][
             "code"
           ] == "invalid_request"

    {:ok, {{_, 404, _}, _, _}} =
      :httpc.request(
        :put,
        {String.to_charlist(base <> url), [{~c"x-api-key", String.to_charlist(key)}],
         ~c"application/json", "{}"},
        [timeout: 5_000],
        []
      )
  end

  defp request(base, method, path, key, payload, expected) do
    headers = [{~c"accept", ~c"application/json"}]
    headers = if key, do: [{~c"x-api-key", String.to_charlist(key)} | headers], else: headers
    url = String.to_charlist(base <> path)

    request =
      if method == :get,
        do: {url, headers},
        else:
          {url, headers, ~c"application/json",
           if(is_binary(payload), do: payload, else: Jason.encode!(payload))}

    {:ok, {{_, status, _}, response_headers, body}} =
      :httpc.request(method, request, [timeout: 5_000], [])

    assert status == expected

    assert Enum.any?(response_headers, fn {name, value} ->
             name == ~c"content-type" and List.to_string(value) =~ "application/json"
           end)

    if status == 401,
      do: assert({~c"www-authenticate", ~c"Bearer realm=\"api\""} in response_headers)

    {Jason.decode!(body), response_headers}
  end
end

ConditionalOrdersHTTP.run()
