defmodule PurchaseHTTP do
  import ExUnit.Assertions
  alias FootballMarket.{Repo, Market, MarketCase, PurchasesCase}
  alias FootballMarket.Infrastructure.{Configuration, Redis}
  alias FootballMarket.Quotes.RuntimeProbe

  def run do
    {:ok, _} = Application.ensure_all_started(:inets)
    store = RuntimeProbe.owned_store!()
    original = Application.fetch_env!(:football_market, Repo)

    try do
      Supervisor.terminate_child(FootballMarket.Supervisor, Repo)

      config =
        original
        |> Keyword.put(:pool, DBConnection.ConnectionPool)
        |> Keyword.put(:parameters, search_path: store.schema)

      Application.put_env(:football_market, Repo, config)
      {:ok, _} = Supervisor.restart_child(FootballMarket.Supervisor, Repo)
      assert Repo.query!("SELECT 1").rows == [[1]]
      {:ok, redis} = Redis.start_link(Configuration.redis())

      try do
        assert Redis.ping(redis) == {:ok, "PONG"}
      after
        GenServer.stop(redis)
      end

      f = MarketCase.fixture()
      {:ok, _} = Market.initialize_player(f.player.id)
      PurchasesCase.fund(f.buyer, "10.25")

      {:ok, {:ok, key}} =
        Repo.transaction(fn -> FootballMarket.Accounts.issue_api_key(f.buyer.id) end)

      {:ok, server} =
        Bandit.start_link(plug: FootballMarketWeb.Endpoint, ip: {127, 0, 0, 1}, port: 0)

      try do
        {:ok, {_, port}} = ThousandIsland.listener_info(server)
        url = ~c"http://127.0.0.1:#{port}/api/purchases"

        RuntimeProbe.await(fn ->
          case :httpc.request(:get, {url, []}, [timeout: 500], []) do
            {:ok, {{_, 404, _}, _, _}} -> true
            _ -> false
          end
        end)

        payload = PurchasesCase.request(f)
        original = request(url, key.secret, payload, 200)
        assert original["data"]["buyer_id"] == f.buyer.id
        assert original["data"]["unit_price"] == "1.00"
        assert original["data"]["total"] == "3.00"
        assert request(url, key.secret, payload, 200) == original

        assert request(url, key.secret, %{payload | quantity: 4}, 409) == %{
                 "error" => %{"code" => "key_conflict"}
               }

        before = PurchasesCase.snapshot()

        assert request(url, key.secret, %{payload | request_key: "nul\0key"}, 400) == %{
                 "error" => %{"code" => "invalid_request"}
               }

        assert before == PurchasesCase.snapshot()
        assert request(url, key.secret, "{", 400) == %{"error" => %{"code" => "invalid_request"}}

        assert request(url, key.secret, %{payload | request_key: "unfunded", quantity: 10}, 409) ==
                 %{"error" => %{"code" => "insufficient_funds"}}

        assert request(url, nil, payload, 401) == %{"error" => %{"code" => "unauthenticated"}}
        assert before == PurchasesCase.snapshot()
        assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]

        assert Repo.query!("SELECT amount FROM market_credit_balances WHERE user_id=$1", [
                 Ecto.UUID.dump!(f.buyer.id)
               ]).rows == [[Decimal.new("7.25")]]

        assert Repo.query!("SELECT amount FROM market_credit_balances WHERE user_id=$1", [
                 Ecto.UUID.dump!(f.owner.id)
               ]).rows == [[Decimal.new("3")]]

        assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[1]]
        assert Repo.query!("SELECT count(*) FROM market_token_transfers").rows == [[1]]
        assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[2]]

        IO.puts(
          "PURCHASE_HTTP_PASS: real HTTP status/header/body and persisted financial assertions"
        )
      after
        Supervisor.stop(server)
      end
    after
      Supervisor.terminate_child(FootballMarket.Supervisor, Repo)
      Application.put_env(:football_market, Repo, original)
      {:ok, _} = Supervisor.restart_child(FootballMarket.Supervisor, Repo)
      RuntimeProbe.destroy_store!(store)
    end
  end

  defp request(url, secret, payload, status) do
    headers = [{~c"accept", ~c"application/json"}]

    headers =
      if secret, do: [{~c"x-api-key", String.to_charlist(secret)} | headers], else: headers

    {:ok, {{_, actual, _}, response_headers, body}} =
      :httpc.request(
        :post,
        {url, headers, ~c"application/json",
         if(is_binary(payload), do: payload, else: Jason.encode!(payload))},
        [timeout: 5_000],
        []
      )

    assert actual == status

    assert Enum.any?(response_headers, fn {name, value} ->
             name == ~c"content-type" and List.to_string(value) =~ "application/json"
           end)

    if status == 401,
      do: assert({~c"www-authenticate", ~c"Bearer realm=\"api\""} in response_headers)

    Jason.decode!(body)
  end
end

PurchaseHTTP.run()
