defmodule FootballMarket.SalesCase do
  @moduledoc false
  alias FootballMarket.{Market, PurchasesCase, Repo}

  def fixture(quantity \\ 5) do
    fixture = PurchasesCase.fixture()
    PurchasesCase.fund(fixture.buyer, "10")
    {:ok, _purchase} = PurchasesCase.purchase(fixture, "sale-setup-purchase", quantity)
    fixture
  end

  def request(fixture, key \\ "sale-key", quantity \\ 3),
    do: %{player_id: fixture.player.id, quantity: quantity, request_key: key}

  def sell(fixture, key \\ "sale-key", quantity \\ 3),
    do: Market.sell(PurchasesCase.actor(fixture.buyer), request(fixture, key, quantity))

  def snapshot do
    Map.new(
      ~w(market_credit_balances market_purchases market_credit_entries market_token_transfers market_sales market_sale_credit_entries market_sale_token_transfers market_holdings),
      fn table ->
        {table,
         Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows}
      end
    )
  end
end
