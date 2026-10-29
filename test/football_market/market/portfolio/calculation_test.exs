defmodule FootballMarket.Market.PortfolioCalculationTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  alias FootballMarket.Market.Portfolio

  test "weighted average basis tracks multiple purchase prices and partial sale profit" do
    player_id = Ecto.UUID.generate()

    result =
      Portfolio.calculate([
        transaction("purchase", player_id, 2, "2", ~U[2026-10-01 00:00:00Z], "a"),
        transaction("purchase", player_id, 2, "6", ~U[2026-10-02 00:00:00Z], "b"),
        transaction("sale", player_id, 1, "4", ~U[2026-10-03 00:00:00Z], "c")
      ])

    assert [position] = result
    assert position.quantity == 3
    assert Decimal.equal?(position.average_unit_cost, "2")
    assert Decimal.equal?(position.realized_profit_loss, "2")
  end

  test "weighted cost remains after a partial sale and is recalculated by later purchases" do
    player_id = Ecto.UUID.generate()

    result =
      Portfolio.calculate([
        transaction("purchase", player_id, 2, "2", ~U[2026-10-01 00:00:00Z], "a"),
        transaction("purchase", player_id, 2, "6", ~U[2026-10-02 00:00:00Z], "b"),
        transaction("sale", player_id, 1, "4", ~U[2026-10-03 00:00:00Z], "c"),
        transaction("purchase", player_id, 1, "5", ~U[2026-10-04 00:00:00Z], "d"),
        transaction("sale", player_id, 4, "4", ~U[2026-10-05 00:00:00Z], "e")
      ])

    assert result == []
  end

  test "the reduced basis stays exact for a supported large cent-exact amount and ignores a hostile caller context" do
    player_id = Ecto.UUID.generate()

    Decimal.Context.with(%Decimal.Context{precision: 4, rounding: :half_even}, fn ->
      result =
        Portfolio.calculate([
          transaction(
            "purchase",
            player_id,
            3,
            "277037036703703703670370370367038.73",
            ~U[2026-10-01 00:00:00Z],
            "a"
          )
        ])

      assert [position] = result
      assert position.quantity == 3
      assert Decimal.equal?(position.average_unit_cost, "92345678901234567890123456789012.91")
      assert Decimal.equal?(position.realized_profit_loss, "0")
    end)
  end

  test "ordinary fractional averages are exact and nonterminating sales round half-up at eighteen places" do
    player_id = Ecto.UUID.generate()

    result =
      Portfolio.calculate([
        transaction("purchase", player_id, 1, "0.01", ~U[2026-10-01 00:00:00Z], "a"),
        transaction("purchase", player_id, 1, "0.06", ~U[2026-10-02 00:00:00Z], "b")
      ])

    assert [position] = result
    assert Decimal.equal?(position.average_unit_cost, "0.035")

    sold =
      Portfolio.calculate([
        transaction("purchase", player_id, 1, "0.01", ~U[2026-10-01 00:00:00Z], "a"),
        transaction("purchase", player_id, 1, "0.06", ~U[2026-10-02 00:00:00Z], "b"),
        transaction("sale", player_id, 1, "0.03", ~U[2026-10-03 00:00:00Z], "c")
      ])

    assert [position] = sold
    assert Decimal.equal?(position.realized_profit_loss, "-0.005")

    indivisible =
      Portfolio.calculate([
        transaction("purchase", player_id, 3, "0.07", ~U[2026-10-01 00:00:00Z], "a")
      ])

    assert [position] = indivisible
    assert Decimal.equal?(position.average_unit_cost, "0.023333333333333333")

    sale_basis =
      Portfolio.calculate([
        transaction("purchase", player_id, 3, "0.07", ~U[2026-10-01 00:00:00Z], "a"),
        transaction("sale", player_id, 1, "0.03", ~U[2026-10-02 00:00:00Z], "b")
      ])

    assert [position] = sale_basis
    assert Decimal.equal?(position.realized_profit_loss, "0.006666666666666667")
    assert Decimal.equal?(position.average_unit_cost, "0.023333333333333333")
  end

  defp transaction(type, player_id, quantity, total, completed_at, id_suffix) do
    {money, ""} = Decimal.parse(total, max_digits: :infinity)

    %{
      id: id_suffix,
      type: type,
      player_id: player_id,
      quantity: quantity,
      total: money,
      completed_at: completed_at
    }
  end
end
