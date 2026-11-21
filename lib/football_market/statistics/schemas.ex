defmodule FootballMarket.Statistics.Error do
  @moduledoc "Structured validation and conflict error helpers for the Statistics domain."

  def validation(field, reason),
    do: {:error, %{kind: :validation, field: field, reason: reason, record: nil}}

  def conflict(field),
    do: {:error, %{kind: :conflict, field: field, reason: :duplicate, record: nil}}

  def at({:error, error}, match_index, performance_index) when is_map(error),
    do:
      {:error,
       %{error | record: %{match_index: match_index, performance_index: performance_index}}}

  def changeset(changeset) do
    {field, {_message, opts}} = hd(changeset.errors)

    case opts[:constraint] do
      :unique -> conflict(field)
      :foreign -> validation(field, :missing_reference)
      _ -> validation(field, :invalid_count)
    end
  end
end

defmodule FootballMarket.Statistics.Count do
  @moduledoc false
  use Ecto.Type
  def type, do: :decimal
  def cast(nil), do: {:ok, nil}
  def cast(n) when is_integer(n) and n >= 0, do: {:ok, n}
  def cast(_), do: :error
  def dump(nil), do: {:ok, nil}
  def dump(n) when is_integer(n) and n >= 0, do: {:ok, Decimal.new(n)}
  def dump(_), do: :error
  def load(nil), do: {:ok, nil}

  def load(%Decimal{coef: coef} = value) when is_integer(coef) do
    if Decimal.compare(value, 0) != :lt and Decimal.equal?(value, Decimal.round(value, 0)),
      do: {:ok, Decimal.to_integer(value)},
      else: :error
  end

  def load(_), do: :error
end

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
    field :position_basis, :string, default: "legacy_direct"
    field :participation, :string
    field :position_reason, :string
    field :position_evidence, :map
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
      |> check_constraint(:position_id, name: :performances_position_evidence_state)

    Enum.reduce([:minutes_played | Input.metrics()], cs, fn f, cs ->
      check_constraint(cs, f, name: "performances_#{f}_count")
    end)
  end
end

defmodule FootballMarket.Statistics.Enrichment do
  @moduledoc "Append-only cumulative metric evidence; original performances remain authoritative."
  use Ecto.Schema
  import Ecto.Query
  alias FootballMarket.{Repo, Statistics.Input}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "performance_enrichments" do
    field :performance_id, :binary_id
    field :check_id, :binary_id
    field :values, :map
    field :revision, :integer
  end

  def fields, do: [:minutes_played | Input.metrics()]
  def values(row), do: Map.take(row, fields())

  def versions(id) do
    Repo.all(from e in __MODULE__, where: e.performance_id == ^id, order_by: e.revision)
    |> Enum.map(&decode(&1.values))
  end

  def overlay(rows) do
    ids = Enum.map(rows, & &1.id)

    latest =
      Repo.all(from e in __MODULE__, where: e.performance_id in ^ids, order_by: e.revision)
      |> Map.new(&{&1.performance_id, decode(&1.values)})

    Enum.map(rows, fn row -> struct!(row, Map.get(latest, row.id, %{})) end)
  end

  def additions!(existing, incoming) do
    [current] = overlay([existing])
    prior = values(current)

    merged =
      Map.new(prior, fn {key, known} ->
        supplied = Map.get(incoming, key)

        if not is_nil(known) and not is_nil(supplied) and known != supplied,
          do: Repo.rollback(:immutable_conflict)

        {key, if(is_nil(known), do: supplied, else: known)}
      end)

    if merged == prior, do: :existing, else: {:enriched, merged}
  end

  def append!(id, {:enriched, values}, check) do
    revision = Repo.aggregate(from(e in __MODULE__, where: e.performance_id == ^id), :count) + 1

    Repo.insert!(%__MODULE__{
      performance_id: id,
      check_id: check.id,
      revision: revision,
      values: Map.new(values, fn {k, v} -> {Atom.to_string(k), v} end)
    })
  end

  def append!(_id, _state, _check), do: :ok

  defp decode(values), do: Map.new(fields(), &{&1, values[Atom.to_string(&1)]})
end
