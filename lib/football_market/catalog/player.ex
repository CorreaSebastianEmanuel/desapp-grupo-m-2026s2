defmodule FootballMarket.Catalog.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :catalog_identity, :string
    field :display_name, :string
    belongs_to :team, FootballMarket.Catalog.Team
    belongs_to :season, FootballMarket.Catalog.Season
    belongs_to :position, FootballMarket.Catalog.Position
    timestamps(type: :utc_datetime_usec)
  end

  def create_changeset(player, attrs, season_id) do
    player
    |> cast(attrs, [:team_id, :position_id, :catalog_identity, :display_name])
    |> put_change(:season_id, season_id)
    |> trim([:catalog_identity, :display_name])
    |> validate_required([:team_id, :season_id, :position_id, :catalog_identity, :display_name])
    |> add_constraints()
  end

  def update_changeset(player, attrs, season_id) do
    player
    |> cast(attrs, [:team_id, :position_id, :display_name])
    |> put_change(:season_id, season_id)
    |> trim([:display_name])
    |> validate_required([:team_id, :season_id, :position_id, :catalog_identity, :display_name])
    |> add_constraints()
  end

  defp add_constraints(changeset) do
    changeset
    |> foreign_key_constraint(:position_id)
    |> foreign_key_constraint(:season_id)
    |> foreign_key_constraint(:team_id,
      name: :players_team_season_fkey,
      message: "must belong to the player's season"
    )
    |> unique_constraint(:catalog_identity, name: :players_season_normalized_identity_index)
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
