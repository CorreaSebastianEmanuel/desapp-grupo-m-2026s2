defmodule FootballMarket.Catalog.Ingestion.Observation do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_ingestion_observations" do
    field :scope_id, :binary_id
    field :revision, :integer
    field :operation, :string
    field :provider, :string
    field :retrieved_at, :utc_datetime_usec
    field :accepted_at, :utc_datetime_usec
    field :fixture_id, :string
    field :canonical_version, :integer
    field :delivery_digest, :binary
    field :canonical_delivery, :map
    field :counts, :map
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [
      :scope_id,
      :revision,
      :operation,
      :provider,
      :retrieved_at,
      :accepted_at,
      :fixture_id,
      :canonical_version,
      :delivery_digest,
      :canonical_delivery,
      :counts
    ])
    |> validate_required([
      :scope_id,
      :revision,
      :operation,
      :provider,
      :retrieved_at,
      :accepted_at,
      :canonical_version,
      :delivery_digest,
      :canonical_delivery,
      :counts
    ])
    |> validate_number(:revision, greater_than: 0)
    |> validate_inclusion(:operation, ["catalog"])
    |> validate_inclusion(:canonical_version, [1])
    |> validate_change(:delivery_digest, fn :delivery_digest, value ->
      if byte_size(value) == 32, do: [], else: [delivery_digest: "must be SHA-256"]
    end)
    |> validate_change(:canonical_delivery, fn :canonical_delivery, value ->
      if match?(%{"v1" => [_ | _]}, value) and map_size(value) == 1 and length(value["v1"]) == 11,
        do: [],
        else: [canonical_delivery: "must be versioned resolved facts"]
    end)
    |> validate_change(:counts, fn :counts, value ->
      valid =
        Enum.sort(Map.keys(value)) == ~w(league player season team) and
          Enum.all?(value, fn {_, counts} ->
            is_map(counts) and Enum.sort(Map.keys(counts)) == ~w(created unchanged updated) and
              Enum.all?(Map.values(counts), &(is_integer(&1) and &1 >= 0))
          end)

      if valid, do: [], else: [counts: "must have nonnegative per-kind counts"]
    end)
    |> immutable(row)
  end

  defp immutable(cs, %{__meta__: %{state: :built}}), do: cs
  defp immutable(cs, _), do: add_error(cs, :id, "accepted observations are immutable")
end
