defmodule FootballMarket.Market.CreditBalances do
  @moduledoc "Authenticated read model for spendable credit balances."

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{CreditBalanceStore, Error}

  def available(%AuthenticatedActor{account_id: owner}) when is_binary(owner) do
    case Ecto.UUID.cast(owner) do
      {:ok, id} -> CreditBalanceStore.available(id)
      :error -> Error.new(:unauthenticated, :unauthenticated)
    end
  end

  def available(_), do: Error.new(:unauthenticated, :unauthenticated)
end
