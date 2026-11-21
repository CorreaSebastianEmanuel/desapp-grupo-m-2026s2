defmodule FootballMarket.Statistics.Ingestion.Outcome do
  @moduledoc false
  defstruct [
    :status,
    :scope,
    :run_id,
    :check_id,
    :calculation_intent_id,
    :reason,
    :recovery,
    :provider_category,
    :retryable,
    :retry_after_ms
  ]

  @statuses [:accepted_changes, :accepted_unchanged, :replay, :accepted_empty]

  def accepted(status, scope, attrs \\ []) when status in @statuses do
    {:ok, struct!(__MODULE__, Keyword.merge([status: status, scope: scope], attrs))}
  end

  def failure(status, scope, reason, options \\ []) do
    {:error,
     struct!(
       __MODULE__,
       Keyword.merge(
         [status: status, scope: scope, reason: reason, recovery: :inspect_run],
         options
       )
     )}
  end
end

defmodule FootballMarket.Statistics.Ingestion.CalculationIntent do
  @moduledoc "Durable post-commit request to calculate accepted performance changes."
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_calculation_intents" do
    field :accepted_check_id, :binary_id
    field :changed_performance_ids, {:array, :binary_id}
    field :requested_at, :utc_datetime_usec
    field :state, :string, default: "pending"
    field :attempts, :integer, default: 0
    field :next_attempt_at, :utc_datetime_usec
    field :delivered_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Statistics.Ingestion.Check do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_import_checks" do
    field :scope_id, :binary_id
    field :run_id, :binary_id
    field :attempt_id, :binary_id
    field :accepted_at, :utc_datetime_usec
    field :retrieved_at, :utc_datetime_usec
    field :evidence_version, :integer
    field :evidence, :map
    field :outcome, :string
    field :canonical_digest, :string
    field :canonical_material, :map
    field :changed_matches, :integer, default: 0
    field :changed_performances, :integer, default: 0
    field :replay_of_id, :binary_id
  end
end

defmodule FootballMarket.Statistics.Ingestion.FactObservation do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fact_observations" do
    field :provenance_id, :binary_id
    field :check_id, :binary_id
  end
end

defmodule FootballMarket.Statistics.Ingestion.FactProvenance do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fact_provenance" do
    field :match_id, :binary_id
    field :performance_id, :binary_id
    field :accepted_check_id, :binary_id
    field :run_id, :binary_id
    field :provider, :string
    field :retrieved_at, :utc_datetime_usec
    field :source_identity, :map
    field :source_material, :map
    field :fixture_artifact_id, :binary_id
  end
end

defmodule FootballMarket.Statistics.Ingestion.FixtureArtifact do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_fixture_artifacts" do
    field :fixture_id, :string
    field :artifact_path, :string
    field :sha256, :string
    field :origin, :string
    field :captured_at, :utc_datetime_usec
    field :synthetic_created_at, :utc_datetime_usec
    field :expected_case, :string
    field :rule_ids, {:array, :string}
    field :non_live, :boolean, default: true
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end
end

defmodule FootballMarket.Statistics.Ingestion.MatchBinding do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "statistics_match_bindings" do
    field :provider, :string
    field :kind, :string, default: "match"
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :source_id, :string
    field :match_id, :binary_id
  end
end

defmodule FootballMarket.Statistics.Ingestion.PositionBasis do
  use Ecto.Schema
  @primary_key false
  schema "statistics_position_basis" do
    field :performance_id, :binary_id, primary_key: true
    field :prior_performance_id, :binary_id, primary_key: true
    field :position_id, :binary_id
    field :frequency, :integer
  end
end

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

  def find(provider, season_id, player_id) do
    FootballMarket.Repo.get_by(__MODULE__,
      identity_namespace: provider,
      season_id: season_id,
      player_id: player_id
    )
  end

  def find(provider, season_id), do: find(provider, season_id, nil)
end
