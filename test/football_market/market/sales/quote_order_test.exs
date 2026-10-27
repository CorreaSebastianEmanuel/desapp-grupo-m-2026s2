defmodule FootballMarket.Market.Sales.QuoteOrderTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{MarketCase, PurchasesCase, Quotes, QuotesCase, Repo, SalesCase}
  alias FootballMarket.Valuation.Configurations

  setup do
    namespace = MarketCase.private_schema()
    PurchasesCase.cleanup(namespace.schema)
    fixture = QuotesCase.fixture()

    {:ok, seller} =
      FootballMarket.Accounts.register_user(%{
        email: "quote-seller-#{Ecto.UUID.generate()}@example.test",
        password: "sale-password"
      })

    PurchasesCase.fund(seller, "100")
    sale_fixture = Map.merge(fixture, Map.merge(namespace, %{buyer: seller, owner: fixture.user}))
    assert {:ok, _purchase} = PurchasesCase.purchase(sale_fixture, "sale-quote-setup", 5)
    {:ok, _} = Configurations.activate(fixture.configuration.id, nil)
    sale_fixture
  end

  test "quote committed first prices the sale at the new exact quote", fixture do
    assert {:ok, %{calculation: calculation}} = update_quote(fixture)
    assert {:ok, sale} = SalesCase.sell(fixture)
    assert sale.quote_id != fixture.issuance.initial_quote_id
    assert sale.configuration_version_id == calculation.configuration_version_id
    assert Decimal.equal?(sale.unit_price, "1.25")
    assert Decimal.equal?(sale.total, "3.75")
    assert sale.mapping_id == fixture.mapping.id
  end

  test "sale committed first excludes quote confirmation until sale commit", fixture do
    Repo.query!(
      "CREATE FUNCTION sale_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(30030); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER sale_pause BEFORE INSERT ON market_sales FOR EACH ROW EXECUTE FUNCTION sale_pause()"
    )

    parent = self()

    {:ok, {sale, quote}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(30030)")
        sale = start(fixture, parent, :sale, fn -> SalesCase.sell(fixture) end)
        assert_receive {:sale, sale_backend}, 10_000
        MarketCase.blocked(sale_backend)
        quote = start(fixture, parent, :quote, fn -> update_quote(fixture) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        refute Task.yield(sale, 0)
        refute Task.yield(quote, 0)
        {sale, quote}
      end)

    assert {:ok, completed_sale} = Task.await(sale, 20_000)
    assert {:ok, _} = Task.await(quote, 20_000)
    assert completed_sale.quote_id == fixture.issuance.initial_quote_id
    assert Decimal.equal?(completed_sale.total, "3")
    assert {:ok, latest} = Quotes.latest(fixture.player.id)
    assert Decimal.equal?(latest.unit_price, "1.25")
  end

  test "quote committed first while sale waits is the retained sale quote", fixture do
    Repo.query!(
      "CREATE FUNCTION sale_quote_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(30031); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE TRIGGER sale_quote_pause BEFORE INSERT ON market_quotes FOR EACH ROW EXECUTE FUNCTION sale_quote_pause()"
    )

    parent = self()

    {:ok, {quote, sale}} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(30031)")
        quote = start(fixture, parent, :quote, fn -> update_quote(fixture) end)
        assert_receive {:quote, quote_backend}, 10_000
        MarketCase.blocked(quote_backend)
        sale = start(fixture, parent, :sale, fn -> SalesCase.sell(fixture) end)
        assert_receive {:sale, sale_backend}, 10_000
        MarketCase.blocked(sale_backend)
        refute Task.yield(quote, 0)
        refute Task.yield(sale, 0)
        {quote, sale}
      end)

    assert {:ok, _} = Task.await(quote, 20_000)
    assert {:ok, completed_sale} = Task.await(sale, 20_000)
    assert Decimal.equal?(completed_sale.unit_price, "1.25")
    assert Decimal.equal?(completed_sale.total, "3.75")
    assert {:ok, latest} = Quotes.latest(fixture.player.id)
    assert completed_sale.quote_id == latest.id
  end

  defp update_quote(fixture),
    do: Quotes.request(fixture.subject, :active, fixture.mapping.id, Ecto.UUID.generate())

  defp start(fixture, parent, label, fun) do
    Task.async(fn ->
      MarketCase.in_client(fixture.schema, fn -> checked(parent, label, fun) end)
    end)
  end

  defp checked(parent, label, fun) do
    Repo.checkout(fn ->
      send(parent, {label, MarketCase.backend()})
      fun.()
    end)
  end
end
