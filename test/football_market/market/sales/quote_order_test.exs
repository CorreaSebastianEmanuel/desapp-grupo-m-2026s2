defmodule FootballMarket.Market.Sales.QuoteOrderTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{MarketCase, Market, PurchasesCase, Quotes, QuotesCase, SalesCase}
  alias FootballMarket.Valuation.Configurations

  setup do
    ns = MarketCase.private_schema()
    PurchasesCase.cleanup(ns.schema)
    f = QuotesCase.fixture()

    {:ok, seller} =
      FootballMarket.Accounts.register_user(%{
        email: "sale-seller-#{Ecto.UUID.generate()}@example.test",
        password: "sale-password"
      })

    PurchasesCase.fund(seller, "100")
    {:ok, _} = Configurations.activate(f.configuration.id, nil)

    # Seed real seller holdings and market credits through the purchase contract.
    seed = Map.put(f, :buyer, seller)
    assert {:ok, _} = PurchasesCase.purchase(seed)
    # Extra market credits so a sale can cover the quote that races commit.
    PurchasesCase.fund(f.user, "10")

    Map.merge(ns, Map.merge(f, %{seller: seller}))
  end

  test "quote committed first prices the sale exactly at the newly retained quote", f do
    SalesCase.fund(f.user, "0")
    before = SalesCase.snapshot()
    assert {:error, %{kind: :insufficient_funds}} = sale(f, "sale-key")
    assert before == SalesCase.snapshot()
    SalesCase.fund(f.user, "10")
    assert {:ok, %{calculation: c}} = update_quote(f)
    assert {:ok, s} = sale(f, "sale-key")
    assert s.quote_id != f.issuance.initial_quote_id
    assert s.configuration_version_id == c.configuration_version_id
    assert Decimal.equal?(s.unit_price, "1.25")
    assert Decimal.equal?(s.total, "3.75")
    assert s.mapping_id == f.mapping.id
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
    # Two entries from the seeded purchase plus the sale's own paired entries.
    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[4]]

    Repo.query!("ALTER TABLE market_quotes DISABLE TRIGGER ALL")
    Repo.query!("ALTER TABLE market_quotes DROP CONSTRAINT market_quote_canonical")

    Repo.query!("UPDATE market_quotes SET unit_price=0 WHERE id=$1", [
      Ecto.UUID.dump!(s.quote_id)
    ])

    before = SalesCase.snapshot()
    assert {:error, %{kind: :quote_unavailable}} = sale(f, "invalid-current")
    assert before == SalesCase.snapshot()
  end

  test "sale decision excludes quote confirmation until sale commit", f do
    Repo.query!(
      "CREATE FUNCTION sale_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(31031); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER sale_pause BEFORE INSERT ON market_sales FOR EACH ROW EXECUTE FUNCTION sale_pause()"
    )

    parent = self()

    {:ok, {sale, quote}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(31031)")
        sale = start(f, parent, :sale, fn -> sale(f, "sale-key") end)
        assert_receive {:sale, backend}, 10_000
        MarketCase.blocked(backend)
        quote = start(f, parent, :quote, fn -> update_quote(f) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        refute Task.yield(sale, 0)
        refute Task.yield(quote, 0)
        {sale, quote}
      end)

    assert {:ok, s} = Task.await(sale, 20_000)
    assert {:ok, _} = Task.await(quote, 20_000)
    assert s.quote_id == f.issuance.initial_quote_id
    assert Decimal.equal?(s.total, "3")
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert Decimal.equal?(latest.unit_price, "1.25")
    assert {:ok, ^s} = sale(f, "sale-key")
  end

  test "quote committed first while sale waits uses the newly committed quote", f do
    Repo.query!(
      "CREATE FUNCTION quote_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(31032); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER quote_pause BEFORE INSERT ON market_quotes FOR EACH ROW EXECUTE FUNCTION quote_pause()"
    )

    parent = self()

    {:ok, {quote, sale}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(31032)")
        quote = start(f, parent, :quote, fn -> update_quote(f) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        sale = start(f, parent, :sale, fn -> sale(f, "sale-key") end)
        assert_receive {:sale, sale_backend}, 10_000
        MarketCase.blocked(sale_backend)
        refute Task.yield(quote, 0)
        refute Task.yield(sale, 0)
        {quote, sale}
      end)

    assert {:ok, _} = Task.await(quote, 20_000)
    assert {:ok, s} = Task.await(sale, 20_000)
    assert s.quote_id != f.issuance.initial_quote_id
    assert Decimal.equal?(s.unit_price, "1.25")
    assert Decimal.equal?(s.total, "3.75")
    assert {:ok, latest} = Quotes.latest(f.player.id)
    assert s.quote_id == latest.id
  end

  defp sale(f, key) do
    Market.sale(PurchasesCase.actor(f.seller), %{
      player_id: f.player.id,
      quantity: 3,
      request_key: key
    })
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
