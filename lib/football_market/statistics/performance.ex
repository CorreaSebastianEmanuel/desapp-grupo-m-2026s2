defmodule FootballMarket.Statistics.Performance do
  use Ecto.Schema
  import Ecto.Changeset
  alias FootballMarket.Statistics.{Count, Input}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "player_match_performances" do
    belongs_to :match, FootballMarket.Statistics.Match
    field :player_id, :binary_id
    field :team_id, :binary_id
    field :position_id, :binary_id
    field :season_id, :binary_id
    field :minutes_played, Count
    for field <- Input.metrics(), do: field(field, Count)
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(attrs, match) do
    cs =
      %__MODULE__{}
      |> cast(
        attrs,
        [:match_id, :player_id, :team_id, :position_id, :minutes_played] ++ Input.metrics()
      )
      |> put_change(:season_id, match.season_id)
      |> unique_constraint(:player_id, name: :performances_player_match_index)
      |> foreign_key_constraint(:match_id, name: :performances_match_id_season_fkey)
      |> foreign_key_constraint(:player_id, name: :performances_player_id_season_fkey)
      |> foreign_key_constraint(:team_id, name: :performances_team_id_season_fkey)
      |> foreign_key_constraint(:position_id, name: :player_match_performances_position_id_fkey)
      |> check_constraint(:team_id, name: :performances_participation)

    Enum.reduce([:minutes_played | Input.metrics()], cs, fn f, cs ->
      check_constraint(cs, f, name: "performances_#{f}_count")
    end)
  end
end
