defmodule FootballMarket.Market.Analytics do
  @moduledoc "Owner-scoped investor allocation and daily historical analytics."
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{Error, PortfolioLedger}
  alias FootballMarket.Market.Analytics.{Projection, Store}

  def allocation(actor), do: read(actor, :allocation, %{})
  def history(actor, options), do: read(actor, :history, options)

  defp read(%AuthenticatedActor{account_id: owner}, mode, options) when is_binary(owner) do
    with {:ok, _} <- Ecto.UUID.cast(owner),
         {:ok, snapshot} <- Store.read(owner, mode, options) do
      {:ok, PortfolioLedger.exact(fn -> Projection.build(snapshot, mode) end)}
    else
      :error -> Error.new(:unauthenticated, :unauthenticated)
      {:error, reason} -> Error.new(reason, reason)
    end
  end

  defp read(_, _, _), do: Error.new(:unauthenticated, :unauthenticated)
end
