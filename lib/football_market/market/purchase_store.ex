defmodule FootballMarket.Market.PurchaseStore do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Market.{Error, Purchase, PurchaseTransaction}

  def execute(input) do
    if Repo.in_transaction?() do
      Error.new(:invalid_request, :transaction_in_progress)
    else
      safely(fn -> transaction(input) end)
    end
  end

  defp transaction(input), do: Repo.transaction(fn -> transact(input) end)

  def get_for_buyer(buyer, id) do
    safely(fn -> lookup(buyer, id) end)
  end

  defp lookup(buyer, id) do
    case Repo.one(from p in Purchase, where: p.id == ^id and p.buyer_id == ^buyer) do
      nil -> {:error, :not_found}
      purchase -> {:ok, PurchaseTransaction.evidence(purchase)}
    end
  end

  defp transact(i) do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: Repo.rollback(%Error{kind: :invalid_request, reason: :invalid_request})

    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      i.buyer_id <> ":" <> i.request_key
    ])

    previous =
      Repo.one(
        from p in Purchase,
          where:
            p.buyer_id == ^i.buyer_id and p.request_key == ^i.request_key and
              is_nil(p.conditional_order_id)
      )

    cond do
      previous == nil ->
        i |> PurchaseTransaction.complete() |> PurchaseTransaction.evidence()

      previous.player_id == i.player_id and previous.quantity == i.quantity ->
        PurchaseTransaction.evidence(previous)

      true ->
        Repo.rollback(%Error{kind: :key_conflict, reason: :key_conflict})
    end
  end

  defp safely(fun) do
    fun.()
  rescue
    _ in [
      Postgrex.Error,
      DBConnection.ConnectionError,
      Ecto.ConstraintError,
      Ecto.InvalidChangesetError
    ] ->
      Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
