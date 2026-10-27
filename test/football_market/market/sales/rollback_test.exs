defmodule FootballMarket.Market.Sales.RollbackTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, SalesCase}

  setup do
    SalesCase.fixture()
  end

  test "nested transaction cannot return a premature completion", fixture do
    before = SalesCase.snapshot()

    assert {:ok, {:error, %{kind: :invalid_request}}} =
             Repo.transaction(fn -> SalesCase.sell(fixture) end)

    assert before == SalesCase.snapshot()
  end

  test "faults at every sale write and deferred commit roll back everything", fixture do
    for table <-
          ~w(market_credit_balances market_holdings market_sales market_sale_token_transfers market_sale_credit_entries),
        deferred <- [false, true] do
      Repo.query!(
        "CREATE OR REPLACE FUNCTION sale_test_fault() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'test failure'; END $$"
      )

      timing =
        if deferred,
          do: "CONSTRAINT TRIGGER sale_test_fault AFTER",
          else: "TRIGGER sale_test_fault BEFORE"

      defer = if deferred, do: "DEFERRABLE INITIALLY DEFERRED", else: ""

      Repo.query!(
        "CREATE #{timing} INSERT OR UPDATE ON #{table} #{defer} FOR EACH ROW EXECUTE FUNCTION sale_test_fault()"
      )

      before = SalesCase.snapshot()
      assert {:error, %{kind: :temporarily_unavailable}} = SalesCase.sell(fixture)
      assert before == SalesCase.snapshot()
      Repo.query!("DROP TRIGGER sale_test_fault ON #{table}")
    end

    assert {:ok, _sale} = SalesCase.sell(fixture)
  end
end
