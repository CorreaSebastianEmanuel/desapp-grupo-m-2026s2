defmodule FootballMarket.Catalog.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "teams" do
    field :code, :string
    field :name, :string
    belongs_to :season, FootballMarket.Catalog.Season
    has_many :players, FootballMarket.Catalog.Player
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(team, attrs) do
    team
    |> cast(attrs, [:season_id, :code, :name])
    |> trim([:code, :name])
    |> validate_required([:season_id, :code, :name])
    |> foreign_key_constraint(:season_id)
    |> unique_constraint(:code, name: :teams_season_normalized_code_index)
    |> unique_constraint(:name, name: :teams_season_normalized_name_index)
  end

  def delete_changeset(team) do
    team
    |> change()
    |> foreign_key_constraint(:players,
      name: :players_team_season_fkey,
      message: "still has associated players"
    )
  end

  defp trim(changeset, fields),
    do:
      Enum.reduce(fields, changeset, fn field, cs ->
        case get_change(cs, field) do
          value when is_binary(value) -> put_change(cs, field, String.trim(value))
          _ -> cs
        end
      end)
end
