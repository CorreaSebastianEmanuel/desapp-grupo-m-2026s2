defmodule FootballMarket.Market.Purchases.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{PurchasesCase, Market, Repo}
  alias FootballMarket.Purchases.RuntimeProbe

  setup do
    PurchasesCase.fixture()
  end

  test "different players cannot double spend one buyer balance", f do
    assert {:ok, _} = Market.initialize_player(f.other.id)
    PurchasesCase.fund(f.buyer, "3")
    other = %{f | player: f.other}

    results =
      RuntimeProbe.queued(
        f,
        [
          fn -> PurchasesCase.purchase(f, "one") end,
          fn -> PurchasesCase.purchase(other, "two") end
        ],
        "users"
      )

    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &match?({:error, %{kind: :insufficient_funds}}, &1)) == 1

    assert Repo.query!("SELECT min(amount) FROM market_credit_balances").rows == [
             [Decimal.new(0)]
           ]

    assert Repo.query!("SELECT sum(quantity) FROM market_holdings GROUP BY player_id").rows == [
             [100],
             [100]
           ]
  end

  test "competing buyers cannot oversell recipient inventory", f do
    {:ok, buyer2} =
      FootballMarket.Accounts.register_user(%{
        email: "race-#{Ecto.UUID.generate()}@example.test",
        password: "purchase-password"
      })

    for u <- [f.buyer, buyer2], do: PurchasesCase.fund(u, "1000")
    other = %{f | buyer: buyer2}

    results =
      RuntimeProbe.queued(f, [
        fn -> PurchasesCase.purchase(f, "a", 60) end,
        fn -> PurchasesCase.purchase(other, "b", 60) end
      ])

    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &match?({:error, %{kind: :insufficient_inventory}}, &1)) == 1

    assert Repo.query!("SELECT sum(quantity), min(quantity) FROM market_holdings").rows == [
             [100, 40]
           ]
  end
end
