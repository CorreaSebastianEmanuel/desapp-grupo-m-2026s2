defmodule FootballMarket.Market.ConditionalOrders.QuoteOrderTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{MarketCase, PurchasesCase, Quotes, QuotesCase, Repo}
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  alias FootballMarket.ConditionalOrdersCase, as: C
  alias FootballMarket.Valuation.Configurations

  setup do
    ns = MarketCase.private_schema()
    PurchasesCase.cleanup(ns.schema)
    f = QuotesCase.fixture()

    {:ok, buyer} =
      FootballMarket.Accounts.register_user(%{
        email: "quote-buyer-#{Ecto.UUID.generate()}@example.test",
        password: "purchase-password"
      })

    PurchasesCase.fund(buyer, "100")
    {:ok, _} = Configurations.activate(f.configuration.id, nil)
    Map.merge(f, Map.merge(ns, %{buyer: buyer}))
  end

  test "evaluation decision excludes quote confirmation until purchase commit", f do
    Repo.query!(
      "CREATE FUNCTION purchase_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(29029); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER purchase_pause BEFORE INSERT ON market_purchases FOR EACH ROW EXECUTE FUNCTION purchase_pause()"
    )

    o = C.order!(f)
    parent = self()

    {:ok, {purchase, quote}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(29029)")
        purchase = start(f, parent, :purchase, fn -> Orders.evaluate(o.id) end)
        assert_receive {:purchase, backend}, 10_000
        MarketCase.blocked(backend)
        quote = start(f, parent, :quote, fn -> update_quote(f) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        refute Task.yield(purchase, 0)
        refute Task.yield(quote, 0)
        {purchase, quote}
      end)

    assert {:ok, result} = Task.await(purchase, 20_000)
    assert {:ok, _} = Task.await(quote, 20_000)
    assert result.status == "executed"
    assert result.execution.quote_id == f.issuance.initial_quote_id
    assert Decimal.equal?(result.execution.total, "3")
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert Decimal.equal?(latest.unit_price, "1.25")
    assert {:ok, ^result} = Orders.evaluate(o.id)
  end

  test "quote committed first prevents stale cheap authorization while evaluation waits", f do
    Repo.query!(
      "CREATE FUNCTION quote_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(29030); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER quote_pause BEFORE INSERT ON market_quotes FOR EACH ROW EXECUTE FUNCTION quote_pause()"
    )

    o = C.order!(f)
    parent = self()

    {:ok, {quote, purchase}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(29030)")
        quote = start(f, parent, :quote, fn -> update_quote(f) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        purchase = start(f, parent, :purchase, fn -> Orders.evaluate(o.id) end)
        assert_receive {:purchase, purchase_backend}, 10_000
        MarketCase.blocked(purchase_backend)
        refute Task.yield(quote, 0)
        refute Task.yield(purchase, 0)
        {quote, purchase}
      end)

    assert {:ok, _} = Task.await(quote, 20_000)
    assert {:ok, result} = Task.await(purchase, 20_000)
    assert result.status == "pending"
    assert result.execution == nil
    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[0]]
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert Decimal.equal?(latest.unit_price, "1.25")
  end

  test "player lock wait crossing expiry uses wall clock after locks", f do
    o = C.order!(f, %{expires_at: DateTime.add(DateTime.utc_now(), 1)})
    owner = self()

    {:ok, task} =
      Repo.transaction(fn ->
        Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [
          Ecto.UUID.dump!(f.player.id)
        ])

        task = start(f, owner, :evaluation, fn -> Orders.evaluate(o.id) end)
        assert_receive {:evaluation, backend}, 10_000
        MarketCase.blocked(backend)

        Repo.query!(
          "SELECT pg_sleep(GREATEST(0, EXTRACT(EPOCH FROM $1::timestamp-(clock_timestamp() AT TIME ZONE 'UTC')))+0.05)",
          [DateTime.to_naive(o.expires_at)]
        )

        task
      end)

    assert {:ok, %{status: "expired"}} = Task.await(task, 20_000)
    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[0]]
  end

  defp update_quote(f), do: Quotes.request(f.subject, :active, f.mapping.id, Ecto.UUID.generate())

  defp start(f, parent, label, fun) do
    Task.async(fn -> MarketCase.in_client(f.schema, fn -> checked(parent, label, fun) end) end)
  end

  defp checked(parent, label, fun) do
    Repo.checkout(fn ->
      send(parent, {label, MarketCase.backend()})
      fun.()
    end)
  end
end
