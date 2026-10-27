defmodule FootballMarket.Market.ConditionalOrders.StorageTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, PurchasesCase, Repo, MarketCase}
  alias FootballMarket.Market.ConditionalOrder
  setup do: ConditionalOrdersCase.fixture()

  test "database enforces terms ownership and immutable pending instructions", f do
    o = ConditionalOrdersCase.order!(f)
    before = ConditionalOrdersCase.snapshot()

    for sql <- [
          "UPDATE market_conditional_buy_orders SET quantity=4",
          "UPDATE market_conditional_buy_orders SET owner_id=player_id",
          "DELETE FROM market_conditional_buy_orders",
          "TRUNCATE market_conditional_buy_orders CASCADE"
        ] do
      assert_raise Postgrex.Error, fn -> Repo.query!(sql) end
      assert before == ConditionalOrdersCase.snapshot()
    end

    row = Repo.get!(ConditionalOrder, o.id)

    for {field, value} <- [
          quantity: 0,
          quantity: 101,
          maximum_unit_price: Decimal.new("0.001"),
          owner_id: Ecto.UUID.generate(),
          player_id: f.other.id,
          status: "other",
          expires_at: row.created_at
        ] do
      attrs = row |> Map.from_struct() |> Map.drop([:__meta__, :id]) |> Map.put(field, value)
      assert_raise Ecto.ConstraintError, fn -> Repo.insert!(struct!(ConditionalOrder, attrs)) end
      assert before == ConditionalOrdersCase.snapshot()
    end
  end

  test "terminal outcomes are immutable and reciprocal purchase origin is required at commit",
       f do
    o = ConditionalOrdersCase.order!(f)
    assert {:ok, executed} = FootballMarket.Market.ConditionalOrders.evaluate(o.id)
    before = ConditionalOrdersCase.snapshot()

    for sql <- [
          "UPDATE market_conditional_buy_orders SET status='cancelled',purchase_id=NULL",
          "UPDATE market_conditional_buy_orders SET completed_at=completed_at",
          "UPDATE market_purchases SET conditional_order_id=NULL",
          "DELETE FROM market_credit_entries",
          "TRUNCATE market_token_transfers CASCADE"
        ] do
      assert_raise Postgrex.Error, fn -> Repo.query!(sql) end
      assert before == ConditionalOrdersCase.snapshot()
    end

    assert {:ok, direct} = PurchasesCase.purchase(f)
    pending = ConditionalOrdersCase.order!(f)
    before = ConditionalOrdersCase.snapshot()

    assert_raise Postgrex.Error, fn ->
      Repo.transaction(fn ->
        Repo.query!(
          "UPDATE market_conditional_buy_orders SET status='executed',completed_at=clock_timestamp(),purchase_id=$1 WHERE id=$2",
          [Ecto.UUID.dump!(direct.id), Ecto.UUID.dump!(pending.id)]
        )
      end)
    end

    assert before == ConditionalOrdersCase.snapshot()

    assert Repo.query!("SELECT conditional_order_id FROM market_purchases WHERE id=$1", [
             Ecto.UUID.dump!(executed.execution.purchase_id)
           ]).rows == [[Ecto.UUID.dump!(o.id)]]

    for value <- ["NaN", "Infinity", "0", "-1", "0.001"] do
      assert_raise Postgrex.Error, fn ->
        Repo.query!(
          "INSERT INTO market_conditional_buy_orders SELECT gen_random_uuid(),owner_id,player_id,quantity,$1::numeric,created_at,expires_at,'pending',NULL,NULL,NULL FROM market_conditional_buy_orders LIMIT 1",
          [Decimal.new(value)]
        )
      end
    end
  end

  test "migration upgrades committed direct purchases without rewriting append-only evidence" do
    schema = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{schema}")
    PurchasesCase.cleanup(schema)

    MarketCase.in_client(schema, fn ->
      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up,
        to: 20_261_026_000_100,
        prefix: schema,
        log: false
      )

      # Determine preceding version from the migration file list; no data reset.
      f = MarketCase.fixture()
      {:ok, _} = FootballMarket.Market.initialize_player(f.player.id)
      PurchasesCase.fund(f.buyer, "10")

      {:ok, row} =
        Repo.transaction(fn ->
          FootballMarket.Market.PurchaseTransaction.complete(%{
            buyer_id: f.buyer.id,
            player_id: f.player.id,
            quantity: 3,
            request_key: "purchase-key"
          })
        end)

      p = FootballMarket.Market.PurchaseTransaction.evidence(row)
      before = PurchasesCase.snapshot()
      Ecto.Migrator.run(Repo, "priv/repo/migrations", :up, all: true, prefix: schema, log: false)
      after_upgrade = PurchasesCase.snapshot()

      assert Map.delete(before, "market_purchases") ==
               Map.delete(after_upgrade, "market_purchases")

      assert {:ok, ^p} = PurchasesCase.purchase(f)
      assert Repo.query!("SELECT conditional_order_id FROM market_purchases").rows == [[nil]]
    end)
  end
end
