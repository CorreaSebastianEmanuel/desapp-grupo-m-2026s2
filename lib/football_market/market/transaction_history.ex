defmodule FootballMarket.Market.TransactionHistory do
  @moduledoc "Read-only, authenticated user's immutable purchase and sale history."
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{Error, TransactionHistoryStore}

  def list(%AuthenticatedActor{account_id: owner}, options) when is_binary(owner),
    do: TransactionHistoryStore.list(owner, options)

  def list(_, _), do: Error.new(:unauthenticated, :unauthenticated)
end
