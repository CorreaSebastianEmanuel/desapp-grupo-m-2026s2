defmodule FootballMarket.Catalog.Ingestion.SourceBinding do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_source_bindings" do
    field :scope_id, :binary_id
    field :season_scope_id, :binary_id
    field :league_scope_id, :binary_id
    field :provider, :string
    field :kind, :string
    field :source_id, :string
    field :league_id, :binary_id
    field :season_id, :binary_id
    field :team_id, :binary_id
    field :player_id, :binary_id
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [
      :scope_id,
      :season_scope_id,
      :league_scope_id,
      :provider,
      :kind,
      :source_id,
      :league_id,
      :season_id,
      :team_id,
      :player_id
    ])
    |> validate_required([
      :scope_id,
      :season_scope_id,
      :league_scope_id,
      :provider,
      :kind,
      :source_id
    ])
    |> validate_inclusion(:kind, ~w(league season team player))
    |> validate_target()
    |> immutable(row)
  end

  defp validate_target(cs) do
    fields = [:league_id, :season_id, :team_id, :player_id]
    active = Enum.filter(fields, &(not is_nil(get_field(cs, &1))))
    kind = get_field(cs, :kind)

    if kind in ~w(league season team player) and
         active == [String.to_existing_atom(kind <> "_id")],
       do: cs,
       else: add_error(cs, :kind, "requires exactly its typed target")
  end

  defp immutable(cs, %{__meta__: %{state: :built}}), do: cs
  defp immutable(cs, _), do: add_error(cs, :id, "source correspondences are immutable")
end
