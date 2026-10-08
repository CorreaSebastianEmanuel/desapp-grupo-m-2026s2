defmodule FootballMarket.Catalog.Ingestion.ObservationBinding do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "catalog_ingestion_observation_bindings" do
    field :observation_id, :binary_id, primary_key: true
    field :binding_id, :binary_id, primary_key: true
    field :scope_id, :binary_id
  end

  def changeset(row, attrs),
    do:
      row
      |> cast(attrs, [:observation_id, :binding_id, :scope_id])
      |> validate_required([:observation_id, :binding_id, :scope_id])
      |> immutable(row)

  defp immutable(cs, %{__meta__: %{state: :built}}), do: cs
  defp immutable(cs, _), do: add_error(cs, :observation_id, "observation membership is immutable")
end
