defmodule FootballMarket.Market.PortfolioQuoteTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.{Accounts, Market, QuotesCase, ValuationConfigurationCase}

  setup do
    ValuationConfigurationCase.private_schema()
    {:ok, QuotesCase.fixture()}
  end

  test "current valuation uses the latest quote rather than the purchase price", f do
    {:ok, buyer} =
      Accounts.register_user(%{
        email: "portfolio-quote-#{Ecto.UUID.generate()}@example.test",
        password: "portfolio-fixture-password"
      })

    FootballMarket.PurchasesCase.fund(buyer, "100")

    assert {:ok, purchase} =
             Market.purchase(FootballMarket.PurchasesCase.actor(buyer), %{
               player_id: f.player.id,
               quantity: 3,
               request_key: "portfolio-quote-buy"
             })

    assert Decimal.equal?(purchase.unit_price, "1")

    QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), 1, :second), "2")

    assert {:ok, [position]} = Market.portfolio(FootballMarket.PurchasesCase.actor(buyer))
    assert position.quantity == 3
    assert Decimal.equal?(position.average_unit_cost, "1")
    assert Decimal.equal?(position.current_quote, "2")
    assert Decimal.equal?(position.current_value, "6")
    assert Decimal.equal?(position.unrealized_profit_loss, "3")
  end

  test "positions keep exact decimal money for a supported large cent-exact amount regardless of caller context",
       f do
    {:ok, buyer} =
      Accounts.register_user(%{
        email: "portfolio-exact-#{Ecto.UUID.generate()}@example.test",
        password: "portfolio-fixture-password"
      })

    unit = "92345678901234567890123456789012.91"
    {total, ""} = Decimal.parse("277037036703703703670370370367038.73", max_digits: :infinity)

    FootballMarket.PurchasesCase.fund(
      buyer,
      Decimal.Context.with(
        %Decimal.Context{precision: 200},
        fn -> total |> Decimal.mult("10") |> Decimal.to_string(:normal) end
      )
    )

    QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), 1, :second), unit)

    assert {:ok, purchase} =
             Market.purchase(FootballMarket.PurchasesCase.actor(buyer), %{
               player_id: f.player.id,
               quantity: 3,
               request_key: "portfolio-exact-buy"
             })

    assert Decimal.equal?(purchase.unit_price, unit)
    assert Decimal.equal?(purchase.total, total)

    Decimal.Context.with(%Decimal.Context{precision: 4, rounding: :half_even}, fn ->
      assert {:ok, [position]} = Market.portfolio(FootballMarket.PurchasesCase.actor(buyer))
      assert position.quantity == 3
      assert Decimal.equal?(position.average_unit_cost, unit)
      assert Decimal.equal?(position.current_quote, unit)
      assert Decimal.equal?(position.current_value, total)
      assert Decimal.equal?(position.unrealized_profit_loss, "0")
      assert Decimal.equal?(position.realized_profit_loss, "0")
    end)
  end
end
