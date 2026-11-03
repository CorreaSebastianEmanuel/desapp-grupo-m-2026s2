defmodule FootballMarket.Statistics.Ingestion.ScopeCheck do
  @moduledoc "Mutable pointer to the last complete accepted source-season check."
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_import_scopes" do
    field :provider, :string
    field :identity_namespace, :string
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :season_id, :binary_id
    field :player_id, :binary_id
    field :last_checked_at, :utc_datetime_usec
    field :last_accepted_check_id, :binary_id
  end

  def find(provider, season_id, nil) do
    import Ecto.Query

    FootballMarket.Repo.one(
      from row in __MODULE__,
        where:
          row.identity_namespace == ^provider and row.season_id == ^season_id and
            is_nil(row.player_id)
    )
  end

  def find(provider, season_id, player_id),
    do:
      FootballMarket.Repo.get_by(__MODULE__,
        identity_namespace: provider,
        season_id: season_id,
        player_id: player_id
      )

  def find(provider, season_id), do: find(provider, season_id, nil)
end
