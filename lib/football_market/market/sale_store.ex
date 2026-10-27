defmodule FootballMarket.Market.SaleStore do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Market.{Error, Sale, SaleTransaction}

  def execute(input) do
    if Repo.in_transaction?() do
      Error.new(:invalid_request, :transaction_in_progress)
    else
      safely(fn -> transaction(input) end)
    end
  end

  defp transaction(input), do: Repo.transaction(fn -> transact(input) end)

  def get_for_seller(seller, id) do
    safely(fn -> lookup(seller, id) end)
  end

  defp lookup(seller, id) do
    case Repo.one(from s in Sale, where: s.id == ^id and s.seller_id == ^seller) do
      nil -> {:error, :not_found}
      sale -> {:ok, SaleTransaction.evidence(sale)}
    end
  end

  defp transact(i) do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: Repo.rollback(%Error{kind: :invalid_request, reason: :invalid_request})

    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      i.seller_id <> ":" <> i.request_key
    ])

    previous =
      Repo.one(
        from s in Sale, where: s.seller_id == ^i.seller_id and s.request_key == ^i.request_key
      )

    cond do
      previous == nil ->
        i |> SaleTransaction.complete() |> SaleTransaction.evidence()

      previous.player_id == i.player_id and previous.quantity == i.quantity ->
        SaleTransaction.evidence(previous)

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
