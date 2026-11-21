defmodule FootballMarket.Catalog.SchemaHelpers do
  @moduledoc false
  import Ecto.Changeset

  def trim(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      case get_change(cs, field) do
        value when is_binary(value) -> put_change(cs, field, String.trim(value))
        _ -> cs
      end
    end)
  end
end

defmodule FootballMarket.Catalog.League do
  use Ecto.Schema
  import Ecto.Changeset
  alias FootballMarket.Catalog.SchemaHelpers

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "leagues" do
    field :code, :string
    field :name, :string
    has_many :seasons, FootballMarket.Catalog.Season
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(league, attrs) do
    league
    |> cast(attrs, [:code, :name])
    |> SchemaHelpers.trim([:code, :name])
    |> validate_required([:code, :name])
    |> validate_supported_pair()
    |> check_constraint(:code, name: :leagues_supported_code)
    |> unique_constraint(:code, name: :leagues_normalized_code_index)
    |> unique_constraint(:name, name: :leagues_normalized_name_index)
  end

  def delete_changeset(league), do: league |> change() |> no_assoc_constraint(:seasons)

  defp validate_supported_pair(changeset) do
    pair = {get_field(changeset, :code), get_field(changeset, :name)}

    if pair in FootballMarket.Catalog.supported_leagues(),
      do: changeset,
      else: add_error(changeset, :code, "is not a supported league pair")
  end
end

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

  def delete_changeset(season) do
    season
    |> change()
    |> no_assoc_constraint(:teams)
    |> foreign_key_constraint(:import_scopes,
      name: :catalog_ingestion_scopes_season_id_league_id_fkey,
      message: "still has retained import references"
    )
    |> foreign_key_constraint(:source_bindings,
      name: :catalog_source_bindings_season_id_fkey,
      message: "still has retained import references"
    )
    |> foreign_key_constraint(:statistics_import_scopes,
      name: :statistics_import_scopes_season_id_fkey,
      message: "still has retained import references"
    )
    |> foreign_key_constraint(:matches,
      name: :matches_season_witness_fkey,
      message: "still has historical matches"
    )
  end

  defp validate_year_span(changeset) do
    start_year = get_field(changeset, :start_year)
    end_year = get_field(changeset, :end_year)

    if is_integer(start_year) and is_integer(end_year) and
         end_year not in [start_year, start_year + 1],
       do: add_error(changeset, :end_year, "must equal start year or the following year"),
       else: changeset
  end
end

defmodule FootballMarket.Catalog.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias FootballMarket.Catalog.SchemaHelpers

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
    |> SchemaHelpers.trim([:code, :name])
    |> validate_required([:season_id, :code, :name])
    |> foreign_key_constraint(:season_id)
    |> unique_constraint(:code, name: :teams_season_normalized_code_index)
    |> unique_constraint(:name, name: :teams_season_normalized_name_index)
  end

  def delete_changeset(team) do
    team
    |> change()
    |> foreign_key_constraint(:source_bindings,
      name: :catalog_source_bindings_team_id_season_scope_id_fkey,
      message: "still has retained import references"
    )
    |> foreign_key_constraint(:matches,
      name: :matches_home_team_id_season_fkey,
      message: "still has historical matches"
    )
    |> foreign_key_constraint(:matches,
      name: :matches_away_team_id_season_fkey,
      message: "still has historical matches"
    )
    |> foreign_key_constraint(:performances,
      name: :performances_team_id_season_fkey,
      message: "still has historical performances"
    )
    |> foreign_key_constraint(:players,
      name: :players_team_season_fkey,
      message: "still has associated players"
    )
  end
end

defmodule FootballMarket.Catalog.Position do
  use Ecto.Schema
  import Ecto.Changeset
  alias FootballMarket.Catalog.SchemaHelpers

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "positions" do
    field :code, :string
    field :name, :string
    has_many :players, FootballMarket.Catalog.Player
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, [:code, :name])
    |> SchemaHelpers.trim([:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code, name: :positions_normalized_code_index)
    |> unique_constraint(:name, name: :positions_normalized_name_index)
  end

  def delete_changeset(position) do
    position
    |> change()
    |> no_assoc_constraint(:players)
    |> foreign_key_constraint(:performances,
      name: :player_match_performances_position_id_fkey,
      message: "still has historical performances"
    )
  end
end

defmodule FootballMarket.Catalog.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias FootballMarket.Catalog.SchemaHelpers

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
    |> SchemaHelpers.trim([:catalog_identity, :display_name])
    |> validate_required([:team_id, :season_id, :position_id, :catalog_identity, :display_name])
    |> add_constraints()
  end

  def update_changeset(player, attrs, season_id) do
    player
    |> cast(attrs, [:team_id, :position_id, :display_name])
    |> put_change(:season_id, season_id)
    |> SchemaHelpers.trim([:display_name])
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
end

defmodule FootballMarket.Catalog.ScoutRun do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_scout_runs" do
    field :normalized_name, :string
    field :display_name, :string
    field :state, :string
    field :config_digest, :string
    field :admitted_at, :utc_datetime_usec
    field :finished_at, :utc_datetime_usec
    field :next_attempt_at, :utc_datetime_usec
    field :scope_inputs, :map, default: %{}
    field :synchronization_run_ids, {:array, :binary_id}, default: []
    field :configured_scope_count, :integer
    field :request_count, :integer, default: 0
    field :error_category, :string
    field :job_id, :integer

    timestamps(type: :utc_datetime_usec)
  end
end
