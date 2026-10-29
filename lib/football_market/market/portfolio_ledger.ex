defmodule FootballMarket.Market.PortfolioLedger do
  @moduledoc false

  # Preserve TASK-032 accounting, independent of caller precision. Keep closed
  # positions here so analytics retains their cumulative realized profit.
  @average_decimals 18

  def exact(fun), do: Decimal.Context.with(%Decimal.Context{precision: 200}, fun)

  def apply_transaction(%{type: "purchase"} = transaction, positions) do
    prior = Map.get(positions, transaction.player_id, empty_position())
    quantity = prior.quantity + transaction.quantity

    basis =
      Decimal.add(
        Decimal.mult(prior.average_unit_cost, prior.quantity),
        transaction.total
      )

    average =
      basis
      |> Decimal.div(quantity)
      |> Decimal.round(@average_decimals, :half_up)

    Map.put(positions, transaction.player_id, %{
      quantity: quantity,
      average_unit_cost: average,
      realized_profit_loss: prior.realized_profit_loss
    })
  end

  def apply_transaction(%{type: "sale"} = transaction, positions) do
    prior = Map.get(positions, transaction.player_id, empty_position())
    cost = Decimal.mult(prior.average_unit_cost, transaction.quantity)

    Map.put(positions, transaction.player_id, %{
      quantity: prior.quantity - transaction.quantity,
      average_unit_cost: prior.average_unit_cost,
      realized_profit_loss:
        Decimal.add(prior.realized_profit_loss, Decimal.sub(transaction.total, cost))
    })
  end

  defp empty_position do
    %{quantity: 0, average_unit_cost: Decimal.new(0), realized_profit_loss: Decimal.new(0)}
  end
end
