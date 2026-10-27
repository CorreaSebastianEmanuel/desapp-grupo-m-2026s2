defmodule FootballMarket.SalesCase do
  @moduledoc false
  alias FootballMarket.{Market, MarketCase, PurchasesCase}

  def fixture(opts \\ []) do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.owner, Keyword.get(opts, :market, "10"))
    MarketCase.transfer(f, Keyword.get(opts, :tokens, 4))
    f
  end

  def fund(user, amount), do: PurchasesCase.fund(user, amount)

  def request(f, key \\ "sale-key", quantity \\ 3),
    do: %{player_id: f.player.id, quantity: quantity, request_key: key}

  defdelegate actor(user), to: PurchasesCase

  def sale(f, key \\ "sale-key", quantity \\ 3),
    do: Market.sale(actor(f.buyer), request(f, key, quantity))

  def snapshot do
    tables =
      ~w(market_sales market_credit_balances market_purchases market_credit_entries market_token_transfers market_holdings)

    Map.new(tables, fn table ->
      {table,
       FootballMarket.Repo.query!(
         "SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text"
       ).rows}
    end)
  end
end
