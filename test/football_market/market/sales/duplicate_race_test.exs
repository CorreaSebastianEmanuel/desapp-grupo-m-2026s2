defmodule FootballMarket.Market.Sales.DuplicateRaceTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{SalesCase, Repo}
  alias FootballMarket.Purchases.RuntimeProbe

  setup do
    f = SalesCase.fixture()
    f
  end

  test "concurrent identical deliveries return one immutable operation", f do
    assert [{:ok, a}, {:ok, b}] =
             RuntimeProbe.queued(f, [
               fn -> SalesCase.sale(f) end,
               fn -> SalesCase.sale(f) end
             ])

    assert a == b
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[2]]
  end

  test "concurrent conflicting deliveries create one success and one conflict", f do
    results =
      RuntimeProbe.queued(f, [
        fn -> SalesCase.sale(f) end,
        fn -> SalesCase.sale(f, "sale-key", 4) end
      ])

    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &match?({:error, %{kind: :key_conflict}}, &1)) == 1
  end

  test "same key scoped independently to two sellers", f do
    {:ok, other} =
      FootballMarket.Accounts.register_user(%{
        email: "other-seller-#{Ecto.UUID.generate()}@example.test",
        password: "sale-password"
      })

    # Give the second seller its own tokens from the market stand inventory.
    Repo.transaction(fn ->
      Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [
        Ecto.UUID.dump!(f.player.id)
      ])

      Repo.query!(
        "UPDATE market_holdings SET quantity=quantity-2 WHERE player_id=$1 AND user_id=$2",
        [Ecto.UUID.dump!(f.player.id), Ecto.UUID.dump!(f.owner.id)]
      )

      Repo.insert!(
        struct!(FootballMarket.Market.Holding, %{
          player_id: f.player.id,
          user_id: other.id,
          quantity: 2
        })
      )
    end)

    second = %{f | buyer: other}

    assert [{:ok, a}, {:ok, b}] =
             RuntimeProbe.queued(f, [
               fn -> SalesCase.sale(f) end,
               fn -> SalesCase.sale(second, "sale-key", 2) end
             ])

    refute a.id == b.id
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]
  end
end
