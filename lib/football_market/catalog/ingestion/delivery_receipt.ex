defmodule FootballMarket.Catalog.Ingestion.DeliveryReceipt do
  @moduledoc "Neutral fenced publication receipt, confirmed inside the domain transaction."
  use Ecto.Schema
  import Ecto.Query
  alias FootballMarket.Repo
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_delivery_receipts" do
    field :fence, :binary_id
    field :run_id, :binary_id
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :state, :string
    field :outcome, :map
    field :confirmed_at, :utc_datetime_usec
  end

  def lock!(nil, _scope), do: nil

  def lock!(%{receipt_id: id, fence: fence} = context, scope) when map_size(context) == 2 do
    unless match?({:ok, _}, Ecto.UUID.cast(id)) and match?({:ok, _}, Ecto.UUID.cast(fence)),
      do: invalid!()

    receipt = Repo.one(from r in __MODULE__, where: r.id == ^id, lock: "FOR UPDATE")

    if receipt && receipt.state == "prepared" && receipt.fence == fence &&
         Map.take(receipt, [:league_code, :start_year, :end_year]) == scope,
       do: receipt,
       else: invalid!()
  end

  def lock!(_, _), do: invalid!()

  def confirm!(nil, outcome), do: outcome

  def confirm!(receipt, outcome) do
    safe = outcome |> Map.from_struct() |> Jason.encode!() |> Jason.decode!()

    receipt
    |> Ecto.Changeset.change(state: "confirmed", outcome: safe, confirmed_at: DateTime.utc_now())
    |> Repo.update!()

    outcome
  end

  defp invalid!, do: Repo.rollback({:reconciliation_conflict, :invalid_delivery_context})
end
