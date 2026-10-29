defmodule FootballMarket.Market.Analytics.StoreTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{
    Accounts,
    Market,
    PurchasesCase,
    QuotesCase,
    Repo,
    ValuationConfigurationCase
  }

  setup do
    ValuationConfigurationCase.private_schema()
    f = QuotesCase.fixture()

    {:ok, buyer} =
      Accounts.register_user(%{
        email: "analytics-#{Ecto.UUID.generate()}@example.test",
        password: "analytics-fixture-password"
      })

    PurchasesCase.fund(buyer, "100")
    Map.put(f, :buyer, buyer)
  end

  test "allocation and history use owner-scoped persisted trades and remain read-only", f do
    quote = QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), -60), "2")
    assert {:ok, _} = buy(f, "analytics-buy", 3)
    actor = PurchasesCase.actor(f.buyer)
    before = {QuotesCase.protected_snapshot(), FootballMarket.SalesCase.snapshot()}
    assert {:ok, %{positions: [position], totals: totals}} = Market.portfolio_allocation(actor)
    assert position.quote.id == quote.id
    assert Decimal.equal?(position.market_value, "6")
    assert Decimal.equal?(position.weight, "1")
    assert Decimal.equal?(totals.purchase_expenditure, "6")

    assert {:ok, %{positions: [], totals: empty}} =
             Market.portfolio_allocation(PurchasesCase.actor(f.user))

    assert Decimal.equal?(empty.market_value, "0")
    assert {:ok, %{points: points}} = Market.portfolio_history(actor, %{})
    assert length(points) == 30
    assert List.last(points).partial
    assert Decimal.equal?(List.last(points).market_value, "6")
    assert Decimal.equal?(hd(points).market_value, "0")
    assert before == {QuotesCase.protected_snapshot(), FootballMarket.SalesCase.snapshot()}
  end

  test "future quotes are excluded and full sale retains profit after allocation disappears", f do
    QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), -60), "2")
    assert {:ok, _} = buy(f, "analytics-closed-buy", 2)
    QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), -30), "3")
    PurchasesCase.fund(f.user, "100")

    assert {:ok, _} =
             Market.sale(PurchasesCase.actor(f.buyer), %{
               player_id: f.player.id,
               quantity: 2,
               request_key: "analytics-closed-sale"
             })

    QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), 86_400), "9")

    assert {:ok, %{positions: [], totals: totals}} =
             Market.portfolio_allocation(PurchasesCase.actor(f.buyer))

    assert Decimal.equal?(totals.realized_profit_loss, "2")
    assert Decimal.equal?(totals.total_profit_loss, "2")
    assert Decimal.equal?(totals.sale_proceeds, "6")
    assert {:ok, []} = Market.portfolio(PurchasesCase.actor(f.buyer))
  end

  test "history uses bounded batched SQL independent of the number of points", f do
    assert {:ok, _} = buy(f, "analytics-batch-buy", 1)
    owner = self()
    id = "analytics-query-count-#{Ecto.UUID.generate()}"

    :ok =
      :telemetry.attach(
        id,
        [:football_market, :repo, :query],
        fn _, _, metadata, _ ->
          if self() == owner, do: send(owner, {:analytics_query, metadata.query})
        end,
        nil
      )

    try do
      today = Date.utc_today()

      assert {:ok, %{points: points}} =
               Market.portfolio_history(PurchasesCase.actor(f.buyer), %{
                 from: Date.add(today, -365),
                 to: today
               })

      assert length(points) == 366
    after
      :telemetry.detach(id)
    end

    queries = collect([])
    # BEGIN/COMMIT, SET, clock, trades, names, opening quotes, changes.
    assert length(queries) <= 8
    assert Enum.count(queries, &String.contains?(&1, "UNION ALL")) == 1
    refute Enum.any?(queries, &Regex.match?(~r/INSERT|UPDATE|DELETE|FOR UPDATE/, &1))
  end

  test "a quote committed between queries cannot change the established snapshot", f do
    old = QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), -60), "2")
    assert {:ok, _} = buy(f, "analytics-snapshot-buy", 1)
    repo = Repo.get_dynamic_repo()
    owner = self()
    barrier = :ets.new(:analytics_snapshot, [:public, :set])
    id = "analytics-snapshot-#{Ecto.UUID.generate()}"

    :ok =
      :telemetry.attach(
        id,
        [:football_market, :repo, :query],
        fn _, _, metadata, _ ->
          if String.contains?(metadata.query, "UNION ALL") and
               :ets.insert_new(barrier, {:claimed, true}) do
            send(owner, {:snapshot_ready, self()})

            receive do
              :continue -> :ok
            after
              5_000 -> raise "analytics snapshot barrier timed out"
            end
          end
        end,
        nil
      )

    reader =
      spawn(fn ->
        Repo.put_dynamic_repo(repo)
        send(owner, {:snapshot_result, Market.portfolio_allocation(PurchasesCase.actor(f.buyer))})
      end)

    try do
      assert_receive {:snapshot_ready, blocked}, 5_000
      newer = QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), -30), "4")
      send(blocked, :continue)
      assert_receive {:snapshot_result, {:ok, %{positions: [position]}}}, 5_000
      assert position.quote.id == old.id

      assert {:ok, %{positions: [fresh]}} =
               Market.portfolio_allocation(PurchasesCase.actor(f.buyer))

      assert fresh.quote.id == newer.id
    after
      :telemetry.detach(id)
      :ets.delete(barrier)
      if Process.alive?(reader), do: Process.exit(reader, :kill)
    end
  end

  test "unauthenticated callers and incompatible nested transactions are rejected", f do
    assert {:error, %{kind: :unauthenticated}} = Market.portfolio_allocation(nil)
    assert {:error, %{kind: :unauthenticated}} = Market.portfolio_history(nil, %{})

    assert {:ok, {:error, %{kind: :temporarily_unavailable}}} =
             Repo.transaction(fn -> Market.portfolio_allocation(PurchasesCase.actor(f.buyer)) end)

    assert {:error, %{kind: :invalid_date_range}} =
             Market.portfolio_history(PurchasesCase.actor(f.buyer), %{
               from: Date.utc_today(),
               to: Date.add(Date.utc_today(), 1)
             })
  end

  defp buy(f, key, quantity),
    do:
      Market.purchase(PurchasesCase.actor(f.buyer), %{
        player_id: f.player.id,
        quantity: quantity,
        request_key: key
      })

  defp collect(acc) do
    receive do
      {:analytics_query, query} -> collect([query | acc])
    after
      0 -> acc
    end
  end
end
