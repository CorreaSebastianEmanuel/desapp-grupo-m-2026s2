defmodule FootballMarket.Market.Purchases.QuoteOrderTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{MarketCase, PurchasesCase, Quotes, QuotesCase, Repo}
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

  test "quote committed first prices exactly three times 1.25", f do
    PurchasesCase.fund(f.buyer, "0")
    before = PurchasesCase.snapshot()
    assert {:error, %{kind: :insufficient_funds}} = PurchasesCase.purchase(f)
    assert before == PurchasesCase.snapshot()
    PurchasesCase.fund(f.buyer, "100")
    assert {:ok, %{calculation: c}} = update_quote(f)
    assert {:ok, p} = PurchasesCase.purchase(f)
    assert p.quote_id != f.issuance.initial_quote_id
    assert p.configuration_version_id == c.configuration_version_id
    assert Decimal.equal?(p.unit_price, "1.25")
    assert Decimal.equal?(p.total, "3.75")
    assert p.mapping_id == f.mapping.id
    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[2]]
    Repo.query!("ALTER TABLE market_quotes DISABLE TRIGGER ALL")
    Repo.query!("ALTER TABLE market_quotes DROP CONSTRAINT market_quote_canonical")

    Repo.query!("UPDATE market_quotes SET unit_price=0 WHERE id=$1", [Ecto.UUID.dump!(p.quote_id)])

    before = PurchasesCase.snapshot()
    assert {:error, %{kind: :quote_unavailable}} = PurchasesCase.purchase(f, "invalid-current")
    assert before == PurchasesCase.snapshot()
  end

  test "purchase decision excludes quote confirmation until purchase commit", f do
    Repo.query!(
      "CREATE FUNCTION purchase_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(29029); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER purchase_pause BEFORE INSERT ON market_purchases FOR EACH ROW EXECUTE FUNCTION purchase_pause()"
    )

    parent = self()

    {:ok, {purchase, quote}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(29029)")
        purchase = start(f, parent, :purchase, fn -> PurchasesCase.purchase(f) end)
        assert_receive {:purchase, backend}, 10_000
        MarketCase.blocked(backend)
        quote = start(f, parent, :quote, fn -> update_quote(f) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        refute Task.yield(purchase, 0)
        refute Task.yield(quote, 0)
        {purchase, quote}
      end)

    assert {:ok, p} = Task.await(purchase, 20_000)
    assert {:ok, _} = Task.await(quote, 20_000)
    assert p.quote_id == f.issuance.initial_quote_id
    assert Decimal.equal?(p.total, "3")
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert Decimal.equal?(latest.unit_price, "1.25")
    assert {:ok, ^p} = PurchasesCase.purchase(f)
  end

  test "quote committed first while purchase waits uses the newly committed quote", f do
    Repo.query!(
      "CREATE FUNCTION quote_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(29030); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER quote_pause BEFORE INSERT ON market_quotes FOR EACH ROW EXECUTE FUNCTION quote_pause()"
    )

    parent = self()

    {:ok, {quote, purchase}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(29030)")
        quote = start(f, parent, :quote, fn -> update_quote(f) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        purchase = start(f, parent, :purchase, fn -> PurchasesCase.purchase(f) end)
        assert_receive {:purchase, purchase_backend}, 10_000
        MarketCase.blocked(purchase_backend)
        refute Task.yield(quote, 0)
        refute Task.yield(purchase, 0)
        {quote, purchase}
      end)

    assert {:ok, _} = Task.await(quote, 20_000)
    assert {:ok, p} = Task.await(purchase, 20_000)
    assert p.quote_id != f.issuance.initial_quote_id
    assert Decimal.equal?(p.unit_price, "1.25")
    assert Decimal.equal?(p.total, "3.75")
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert p.quote_id == latest.id
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
