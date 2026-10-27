defmodule FootballMarket.Market.ConditionalOrders.RollbackTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, Repo}
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  setup do: ConditionalOrdersCase.fixture()

  test "every financial and order write including deferred commit rolls back and safely retries",
       f do
    o = ConditionalOrdersCase.order!(f)

    boundaries = [
      {"market_conditional_buy_orders", "UPDATE", ""},
      {"market_credit_balances", "UPDATE", ""},
      {"market_credit_balances", "INSERT", ""},
      {"market_holdings", "UPDATE", ""},
      {"market_holdings", "INSERT", ""},
      {"market_purchases", "INSERT", ""},
      {"market_token_transfers", "INSERT", ""},
      {"market_credit_entries", "INSERT", "WHEN (NEW.side='debit')"},
      {"market_credit_entries", "INSERT", "WHEN (NEW.side='credit')"}
    ]

    for {table, action, condition} <- boundaries, deferred <- [false, true] do
      Repo.query!(
        "CREATE OR REPLACE FUNCTION order_fault() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'conditional test fault'; END $$"
      )

      timing =
        if deferred,
          do: "CONSTRAINT TRIGGER order_fault AFTER",
          else: "TRIGGER order_fault BEFORE"

      defer = if deferred, do: "DEFERRABLE INITIALLY DEFERRED", else: ""

      Repo.query!(
        "CREATE #{timing} #{action} ON #{table} #{defer} FOR EACH ROW #{condition} EXECUTE FUNCTION order_fault()"
      )

      before = ConditionalOrdersCase.snapshot()
      assert {:error, %{kind: :temporarily_unavailable}} = Orders.evaluate(o.id)
      assert before == ConditionalOrdersCase.snapshot()
      Repo.query!("DROP TRIGGER order_fault ON #{table}")
    end

    assert {:ok, %{status: "executed"}} = Orders.evaluate(o.id)
    ConditionalOrdersCase.invariant!()
  end
end
