defmodule FootballMarket.Catalog.Ingestion.Scope do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_ingestion_scopes" do
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :league_id, :binary_id
    field :season_id, :binary_id
    field :revision, :integer
    field :latest_observation_id, :binary_id
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [
      :league_code,
      :start_year,
      :end_year,
      :league_id,
      :season_id,
      :revision,
      :latest_observation_id
    ])
    |> validate_required([
      :league_code,
      :start_year,
      :end_year,
      :league_id,
      :season_id,
      :revision,
      :latest_observation_id
    ])
    |> validate_number(:revision, greater_than: 0)
    |> validate_inclusion(:league_code, Map.keys(FootballMarket.Providers.Request.leagues()))
  end
end
