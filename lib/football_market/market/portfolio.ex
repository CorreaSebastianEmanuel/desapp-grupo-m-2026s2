defmodule FootballMarket.Market.Portfolio do
  @moduledoc "Authenticated read model for current player-token positions."

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{Error, PortfolioStore}

  # Money arithmetic must not inherit a caller's Decimal context: with the
  # default 34-digit context, a supported large cent-exact total rounded and
  # produced fictitious profit. Portfolio calculations run in a local context
  # wide enough to keep supported trading amounts exact.
  @exact_precision 200

  # Human product decision (2026-10-28, recorded in the compact spec): the
  # weighted-average unit cost is rounded half-up to 18 decimal places only
  # when the exact quotient does not terminate. Ordinary cent-exact totals
  # divided by integer quantities terminate at 18 decimal places or fewer, and
  # the rounding error stays far below reportable cent amounts.
  @average_decimals 18

  def list(%AuthenticatedActor{account_id: owner}) when is_binary(owner) do
    with {:ok, transactions} <- PortfolioStore.transactions(owner) do
      read(transactions)
    end
  rescue
    _ -> Error.new(:temporarily_unavailable, :storage_rejected)
  end

  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  @doc false
  def calculate(transactions) do
    exact(fn ->
      transactions
      |> Enum.sort_by(&{DateTime.to_unix(&1.completed_at, :microsecond), &1.type, &1.id})
      |> Enum.reduce(%{}, &apply_transaction/2)
      |> Enum.filter(fn {_player_id, position} -> position.quantity > 0 end)
      |> Enum.map(fn {player_id, position} -> Map.put(position, :player_id, player_id) end)
      |> Enum.sort_by(& &1.player_id)
    end)
  end

  defp read(transactions) do
    positions = exact(fn -> calculate(transactions) end)

    if positions == [] do
      {:ok, []}
    else
      with {:ok, details} <- PortfolioStore.details(Enum.map(positions, & &1.player_id)) do
        {:ok, exact(fn -> present(positions, details) end)}
      end
    end
  end

  defp exact(fun), do: Decimal.Context.with(%Decimal.Context{precision: @exact_precision}, fun)

  defp present(positions, details) do
    Enum.map(positions, fn position ->
      detail = Map.fetch!(details, position.player_id)
      current_value = Decimal.mult(detail.current_quote, position.quantity)

      Map.merge(position, %{
        player_name: detail.player_name,
        current_quote: detail.current_quote,
        current_value: current_value,
        unrealized_profit_loss:
          Decimal.mult(
            Decimal.sub(detail.current_quote, position.average_unit_cost),
            position.quantity
          )
      })
    end)
  end

  defp apply_transaction(%{type: "purchase"} = transaction, positions) do
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

  defp apply_transaction(%{type: "sale"} = transaction, positions) do
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
