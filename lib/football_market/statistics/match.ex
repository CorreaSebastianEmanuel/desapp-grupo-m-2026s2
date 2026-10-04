defmodule FootballMarket.Statistics.Match do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    field :match_identity, :string
    field :normalized_identity, :string, read_after_writes: true
    field :kickoff_at, :utc_datetime_usec
    field :season_id, :binary_id
    field :home_team_id, :binary_id
    field :away_team_id, :binary_id
    field :season_league_id, :binary_id
    field :season_start_year, :integer
    field :season_end_year, :integer
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(attrs, season) do
    %__MODULE__{}
    |> cast(attrs, [:match_identity, :kickoff_at, :season_id, :home_team_id, :away_team_id])
    |> put_change(:season_league_id, season.league_id)
    |> put_change(:season_start_year, season.start_year)
    |> put_change(:season_end_year, season.end_year)
    |> unique_constraint(:match_identity, name: :matches_season_identity_index)
    |> check_constraint(:match_identity, name: :matches_identity_not_blank)
    |> check_constraint(:away_team_id, name: :matches_distinct_teams)
    |> foreign_key_constraint(:season_id, name: :matches_season_witness_fkey)
    |> foreign_key_constraint(:home_team_id, name: :matches_home_team_id_season_fkey)
    |> foreign_key_constraint(:away_team_id, name: :matches_away_team_id_season_fkey)
  end
end
