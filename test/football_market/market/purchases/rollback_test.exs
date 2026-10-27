defmodule FootballMarket.Market.Purchases.RollbackTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{PurchasesCase, Repo}

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "100")
    f
  end

  test "nested transaction cannot return a premature completion", f do
    before = PurchasesCase.snapshot()

    assert {:ok, {:error, %{kind: :invalid_request}}} =
             Repo.transaction(fn -> PurchasesCase.purchase(f) end)

    assert before == PurchasesCase.snapshot()
  end

  test "storage faults at every write and deferred commit roll back everything", f do
    for table <-
          ~w(market_credit_balances market_holdings market_purchases market_token_transfers market_credit_entries),
        deferred <- [false, true] do
      Repo.query!(
        "CREATE OR REPLACE FUNCTION purchase_test_fault() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'test failure'; END $$"
      )

      timing =
        if deferred,
          do: "CONSTRAINT TRIGGER purchase_test_fault AFTER",
          else: "TRIGGER purchase_test_fault BEFORE"

      defer = if deferred, do: "DEFERRABLE INITIALLY DEFERRED", else: ""

      Repo.query!(
        "CREATE #{timing} INSERT OR UPDATE ON #{table} #{defer} FOR EACH ROW EXECUTE FUNCTION purchase_test_fault()"
      )

      before = PurchasesCase.snapshot()
      assert {:error, %{kind: :temporarily_unavailable}} = PurchasesCase.purchase(f)
      assert before == PurchasesCase.snapshot()
      Repo.query!("DROP TRIGGER purchase_test_fault ON #{table}")
    end

    assert {:ok, _} = PurchasesCase.purchase(f)
  end
end
