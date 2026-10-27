defmodule FootballMarket.ConditionalOrdersCase do
  @moduledoc false
  import ExUnit.Assertions
  alias FootballMarket.{PurchasesCase, Repo}
  alias FootballMarket.Market.ConditionalOrders

  def fixture do
    old = Application.fetch_env(:football_market, :initial_issuance_recipients)
    ExUnit.Callbacks.on_exit(fn -> restore(old) end)
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "100")
    f
  end

  def restore({:ok, value}),
    do: Application.put_env(:football_market, :initial_issuance_recipients, value)

  def restore(:error), do: Application.delete_env(:football_market, :initial_issuance_recipients)
  def actor(user), do: PurchasesCase.actor(user)

  def terms(f, overrides \\ %{}) do
    Map.merge(
      %{
        player_id: f.player.id,
        quantity: 3,
        maximum_unit_price: "1.00",
        expires_at: DateTime.add(DateTime.utc_now(), 3600)
      },
      overrides
    )
  end

  def create(f, overrides \\ %{}),
    do: ConditionalOrders.create(actor(f.buyer), terms(f, overrides))

  def order!(f, overrides \\ %{}) do
    assert {:ok, order} = create(f, overrides)
    order
  end

  def snapshot do
    Map.merge(
      PurchasesCase.snapshot(),
      Map.new(~w(market_conditional_buy_orders oban_jobs), fn table ->
        {table,
         Repo.query!("SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text").rows}
      end)
    )
  end

  def due!(order) do
    # Test-only transition of the clock fixture; production terms stay immutable.
    Repo.query!(
      "ALTER TABLE market_conditional_buy_orders DISABLE TRIGGER market_order_immutable"
    )

    try do
      Repo.query!(
        "UPDATE market_conditional_buy_orders SET created_at=clock_timestamp()-interval '2 hours', expires_at=clock_timestamp()-interval '1 hour' WHERE id=$1",
        [Ecto.UUID.dump!(order.id)]
      )
    after
      Repo.query!(
        "ALTER TABLE market_conditional_buy_orders ENABLE TRIGGER market_order_immutable"
      )
    end
  end

  def invariant! do
    assert Repo.query!("SELECT count(*) FROM market_credit_balances WHERE amount < 0").rows == [
             [0]
           ]

    assert Enum.all?(
             Repo.query!("SELECT sum(quantity) FROM market_holdings GROUP BY player_id").rows,
             &(&1 == [100])
           )

    assert Repo.query!(
             "SELECT count(*) FROM market_purchases p WHERE (SELECT count(*) FROM market_credit_entries e WHERE e.purchase_id=p.id) <> 2 OR (SELECT count(*) FROM market_token_transfers t WHERE t.purchase_id=p.id) <> 1"
           ).rows == [[0]]

    assert Repo.query!(
             "SELECT count(*) FROM market_credit_entries d JOIN market_credit_entries c USING(purchase_id) WHERE d.side='debit' AND c.side='credit' AND d.amount<>c.amount"
           ).rows == [[0]]
  end
end
