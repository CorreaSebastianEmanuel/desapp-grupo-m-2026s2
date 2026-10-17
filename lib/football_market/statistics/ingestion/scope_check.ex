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
    field :last_checked_at, :utc_datetime_usec
    field :last_accepted_check_id, :binary_id
  end

  def find(provider, season_id),
    do: FootballMarket.Repo.get_by(__MODULE__, identity_namespace: provider, season_id: season_id)
end
