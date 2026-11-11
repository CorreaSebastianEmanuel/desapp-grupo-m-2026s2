defmodule FootballMarket.Statistics.Enrichment do
  @moduledoc "Append-only cumulative metric evidence; original performances remain authoritative."
  use Ecto.Schema
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics.Input}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "performance_enrichments" do
    field :performance_id, :binary_id
    field :check_id, :binary_id
    field :values, :map
    field :revision, :integer
  end

  def fields, do: [:minutes_played | Input.metrics()]
  def values(row), do: Map.take(row, fields())

  def versions(id) do
    Repo.all(from e in __MODULE__, where: e.performance_id == ^id, order_by: e.revision)
    |> Enum.map(&decode(&1.values))
  end

  def overlay(rows) do
    ids = Enum.map(rows, & &1.id)

    latest =
      Repo.all(from e in __MODULE__, where: e.performance_id in ^ids, order_by: e.revision)
      |> Map.new(&{&1.performance_id, decode(&1.values)})

    Enum.map(rows, fn row -> struct!(row, Map.get(latest, row.id, %{})) end)
  end

  def additions!(existing, incoming) do
    [current] = overlay([existing])
    prior = values(current)

    merged =
      Map.new(prior, fn {key, known} ->
        supplied = Map.get(incoming, key)

        if not is_nil(known) and not is_nil(supplied) and known != supplied,
          do: Repo.rollback(:immutable_conflict)

        {key, if(is_nil(known), do: supplied, else: known)}
      end)

    if merged == prior, do: :existing, else: {:enriched, merged}
  end

  def append!(id, {:enriched, values}, check) do
    revision = Repo.aggregate(from(e in __MODULE__, where: e.performance_id == ^id), :count) + 1

    Repo.insert!(%__MODULE__{
      performance_id: id,
      check_id: check.id,
      revision: revision,
      values: Map.new(values, fn {k, v} -> {Atom.to_string(k), v} end)
    })
  end

  def append!(_id, _state, _check), do: :ok

  defp decode(values), do: Map.new(fields(), &{&1, values[Atom.to_string(&1)]})
end
