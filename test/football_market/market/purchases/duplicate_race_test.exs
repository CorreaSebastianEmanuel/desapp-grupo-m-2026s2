defmodule FootballMarket.Market.Purchases.DuplicateRaceTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{PurchasesCase, Repo}
  alias FootballMarket.Purchases.RuntimeProbe

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "100")
    f
  end

  test "concurrent identical deliveries return one immutable operation", f do
    assert [{:ok, a}, {:ok, b}] =
             RuntimeProbe.queued(f, [
               fn -> PurchasesCase.purchase(f) end,
               fn -> PurchasesCase.purchase(f) end
             ])

    assert a == b
    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[2]]
  end

  test "concurrent conflicting deliveries create one success and one conflict", f do
    results =
      RuntimeProbe.queued(f, [
        fn -> PurchasesCase.purchase(f) end,
        fn -> PurchasesCase.purchase(f, "purchase-key", 4) end
      ])

    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &match?({:error, %{kind: :key_conflict}}, &1)) == 1
  end

  test "same key scoped independently to two buyers", f do
    {:ok, other} =
      FootballMarket.Accounts.register_user(%{
        email: "other-#{Ecto.UUID.generate()}@example.test",
        password: "purchase-password"
      })

    PurchasesCase.fund(other, "100")
    second = %{f | buyer: other}

    assert [{:ok, a}, {:ok, b}] =
             RuntimeProbe.queued(f, [
               fn -> PurchasesCase.purchase(f) end,
               fn -> PurchasesCase.purchase(second) end
             ])

    refute a.id == b.id
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]
  end
end
