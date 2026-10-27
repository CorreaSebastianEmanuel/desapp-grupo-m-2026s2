defmodule FootballMarket.Market.ConditionalOrders do
  @moduledoc "Owned conditional buy instructions; durable delivery belongs to TASK-060."
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.{ConditionalOrderInput, ConditionalOrderStore, Error}

  def create(actor, terms) do
    with {:ok, canonical} <- ConditionalOrderInput.validate(actor, terms),
         do: ConditionalOrderStore.create(canonical)
  end

  def cancel(%AuthenticatedActor{account_id: owner}, id) do
    case ConditionalOrderInput.identifier(id) do
      {:ok, id} -> ConditionalOrderStore.cancel(owner, id)
      _ -> {:error, :not_found}
    end
  end

  def cancel(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  def evaluate(id) do
    case ConditionalOrderInput.identifier(id) do
      {:ok, id} -> ConditionalOrderStore.evaluate(id)
      _ -> {:error, :not_found}
    end
  end

  def list(%AuthenticatedActor{account_id: owner}), do: ConditionalOrderStore.list(owner)
  def list(_), do: Error.new(:unauthenticated, :unauthenticated)

  def get(%AuthenticatedActor{account_id: owner}, id) do
    case ConditionalOrderInput.identifier(id) do
      {:ok, id} -> ConditionalOrderStore.get(owner, id)
      _ -> {:error, :not_found}
    end
  end

  def get(_, _), do: Error.new(:unauthenticated, :unauthenticated)
end
