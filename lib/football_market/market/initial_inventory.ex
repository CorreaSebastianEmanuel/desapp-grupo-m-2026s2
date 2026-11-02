defmodule FootballMarket.Market.InitialInventory do
  @moduledoc "Authenticated read model for tokens still held by their initial recipient."

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{Error, InitialInventoryStore}

  def list(%AuthenticatedActor{account_id: owner}) when is_binary(owner),
    do: InitialInventoryStore.list(owner)

  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  def initial_recipient?(%AuthenticatedActor{account_id: owner}) when is_binary(owner) do
    case Ecto.UUID.cast(owner) do
      {:ok, id} -> InitialInventoryStore.initial_recipient?(id)
      :error -> Error.new(:unauthenticated, :unauthenticated)
    end
  end

  def initial_recipient?(_), do: Error.new(:unauthenticated, :unauthenticated)
end
