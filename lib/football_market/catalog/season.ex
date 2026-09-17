defmodule FootballMarket.Catalog.Season do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "seasons" do
    field :start_year, :integer
    field :end_year, :integer
    belongs_to :league, FootballMarket.Catalog.League
    has_many :teams, FootballMarket.Catalog.Team
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(season, attrs) do
    season
    |> cast(attrs, [:league_id, :start_year, :end_year])
    |> validate_required([:league_id, :start_year, :end_year])
    |> validate_year_span()
    |> foreign_key_constraint(:league_id)
    |> unique_constraint([:league_id, :start_year, :end_year], name: :seasons_league_years_index)
    |> check_constraint(:end_year, name: :seasons_valid_year_span)
  end

  def delete_changeset(season), do: season |> change() |> no_assoc_constraint(:teams)

  defp validate_year_span(changeset) do
    start_year = get_field(changeset, :start_year)
    end_year = get_field(changeset, :end_year)

    if is_integer(start_year) and is_integer(end_year) and
         end_year not in [start_year, start_year + 1],
       do: add_error(changeset, :end_year, "must equal start year or the following year"),
       else: changeset
  end
end
