defmodule FootballMarket.Market.PortfolioTest do
  use ExUnit.Case, async: false
  @moduletag :integration

  alias FootballMarket.{Accounts, Market, PurchasesCase}

  test "portfolio values current holdings from completed purchases and sales with owner scoping" do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "100")
    PurchasesCase.fund(f.owner, "100")

    assert {:ok, _purchase} = PurchasesCase.purchase(f, "portfolio-buy", 3)

    assert {:ok, _sale} =
             Market.sale(PurchasesCase.actor(f.buyer), %{
               player_id: f.player.id,
               quantity: 1,
               request_key: "portfolio-partial-sale"
             })

    outsider =
      Accounts.register_user(%{
        email: "portfolio-outsider-#{Ecto.UUID.generate()}@example.test",
        password: "portfolio-fixture-password"
      })
      |> elem(1)

    assert {:ok, [position]} = Market.portfolio(PurchasesCase.actor(f.buyer))
    assert position.player_id == f.player.id
    assert position.player_name == f.player.display_name
    assert position.quantity == 2
    assert Decimal.equal?(position.average_unit_cost, "1")
    assert Decimal.equal?(position.current_quote, "1")
    assert Decimal.equal?(position.current_value, "2")
    assert Decimal.equal?(position.realized_profit_loss, "0")
    assert Decimal.equal?(position.unrealized_profit_loss, "0")

    assert {:ok, []} = Market.portfolio(PurchasesCase.actor(f.owner))
    assert {:ok, []} = Market.portfolio(PurchasesCase.actor(outsider))

    assert {:ok, _sale} =
             Market.sale(PurchasesCase.actor(f.buyer), %{
               player_id: f.player.id,
               quantity: 2,
               request_key: "portfolio-complete-sale"
             })

    assert {:ok, []} = Market.portfolio(PurchasesCase.actor(f.buyer))
  end

  test "trade history is read through one combined statement so committed trades cannot interleave" do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "100")

    assert {:ok, _purchase} = PurchasesCase.purchase(f, "portfolio-statement-buy", 1)

    handler = fn _event_name, _measurements, %{query: query}, _config ->
      if query =~ ~r/market_(purchases|sales)/s, do: send(self(), {:trade_statement, query})
    end

    :ok =
      :telemetry.attach(
        "portfolio-statement-test",
        [:football_market, :repo, :query],
        handler,
        :ok
      )

    try do
      assert {:ok, [position]} = Market.portfolio(PurchasesCase.actor(f.buyer))
      assert position.quantity == 1
    after
      :ok = :telemetry.detach("portfolio-statement-test")
    end

    statements = collect_statements([])
    assert length(statements) == 1
    assert hd(statements) =~ ~r/market_purchases/s
    assert hd(statements) =~ ~r/market_sales/s
    assert hd(statements) =~ ~r/UNION ALL/s
  end

  defp collect_statements(statements) do
    receive do
      {:trade_statement, query} -> collect_statements([query | statements])
    after
      0 -> statements
    end
  end

  test "portfolio requires an authenticated owner" do
    assert {:error, %{kind: :unauthenticated}} = Market.portfolio(nil)
  end
end
