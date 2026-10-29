defmodule FootballMarket.Market.Portfolio do
  @moduledoc "Authenticated read model for current player-token positions."

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{Error, PortfolioLedger, PortfolioStore}

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
      |> Enum.reduce(%{}, &PortfolioLedger.apply_transaction/2)
      |> Enum.filter(fn {_player_id, position} -> position.quantity > 0 end)
      |> Enum.map(fn {player_id, position} -> Map.put(position, :player_id, player_id) end)
      |> Enum.sort_by(& &1.player_id)
    end)
  end

  defp read(transactions) do
    positions = calculate(transactions)

    if positions == [] do
      {:ok, []}
    else
      with {:ok, details} <- PortfolioStore.details(Enum.map(positions, & &1.player_id)) do
        {:ok, exact(fn -> present(positions, details) end)}
      end
    end
  end

  defp exact(fun), do: PortfolioLedger.exact(fun)

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
end
